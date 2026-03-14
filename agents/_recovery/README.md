# Sheba + Fela Recovery Bundle

This folder contains a deterministic restore bundle for the canonical core profiles of:
- `agents/sheba`
- `agents/fela`

## Included
- `templates/sheba/*.md` (6 core files)
- `templates/fela/*.md` (6 core files)
- `manifest.sha256` checksum manifest
- `scripts/restore_sheba_fela.sh` one-command restore script

## Restore
From workspace root:

```bash
bash agents/_recovery/scripts/restore_sheba_fela.sh
```

Optional custom workspace root:

```bash
bash agents/_recovery/scripts/restore_sheba_fela.sh /path/to/workspace
```

## Verify

```bash
shasum -a 256 -c agents/_recovery/manifest.sha256
```

## Notes
- This restores **core identity/system files only** (IDENTITY, SOUL, MEMORY, TOOLS, TASKS, HEARTBEAT).
- It does not overwrite optional extended artifacts unless they are among the core files.
