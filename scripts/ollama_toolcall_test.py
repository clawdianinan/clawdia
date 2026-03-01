#!/usr/bin/env python3
import json
import subprocess
import sys

PAYLOAD = {
    "model": "qwen3:4b",
    "stream": False,
    "think": False,
    "messages": [
        {"role": "user", "content": "Use the weather tool for Lagos and return a tool call."}
    ],
    "tools": [
        {
            "type": "function",
            "function": {
                "name": "get_weather",
                "description": "Get weather for a city",
                "parameters": {
                    "type": "object",
                    "properties": {"city": {"type": "string"}},
                    "required": ["city"]
                }
            }
        }
    ]
}

cmd = [
    "curl", "-sS", "http://127.0.0.1:11434/api/chat",
    "-H", "Content-Type: application/json",
    "-d", json.dumps(PAYLOAD)
]

raw = subprocess.check_output(cmd, text=True)
obj = json.loads(raw)
msg = obj.get("message", {})
tool_calls = msg.get("tool_calls") or []
if not tool_calls:
    print("TOOLCALL_FAIL: no tool_calls returned", file=sys.stderr)
    sys.exit(1)

first = tool_calls[0]
name = ((first.get("function") or {}).get("name"))
args = ((first.get("function") or {}).get("arguments"))

if name != "get_weather":
    print(f"TOOLCALL_FAIL: expected get_weather, got {name}", file=sys.stderr)
    sys.exit(1)

if not isinstance(args, dict) or args.get("city", "").lower() != "lagos":
    print(f"TOOLCALL_FAIL: bad arguments: {args}", file=sys.stderr)
    sys.exit(1)

print("TOOLCALL_OK")
print(json.dumps(first, ensure_ascii=False))
