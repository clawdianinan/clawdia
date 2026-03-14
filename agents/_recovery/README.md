# Sheba + Fela Recovery Bundle

This folder contains a deterministic restore bundle for the canonical core profiles of:
- `agents/sheba`
- `agents/fela`

## Included
- `templates/sheba/*.md` (6 core files)
- `templates/fela/*.md` (6 core files)
- `manifest.sha256` checksum manifest
- `scripts/restore_sheba_fela.sh` one-command restore script

## Backup (dynamic, all agents)
From workspace root:

```bash
bash agents/_recovery/scripts/backup_all_agents.sh
```

Optional custom workspace root:

```bash
bash agents/_recovery/scripts/backup_all_agents.sh /path/to/workspace
```

This command automatically captures **all current agent folders** (excluding internal `_recovery`) and updates:
- `templates/<agent>/...`
- `agents.index`
- `manifest.sha256`
- `archives/latest_agents_recovery_bundle.tar.gz`

Any newly created agent is included the next time this command runs.

## Restore (dynamic, all agents)

```bash
bash agents/_recovery/scripts/restore_all_agents.sh
```

Optional custom workspace root:

```bash
bash agents/_recovery/scripts/restore_all_agents.sh /path/to/workspace
```

## Legacy targeted restore
For only Sheba + Fela core files:

```bash
bash agents/_recovery/scripts/restore_sheba_fela.sh
```

## Verify

```bash
shasum -a 256 -c agents/_recovery/manifest.sha256
```

## Notes
- Dynamic backup snapshots agent config/system files (`.md/.json/.yaml/.yml`) into recovery templates.
- Full recovery bundle archives are also produced under `agents/_recovery/archives/`.
