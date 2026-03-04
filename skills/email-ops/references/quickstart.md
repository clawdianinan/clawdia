# Email Ops Quickstart

## 10-command sequence

```bash
# 1) Find candidate emails
fruitmail search --days 7 --limit 30

# 2) Narrow by subject/sender
fruitmail search --subject "REQUEST FOR STATEMENT" --days 7 --limit 20
fruitmail sender "zumah" --limit 50

# 3) Inspect body
fruitmail body <id>

# 4) List attachments via Mail
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

# 5) Locate attachment in Mail store
find ~/Library/Mail/V10 -type f -name "*keyword*" 2>/dev/null | head -20

# 6) Ensure destination exists
mkdir -p "<destination-folder>"

# 7) Copy file to destination
cp -f "<source-file>" "<destination-folder>/"

# 8) Verify destination
ls -la "<destination-folder>"

# 9) If wrong folder used, move now
mv -f "<wrong-path-file>" "<destination-folder>/"

# 10) Report completion with evidence
```

## Attachment extraction fallback

If Mail script save is inconsistent, do not use `save`; copy directly from Mail store path.
