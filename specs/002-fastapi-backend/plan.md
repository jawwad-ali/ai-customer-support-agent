# Implementation Plan: FastAPI Backend

**Branch**: `002-fastapi-backend` | **Date**: 2026-02-23 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-fastapi-backend/spec.md`

## Summary

Build the FastAPI HTTP layer that exposes the Customer Success Agent as a production API. The API receives messages from the web form frontend (and channel webhooks), passes them to the already-built agent via `run_agent()`, and returns responses. Read-only endpoints reuse existing tool functions via `on_invoke_tool()`. Lifespan management creates a shared `AgentContext` on startup.

## Technical Context

**Language/Version**: Python 3.12+
**Primary Dependencies**: fastapi, uvicorn[standard], httpx (dev)
**Existing Dependencies**: openai-agents, asyncpg, openai, pydantic, python-dotenv
**Storage**: PostgreSQL 16 + pgvector (Neon) — already deployed from 001
**Testing**: pytest + pytest-asyncio + httpx AsyncClient
**Target Platform**: Linux server / Docker container
**Performance Goals**: P95 response time < 3 seconds (same as agent)
**Constraints**: No authentication for MVP, CORS for frontend access

## Constitution Check

| # | Principle | Status | Evidence |
|---|-----------|--------|----------|
| I | Agent-First Architecture | PASS | API is a thin HTTP wrapper — all logic stays in the agent and its tools |
| II | PostgreSQL as CRM | PASS | No new tables — API reads from existing schema via tool reuse |
| III | Channel-Agnostic Core | PASS | Channel is a request parameter — the agent handles channel-specific behavior |
| IV | Async-First | PASS | FastAPI is async, `run_agent()` is async, all DB via asyncpg |
| V | Secrets-Free Codebase | PASS | DATABASE_URL and OPENAI_API_KEY from env vars via `build_context()` |
| VI | Structured Observability | PASS | Per-request `correlation_id` via ContextVar; JSON logging from 001 |
| VII | Graceful Degradation | PASS | Global exception handler returns JSON; agent tools have error fallbacks |

**Result**: All gates PASS.

## Project Structure

### Documentation (this feature)

```text
specs/002-fastapi-backend/
├── plan.md                      # This file
├── spec.md                      # Feature specification
├── research.md                  # Technology decisions
├── contracts/
│   └── endpoint-contracts.md    # Request/response contracts
├── quickstart.md                # Setup instructions
└── tasks.md                     # Task breakdown
```

### Source Code (repository root)

```text
api/
├── __init__.py
└── main.py                      # FastAPI application (lifespan, routes, models)

tests/
├── test_api/
│   ├── __init__.py
│   └── test_main.py             # API endpoint tests
```

### Modified Files

```text
pyproject.toml                   # Add fastapi, uvicorn, httpx; add "api*" to packages
```

**Structure Decision**: Single file (`api/main.py`) for all routes. The API has only 6 endpoints — splitting into multiple route files would be over-engineering. If the API grows beyond 10 endpoints, split into `api/routes/chat.py`, `api/routes/webhooks.py`, etc.

## Key Reuse Points

| What | Where | How |
|------|-------|-----|
| Agent invocation | `agent.customer_success_agent.run_agent` | Call directly in chat/webhook handlers |
| DB pool + OpenAI client | `agent.context.build_context` | Call once in lifespan startup |
| Correlation ID | `agent.set_correlation_id` | Call at start of each request handler |
| Ticket lookup | `agent.tools.ticket.get_ticket` | Call via `on_invoke_tool()` |
| Customer history | `agent.tools.customer.get_customer_history` | Call via `on_invoke_tool()` |
| Pydantic | Already in deps | Request/response models |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| (none)    | —          | —                                    |
