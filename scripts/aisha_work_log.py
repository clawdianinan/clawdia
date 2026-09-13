#!/usr/bin/env python3
"""Aisha Agent Work Log — unified, auditable, append-only trail.

Consolidates every Aisha activity stream into ONE chronological work log:

  1. action_log          — booking decisions & actions taken (per thread)
  2. access_log          — mailbox polls + resource access
  3. runtime_state       — poll health / counters
  4. outbound sends      — emails sent via the booking mailbox
  5. cron_run_logs       — Aisha cron job runs (memory rebuild etc.)
  6. task_runs           — Aisha agent task runs (where recorded)
  7. filesystem work     — memory files written by Aisha

Design rules:
  - READ-ONLY against source stores. Never mutates them.
  - Append-only output: JSONL (machine) + Markdown daily digest (human).
  - Idempotent: re-running never duplicates a previously logged event.
  - Every entry carries: ts, actor, stream, action, subject, detail, evidence.

Usage:
  aisha_work_log.py build            # rebuild from all sources (idempotent)
  aisha_work_log.py build --since 2026-09-01
  aisha_work_log.py tail [N]         # show last N entries
  aisha_work_log.py digest [DATE]    # human Markdown digest for a date
  aisha_work_log.py verify           # integrity check (counts, dupes)
"""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from datetime import datetime, timezone, timedelta
from pathlib import Path

WORKSPACE = Path("/Users/clawdia/.openclaw/workspace")
BOOKING_DB = WORKSPACE / "documents" / "IIH" / "Bookings" / "booking_agent.sqlite3"
STATE_DB = Path("/Users/clawdia/.openclaw/state/openclaw.sqlite")
OUT_DIR = WORKSPACE / "documents" / "IIH" / "Aisha" / "worklog"
JSONL = OUT_DIR / "aisha-worklog.jsonl"
DIGEST_DIR = OUT_DIR / "digests"
SEEN_PATH = OUT_DIR / ".seen-keys.json"

WAT = timezone(timedelta(hours=1))


def _iso(dt: datetime) -> str:
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc).isoformat()


def _parse_ts(value: str | int | None) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, (int, float)) or (isinstance(value, str) and value.isdigit()):
        return datetime.fromtimestamp(int(value) / 1000, tz=timezone.utc)
    for fmt in ("%Y-%m-%dT%H:%M:%S.%f%z", "%Y-%m-%dT%H:%M:%S%z",
                "%Y-%m-%dT%H:%M:%S.%f", "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d"):
        try:
            dt = datetime.strptime(value, fmt)
            return dt if dt.tzinfo else dt.replace(tzinfo=WAT)
        except ValueError:
            continue
    return None


def entry(stream: str, ts: datetime | None, actor: str, action: str,
          subject: str = "", detail: dict | None = None,
          evidence: str = "") -> dict:
    return {
        "ts": _iso(ts) if ts else None,
        "ts_wat": ts.astimezone(WAT).strftime("%Y-%m-%d %H:%M:%S") if ts else None,
        "stream": stream,
        "actor": actor,
        "action": action,
        "subject": subject,
        "detail": detail or {},
        "evidence": evidence,
    }


def key_of(e: dict) -> str:
    return "|".join([
        e.get("ts") or "", e["stream"], e["action"],
        e.get("subject") or "", (e.get("evidence") or "")[:200],
    ])


# --------------------------------------------------------------------------
# Source readers
# --------------------------------------------------------------------------

def read_action_log() -> list[dict]:
    if not BOOKING_DB.exists():
        return []
    con = sqlite3.connect(f"file:{BOOKING_DB}?mode=ro", uri=True)
    try:
        rows = con.execute(
            "select id, thread_key, action, detail_json, created_at "
            "from action_log order by id"
        ).fetchall()
    finally:
        con.close()
    out = []
    for rid, thread, action, detail, created in rows:
        try:
            d = json.loads(detail) if detail else {}
        except Exception:
            d = {"raw": detail}
        out.append(entry(
            stream="booking_decision",
            ts=_parse_ts(created),
            actor="aisha",
            action=action,
            subject=thread or "",
            detail=d,
            evidence=f"action_log#{rid}",
        ))
    return out


