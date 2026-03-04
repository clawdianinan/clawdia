#!/usr/bin/env python3
import json,sys
from pathlib import Path

# usage: calc_progress.py <submission_status.json> <financial_gates.json> <assembly_done:0|1> <review_done:0|1> <out_progress.json>
sub=json.loads(Path(sys.argv[1]).read_text())
gates=json.loads(Path(sys.argv[2]).read_text())
assembly= int(sys.argv[3])
review= int(sys.argv[4])
out=Path(sys.argv[5])

depts=sub.get('departments',{})
received=sum(1 for v in depts.values() if v.get('status')=='received')
sub_pct=received/6 if depts else 0
passed=sum(1 for k in ['gate10_documents_received','gate15_validation_complete','gate20_template_populated'] if gates.get(k) is True)
gate_pct=passed/3

progress=(sub_pct*0.40 + gate_pct*0.30 + (1 if assembly else 0)*0.20 + (1 if review else 0)*0.10)*100
obj={
  'submissions': {'received':received,'total':6,'pct':round(sub_pct*100,2)},
  'gates': {'passed':passed,'total':3,'pct':round(gate_pct*100,2)},
  'assemblyDone': bool(assembly),
  'reviewDone': bool(review),
  'overallProgressPct': round(progress,2)
}
out.parent.mkdir(parents=True,exist_ok=True)
out.write_text(json.dumps(obj,indent=2))
print(json.dumps(obj))
