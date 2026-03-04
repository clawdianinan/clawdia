#!/usr/bin/env python3
import json, subprocess, re
from pathlib import Path
from datetime import datetime, timedelta

BASE = Path('/Users/clawdia/.openclaw/workspace')
ADDR = BASE / 'reports_status/addressbook/report_senders.json'
STATUS_DIR = BASE / 'reports_status'
LOG = STATUS_DIR / 'automation.log'


def now_lagos():
    return datetime.now()


def target_report_month(dt: datetime) -> str:
    first = dt.replace(day=1)
    prev = first - timedelta(days=1)
    return prev.strftime('%Y-%m')


def day_of_month(dt: datetime) -> int:
    return dt.day


def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout + p.stderr


def parse_himalaya_json(raw: str):
    i = raw.find('[')
    if i == -1:
        return []
    try:
        return json.loads(raw[i:])
    except Exception:
        return []


def load_addrbook():
    if not ADDR.exists():
        return {}
    data = json.loads(ADDR.read_text())
    m = {}
    for dep in data.get('departments', []):
        d = dep.get('department')
        for s in dep.get('senders', []):
            m[s.get('primaryEmail','').lower()] = d
            for a in s.get('alternateEmails', []):
                m[a.lower()] = d
    return m


def ensure_files(month):
    d = STATUS_DIR / month
    d.mkdir(parents=True, exist_ok=True)
    sub = d / 'submission_status.json'
    if not sub.exists():
        template = {
            'reportMonth': month,
            'departments': {
                'programs': {'owner':'Programs','status':'pending','receivedAt':None},
                'finance': {'owner':'Finance','status':'pending','receivedAt':None},
                'admin': {'owner':'Administration','status':'pending','receivedAt':None},
                'hr': {'owner':'HR','status':'pending','receivedAt':None},
                'facility': {'owner':'Facility','status':'pending','receivedAt':None},
                'it_marketing': {'owner':'IT & Marketing','status':'pending','receivedAt':None},
            }
        }
        sub.write_text(json.dumps(template, indent=2))
    gates = d / 'financial_gates.json'
    if not gates.exists():
        gates.write_text(json.dumps({'reportMonth':month,'gate10_documents_received':False,'gate15_validation_complete':False,'gate20_template_populated':False}, indent=2))
    return d, sub, gates


def dep_key(dep):
    return {
        'Programs':'programs', 'Finance':'finance', 'Administration':'admin',
        'Human Resources':'hr', 'Facility Management':'facility', 'IT & Marketing':'it_marketing'
    }.get(dep)


def update_from_emails(month_dir, sub_path, addrmap):
    q = 'subject report or subject monthly or subject financial or subject hr or subject facility or subject "IT & Marketing"'
    raw = run(f"himalaya envelope list -a iih_temi -s 300 -o json {q}")
    raw2 = run(f"himalaya envelope list -a iih_clawdia -s 200 -o json {q}")
    emails = parse_himalaya_json(raw) + parse_himalaya_json(raw2)

    sub = json.loads(sub_path.read_text())
    matched = []
    for e in emails:
        sender = (e.get('from',{}) or {}).get('addr','').lower()
        dep = addrmap.get(sender)
        if not dep:
            continue
        k = dep_key(dep)
        if not k:
            continue
        s = sub['departments'][k]
        s['status'] = 'received'
        s['receivedAt'] = e.get('date')
        matched.append({'id':e.get('id'),'sender':sender,'department':dep,'subject':e.get('subject'),'date':e.get('date')})

    sub_path.write_text(json.dumps(sub, indent=2))
    (month_dir / 'sender_match_log.json').write_text(json.dumps(matched, indent=2))
    return sub


