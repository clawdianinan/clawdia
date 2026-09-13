#!/usr/bin/env python3
"""LLM adapter for the IIH booking agent.

Design contract (from analysis/codex-llm-steps/LLM_STEPS.md):

    LLM proposal
      -> strict schema + source-span validation
      -> deterministic authoritative lookup/recalculation
      -> human approval where required
      -> updatedAt CAS + allowed transition
      -> idempotent transactional command + audit

This module implements ONLY the first two arrows. It never mutates booking
state, never computes money, and never sends anything. Callers receive a
*proposal* plus a validation verdict, and remain responsible for the
remaining arrows.

Key properties:
  - Availability is opt-in. If no provider/secret is configured, every call
    returns {"ok": False, "reason": "llm_unavailable"} and the deterministic
    path continues untouched.
  - All responses must be strict JSON validated against a caller-supplied
    schema (enum / type / required). Anything else is rejected, never coerced.
  - Shadow mode: callers can log a proposal without acting on it.
  - Every call is audited with latency, model, tokens and outcome.

Provider: DeepSeek (OpenAI-compatible chat completions). Secret resolution
reuses the booking keychain convention (iih-booking-<NAME>) then env.
"""

from __future__ import annotations

import json
import os
import subprocess
import time
import urllib.error
import urllib.request
from typing import Any


DEFAULT_MODEL = "deepseek/deepseek-v4-flash"
DEFAULT_BASE_URL = "https://api.deepseek.com"
DEFAULT_TIMEOUT = 45


class LlmUnavailable(RuntimeError):
    """Raised when no LLM provider is configured; callers must fall back."""


class LlmSchemaError(RuntimeError):
    """Raised when the model response does not satisfy the required schema."""


def _read_secret(name: str, required: bool = False) -> str | None:
    value = os.environ.get(name)
    if value:
        return value
    service = os.environ.get(f"IIH_BOOKING_{name}_SERVICE", f"iih-booking-{name}")
    try:
        result = subprocess.run(
            ["security", "find-generic-password", "-s", service, "-w"],
            check=True,
            capture_output=True,
            text=True,
        )
        value = result.stdout.strip()
        if value:
            return value
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    if required:
        raise LlmUnavailable(f"Missing required secret: {name}")
    return None


def provider_available() -> bool:
    """True when an API key is resolvable. Cheap; safe to call per poll."""
    return bool(_read_secret("DEEPSEEK_API_KEY", required=False))


def shadow_enabled() -> bool:
    """Master switch for all non-authoritative LLM usage.

    Kill switch: set IIH_LLM_DISABLED=1 to force every LLM call off without
    touching config. Returns False when no provider is configured, so callers
    degrade to the deterministic path silently.
    """
    if os.environ.get("IIH_LLM_DISABLED") in {"1", "true", "yes"}:
        return False
    return provider_available()


def _extract_json(text: str) -> dict[str, Any]:
    """Pull a JSON object out of a model reply, tolerating code fences.

    The model is instructed to return bare JSON, but we defensively strip
    ```json fences and leading/trailing prose. If nothing parses, that is a
    hard failure - we never guess.
    """
    stripped = text.strip()
    if stripped.startswith("```"):
        stripped = stripped.split("```", 2)[1]
        if stripped.startswith("json"):
            stripped = stripped[4:]
        stripped = stripped.strip()
    try:
        parsed = json.loads(stripped)
    except json.JSONDecodeError:
        start = stripped.find("{")
        end = stripped.rfind("}")
        if start == -1 or end == -1 or end <= start:
            raise LlmSchemaError("response was not JSON")
        try:
            parsed = json.loads(stripped[start : end + 1])
        except json.JSONDecodeError as exc:
            raise LlmSchemaError(f"response was not JSON: {exc}") from exc
    if not isinstance(parsed, dict):
        raise LlmSchemaError("response JSON was not an object")
    return parsed


def validate(payload: dict[str, Any], schema: dict[str, Any]) -> dict[str, Any]:
    """Validate payload against a small declarative schema.

    schema shape:
      {
        "required": ["field", ...],
        "enums": {"field": ["a", "b"], ...},
        "types": {"field": "str|int|float|bool|list|dict", ...},
        "null_ok": ["field", ...]         # fields permitted to be null
      }

    Raises LlmSchemaError on any violation. Never coerces (no str->int, no
    case-folding of enums); coercion is where silent corruption starts.
    """
    required = schema.get("required", [])
    enums = schema.get("enums", {})
    types = schema.get("types", {})
    null_ok = set(schema.get("null_ok", []))

    missing = [f for f in required if f not in payload]
    if missing:
        raise LlmSchemaError(f"missing required fields: {', '.join(missing)}")

    type_map = {
        "str": str,
        "int": int,
        "float": (int, float),
        "bool": bool,
        "list": list,
        "dict": dict,
    }
    for field, tname in types.items():
        if field not in payload:
            continue
        value = payload[field]
        if value is None and field in null_ok:
            continue
        if value is None and field not in null_ok:
            raise LlmSchemaError(f"field {field} was null but null is not allowed")
        expected = type_map.get(tname)
        if expected is None:
            continue
        # bool is a subclass of int in Python; guard against it.
        if tname in {"int", "float"} and isinstance(value, bool):
            raise LlmSchemaError(f"field {field} expected {tname}, got bool")
        if not isinstance(value, expected):
            raise LlmSchemaError(f"field {field} expected {tname}, got {type(value).__name__}")

    for field, allowed in enums.items():
        if field not in payload or payload[field] is None:
            continue
        if payload[field] not in allowed:
            raise LlmSchemaError(
                f"field {field} value {payload[field]!r} not in allowed set {allowed}"
            )

    return payload


