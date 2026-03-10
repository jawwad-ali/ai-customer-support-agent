# Implementation Plan: K8s Deployment & 24/7 Readiness

**Branch**: `007-k8s-deployment-readiness` | **Date**: 2026-03-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-k8s-deployment-readiness/spec.md`

## Summary

Containerize the CRM Digital FTE platform (FastAPI backend, Next.js frontend, PostgreSQL, Redis) with Docker Compose for local development and Kubernetes manifests for orchestrated deployment. Add liveness/readiness health probes, horizontal pod autoscaling, ConfigMaps/Secrets, persistent volumes, and auto-initialization of the database — enabling the system to self-heal, scale, and survive the hackathon's 24-hour chaos test on a local cluster.

## Technical Context

**Language/Version**: Python 3.12+ (backend), TypeScript/Node 22 (frontend)
**Primary Dependencies**: FastAPI, OpenAI Agents SDK, asyncpg, redis, Next.js 16, React 19
**Storage**: PostgreSQL 16 + pgvector (containerized), Redis 7 (ephemeral cache)
**Testing**: pytest (backend), Vitest (frontend) — existing tests, no new test code in this feature
**Target Platform**: Local machine — Docker Desktop with built-in K8s or Minikube
**Project Type**: Web application (backend + frontend + infrastructure)
**Performance Goals**: 120s full startup, 30s pod recovery, 99.9% uptime under chaos
**Constraints**: Local-only (no cloud), no Kafka, no TLS, no Ingress controller
**Scale/Scope**: 1-5 API replicas, 1 frontend, 1 PostgreSQL, 1 Redis

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Agent-First Architecture | PASS | No agent changes — deployment only |
| II. PostgreSQL as CRM | PASS | PostgreSQL containerized with PVC, no external CRM |
| III. Channel-Agnostic Core | PASS | No channel logic changes |
| IV. Async-First | PASS | uvicorn stays async, no sync changes |
| V. Secrets-Free Codebase | PASS | FR-008: secrets in K8s Secrets, not code |
| VI. Structured Observability | PASS | Logging unchanged, health endpoints added |
| VII. Graceful Degradation | PASS | Readiness probe checks dependencies, sync fallback preserved |

**Post-Phase 1 re-check**: All gates still pass. Health endpoints follow structured JSON output (Principle VI). Secrets managed externally (Principle V).

## Project Structure

### Documentation (this feature)

```text
specs/007-k8s-deployment-readiness/
├── plan.md              # This file
├── research.md          # Phase 0 output — 8 decisions documented
├── data-model.md        # Phase 1 output — service topology, config surface, resource budgets
├── quickstart.md        # Phase 1 output — Docker Compose + K8s deploy instructions
├── contracts/
│   └── health-endpoints.md  # Phase 1 output — /health/live and /health/ready contracts
└── tasks.md             # Phase 2 output (/sp.tasks command)
```

### Source Code (repository root)

```text
# New files to create
Dockerfile                        # Multi-stage Python build (API backend)
web/Dockerfile                    # Multi-stage Node build (Next.js frontend)
.dockerignore                     # Exclude .venv, node_modules, .git, etc.
web/.dockerignore                 # Exclude node_modules, .next, etc.
docker-compose.yml                # 4 services: api, web, postgres, redis
database/migrations/init.sh       # Init script: run schema + seed (for init container)

k8s/
├── namespace.yml                 # crm namespace
├── configmap.yml                 # crm-config (REDIS_URL, OPENAI_MODEL, etc.)
├── secret.yml                    # crm-secrets placeholder (OPENAI_API_KEY, POSTGRES_PASSWORD)
├── postgres-pvc.yml              # PersistentVolumeClaim for database data
├── postgres-deployment.yml       # PostgreSQL 16 + pgvector StatefulSet
├── postgres-service.yml          # ClusterIP service for postgres
├── redis-deployment.yml          # Redis 7 Deployment
├── redis-service.yml             # ClusterIP service for redis
├── api-deployment.yml            # API Deployment (1-5 replicas, health probes, init container)
├── api-service.yml               # ClusterIP service for API
├── api-hpa.yml                   # HorizontalPodAutoscaler (CPU-based)
├── web-deployment.yml            # Web frontend Deployment
└── web-service.yml               # NodePort service for web (external access)

