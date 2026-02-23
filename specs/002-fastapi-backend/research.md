# Research: FastAPI Backend

**Feature Branch**: `002-fastapi-backend`
**Date**: 2026-02-23

## Decision 1: Web Framework — FastAPI

**Decision**: Use FastAPI as the HTTP framework.

**Rationale**: FastAPI is specified in the hackathon tech stack (spec line 221). It provides native async support (critical since our agent and DB driver are async), automatic OpenAPI docs, Pydantic model validation, and dependency injection. It integrates naturally with our existing async codebase.

**Alternatives considered**:
- Flask — synchronous by default, would require ASGI adapter for async
- Starlette — FastAPI is built on Starlette; using Starlette directly adds boilerplate without benefit
- Django — too heavy for an API-only service, ORM would conflict with asyncpg

**Key patterns**:
- `@asynccontextmanager` lifespan for startup/shutdown
- `app.state` for sharing `AgentContext` across requests
- Pydantic `BaseModel` for request/response validation
- `Depends()` for dependency injection

## Decision 2: ASGI Server — Uvicorn

**Decision**: Use uvicorn with standard extras for production serving.

**Rationale**: Uvicorn is the recommended ASGI server for FastAPI. The `[standard]` extra includes uvloop and httptools for optimal performance. It supports `--reload` for development.

**Alternatives considered**:
- Gunicorn with uvicorn workers — better for multi-process production, but adds complexity not needed for hackathon
- Hypercorn — compatible alternative, but uvicorn has better FastAPI integration and documentation
- Daphne — Django-focused, not relevant

## Decision 3: Lifespan Management

**Decision**: Use FastAPI's lifespan context manager to create and destroy `AgentContext`.

**Rationale**: The `AgentContext` (DB pool + OpenAI client) must be created once on startup and cleaned up on shutdown. FastAPI's lifespan is the idiomatic way to do this. It replaces the deprecated `@app.on_event("startup/shutdown")` pattern.

**Pattern**:
```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.agent_ctx = await build_context()
    yield
    await app.state.agent_ctx.db_pool.close()

app = FastAPI(lifespan=lifespan)
```

## Decision 4: Correlation ID Strategy

**Decision**: Call `set_correlation_id()` from `agent/__init__.py` at the start of every request handler.

**Rationale**: The correlation ID lives in a Python `ContextVar`, which is automatically scoped to the current asyncio task. Each FastAPI request runs in its own task, so per-request tracing works without middleware. This reuses the existing infrastructure from 001.

**Alternatives considered**:
- Middleware-based correlation ID — adds complexity, ContextVar approach is simpler
- X-Request-ID header extraction — nice-to-have, but not needed for MVP

## Decision 5: Tool Reuse for Read Endpoints

**Decision**: Reuse existing `@function_tool` functions via `on_invoke_tool()` for ticket and customer lookup endpoints.

**Rationale**: `get_ticket` and `get_customer_history` already implement the DB queries, error handling, and JSON serialization. Duplicating these queries in the API layer would violate DRY and create maintenance burden. The `on_invoke_tool()` pattern is already used in `agent/__main__.py`.

**Pattern**:
```python
from agents import RunContextWrapper

wrapper = RunContextWrapper(context=request.app.state.agent_ctx)
result = await get_ticket.on_invoke_tool(wrapper, json.dumps({"ticket_id": ticket_id}))
return json.loads(result)
```

## Decision 6: CORS Configuration

**Decision**: Use `CORSMiddleware` with `allow_origins=["*"]` for development, configurable via environment variable.

**Rationale**: The frontend (Next.js on localhost:3000) needs to call the API (uvicorn on localhost:8000). Wildcard origins are acceptable for development/hackathon. Production would restrict to specific domains.

## Decision 7: Error Handling Strategy

**Decision**: Global exception handler that catches all unhandled exceptions and returns JSON error responses.

**Rationale**: FastAPI's default error handler returns HTML for unexpected errors. For an API consumed by a frontend, all responses must be JSON. A global handler ensures this.

**Pattern**:
```python
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    return JSONResponse(status_code=500, content={"error": "Internal server error"})
```