def calc_progress(month_dir, sub, gates):
    received = sum(1 for v in sub['departments'].values() if v.get('status') == 'received')
    sub_pct = received / 6
    passed = sum(1 for k in ['gate10_documents_received','gate15_validation_complete','gate20_template_populated'] if gates.get(k))
    gate_pct = passed / 3
    assembly = 1 if (BASE / f'Reports/IIH_Monthly_Report_{sub["reportMonth"]}_Draft_v1.0.md').exists() else 0
    review = 1 if (BASE / f'Reports/IIH_Monthly_Report_{sub["reportMonth"]}_MD_Review_Pack_v1.0.md').exists() else 0
    progress = (sub_pct*0.4 + gate_pct*0.3 + assembly*0.2 + review*0.1) * 100
    out = {
        'submissions': {'received':received, 'total':6, 'pct':round(sub_pct*100,2)},
        'gates': {'passed':passed, 'total':3, 'pct':round(gate_pct*100,2)},
        'assemblyDone': bool(assembly),
        'reviewDone': bool(review),
        'overallProgressPct': round(progress,2)
    }
    (month_dir / 'progress.json').write_text(json.dumps(out, indent=2))
    return out


def trigger_actions(month_dir, day):
    statef = month_dir / 'trigger_state.json'
    state = json.loads(statef.read_text()) if statef.exists() else {'executed': []}
    due = [1,3,5,6,7,8]
    if day in due and day not in state['executed']:
        (month_dir / f'trigger_day_{day}.md').write_text(f'Trigger day {day} executed at {now_lagos().isoformat()}')
        state['executed'].append(day)
        statef.write_text(json.dumps(state, indent=2))


def target_for_day(day:int)->float:
    if day >= 8:
        return 100.0
    if day >= 7:
        return 95.0
    if day >= 6:
        return 80.0
    if day >= 5:
        return 65.0
    if day >= 3:
        return 40.0
    return 0.0


def apply_target_alerts(month_dir, day, progress_pct):
    target = target_for_day(day)
    riskf = month_dir / 'risk_flags.json'
    planf = month_dir / 'recovery_plan.md'
    escf = month_dir / 'escalation_md_draft.md'

    risk = {'reportMonth': month_dir.name, 'risks': []}
    if riskf.exists():
        try:
            risk = json.loads(riskf.read_text())
        except Exception:
            pass

    # clear prior progress lag risk entries
    risks = [r for r in risk.get('risks',[]) if r.get('code')!='PROGRESS_BELOW_TARGET']

    if progress_pct < target:
        gap = round(target - progress_pct, 2)
        risks.append({
            'code': 'PROGRESS_BELOW_TARGET',
            'severity': 'high' if gap >= 15 else 'medium',
            'calendarDay': day,
            'targetPct': target,
            'actualPct': progress_pct,
            'gapPct': gap,
            'timestamp': now_lagos().isoformat()
        })
        planf.write_text(
            f"# Recovery Plan (Auto)\n\n"
            f"- Calendar day: {day}\n"
            f"- Target: {target}%\n"
            f"- Actual: {progress_pct}%\n"
            f"- Gap: {gap}%\n\n"
            f"## Immediate Actions\n"
            f"1. Send missing department reminders (drafts).\n"
            f"2. Escalate finance gate blockers if any.\n"
            f"3. Prioritize incomplete sections for same-day closure.\n"
        )
        escf.write_text(
            f"Subject: Monthly Report Progress Escalation ({month_dir.name})\n\n"
            f"MD,\nCurrent progress is {progress_pct}% vs target {target}% on calendar day {day}.\n"
            f"Gap is {gap}%. Draft recovery actions have been generated in recovery_plan.md.\n"
            f"\n(Generated automatically; draft only, not sent.)\n"
        )

    risk['risks'] = risks
    riskf.write_text(json.dumps(risk, indent=2))


def main():
    dt = now_lagos()
    month = target_report_month(dt)
    addr = load_addrbook()
    month_dir, subf, gatef = ensure_files(month)
    sub = update_from_emails(month_dir, subf, addr)
    gates = json.loads(gatef.read_text())
    prog = calc_progress(month_dir, sub, gates)
    day = day_of_month(dt)
    trigger_actions(month_dir, day)
    apply_target_alerts(month_dir, day, prog['overallProgressPct'])
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open('a') as f:
        f.write(f"{dt.isoformat()} month={month} day={day} progress={prog['overallProgressPct']} target={target_for_day(day)}\n")
    print(json.dumps({'ok':True,'month':month,'calendarDay':day,'progress':prog['overallProgressPct'],'target':target_for_day(day)}))


if __name__ == '__main__':
    main()
