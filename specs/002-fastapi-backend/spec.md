# Feature Specification: FastAPI Backend

**Feature Branch**: `002-fastapi-backend`
**Created**: 2026-02-23
**Status**: Draft
**Depends On**: `001-customer-success-agent` (complete)
**Input**: User description: "Build the FastAPI HTTP layer that exposes the Customer Success Agent as a production API. The API receives messages from the web form frontend (and later Gmail/WhatsApp webhooks), passes them to the already-built agent, and returns responses. Includes endpoints for ticket lookup, customer history, health checks, and channel-specific webhook stubs."

## Clarifications

### Session 2026-02-23

- Q: Should the API pre-create customers before calling the agent, or let the agent handle it? → A: Let the agent handle it. The system prompt instructs the agent to call `find_or_create_customer` as its first step. The API just prepends customer context (email + channel) to the message.
- Q: Should webhook endpoints (Gmail, WhatsApp) be fully functional or stubs? → A: Stubs with the correct request schema. They should process messages through the agent but won't integrate with real Gmail API / Twilio yet. That's a separate feature.
- Q: How should the API share the database pool and OpenAI client? → A: FastAPI lifespan. Create the `AgentContext` once on startup using the existing `build_context()`, store in `app.state`, close on shutdown.
- Q: Should the API use streaming responses? → A: No. `Runner.run()` returns a complete response. Simple JSON request/response is sufficient.
- Q: What about authentication? → A: None for now. This is a development/hackathon backend. Auth can be added later.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Web Form Chat (Priority: P1)

A customer submits a message through the web support form. The frontend POSTs to `/api/chat` with the message, email, and channel. The API passes the message to the agent, which autonomously handles the full workflow (customer creation, ticket, KB search, response). The API returns the agent's response to the frontend.

**Why this priority**: This is the primary endpoint that connects the frontend to the agent. Without it, the agent has no HTTP interface.

**Independent Test**: POST a product question to `/api/chat`. Verify the response contains the agent's answer and a correlation ID for tracing.

**Acceptance Scenarios**:

1. **Given** the API is running, **When** a POST arrives at `/api/chat` with `{"message": "How do I reset my password?", "email": "alice@example.com", "channel": "web"}`, **Then** the response contains the agent's answer and a `correlation_id`.
2. **Given** an invalid request body (missing email), **When** posted to `/api/chat`, **Then** a 422 validation error is returned with field-level details.
3. **Given** the agent encounters an unrecoverable error, **When** processing a chat request, **Then** the API returns a 500 with a JSON error message — never an HTML stack trace.

---

### User Story 2 - Ticket and Customer Lookup (Priority: P2)

The frontend needs to display ticket details and customer history. The API provides read-only GET endpoints that reuse existing agent tool functions.

**Why this priority**: The frontend needs these endpoints to show ticket status and customer conversation history.

**Independent Test**: Create a ticket via `/api/chat`, then GET it via `/api/tickets/{id}`. Verify the full ticket with conversation and messages is returned.

**Acceptance Scenarios**:

1. **Given** a ticket exists, **When** GET `/api/tickets/{ticket_id}` is called, **Then** the response includes ticket details, conversation, and messages.
2. **Given** a ticket does not exist, **When** GET `/api/tickets/{bad_id}` is called, **Then** a JSON error is returned (not 500).
3. **Given** a customer exists with conversations across multiple channels, **When** GET `/api/customers/{id}/history` is called, **Then** the response includes conversations grouped by channel.

---

### User Story 3 - Channel Webhooks (Priority: P3)

Gmail and WhatsApp send inbound messages via webhooks. The API provides POST endpoints that accept channel-specific payloads, process them through the agent, and return the response.

**Why this priority**: Webhook endpoints are stubs for now, but the schema and routing must be in place for channel integration.

**Independent Test**: POST a Gmail-format payload to `/api/webhooks/gmail`. Verify it processes through the agent and returns a response.

**Acceptance Scenarios**:

1. **Given** a Gmail webhook payload, **When** posted to `/api/webhooks/gmail`, **Then** the message is processed through the agent with `channel="gmail"` and the response is returned.
2. **Given** a WhatsApp webhook payload, **When** posted to `/api/webhooks/whatsapp`, **Then** the message is processed through the agent with `channel="whatsapp"` and the response is returned.

---

### User Story 4 - Health and Observability (Priority: P1)

The API provides a health check endpoint for Kubernetes liveness probes and monitoring. Every request gets a unique correlation ID for distributed tracing.

**Why this priority**: Health checks are required for production deployment. Correlation IDs are essential for debugging.

**Independent Test**: GET `/health` returns 200 with `{"status": "ok"}`.

**Acceptance Scenarios**:

