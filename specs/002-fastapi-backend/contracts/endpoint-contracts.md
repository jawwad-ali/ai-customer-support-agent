# Endpoint Contracts: FastAPI Backend

**Feature Branch**: `002-fastapi-backend`
**Date**: 2026-02-23

All endpoints return JSON. Errors always return `{"error": "...", "detail": "..."}`.

---

## Health

### GET /health

```
Input: None

Output (200):
  status: str      — "ok"

Errors: None (always returns 200 if the process is alive)

Notes:
  - Used by Kubernetes liveness probes
  - No authentication required
```

---

## Chat

### POST /api/chat

```
Input (JSON body):
  message: str           — customer's message text (required)
  email: str             — customer's email address (required)
  channel: str           — "web" | "gmail" | "whatsapp" (default: "web")
  name: str | None       — customer display name (optional)

Output (200):
  response: str          — the agent's reply
  correlation_id: str    — unique request trace ID

Errors:
  - 422: Pydantic validation failure (missing required fields, wrong types)
  - 500: Agent processing failure (returned as JSON, never HTML)

Flow:
  1. set_correlation_id()
  2. Construct message: f"[Customer: {email}, Channel: {channel}] {message}"
  3. await run_agent(app.state.agent_ctx, message)
  4. Return { response, correlation_id }

Notes:
  - The agent autonomously handles customer creation, ticket, KB search,
    response delivery, and metrics — all via its tool calls.
  - The API does NOT pre-create the customer; the agent's system prompt
    instructs it to call find_or_create_customer as step 1.
```

---

## Ticket Lookup

### GET /api/tickets/{ticket_id}

```
Input:
  ticket_id: str (path parameter) — UUID of the ticket

Output (200):
  ticket: object         — { id, customer_id, channel, category, priority, status,
                             escalation_reason, resolution_notes, parent_ticket_id,
                             created_at, updated_at }
  conversation: object | null — { id, ticket_id, customer_id, channel, created_at }
  messages: list         — [{ id, direction, channel, content, sentiment, created_at }]

Errors:
  - Ticket not found → 404 { "error": "ticket not found" }

Implementation:
  - Reuses get_ticket tool via on_invoke_tool()
  - Parses the JSON result and returns as-is
```

---

## Customer History

### GET /api/customers/{customer_id}/history

```
Input:
  customer_id: str (path parameter) — UUID of the customer

Output (200):
  customer: object       — { id, name, created_at }
  identifiers: list      — [{ identifier_type, identifier_value, channel }]
  conversations: list    — recent conversations with message_count
  conversations_by_channel: object — conversations grouped by channel
  tickets: list          — recent tickets

Errors:
  - Customer not found → 404 { "error": "customer not found" }

Implementation:
  - Reuses get_customer_history tool via on_invoke_tool()
```

---

## Webhooks

### POST /api/webhooks/gmail

```
Input (JSON body):
  from_address: str      — sender's email address (required)
  body: str              — email body text (required)

Output (200):
  response: str          — the agent's reply
  correlation_id: str    — unique request trace ID

Flow:
  1. set_correlation_id()
  2. message = f"[Customer: {from_address}, Channel: gmail] {body}"
  3. await run_agent(app.state.agent_ctx, message)
  4. Return { response, correlation_id }

Notes:
  - Stub implementation — accepts payload and processes through agent
  - Real Gmail API integration is a future feature
```

### POST /api/webhooks/whatsapp

```
Input (JSON body):
  from_address: str      — sender's phone number (required)
  body: str              — message text (required)

Output (200):
  response: str          — the agent's reply
  correlation_id: str    — unique request trace ID

Flow:
  1. set_correlation_id()
  2. message = f"[Customer: {from_address}, Channel: whatsapp] {body}"
  3. await run_agent(app.state.agent_ctx, message)
  4. Return { response, correlation_id }

Notes:
  - Stub implementation — accepts payload and processes through agent
  - Real Twilio WhatsApp integration is a future feature
```
