# Clawdia Branch Strategy

## Branch roles

- `main`
  - Mirror of `upstream/main` (official OpenClaw).
  - No custom commits.
  - Updated by sync process.

- `clawdia/main`
  - Stable Clawdia customization branch.
  - Production-ready custom behavior.

- `clawdia/dev`
  - Active development branch for new features.
  - Open PRs from `clawdia/dev` -> `clawdia/main`.

## Sync model

1. Update mirror `main` from `upstream/main`.
2. Rebase `clawdia/main` on latest `main`.
3. Rebase `clawdia/dev` on latest `clawdia/main`.

Use `./SYNC_UPSTREAM.sh` to run this flow.

## Daily workflow

```bash
# start work
git checkout clawdia/dev
git pull

# create feature branch
git checkout -b feature/<name>

# after work
git push -u origin feature/<name>
# open PR: feature/<name> -> clawdia/dev
```

## Release workflow

- Merge approved changes into `clawdia/dev`.
- Promote tested changes from `clawdia/dev` to `clawdia/main` via PR.
- Keep `main` reserved for upstream mirror only.

## Automated Sync (GitHub Actions)

Workflow: `.github/workflows/upstream-sync.yml`

- Runs every 6 hours and on manual dispatch.
- Opens/updates PRs for:
  1. `main` <= `upstream/main`
  2. `clawdia/main` <= `main`
  3. `clawdia/dev` <= `clawdia/main`

This keeps your custom branches cleanly layered while preserving review control.