1. **Given** the API and database are healthy, **When** GET `/health` is called, **Then** `{"status": "ok"}` is returned with 200.
2. **Given** every request, **Then** `set_correlation_id()` is called so all logs for that request share a unique ID.
3. **Given** the frontend runs on a different origin, **When** it makes requests to the API, **Then** CORS headers allow the request.

---

### Edge Cases

- What happens when the agent takes longer than 30 seconds? The client may timeout, but the API should not crash. Consider documenting timeout behavior.
- What happens when two concurrent requests hit `/api/chat` for the same customer? The agent handles it — `find_or_create_customer` is idempotent.
- What happens when the database pool is exhausted? The API should return 503 Service Unavailable, not hang.
- What happens when OPENAI_API_KEY is invalid? The agent tool catches the error and returns a fallback. The API returns the fallback as a normal response.
- What happens when the request body has extra fields? FastAPI/Pydantic ignores them by default (forbid can be configured later).

## Requirements *(mandatory)*

### Functional Requirements

**API Application**

- **FR-001**: System MUST provide a FastAPI application with lifespan-managed `AgentContext` (DB pool + OpenAI client created on startup, closed on shutdown).
- **FR-002**: System MUST provide a `POST /api/chat` endpoint accepting `{message, email, channel, name?}` and returning `{response, correlation_id}`.
- **FR-003**: System MUST provide a `GET /api/tickets/{ticket_id}` endpoint returning ticket details with conversation and messages.
- **FR-004**: System MUST provide a `GET /api/customers/{customer_id}/history` endpoint returning customer profile, identifiers, conversations by channel, and tickets.
- **FR-005**: System MUST provide a `POST /api/webhooks/gmail` endpoint accepting `{from_address, body}` and processing through the agent with channel="gmail".
- **FR-006**: System MUST provide a `POST /api/webhooks/whatsapp` endpoint accepting `{from_address, body}` and processing through the agent with channel="whatsapp".
- **FR-007**: System MUST provide a `GET /health` endpoint returning `{"status": "ok"}` when the service is healthy.

**Cross-Cutting Concerns**

- **FR-008**: Every request MUST call `set_correlation_id()` to generate a unique request-scoped tracing ID.
- **FR-009**: System MUST include CORS middleware allowing configurable origins (default `["*"]` for development).
- **FR-010**: All error responses MUST be JSON — never HTML stack traces. Use a global exception handler.
- **FR-011**: Request/response models MUST use Pydantic BaseModel with proper type annotations.
- **FR-012**: The chat endpoint MUST prepend `[Customer: {email}, Channel: {channel}]` to the message before passing to the agent, matching the existing CLI pattern.
- **FR-013**: The API MUST reuse existing agent tool functions for ticket and customer lookups — no duplicated DB queries.

**Dependencies**

- **FR-014**: `fastapi` and `uvicorn[standard]` MUST be added to project dependencies.
- **FR-015**: `httpx` MUST be added to dev dependencies for async test client.
- **FR-016**: `api*` MUST be added to `[tool.setuptools.packages.find] include` in pyproject.toml.

### Key Entities

- **ChatRequest**: Pydantic model for POST /api/chat — message (str, required), email (str, required), channel (str, default "web"), name (str | None).
- **ChatResponse**: Pydantic model — response (str), correlation_id (str).
- **WebhookPayload**: Pydantic model for webhooks — from_address (str, required), body (str, required).
- **ErrorResponse**: Pydantic model — error (str), detail (str | None).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: POST `/api/chat` processes a product question end-to-end and returns the agent's response with status 200.
- **SC-002**: GET `/api/tickets/{id}` returns full ticket details (ticket + conversation + messages) for an existing ticket.
- **SC-003**: GET `/api/customers/{id}/history` returns customer profile with conversations grouped by channel.
- **SC-004**: POST `/api/webhooks/gmail` processes a message through the agent with channel="gmail".
- **SC-005**: POST `/api/webhooks/whatsapp` processes a message through the agent with channel="whatsapp".
- **SC-006**: GET `/health` returns `{"status": "ok"}` with status 200.
- **SC-007**: Invalid request bodies return 422 with Pydantic validation errors — never 500.
- **SC-008**: CORS headers are present on all responses, allowing frontend access.
- **SC-009**: Every request generates a unique correlation_id visible in logs.
- **SC-010**: `uvicorn api.main:app --reload` starts the server without errors.

### Assumptions

- The agent (from 001-customer-success-agent) is fully functional — all 11 tools, DB schema, and KB are deployed.
- No authentication is needed for the hackathon MVP. Auth is a future concern.
- Gmail and WhatsApp webhooks are stubs — they process messages through the agent but don't integrate with real Gmail API or Twilio.
- The frontend will run on a different origin (e.g., localhost:3000) and needs CORS.
- The database is already running and seeded from the 001 feature work.
