#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from typing import Any


def fail(msg: str, code: int = 1):
    print(f"VALIDATION_FAIL: {msg}", file=sys.stderr)
    sys.exit(code)


def parse_type(s: str):
    m = {
        "str": str,
        "string": str,
        "int": int,
        "integer": int,
        "float": float,
        "number": (int, float),
        "bool": bool,
        "boolean": bool,
        "list": list,
        "array": list,
        "dict": dict,
        "object": dict,
        "any": object,
    }
    if s.lower() not in m:
        fail(f"unknown type '{s}'")
    return m[s.lower()]


def get_path(obj: Any, path: str):
    cur = obj
    for part in path.split('.'):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            fail(f"missing path '{path}'")
    return cur


def main():
    ap = argparse.ArgumentParser(description="Validate Ollama JSON response schema")
    ap.add_argument("--model", default="qwen3:4b")
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--require", action="append", default=[], help="Required key path, e.g. status or data.items")
    ap.add_argument("--expect", action="append", default=[], help="Type assertion path:type, e.g. status:string")
    ap.add_argument("--allow-extra", action="store_true")
    args = ap.parse_args()

    cmd = [
        "/Users/clawdia/.openclaw/workspace/scripts/ollama_json_safe.sh",
        args.model,
        args.prompt,
    ]

    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        fail(f"generator error: {e.output.strip()}")

    text = out.strip()
    try:
        obj = json.loads(text)
    except json.JSONDecodeError as e:
        fail(f"invalid JSON from model: {e}")

    for key in args.require:
        _ = get_path(obj, key)

    for spec in args.expect:
        if ':' not in spec:
            fail(f"bad --expect '{spec}' (use path:type)")
        path, typ = spec.split(':', 1)
        value = get_path(obj, path)
        t = parse_type(typ)
        if t is float:
            ok = isinstance(value, (int, float))
        else:
            ok = isinstance(value, t)
        if not ok:
            fail(f"path '{path}' expected {typ}, got {type(value).__name__}")

    print("VALIDATION_OK")
    print(json.dumps(obj, ensure_ascii=False))


if __name__ == "__main__":
    main()
