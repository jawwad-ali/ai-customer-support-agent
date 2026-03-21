# Research: K8s Deployment & 24/7 Readiness

**Date**: 2026-03-10
**Feature**: 007-k8s-deployment-readiness

## Current State Findings

### Existing Infrastructure

- **No Dockerfile** exists anywhere in the repo
- **No docker-compose.yml** exists
- **No k8s/ directory** exists
- Everything must be created from scratch

### Health Endpoint

- Exists at `GET /health` in `api/main.py:154-156`
- Returns `{"status": "ok"}` — simple liveness check
- Does NOT verify database or Redis connectivity (needs readiness extension)

### Backend (Python)

- **Python 3.12+** required (`pyproject.toml`)
- **Package manager**: `uv` (not pip)
- **ASGI server**: `uvicorn[standard]>=0.34.0`
- **Key deps**: `fastapi>=0.115.0`, `asyncpg>=0.30.0`, `redis[hiredis]>=5.0.0`, `openai-agents>=0.0.16`
- **Entry point**: `uvicorn api.main:app --host 0.0.0.0 --port 8000`

### Frontend (Next.js)

- **Node 20+** required (Next.js 16.1.6 + React 19.2.3)
- **Build**: `npm run build` produces `.next/` directory
- **Start**: `npm run start` serves production build on port 3000
- **API URL**: configured via `NEXT_PUBLIC_API_URL` env var (build-time)
- **No proxy rewrites** configured in `next.config.ts` currently

### Database Migrations

- `database/migrations/001_initial_schema.sql` — 8 tables, pgvector extension, idempotent (IF NOT EXISTS)
- `database/migrations/002_seed_knowledge_base.py` — 19 KB articles with embeddings, idempotent (ON CONFLICT DO NOTHING)
- `database/migrations/run_migration.py` — runner script, needs `DATABASE_URL`
- Seeder also needs `OPENAI_API_KEY` for embedding generation

### Environment Variables

| Variable | Source | K8s Resource |
|----------|--------|-------------|
| `OPENAI_API_KEY` | Required | Secret |
| `DATABASE_URL` | Required | Secret |
| `REDIS_URL` | Required | ConfigMap |
| `OPENAI_MODEL` | Optional (default: gpt-4o) | ConfigMap |
| `NEXT_PUBLIC_API_URL` | Required (build-time) | ConfigMap |

## Decisions

### Decision 1: Container Base Images

- **API**: `python:3.12-slim` — small footprint, uv for fast installs
- **Web**: `node:22-alpine` — matches CI (Node 22), minimal image
- **Rationale**: slim/alpine variants reduce image size. No need for full images.
- **Alternatives rejected**: `python:3.12-alpine` (asyncpg compilation issues with musl)

### Decision 2: Docker Compose for Local Dev

- **Decision**: Create `docker-compose.yml` with 4 services (api, web, postgres, redis)
- **Rationale**: Single-command startup (`docker compose up`), matches FR-002
- **Alternatives rejected**: Tilt, Skaffold (overkill for local dev)

### Decision 3: Kubernetes Structure

- **Decision**: Flat `k8s/` directory with named manifests (no Helm, no Kustomize)
- **Rationale**: Hackathon project, local-only. Helm/Kustomize adds complexity without benefit.
- **Alternatives rejected**: Helm charts (too heavy), Kustomize overlays (no multi-env needed)

### Decision 4: Database Initialization

- **Decision**: Init container on API deployment that runs migration scripts
- **Rationale**: Runs once before API starts, idempotent, doesn't block API startup on subsequent restarts
- **Alternatives rejected**: Sidecar (runs continuously), lifespan hook (runs on every pod start, harder to debug)

### Decision 5: Health Check Strategy

- **Decision**: Split existing `/health` into two endpoints: `/health/live` (process alive) and `/health/ready` (dependencies connected)
- **Rationale**: K8s liveness and readiness probes serve different purposes. Liveness = restart if dead. Readiness = stop traffic if dependencies down.
- **Alternatives rejected**: Single `/health` for both (can't distinguish "needs restart" from "temporarily degraded")

### Decision 6: Frontend API Communication in K8s

- **Decision**: Frontend uses `NEXT_PUBLIC_API_URL` baked at build time. In K8s, set to `/api` and use a reverse proxy or direct service URL.
- **Rationale**: Next.js client-side code needs the URL at build time. In docker-compose, use `http://api:8000`. In K8s, the browser needs a routable URL.
- **Alternatives rejected**: Server-side proxy (adds latency, Next.js SSR complexity)

### Decision 7: PostgreSQL in K8s

- **Decision**: Use official `postgres:16` image with a PersistentVolumeClaim for data
- **Rationale**: Matches existing schema (pgvector extension). PVC ensures data survives pod restarts (FR-010).
- **Alternatives rejected**: External managed DB (out of scope — local only)

### Decision 8: Redis in K8s

- **Decision**: Use `redis:7-alpine` with AOF persistence and a PersistentVolumeClaim
- **Rationale**: Redis stores in-flight background job states. If Redis restarts empty, clients polling for job results would never get a response. AOF persistence + PVC ensures job data and cache entries survive pod restarts. Redis availability is critical — downtime is not acceptable.
- **Alternatives rejected**: Ephemeral Redis without PVC (loses in-flight jobs on restart, unacceptable for 24/7 reliability)
