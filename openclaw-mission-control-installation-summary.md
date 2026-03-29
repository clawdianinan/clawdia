# OpenClaw Mission Control Installation

**Date:** 2026-03-29  
**Status:** ✅ Complete  
**Deployment Mode:** Docker  
**Installation Location:** `/Users/clawdia/.openclaw/workspace/openclaw-mission-control`

## Access URLs

- **Frontend UI:** http://localhost:3001
- **Backend API:** http://localhost:8000
- **Health Check:** http://localhost:8000/healthz

## Authentication

- **Mode:** Local
- **Auth Token:** See `.env` file: `openclaw-mission-control/.env` (LOCAL_AUTH_TOKEN)
- **Token Usage:** Include as Bearer token in API requests: `Authorization: Bearer <token>`

## Running Containers

```
openclaw-mission-control-frontend-1   Up   0.0.0.0:3001->3000/tcp
openclaw-mission-control-backend-1    Up   0.0.0.0:8000->8000/tcp
openclaw-mission-control-db-1         Up   (healthy) PostgreSQL
openclaw-mission-control-redis-1      Up   (healthy) Redis
openclaw-mission-control-webhook-worker-1 Up RQ worker
```

## Management Commands

**Stop services:**
```bash
cd openclaw-mission-control
docker compose -f compose.yml --env-file .env down
```

**View logs:**
```bash
docker compose -f compose.yml --env-file .env logs -f
```

**Restart services:**
```bash
docker compose -f compose.yml --env-file .env restart
```

## Configuration

- Environment file: `openclaw-mission-control/.env`
- Backend env: `openclaw-mission-control/backend/.env`
- Frontend env: `openclaw-mission-control/frontend/.env`

**Note:** Frontend port was changed from 3000 to 3001 due to port conflict with existing Supabase instance.

## Next Steps

1. Access http://localhost:3001 to use the Mission Control UI
2. Log in with the LOCAL_AUTH_TOKEN as the initial credential
3. Configure organizations, board groups, and agents as needed
4. Connect gateways for distributed runtime environments

## Documentation

- Repository: https://github.com/abhi1693/openclaw-mission-control
- Local docs: `openclaw-mission-control/docs/`
