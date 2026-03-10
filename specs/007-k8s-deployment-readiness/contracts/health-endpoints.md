# API Contract: Health Check Endpoints

**Feature**: 007-k8s-deployment-readiness
**Service**: API Backend (FastAPI)

## Endpoints

### GET /health/live

Liveness probe — is the process alive?

**Response 200 OK**:
```json
{
  "status": "alive"
}
```

**Failure mode**: No response (process hung/dead) — K8s restarts pod.

---

### GET /health/ready

Readiness probe — can this instance serve traffic?

**Response 200 OK** (all dependencies connected):
```json
{
  "status": "ready",
  "database": "connected",
  "redis": "connected"
}
```

**Response 503 Service Unavailable** (one or more dependencies down):
```json
{
  "status": "not_ready",
  "database": "disconnected",
  "redis": "connected"
}
```

**Behavior**: When readiness fails, K8s removes the pod from the Service's endpoint list (stops routing traffic to it) but does NOT restart it. The pod continues running and is re-added when readiness passes again.

---

### GET /health (existing, unchanged)

Backward-compatible simple health check. Returns `{"status": "ok"}`.

Retained for external monitoring tools and the CI badge. Not used by K8s probes.
