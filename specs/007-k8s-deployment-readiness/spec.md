# Feature Specification: K8s Deployment & 24/7 Readiness

**Feature Branch**: `007-k8s-deployment-readiness`
**Created**: 2026-03-10
**Status**: Draft
**Input**: User description: "K8s deployment, 24/7 readiness — containerize all services, deploy locally with Kubernetes, ensure the AI agent survives failures and scales without human intervention"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One-Command Local Startup (Priority: P1)

A developer clones the repository and wants to run the entire platform (backend API, frontend, database, and cache) locally with a single command, without installing individual dependencies on their host machine.

**Why this priority**: Without containerization, no other deployment or readiness story is possible. This is the foundation.

**Independent Test**: Can be fully tested by running the single startup command on a fresh machine with only container tooling installed, then opening the web form and submitting a support request.

**Acceptance Scenarios**:

1. **Given** a freshly cloned repository with container tooling installed, **When** the developer runs the startup command, **Then** all services (API, frontend, database, cache) start and become reachable within 120 seconds.
2. **Given** the platform is running via containers, **When** the developer opens the web form at its published port, **Then** they can submit a support request and receive an AI-generated response.
3. **Given** no prior database setup, **When** containers start for the first time, **Then** the database schema and seed data are automatically initialized.

---

### User Story 2 - Survive Service Restarts (Priority: P1)

An operator needs confidence that if any single service crashes or is killed, the platform recovers automatically without losing in-flight requests or requiring manual intervention.

**Why this priority**: 24/7 availability is the core promise of the Digital FTE. Self-healing is non-negotiable.

**Independent Test**: Can be tested by killing a running API service instance and verifying it restarts automatically, with subsequent requests succeeding within the recovery window.

**Acceptance Scenarios**:

1. **Given** the platform is running and healthy, **When** the API service is killed, **Then** it restarts automatically within 30 seconds and begins serving requests again.
2. **Given** a support request is in-flight when the API service restarts, **When** the client polls for the job result, **Then** it receives either the completed result or a clear "try again" response (no silent data loss).
3. **Given** the cache service is unavailable, **When** a support request arrives, **Then** the system falls back to synchronous processing mode and still returns a valid response.
4. **Given** the database service restarts, **When** it becomes healthy again, **Then** the API reconnects automatically without operator intervention.

---

### User Story 3 - Horizontal Scaling (Priority: P2)

An operator needs to scale the API service to multiple instances to handle increased load, and scale it back down during quiet periods, without downtime or configuration changes.

**Why this priority**: Scaling is required for production readiness and the hackathon's chaos testing (100+ web submissions, pod kills every 2 hours).

**Independent Test**: Can be tested by scaling the API to 3 replicas, sending concurrent requests, and verifying all are served correctly with load distributed.

**Acceptance Scenarios**:

1. **Given** the platform is running with 1 API instance, **When** the operator scales to 3 instances, **Then** all 3 become healthy and begin serving requests within 60 seconds.
2. **Given** 3 API instances are running, **When** concurrent support requests arrive, **Then** requests are distributed across instances (no single instance receives all traffic).
3. **Given** 3 API instances are running, **When** the operator scales down to 1, **Then** the remaining instance continues serving requests without interruption.
4. **Given** auto-scaling rules are configured, **When** request volume exceeds the defined threshold, **Then** additional instances are created automatically (up to the configured maximum).

---

### User Story 4 - Health Monitoring & Liveness (Priority: P2)

The orchestrator needs health check endpoints to determine whether each service is alive and ready to serve traffic, so it can automatically route traffic away from unhealthy instances and restart failed ones.

**Why this priority**: Health checks are the mechanism that enables self-healing. Without them, the orchestrator cannot distinguish healthy from unhealthy instances.

**Independent Test**: Can be tested by querying the health endpoints and verifying correct responses, then simulating a failure and confirming the orchestrator detects it.

**Acceptance Scenarios**:

1. **Given** the API service is running normally, **When** the health endpoint is called, **Then** it returns a success response within 1 second.
2. **Given** the API service cannot connect to the database, **When** the readiness endpoint is called, **Then** it returns a failure response, and the orchestrator stops routing traffic to that instance.
3. **Given** an API instance enters a hung state, **When** the liveness check fails 3 consecutive times, **Then** the orchestrator kills and restarts the instance.

---

### User Story 5 - Configuration & Secrets Management (Priority: P3)

An operator needs to manage environment-specific configuration (database connection, API keys, service URLs) separately from the application code, so that the same container images work across different environments without rebuilds.

**Why this priority**: Separating config from code is a prerequisite for portable deployments, but the platform already functions with environment variables, so this is an enhancement.

**Independent Test**: Can be tested by changing a configuration value (e.g., log level) and verifying the running service picks it up without rebuilding the container image.

**Acceptance Scenarios**:

1. **Given** configuration values are defined externally, **When** containers start, **Then** the application reads all config from the external source (not from hardcoded values).
2. **Given** sensitive values (API keys, database passwords), **When** they are stored, **Then** they are kept in a dedicated secrets store, not in plain text config files or version control.
3. **Given** a configuration value is changed, **When** the service is restarted (not rebuilt), **Then** it picks up the new value.

