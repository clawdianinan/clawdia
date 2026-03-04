#!/usr/bin/env python3
import json,sys
from pathlib import Path

# minimal generator: python generate_reminder_draft.py <submission_status.json> <out_dir>
status=json.loads(Path(sys.argv[1]).read_text())
out=Path(sys.argv[2]); out.mkdir(parents=True,exist_ok=True)
for dept,meta in status.get('departments',{}).items():
    if meta.get('status')!='received':
        f=out/f'reminder_day5_{dept}_{status.get("reportMonth","unknown")}.md'
        f.write_text(f'Subject: Reminder: {status.get("reportMonth")} {dept} report\n\nDear {meta.get("owner","Team")},\nPlease submit your monthly report.\n')
print('ok')