# Modified files
api/main.py                       # Add /health/live and /health/ready endpoints
```

**Structure Decision**: Infrastructure-as-code files live at repo root (`Dockerfile`, `docker-compose.yml`) and in a dedicated `k8s/` directory. No changes to existing `agent/`, `web/src/`, or `tests/` code beyond health endpoint additions.

## Implementation Phases

### Phase 1: Dockerfiles + Compose (User Story 1 — P1)

Create container images and docker-compose for single-command startup.

**Tasks**:
1. Create `.dockerignore` and `web/.dockerignore`
2. Create `Dockerfile` (API) — multi-stage: install deps with uv, copy source, run uvicorn
3. Create `web/Dockerfile` (frontend) — multi-stage: npm ci, build, serve with `next start`
4. Create `database/migrations/init.sh` — runs schema SQL + seed script
5. Create `docker-compose.yml` — 4 services with health checks, depends_on, volumes
6. Test: `docker compose up --build` starts all services, web form works end-to-end

### Phase 2: Health Endpoints (User Story 4 — P2)

Add liveness and readiness probes to the API.

**Tasks**:
7. Add `GET /health/live` endpoint — returns `{"status": "alive"}`
8. Add `GET /health/ready` endpoint — verifies DB + Redis connectivity, returns 200 or 503
9. Keep existing `GET /health` unchanged (backward compatibility)
10. Test: health endpoints return correct responses when dependencies are up/down

### Phase 3: Kubernetes Manifests (User Stories 2, 3, 5 — P1/P2/P3)

Create all K8s manifests for orchestrated deployment.

**Tasks**:
11. Create `k8s/namespace.yml` — `crm` namespace
12. Create `k8s/configmap.yml` — non-sensitive config (REDIS_URL, OPENAI_MODEL)
13. Create `k8s/secret.yml` — placeholder for OPENAI_API_KEY, POSTGRES_PASSWORD
14. Create `k8s/postgres-pvc.yml` + `k8s/postgres-deployment.yml` + `k8s/postgres-service.yml`
15. Create `k8s/redis-pvc.yml` + `k8s/redis-deployment.yml` + `k8s/redis-service.yml` (AOF persistence + PVC)
16. Create `k8s/api-deployment.yml` — with init container (migrations), health probes, resource limits
17. Create `k8s/api-service.yml` — ClusterIP
18. Create `k8s/api-hpa.yml` — HPA targeting 70% CPU, min 1, max 5 replicas
19. Create `k8s/web-deployment.yml` + `k8s/web-service.yml` — NodePort for external access
20. Test: `kubectl apply -f k8s/` deploys all resources, pods reach Ready state

### Phase 4: Validation & Chaos Testing

Verify self-healing, scaling, and data persistence.

**Tasks**:
21. Verify: kill an API pod → auto-restarts within 30s
22. Verify: scale API to 3 replicas → all serve traffic
23. Verify: restart postgres pod → data persists (PVC)
24. Verify: HPA scales up when load increases
25. Update quickstart.md with final tested commands

## Complexity Tracking

No constitution violations. No complexity justifications needed.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| pgvector extension not in default postgres image | Medium | High | Use `pgvector/pgvector:pg16` image or init script to `CREATE EXTENSION` |
| KB seed script needs OpenAI API at startup | High | Medium | Make seeding optional (skip if `OPENAI_API_KEY` not set, or pre-generate embeddings) |
| Docker Desktop K8s resource constraints | Medium | Medium | Conservative resource limits (256Mi-512Mi per pod) |
| `NEXT_PUBLIC_API_URL` baked at build time | Low | Low | Document that web image must be rebuilt if API URL changes |
