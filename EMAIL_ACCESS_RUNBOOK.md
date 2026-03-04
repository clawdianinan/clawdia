# EMAIL_ACCESS_RUNBOOK.md

Purpose: Practical, repeatable steps for accessing Temi’s email data and saving report attachments reliably.

Scope: Read/search/extract workflow only. No sending.

---

## Quick Start (10-command cheat sheet)

Use this when a model needs a fast, reliable path.

```bash
# 1) Find candidate emails
fruitmail search --days 7 --limit 30

# 2) Narrow by subject/sender
fruitmail search --subject "REQUEST FOR STATEMENT" --days 7 --limit 20
fruitmail sender "zumah" --limit 50

# 3) Inspect body/context
fruitmail body <id>

# 4) List attachment names from Mail
osascript <<'APPLESCRIPT'
tell application "Mail"
  set msgs to (messages of inbox whose subject contains "STATEMENT")
  repeat with m in msgs
    log "subject:" & (subject of m)
    repeat with a in mail attachments of m
      log " - " & (name of a)
    end repeat
  end repeat
end tell
APPLESCRIPT

# 5) Locate attachment file path in Mail store
find ~/Library/Mail/V10 -type f -name "*ILORIN TECH PARK LTD*.pdf" 2>/dev/null | head -20

# 6) Ensure destination folder exists
mkdir -p "/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports"

# 7) Copy attachment to destination
cp -f "<source-file-from-find>" "/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports/"

# 8) Verify saved files
ls -la "/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports"

# 9) If wrong folder used, move immediately (example)
# mv -f "/wrong/path/file.pdf" "/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports/"

# 10) Report completion with subject/date/filename evidence
```

---

## 0) Preconditions

- Host is macOS with Mail.app synced to target accounts.
- `fruitmail` CLI is installed and working.
- You have local filesystem access to:
  - `~/Library/Mail/V10/...` (Mail store)
  - Google Drive sync path used by this workspace:
    - `/Users/clawdia/My Drive/Clawdia Documents/IIH/...`

Do NOT store credentials in files. Do NOT send emails unless explicitly instructed.

---

## 1) Fast search in Apple Mail metadata (fruitmail)

Use this first for quick discovery.

### 1.1 Recent messages
```bash
fruitmail search --days 7 --limit 30
```

### 1.2 Subject-focused search
```bash
fruitmail search --subject "REQUEST FOR STATEMENT" --days 7 --limit 20
fruitmail search --subject "Feb 2026 Sales, Drinks & Profit-Sharing Report" --days 7 --limit 20
```

### 1.3 Sender-focused search
```bash
fruitmail sender "zumah" --limit 50
fruitmail sender "adebola" --limit 50
fruitmail sender "@cchub" --limit 50
fruitmail sender "future africa" --limit 50
```

### 1.4 Read message body by id
```bash
fruitmail body <id>
# Example:
fruitmail body 400
```

---

## 2) Enumerate attachment names from Mail.app (AppleScript)

Use when fruitmail doesn’t expose attachment metadata clearly.

```bash
osascript <<'APPLESCRIPT'
tell application "Mail"
  set msgs to (messages of inbox whose subject contains "STATEMENT")
  repeat with m in msgs
    log "subject:" & (subject of m)
    repeat with a in mail attachments of m
      log " - " & (name of a)
    end repeat
  end repeat
end tell
APPLESCRIPT
```

Tip: Match by exact subject fragments to avoid broad noise.

---

## 3) Locate attachment files directly in Apple Mail store

Most reliable extraction method for PDFs/XLSX when AppleScript save is inconsistent.

```bash
find ~/Library/Mail/V10 -type f -name "*ILORIN TECH PARK LTD*.pdf" 2>/dev/null | head -20
find ~/Library/Mail/V10 -type f -name "*BOA_Foods_IIH_February_2026_Drinks_Ledger.pdf" 2>/dev/null | head -20
find ~/Library/Mail/V10 -type f -name "*IIH_Cafeteria_Settlement_Summary_Feb_2026.pdf" 2>/dev/null | head -20
```

Typical resolved pattern:
`~/Library/Mail/V10/<ACCOUNT_ID>/INBOX.mbox/.../Data/Attachments/<message-id>/<part>/filename.ext`

---

## 4) Save/copy report attachments to the correct IIH folder

Current canonical February source folder:

`/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports`

### 4.1 Create folder if missing
```bash
mkdir -p "/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports"
```

### 4.2 Copy files
```bash
cp -f "<mail-store-source-file>" "/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports/"
```

### 4.3 Verify
```bash
ls -la "/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/2026-02 Source Reports"
```

---

## 5) Folder discipline rule (important)

- `IIH/Archive/...` is for archived documents.
- Active monthly source-report inputs belong in:
  - `IIH/Reports/Latest-Monthly-Submissions/<YYYY-MM Source Reports>`

If files were saved to the wrong place, move immediately.

---

## 6) Common failure modes and fixes

1. **`fruitmail` can find email but not attachments**
   - Use AppleScript list + direct `find` in `~/Library/Mail/V10`.

2. **AppleScript `save` creates wrong file/overwrites unexpectedly**
   - Prefer direct filesystem copy from Mail store path.

3. **Duplicate todo/email noise**
   - Search by specific subject + sender + date window.
   - Treat repeated parser items as one thread unless new evidence appears.

4. **Missing expected email in one account**
   - Check forwards to `clawdia.ai@iih.ng` and original in `temi.kolawole@iih.ng`.

---

## 7) Minimal execution sequence (quick checklist)

1. Search message IDs with `fruitmail search`.
2. Confirm message context with `fruitmail body <id>`.
3. Enumerate attachment names via AppleScript.
4. Find exact attachment files under `~/Library/Mail/V10`.
5. Copy into `IIH/Reports/Latest-Monthly-Submissions/<month-folder>`.
6. Verify final folder listing and report completion.

---

## 8) Safety guardrails

- No outbound emails without explicit instruction.
- No secret/token dumping in logs/files.
- Keep actions auditable: cite subject/date/filepath when reporting completion.
