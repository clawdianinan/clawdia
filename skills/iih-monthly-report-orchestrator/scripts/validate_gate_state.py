#!/usr/bin/env python3
import json,sys
from pathlib import Path

if len(sys.argv)<2:
    print('usage: validate_gate_state.py <financial_gates.json>')
    sys.exit(2)
p=Path(sys.argv[1])
obj=json.loads(p.read_text())
ok= all([obj.get('gate10_documents_received'),obj.get('gate15_validation_complete'),obj.get('gate20_template_populated')])
print(json.dumps({'status':'pass' if ok else 'fail','gates':obj},indent=2))
sys.exit(0 if ok else 1)
