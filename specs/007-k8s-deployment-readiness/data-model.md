# Data Model: K8s Deployment & 24/7 Readiness

**Date**: 2026-03-10
**Feature**: 007-k8s-deployment-readiness

## Overview

This feature introduces no new database entities. All existing tables (customers, tickets, conversations, messages, knowledge_base, channel_configs, agent_metrics, customer_identifiers) remain unchanged.

The "data model" for this feature is the **deployment topology** — the services, their relationships, and their configuration surface.

## Service Topology

```
┌─────────────────────────────────────────────────────┐
│                   K8s Namespace: crm                │
│                                                     │
│  ┌─────────┐    ┌─────────┐    ┌──────────────┐    │
│  │   web   │───▶│   api   │───▶│  postgresql   │    │
│  │ (1 pod) │    │(1-5 pods│    │  (1 pod +PVC) │    │
│  │ :3000   │    │  :8000) │    │  :5432        │    │
│  └─────────┘    └────┬────┘    └──────────────┘    │
│                      │                              │
│                      ▼                              │
│                 ┌─────────┐                         │
│                 │  redis  │                         │
│                 │ (1 pod) │                         │
│                 │ :6379   │                         │
│                 └─────────┘                         │
└─────────────────────────────────────────────────────┘
```

## Configuration Surface

### ConfigMap: `crm-config`

| Key | Default | Used By |
|-----|---------|---------|
| `OPENAI_MODEL` | `gpt-4o` | api |
| `REDIS_URL` | `redis://redis:6379` | api |
| `DATABASE_URL` | (from secret) | api |
| `NEXT_PUBLIC_API_URL` | `http://api:8000` | web (build-time) |

### Secret: `crm-secrets`

| Key | Used By |
|-----|---------|
| `OPENAI_API_KEY` | api |
| `POSTGRES_PASSWORD` | postgresql, api |

## Health Check Contracts

### Liveness Probe: `GET /health/live`

- **Purpose**: Is the process alive and responsive?
- **Response (healthy)**: `200 {"status": "alive"}`
- **Response (unhealthy)**: No response / timeout
- **K8s config**: `periodSeconds: 10`, `failureThreshold: 3`

### Readiness Probe: `GET /health/ready`

- **Purpose**: Can this instance serve traffic? (dependencies connected)
- **Response (ready)**: `200 {"status": "ready", "database": "connected", "redis": "connected"}`
- **Response (not ready)**: `503 {"status": "not_ready", "database": "disconnected"}`
- **K8s config**: `periodSeconds: 5`, `failureThreshold: 2`

## Resource Budgets

| Service | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---------|-------------|-----------|----------------|--------------|
| api | 100m | 500m | 256Mi | 512Mi |
| web | 50m | 200m | 128Mi | 256Mi |
| postgresql | 100m | 500m | 256Mi | 512Mi |
| redis | 50m | 200m | 128Mi | 256Mi |