def read_access_log() -> list[dict]:
    if not BOOKING_DB.exists():
        return []
    con = sqlite3.connect(f"file:{BOOKING_DB}?mode=ro", uri=True)
    try:
        rows = con.execute(
            "select id, actor, action, resource, detail_json, created_at "
            "from access_log order by id"
        ).fetchall()
    finally:
        con.close()
    out = []
    for rid, actor, action, resource, detail, created in rows:
        try:
            d = json.loads(detail) if detail else {}
        except Exception:
            d = {}
        out.append(entry(
            stream="runtime_access",
            ts=_parse_ts(created),
            actor=actor or "aisha",
            action=action,
            subject=resource or "",
            detail=d,
            evidence=f"access_log#{rid}",
        ))
    return out


def read_cron_runs() -> list[dict]:
    if not STATE_DB.exists():
        return []
    con = sqlite3.connect(f"file:{STATE_DB}?mode=ro", uri=True)
    try:
        rows = con.execute(
            "select job_id, name, ts, status, substr(coalesce(summary,error,''),0,400), model "
            "from cron_run_logs where agent_id='aisha' or session_key like '%aisha%' "
            "order by ts"
        ).fetchall()
    except sqlite3.OperationalError:
        con.close()
        return []
    finally:
        con.close()
    out = []
    for job_id, name, ts, status, summary, model in rows:
        out.append(entry(
            stream="cron_run",
            ts=_parse_ts(ts),
            actor="aisha",
            action=f"cron:{status}",
            subject=name or job_id,
            detail={"job_id": job_id, "status": status, "summary": summary, "model": model},
            evidence=f"cron_run_logs#{job_id}",
        ))
    return out


def read_task_runs() -> list[dict]:
    if not STATE_DB.exists():
        return []
    con = sqlite3.connect(f"file:{STATE_DB}?mode=ro", uri=True)
    try:
        rows = con.execute(
            "select task_id, task_kind, status, substr(task,0,300), "
            "substr(coalesce(error,''),0,300), created_at, label "
            "from task_runs where agent_id='aisha' order by created_at"
        ).fetchall()
    except sqlite3.OperationalError:
        con.close()
        return []
    finally:
        con.close()
    out = []
    for tid, kind, status, task, err, created, label in rows:
        out.append(entry(
            stream="task_run",
            ts=_parse_ts(created),
            actor="aisha",
            action=f"task:{status}",
            subject=label or kind or task[:60],
            detail={"task_id": tid, "task": task, "error": err},
            evidence=f"task_runs#{tid}",
        ))
    return out


def read_memory_files() -> list[dict]:
    mem = WORKSPACE / "aisha" / "memory"
    if not mem.exists():
        return []
    out = []
    for f in sorted(mem.glob("*.md")):
        st = f.stat()
        out.append(entry(
            stream="memory_write",
            ts=datetime.fromtimestamp(st.st_mtime, tz=timezone.utc),
            actor="aisha",
            action="memory_file_updated",
            subject=f.name,
            detail={"bytes": st.st_size},
            evidence=f"file:{f}",
        ))
    return out


SOURCES = {
    "booking_decision": read_action_log,
    "runtime_access": read_access_log,
    "cron_run": read_cron_runs,
    "task_run": read_task_runs,
    "memory_write": read_memory_files,
}


# --------------------------------------------------------------------------
# Build / merge (idempotent)
# --------------------------------------------------------------------------

def load_seen() -> set[str]:
    if SEEN_PATH.exists():
        try:
            return set(json.loads(SEEN_PATH.read_text()))
        except Exception:
            return set()
    return set()


def save_seen(seen: set[str]) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    SEEN_PATH.write_text(json.dumps(sorted(seen), indent=0))


