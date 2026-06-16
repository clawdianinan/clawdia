#!/usr/bin/env python3
import json, subprocess, re
from pathlib import Path
from datetime import datetime, timedelta

BASE = Path('/Users/clawdia/.openclaw/workspace')
ADDR = BASE / 'reports_status/addressbook/report_senders.json'
STATUS_DIR = BASE / 'reports_status'

def target_report_month(dt: datetime) -> str:
    first = dt.replace(day=1)
    prev = first - timedelta(days=1)
    return prev.strftime('%Y-%m')

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

def parse_himalaya_json(raw: str):
    m = re.search(r'\[\s*\{', raw)
    if not m:
        return []
    i = m.start()
    depth = 0
    start = None
    end = None
    in_str = False
    escape = False
    for idx, ch in enumerate(raw[i:], start=i):
        if in_str:
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_str = False
            continue
        if ch == '"':
            in_str = True
            continue
        if ch == '[':
            if start is None:
                start = idx
            depth += 1
        elif ch == ']':
            depth -= 1
            if depth == 0 and start is not None:
                end = idx + 1
                break
    if start is None or end is None:
        return []
    try:
        return json.loads(raw[start:end])
    except Exception:
        return []

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout + p.stderr

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
    raw = run("himalaya envelope list -a iih_temi -s 400 -o json")
    raw2 = run("himalaya envelope list -a iih_clawdia -s 300 -o json")
    emails = parse_himalaya_json(raw) + parse_himalaya_json(raw2)
    sub = json.loads(sub_path.read_text())
    matched = []
    keywords = [
        'report', 'monthly report', 'financial report', 'department report',
        'facility department report', 'hr report', 'it & marketing report'
    ]
    for e in emails:
        subject = (e.get('subject') or '').lower()
        has_attachment = bool(e.get('has_attachment'))
        if not has_attachment:
            continue
        if not any(k in subject for k in keywords):
            continue
        sender = (e.get('from', {}) or {}).get('addr', '').lower()
        dep = addrmap.get(sender)
        if not dep:
            continue
        k = dep_key(dep)
        if not k:
            continue
        s = sub['departments'][k]
        s['status'] = 'received'
        dt = e.get('date')
        if not s.get('receivedAt') or (dt and dt > s.get('receivedAt')):
            s['receivedAt'] = dt
        matched.append({
            'id': e.get('id'),
            'sender': sender,
            'department': dep,
            'subject': e.get('subject'),
            'date': e.get('date')
        })
    sub_path.write_text(json.dumps(sub, indent=2))
    (month_dir / 'sender_match_log.json').write_text(json.dumps(matched, indent=2))
    return sub

def main():
    dt = datetime.now()
    month = target_report_month(dt)
    print(f"Report month: {month}")
    addr = load_addrbook()
    month_dir, subf, gatef = ensure_files(month)
    sub = update_from_emails(month_dir, subf, addr)
    print("Submission status:")
    for dep_key, info in sub['departments'].items():
        print(f"  {info['owner']}: {info['status']} {info.get('receivedAt', '')}")
    # Determine missing departments
    missing = [info['owner'] for dep_key, info in sub['departments'].items() if info['status'] != 'received']
    print(f"Missing departments: {missing}")
    # Generate draft reminder emails
    recipient_by_dep = {
        'admin': ('maureen.okey@iih.ng', 'Administration'),
        'hr': ('sinachi@iih.ng', 'Human Resources'),
        'it_marketing': ('nasiru.muhammed@iih.ng', 'IT & Marketing'),
        'programs': ('zumah.yahaya@iih.ng', 'Programs'),
        'finance': ('khadijat.bello@iih.ng', 'Finance'),
        'facility': ('kamil.ahmed@iih.ng', 'Facility Management'),
    }
    sig_plain = (
        "Clawdia AI\n"
        "AI Assistant | Ilorin Innovation Hub\n"
        "https://iih.ng\n"
        "Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria"
    )
    drafts = []
    for dep_key_name, rec in recipient_by_dep.items():
        dep = sub['departments'].get(dep_key_name, {})
        if dep.get('status') == 'received':
            continue
        to_email, dept_label = rec
        html = (
            f"<html><body>"
            f"<p>Dear {dept_label} Team,</p>"
            f"<p>This is an automated reminder that your {month} monthly report is still pending. "
            f"Please submit immediately with all relevant attachments for IIH monthly report consolidation.</p>"
            f"<p>Please copy the Managing Director (temi@iih.ng) in your response.</p>"
            f"<p>Thank you.</p>"
            f"<p>{sig_plain.replace(chr(10), '<br>')}</p>"
            f"</body></html>"
        )
        plain = (
            f"Dear {dept_label} Team,\n\n"
            f"This is an automated reminder that your {month} monthly report is still pending. "
            f"Please submit immediately with all relevant attachments for IIH monthly report consolidation.\n\n"
            f"Please copy the Managing Director (temi@iih.ng) in your response.\n\n"
            f"Thank you.\n\n{sig_plain}"
        )
        drafts.append({
            'department': dep_key_name,
            'to': to_email,
            'subject': f'Reminder: {month} {dept_label} Monthly Report Submission',
            'html': html,
            'plain': plain
        })
    # Save drafts to file
    drafts_file = month_dir / 'reminder_drafts.json'
    drafts_file.write_text(json.dumps(drafts, indent=2))
    print(f"Draft reminders saved to {drafts_file}")
    # Also create human-readable draft emails
    for draft in drafts:
        draft_file = month_dir / f"reminder_draft_{draft['department']}.txt"
        content = f"To: {draft['to']}\nCc: temi@iih.ng\nSubject: {draft['subject']}\n\n{draft['plain']}"
        draft_file.write_text(content)
        print(f"  - {draft['department']}: {draft_file}")
    # Progress calculation
    received = sum(1 for v in sub['departments'].values() if v.get('status') == 'received')
    total = len(sub['departments'])
    progress_pct = (received / total) * 100
    print(f"Progress: {received}/{total} ({progress_pct:.1f}%)")
    # Determine if reminders should be sent (based on day)
    day = dt.day
    target = 0.0
    if day >= 8:
        target = 100.0
    elif day >= 7:
        target = 95.0
    elif day >= 6:
        target = 80.0
    elif day >= 5:
        target = 65.0
    elif day >= 3:
        target = 40.0
    print(f"Day {day}, target progress: {target}%")
    if progress_pct < target:
        print("⚠️  Progress below target. Reminders needed.")
    else:
        print("✅ Progress meets target.")
    # Return summary for cron delivery
    print("\n--- SUMMARY ---")
    print(f"Month: {month}")
    print(f"Missing departments: {', '.join(missing) if missing else 'None'}")
    print(f"Draft reminders generated: {len(drafts)}")
    print("Reminder drafts saved in monthly directory.")
    print("ACTION REQUIRED: Review draft reminders and approve sending.")

if __name__ == '__main__':
    main()