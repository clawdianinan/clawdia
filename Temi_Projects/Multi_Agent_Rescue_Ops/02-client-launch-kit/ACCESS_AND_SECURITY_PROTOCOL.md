# Access & Security Protocol (Client-Ready)

1. Use dedicated service accounts only (no personal logins).
2. All credentials must be temporary and revocable.
3. Default to least privilege; escalate only if required.
4. All production changes require:
   - approved change note
   - rollback path
   - verification checklist
5. On closure:
   - revoke issued credentials
   - rotate exposed tokens if applicable
   - share final incident summary

## Access Tiers
- Tier A: Evidence only (logs/config export/screenshots)
- Tier B: Read-only diagnostic access
- Tier C: Time-boxed admin access for restoration