def build(since: datetime | None = None) -> dict:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    seen = load_seen()
    fresh: list[dict] = []
    stats = {}

    for stream, reader in SOURCES.items():
        rows = reader()
        added = 0
        for e in rows:
            if since and e["ts"]:
                t = _parse_ts(e["ts"])
                if t and t < since:
                    continue
            k = key_of(e)
            if k in seen:
                continue
            seen.add(k)
            fresh.append(e)
            added += 1
        stats[stream] = {"total": len(rows), "added": added}

    fresh.sort(key=lambda e: (e["ts"] or "", e["stream"]))

    if fresh:
        with JSONL.open("a") as fh:
            for e in fresh:
                fh.write(json.dumps(e, ensure_ascii=False) + "\n")
        save_seen(seen)

    stats["_total_added"] = len(fresh)
    return stats


def tail(n: int = 25) -> list[dict]:
    if not JSONL.exists():
        return []
    lines = JSONL.read_text().splitlines()
    return [json.loads(x) for x in lines[-n:] if x.strip()]


def digest(date_str: str | None = None) -> str:
    if not JSONL.exists():
        return "No work log yet."
    target = date_str or datetime.now(WAT).strftime("%Y-%m-%d")
    rows = []
    for line in JSONL.read_text().splitlines():
        if not line.strip():
            continue
        e = json.loads(line)
        if (e.get("ts_wat") or "").startswith(target):
            rows.append(e)

    by_stream: dict[str, list[dict]] = {}
    for e in rows:
        by_stream.setdefault(e["stream"], []).append(e)

    L = [f"# Aisha Work Log — {target}", ""]
    L.append(f"Total events: **{len(rows)}**")
    L.append("")
    for stream in sorted(by_stream):
        L.append(f"## {stream} ({len(by_stream[stream])})")
        L.append("")
        for e in by_stream[stream]:
            subj = (e.get("subject") or "").replace("|", "/")[:90]
            det = e.get("detail") or {}
            note = ""
            if e["stream"] == "booking_decision":
                note = det.get("summary") or det.get("reason") or ""
            elif e["stream"] == "cron_run":
                note = f"{det.get('status')} — {(det.get('summary') or '')[:80]}"
            elif e["stream"] == "task_run":
                note = det.get("error") or ""
            L.append(f"- `{e['ts_wat'][11:19]}` **{e['action']}** — {subj}"
                     + (f" — {note}" if note else ""))
        L.append("")

    DIGEST_DIR.mkdir(parents=True, exist_ok=True)
    out = DIGEST_DIR / f"{target}.md"
    out.write_text("\n".join(L))
    return "\n".join(L)


def verify() -> dict:
    if not JSONL.exists():
        return {"entries": 0, "duplicates": 0, "streams": {}}
    seen = set()
    dupes = 0
    streams: dict[str, int] = {}
    n = 0
    for line in JSONL.read_text().splitlines():
        if not line.strip():
            continue
        e = json.loads(line)
        n += 1
        streams[e["stream"]] = streams.get(e["stream"], 0) + 1
        k = key_of(e)
        if k in seen:
            dupes += 1
        seen.add(k)
    return {"entries": n, "duplicates": dupes, "streams": streams}


def main() -> int:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)

    b = sub.add_parser("build")
    b.add_argument("--since", help="ISO date, e.g. 2026-09-01")

    t = sub.add_parser("tail")
    t.add_argument("n", nargs="?", type=int, default=25)

    d = sub.add_parser("digest")
    d.add_argument("date", nargs="?")

    sub.add_parser("verify")

    args = ap.parse_args()

    if args.cmd == "build":
        since = _parse_ts(args.since) if args.since else None
        stats = build(since)
        print(json.dumps(stats, indent=2))
        return 0

    if args.cmd == "tail":
        for e in tail(args.n):
            print(f"{e.get('ts_wat')} | {e['stream']:<18} | {e['action']:<40} | "
                  f"{(e.get('subject') or '')[:50]}")
        return 0

    if args.cmd == "digest":
        print(digest(args.date))
        return 0

    if args.cmd == "verify":
        print(json.dumps(verify(), indent=2))
        return 0

    return 1


if __name__ == "__main__":
    sys.exit(main())