---

### Edge Cases

- What happens when the database container runs out of disk space? The system should log the error and return graceful error responses rather than crashing.
- What happens when two API instances try to process the same background job? The job store (Redis) ensures atomic read-and-claim, so duplicate processing does not occur.
- What happens when the container orchestrator itself is restarted? All managed services should restart automatically once the orchestrator recovers.
- What happens when a container image pull fails during scaling? The orchestrator should retry with backoff and report the failure via events, not leave the deployment in a broken state.
- What happens when the frontend container starts before the API is ready? The frontend should handle API unavailability gracefully (it already shows error states) and recover when the API becomes available.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST package each service (API backend, web frontend, database, cache) as an independent container with a defined image.
- **FR-002**: System MUST provide a single-command local startup that launches all services together with correct networking and dependency ordering.
- **FR-003**: System MUST automatically initialize the database schema and seed data on first startup (no manual SQL execution required).
- **FR-004**: System MUST expose health check endpoints (liveness and readiness) on the API service that the orchestrator can poll.
- **FR-005**: System MUST restart any failed service automatically within 30 seconds without human intervention.
- **FR-006**: System MUST support scaling the API service from 1 to at least 5 replicas without configuration changes or downtime.
- **FR-007**: System MUST distribute incoming requests across all healthy API replicas.
- **FR-008**: System MUST store all sensitive configuration (API keys, database passwords) in a dedicated secrets mechanism, never in plain text files or container images.
- **FR-009**: System MUST store non-sensitive configuration (service URLs, feature flags, log levels) in external config separate from the container image.
- **FR-010**: System MUST persist database data across container restarts (data must not be lost when a container stops and restarts).
- **FR-011**: System MUST define resource limits (memory, CPU) for each service to prevent a single misbehaving service from starving others.
- **FR-012**: System MUST support auto-scaling the API service based on resource utilization (e.g., when average utilization exceeds 70%, add instances up to a defined maximum).
- **FR-013**: System MUST provide orchestrator manifests that define all services, networking, scaling rules, and health checks in version-controlled declarative files.

### Key Entities

- **Service**: A deployable unit (API, frontend, database, cache) with its own container image, resource limits, health checks, and scaling rules.
- **Configuration**: Non-sensitive key-value pairs consumed by services at startup (connection strings, log levels, feature flags).
- **Secret**: Sensitive credential consumed by services (API keys, database passwords) stored separately from configuration.
- **Health Check**: A periodic probe (liveness or readiness) that the orchestrator uses to determine service health and trigger restarts or traffic rerouting.
- **Scaling Rule**: A policy that defines when to add or remove service instances based on resource utilization thresholds.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All services start and become reachable within 120 seconds of running the startup command on a machine with only container tooling installed.
- **SC-002**: A killed API instance is automatically restarted and serving requests within 30 seconds.
- **SC-003**: The system handles 100+ support requests over 24 hours across 3 API replicas with zero message loss.
- **SC-004**: Scaling from 1 to 3 API replicas completes within 60 seconds, with all replicas healthy and serving traffic.
- **SC-005**: Random service kills every 2 hours over a 24-hour period result in zero unrecoverable failures (system self-heals every time).
- **SC-006**: System uptime exceeds 99.9% during the 24-hour chaos test (less than 86 seconds total downtime).
- **SC-007**: Database data persists across container restarts — no customer records, tickets, or conversations are lost.
- **SC-008**: No sensitive credentials are stored in plain text in the repository or container images.

## Assumptions

- The target environment is a local developer machine running Docker Desktop with its built-in Kubernetes, or Minikube. No cloud provider is required.
- The existing `/health` endpoint on the API service can be extended for liveness/readiness checks without breaking current behavior.
- The database schema migration scripts already exist and can be executed automatically via a container init process.
- Redis is used for async job management (not Kafka) — this is an intentional architectural decision documented in the project, and the deployment will reflect this.
- The frontend is a static Next.js build served by its own container, proxying API requests to the backend service.
- Resource limits will use conservative defaults suitable for local development (e.g., 256Mi-512Mi memory per service), not production cloud sizing.

## Scope Boundaries

### In Scope

- Containerization of all services (API, frontend, database, cache)
- Docker Compose for single-command local development
- Kubernetes manifests for orchestrated deployment (local cluster)
- Health checks (liveness + readiness) on the API service
- Auto-restart and self-healing via orchestrator
- Horizontal scaling (HPA) for the API service
- ConfigMaps and Secrets for configuration management
- Persistent volume for database data
- Resource limits and requests for all containers
- Database auto-initialization on first startup

### Out of Scope

- Cloud provider deployment (AWS EKS, GCP GKE, Azure AKS)
- CI/CD pipeline integration (GitHub Actions already handles tests separately)
- TLS/SSL certificate management
- External Ingress controller or load balancer (use NodePort/port-forward locally)
- Kafka integration (Redis handles async processing)
- Production-grade monitoring stack (Prometheus, Grafana) — basic health checks only
- Multi-node cluster setup (single-node local cluster is sufficient)