def complete(
    prompt: str,
    schema: dict[str, Any],
    system: str = "You are a careful assistant. Reply with ONE JSON object and nothing else.",
    model: str | None = None,
    timeout: int = DEFAULT_TIMEOUT,
    max_tokens: int = 4000,
) -> dict[str, Any]:
    """Call the provider, parse JSON, validate against schema.

    Returns:
      {"ok": True, "data": {...}, "meta": {...}}  on success
      {"ok": False, "reason": "...", "meta": {...}} on any failure

    Never raises for provider/schema problems: callers must be able to fall
    back to the deterministic path without exception handling gymnastics.
    """
    started = time.time()
    meta: dict[str, Any] = {"model": model or DEFAULT_MODEL}

    api_key = _read_secret("DEEPSEEK_API_KEY", required=False)
    if not api_key:
        meta["latency_ms"] = int((time.time() - started) * 1000)
        return {"ok": False, "reason": "llm_unavailable", "meta": meta}

    base_url = os.environ.get("IIH_LLM_BASE_URL", DEFAULT_BASE_URL).rstrip("/")
    used_model = (model or os.environ.get("IIH_LLM_MODEL") or DEFAULT_MODEL).split("/")[-1]

    return _complete_once(prompt, schema, system, used_model, base_url, api_key,
                          timeout, max_tokens, started, meta)


def _complete_once(
    prompt: str,
    schema: dict[str, Any],
    system: str,
    used_model: str,
    base_url: str,
    api_key: str,
    timeout: int,
    max_tokens: int,
    started: float,
    meta: dict[str, Any],
) -> dict[str, Any]:
    body = json.dumps(
        {
            "model": used_model,
            "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": prompt},
            ],
            "temperature": 0,
            "max_tokens": max_tokens,
            "response_format": {"type": "json_object"},
        }
    ).encode()

    req = urllib.request.Request(
        f"{base_url}/chat/completions",
        data=body,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            payload = json.loads(resp.read().decode())
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
        meta["latency_ms"] = int((time.time() - started) * 1000)
        meta["error"] = f"{type(exc).__name__}: {exc}"
        return {"ok": False, "reason": "llm_call_failed", "meta": meta}

    meta["latency_ms"] = int((time.time() - started) * 1000)
    try:
        meta["tokens"] = (payload.get("usage") or {}).get("total_tokens")
        meta["finish_reason"] = (payload["choices"][0].get("finish_reason"))
        message = payload["choices"][0]["message"]
        content = message.get("content")
        # deepseek-v4-flash is a reasoning model: it spends the token budget on
        # hidden reasoning_content FIRST, then emits the answer. If reasoning
        # exhausts max_tokens, content is empty and finish_reason is 'length'.
        # Retry once with a larger budget rather than silently failing.
        if (not content or not content.strip()) and meta.get("finish_reason") == "length":
            meta["retried_larger_budget"] = True
            return _complete_once(prompt, schema, system, used_model, base_url, api_key,
                                  timeout, max_tokens * 3, started, meta)
    except (KeyError, IndexError, TypeError) as exc:
        meta["error"] = f"malformed provider response: {exc}"
        return {"ok": False, "reason": "llm_bad_response", "meta": meta}

    if not content or not content.strip():
        meta["error"] = f"empty content (finish_reason={meta.get('finish_reason')})"
        return {"ok": False, "reason": "llm_empty_response", "meta": meta}
    if meta.get("finish_reason") == "length":
        meta["error"] = "response truncated by max_tokens"
        return {"ok": False, "reason": "llm_truncated", "meta": meta}

    try:
        parsed = _extract_json(content)
        validated = validate(parsed, schema)
    except LlmSchemaError as exc:
        meta["error"] = str(exc)
        meta["raw_preview"] = content[:500]
        return {"ok": False, "reason": "llm_schema_invalid", "meta": meta}

    return {"ok": True, "data": validated, "meta": meta}
