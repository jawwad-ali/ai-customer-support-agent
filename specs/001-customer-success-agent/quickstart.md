# Quickstart: Customer Success Agent

**Feature Branch**: `001-customer-success-agent`

## Prerequisites

- Python 3.12+
- PostgreSQL 16 with pgvector extension (Neon or local)
- OpenAI API key

## Setup

### 1. Clone and install dependencies

```bash
git checkout 001-customer-success-agent
pip install openai-agents asyncpg openai python-dotenv pydantic
```

### 2. Configure environment

Copy `.env.example` to `.env` and fill in values:

```bash
cp .env.example .env
```

Required variables:

```env
DATABASE_URL=postgresql://user:pass@host:5432/dbname
OPENAI_API_KEY=sk-...
```

### 3. Run database migrations

```bash
# Apply schema
psql "$DATABASE_URL" -f database/migrations/001_initial_schema.sql

# Seed knowledge base
python database/migrations/002_seed_knowledge_base.py
```

### 4. Verify setup

```bash
# Run tests
pytest tests/ -v

# Quick smoke test
python -m agent.customer_success_agent "How do I reset my password?"
```

## Project Structure

```
agent/
├── customer_success_agent.py   # Agent definition
├── tools/                      # @function_tool functions
│   ├── customer.py
│   ├── ticket.py
│   ├── knowledge.py
│   ├── conversation.py
│   ├── escalation.py
│   ├── response.py
│   └── metrics.py
├── prompts.py                  # System prompt
└── context.py                  # AgentContext dataclass

database/
├── migrations/
│   ├── 001_initial_schema.sql
│   └── 002_seed_knowledge_base.py
└── pool.py                     # asyncpg pool setup

tests/
├── conftest.py
├── test_tools/
└── test_agent.py
```

## How It Works

1. A message arrives (from web form, email, or WhatsApp)
2. The agent receives the message text + channel metadata
3. The agent autonomously decides which tools to call:
   - `find_or_create_customer` → identify the sender
   - `create_ticket` → log the interaction (also creates a conversation)
   - `save_message` → store the inbound message
   - `search_knowledge_base` → find relevant answers
   - `send_response` → reply via the correct channel
   - `update_ticket` → mark as resolved (or `escalate_to_human`)
   - `log_metric` → record performance data
4. The agent returns a response

## Validation Checklist

After setup, verify these work:

- [ ] Database tables created (8 tables)
- [ ] Knowledge base seeded (15+ articles)
- [ ] Semantic search returns relevant results
- [ ] Agent resolves a simple product question end-to-end
- [ ] Agent escalates a refund request
- [ ] Metrics are logged for both scenarios
