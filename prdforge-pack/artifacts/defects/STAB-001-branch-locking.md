# STAB-001: Release Candidate Branch Locking

## Summary
Created and locked the release candidate branch for PRDForge v1.0 launch stabilization phase.

## Details
- **Date:** 2026-03-18 06:43 GMT+1
- **Branch Name:** `release-candidate-v1.0`
- **Source:** Created from clean `main` branch commit `8becf73` (fix: project limits enforcement and plan resolution)
- **Repository:** `/Users/clawdia/apps/prdforge`
- **Remote:** Pushed to `origin/release-candidate-v1.0`

## Protection Rules
**Branch protection should be configured in GitHub with:**
1. **Require pull request reviews before merging:** 1 approval minimum
2. **Require status checks to pass before merging:** All CI/CD checks
3. **Include administrators:** Yes (Temi has override capability)
4. **Restrict who can push to matching branches:** Only core team members
5. **Require conversation resolution before merging:** Yes
6. **Require signed commits:** Recommended but not required for v1.0

## Frozen Features
All non-critical feature development is frozen on the `release-candidate-v1.0` branch. Only the following types of changes are allowed:

### ✅ **Allowed Changes (Bug Fixes Only):**
1. **Critical security vulnerabilities** (CVSS score ≥ 7.0)
2. **Data loss or corruption issues**
3. **Authentication/authorization failures**
4. **Payment processing failures**
5. **Core functionality breakage** (PRD generation, project management)
6. **Regressions from main branch functionality**
7. **Compliance violations** (GDPR, CCPA, etc.)

### ❌ **Prohibited Changes (Feature Freeze):**
1. **New features or enhancements**
2. **UI/UX redesigns** (unless fixing critical usability issues)
3. **API breaking changes**
4. **Database schema changes** (except for critical bug fixes)
5. **New dependencies or major dependency updates**
6. **Architectural refactoring**
7. **Performance optimizations** (unless addressing critical performance issues)
8. **Documentation updates** (except for fixing incorrect information)

## Exceptions Process
Any exception to the feature freeze requires:
1. **Written justification** explaining why it's a critical bug fix
2. **Impact assessment** on release timeline
3. **Approval from:** Temi (temikolawole@gmail.com)
4. **Testing verification** before merge

## Verification
### Commands Executed:
```bash
# 1. Identified codebase location
find /Users/clawdia -type d -name "*prdforge*" -o -name "*PRDForge*"

# 2. Checked current git status
cd /Users/clawdia/apps/prdforge && git status

# 3. Listed existing branches
cd /Users/clawdia/apps/prdforge && git branch -a

# 4. Stashed uncommitted changes (documentation updates, not bug fixes)
cd /Users/clawdia/apps/prdforge && git stash

# 5. Created clean release candidate branch from main
cd /Users/clawdia/apps/prdforge && git checkout -b release-candidate-v1.0

# 6. Pushed to remote
cd /Users/clawdia/apps/prdforge && git push -u origin release-candidate-v1.0
```

### Verification Results:
- ✅ Branch `release-candidate-v1.0` exists locally and remotely
- ✅ Branch created from clean `main` state (commit 8becf73)
- ✅ No uncommitted feature changes included
- ✅ Ready for GitHub branch protection configuration

## Next Steps
1. **Configure GitHub branch protection** for `release-candidate-v1.0`
2. **Notify team** of feature freeze and branch locking
3. **Proceed to STAB-002** (resolve P0 defects)
4. **Update CI/CD pipelines** to include release candidate branch

## Notes
- The stashed changes included documentation updates and CI configuration changes that were not critical bug fixes
- Security.ts improvements were identified as bug fixes but will be evaluated separately for inclusion
- All future work on the release candidate must follow the bug-fix-only policy
- Emergency hotfix process should be documented separately