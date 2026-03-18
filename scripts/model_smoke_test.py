#!/usr/bin/env python3
import re, subprocess, sys, json

ANSI_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")

def run(cmd, timeout=90):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
    out = ANSI_RE.sub('', (p.stdout or '') + '\n' + (p.stderr or ''))
    lines = [ln.strip() for ln in out.splitlines() if ln.strip()]
    return p.returncode, lines

result = {"models": {}, "status": "ok"}

# inventory
rc, lines = run("ollama list", timeout=30)
if rc != 0:
    print(json.dumps({"status":"error","step":"list","output":lines[-10:]}, indent=2))
    sys.exit(1)

installed = []
for ln in lines:
    if ln.startswith('NAME') or ln.startswith('ID'):
        continue
    parts = ln.split()
    if parts:
        installed.append(parts[0])

for model in ["qwen3.5:9b", "llama3.1:8b"]:
    if model not in installed:
        result["models"][model] = {"installed": False}
        result["status"] = "degraded"
        continue
    rc, lines = run(f"printf 'Reply exactly: OK\\n' | ollama run {model} --nowordwrap", timeout=90)
    clean = [ln for ln in lines if not ln.lower().startswith('thinking') and 'pulling' not in ln.lower()]
    tail = clean[-8:] if clean else lines[-8:]
    got_ok = any(ln.strip() == 'OK' for ln in tail)
    result["models"][model] = {
        "installed": True,
        "inference_ok": bool(got_ok and rc == 0),
        "tail": tail,
        "exit_code": rc,
    }
    if not (got_ok and rc == 0):
        result["status"] = "degraded"

print(json.dumps(result, indent=2))
