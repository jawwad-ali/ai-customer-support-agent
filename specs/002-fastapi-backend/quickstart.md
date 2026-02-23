# Quickstart: FastAPI Backend

**Feature Branch**: `002-fastapi-backend`

## Prerequisites

- Python 3.12+
- PostgreSQL 16 with pgvector (Neon or local) — schema + KB already deployed from 001
- OpenAI API key
- Completed setup from `001-customer-success-agent`

## Setup

### 1. Install new dependencies

```bash
git checkout 002-fastapi-backend
uv pip install -e ".[dev]"
```

### 2. Verify environment

The `.env` file from 001 should already have:

```env
DATABASE_URL=postgresql://user:pass@host:5432/dbname
OPENAI_API_KEY=sk-...
```

### 3. Start the API server

```bash
uvicorn api.main:app --reload
```

Server starts at `http://localhost:8000`.

### 4. Verify setup

```bash
# Health check
curl http://localhost:8000/health

# Chat (requires live DB + OpenAI key)
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "How do I reset my password?", "email": "alice@example.com", "channel": "web"}'

# OpenAPI docs
open http://localhost:8000/docs
```

## Project Structure

```
api/
├── __init__.py
└── main.py               # FastAPI application

tests/
├── test_api/
│   ├── __init__.py
│   └── test_main.py      # API endpoint tests
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| POST | `/api/chat` | Send message to agent |
| GET | `/api/tickets/{ticket_id}` | Get ticket details |
| GET | `/api/customers/{customer_id}/history` | Get customer history |
| POST | `/api/webhooks/gmail` | Gmail webhook (stub) |
| POST | `/api/webhooks/whatsapp` | WhatsApp webhook (stub) |

## Running Tests

```bash
# API tests only
pytest tests/test_api/ -v

# Full suite with coverage
pytest tests/ --cov=agent --cov=api --cov=database --cov-report=term-missing
```
