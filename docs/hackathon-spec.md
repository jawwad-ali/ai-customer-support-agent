# The CRM Digital FTE Factory - Hackathon 5

## Build Your First 24/7 AI Employee: From Incubation to Production

**Duration:** 48-72 Development Hours | **Team Size:** 1 Student | **Difficulty:** Advanced

---

## Executive Summary

Build a real Digital FTE (Full-Time Equivalent) — an AI employee that works 24/7 without breaks, sick days, or vacations.

### Two-Stage Arc

- **Stage 1 - Incubation:** Use Claude Code to explore, prototype, and discover requirements
- **Stage 2 - Specialization:** Transform prototype into production-grade Custom Agent using OpenAI Agents SDK, FastAPI, PostgreSQL, Kafka, and Kubernetes

---

## The Business Problem: Customer Success FTE

A growing SaaS company needs a Customer Success FTE that can:

- Handle customer questions about their product 24/7
- Accept inquiries from 3 channels: **Email (Gmail)**, **WhatsApp**, and **Web Form**
- Triage and escalate complex issues appropriately
- Track all interactions in a ticket management system (PostgreSQL-based)
- Generate daily reports on customer sentiment
- Learn from resolved tickets to improve responses

**Current cost of human FTE:** $75,000/year + benefits + training + management overhead
**Target:** Build a Digital FTE that operates at <$1,000/year with 24/7 availability

> **Note:** PostgreSQL IS the CRM. No external CRM (Salesforce, HubSpot) required.

---

## Multi-Channel Architecture

### Channel Requirements

| Channel   | Integration Method          | Student Builds       | Response Method     |
|-----------|-----------------------------|----------------------|---------------------|
| Gmail     | Gmail API + Pub/Sub or Polling | Webhook handler   | Send via Gmail API  |
| WhatsApp  | Twilio WhatsApp API         | Webhook handler      | Reply via Twilio    |
| Web Form  | Next.js/HTML Form           | Complete form UI     | API response + Email|

> **Important:** Students must build the complete Web Support Form (standalone, embeddable component).

---

## Part 1: Incubation Phase (Hours 1-16)

**Objective:** Use Claude Code as Agent Factory to explore problem space, discover hidden requirements, build working prototype.

### Project Structure (Incubation)

```
project-root/
├── context/
│   ├── company-profile.md      # Fake SaaS company details
│   ├── product-docs.md         # Product documentation to answer from
│   ├── sample-tickets.json     # 50+ sample customer inquiries (multi-channel)
│   ├── escalation-rules.md     # When to involve humans
│   └── brand-voice.md          # How the company communicates
├── src/
│   ├── channels/               # Channel integrations
│   ├── agent/                  # Core agent logic
│   └── web-form/               # Support form frontend
├── tests/                      # Test cases discovered during incubation
└── specs/                      # Crystallized requirements (output)
```

### Exercises

1. **Exercise 1.1: Initial Exploration (2-3 hrs)** — Analyze sample tickets, identify patterns across channels
2. **Exercise 1.2: Prototype Core Loop (4-5 hrs)** — Message input, normalization, doc search, response generation, channel formatting, escalation decision
3. **Exercise 1.3: Add Memory & State (3-4 hrs)** — Conversation memory, sentiment tracking, topic tracking, resolution status, cross-channel identity
4. **Exercise 1.4: Build MCP Server (3-4 hrs)** — Expose tools: `search_knowledge_base`, `create_ticket`, `get_customer_history`, `escalate_to_human`, `send_response`
5. **Exercise 1.5: Define Agent Skills (2-3 hrs)** — Knowledge Retrieval, Sentiment Analysis, Escalation Decision, Channel Adaptation, Customer Identification

### Incubation Deliverables

- Working prototype handling customer queries from any channel
- `specs/discovery-log.md` — Requirements discovered during exploration
- MCP server with 5+ tools (including channel-aware tools)
- Agent skills defined and tested
- Edge cases documented with handling strategies
- Escalation rules crystallized from testing
- Channel-specific response templates
- Performance baseline (response time, accuracy)

### Crystallized Spec (`specs/customer-success-fte-spec.md`)

#### Supported Channels

| Channel        | Identifier    | Response Style            | Max Length         |
|----------------|---------------|---------------------------|--------------------|
| Email (Gmail)  | Email address | Formal, detailed          | 500 words          |
| WhatsApp       | Phone number  | Conversational, concise   | 160 chars preferred|
| Web Form       | Email address | Semi-formal               | 300 words          |

#### In Scope
- Product feature questions, how-to guidance, bug report intake, feedback collection, cross-channel conversation continuity

#### Out of Scope (Escalate)
- Pricing negotiations, refund requests, legal/compliance questions, angry customers (sentiment < 0.3)

#### Performance Requirements
- Response time: <3 seconds (processing), <30 seconds (delivery)
- Accuracy: >85% on test set
- Escalation rate: <20%
- Cross-channel identification: >95% accuracy

#### Guardrails
- NEVER discuss competitor products
- NEVER promise features not in docs
- ALWAYS create ticket before responding
- ALWAYS check sentiment before closing
- ALWAYS use channel-appropriate tone

---

## Transition Phase (Hours 15-18)

**Critical phase:** Transform exploratory code into production-ready systems.

> Claude Code remains your development tool throughout. It's the **factory that builds the Custom Agent**.

### Code Mapping: Incubation → Production

| Incubation                  | Production                              |
|-----------------------------|-----------------------------------------|
| Prototype Python script     | `agent/customer_success_agent.py`       |
| MCP server tools            | `@function_tool` decorated functions    |
| In-memory conversation      | PostgreSQL messages table               |
| Print statements            | Structured logging + Kafka events       |
| Manual testing              | pytest test suite                       |
| Local file storage          | PostgreSQL + S3/MinIO                   |
| Single-threaded             | Async workers on Kubernetes             |
| Hardcoded config            | Environment variables + ConfigMaps      |
| Direct API calls            | Channel handlers with retry logic       |

### Key Transitions
- MCP tools → OpenAI Agents SDK `@function_tool` with Pydantic input validation
- Conversational system prompt → Explicit constraint-based production prompt
- All tools need error handling, proper typing, structured logging

---

## Part 2: Specialization Phase (Hours 17-40)

**Objective:** Transform prototype into production-grade Custom Agent running 24/7 on Kubernetes with Kafka and multi-channel intake.

### Production Project Structure

```
production/
├── agent/
│   ├── __init__.py
│   ├── customer_success_agent.py    # Agent definition (OpenAI Agents SDK)
│   ├── tools.py                      # All @function_tool definitions
│   ├── prompts.py                    # System prompts
│   └── formatters.py                 # Channel-specific response formatting
├── channels/
│   ├── __init__.py
│   ├── gmail_handler.py              # Gmail integration
│   ├── whatsapp_handler.py           # Twilio/WhatsApp integration
│   └── web_form_handler.py           # Web form API
├── workers/
│   ├── __init__.py
│   ├── message_processor.py          # Kafka consumer + agent runner
│   └── metrics_collector.py          # Background metrics
├── api/
│   ├── __init__.py
│   └── main.py                       # FastAPI application
├── database/
│   ├── schema.sql                    # PostgreSQL schema
│   ├── migrations/                   # Database migrations
│   └── queries.py                    # Database access functions
├── tests/
│   ├── test_agent.py
│   ├── test_channels.py
│   └── test_e2e.py
├── k8s/                              # Kubernetes manifests
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```

### Exercises

1. **Exercise 2.1: Database Schema (2-3 hrs)** — PostgreSQL with tables: `customers`, `customer_identifiers`, `conversations`, `messages`, `tickets`, `knowledge_base`, `channel_configs`, `agent_metrics` + pgvector for semantic search
2. **Exercise 2.2: Channel Integrations (4-5 hrs)** — Gmail (API + Pub/Sub), WhatsApp (Twilio webhooks), Web Form (React/Next.js component + FastAPI endpoint)
3. **Exercise 2.3: OpenAI Agents SDK Implementation (4-5 hrs)** — Agent with channel-aware tools, cross-channel history, escalation logic
4. **Exercise 2.4: Unified Message Processor (3-4 hrs)** — Kafka consumer that processes messages from all channels through the agent
5. **Exercise 2.5: Kafka Event Streaming (2-3 hrs)** — Topics: `fte.tickets.incoming`, channel-specific inbound/outbound, escalations, metrics, DLQ
6. **Exercise 2.6: FastAPI Service (3-4 hrs)** — Channel endpoints, webhooks, conversation history, customer lookup, channel metrics
7. **Exercise 2.7: Kubernetes Deployment (4-5 hrs)** — Namespace, ConfigMap, Secrets, API Deployment (3 replicas), Worker Deployment (3 replicas), Service, Ingress, HPA

---

## Part 3: Integration & Testing (Hours 41-48)

### Exercise 3.1: Multi-Channel E2E Testing (3-4 hrs)
- Web form submission, validation, ticket status
- Gmail webhook processing
- WhatsApp webhook processing
- Cross-channel customer continuity
- Channel-specific metrics

### Exercise 3.2: Load Testing (2-3 hrs)
- Locust-based load tests simulating web form users

---

## Tech Stack

| Component        | Technology                        |
|------------------|-----------------------------------|
| Agent SDK        | OpenAI Agents SDK                 |
| API Framework    | FastAPI                           |
| Database/CRM     | PostgreSQL 16 + pgvector          |
| Event Streaming  | Apache Kafka (Confluent Cloud OK) |
| Email            | Gmail API + Pub/Sub               |
| WhatsApp         | Twilio WhatsApp API (Sandbox OK)  |
| Web Form         | Next.js / React                   |
| Deployment       | Kubernetes + Docker               |
| Dev Tools        | Claude Code, VS Code, Docker Desktop |

---

## Scoring Rubric (100 points)

### Technical Implementation (50 pts)
| Criteria              | Points | Requirements                                          |
|-----------------------|--------|-------------------------------------------------------|
| Incubation Quality    | 10     | Discovery log, iterative exploration, multi-channel patterns |
| Agent Implementation  | 10     | All tools work, channel-aware responses, error handling |
| Web Support Form      | 10     | Complete React/Next.js form with validation, submission, status |
| Channel Integrations  | 10     | Gmail + WhatsApp handlers, proper webhook validation   |
| Database & Kafka      | 5      | Normalized schema, channel tracking, event streaming   |
| Kubernetes Deployment | 5      | All manifests work, multi-pod scaling, health checks   |

### Operational Excellence (25 pts)
| Criteria                  | Points | Requirements                                    |
|---------------------------|--------|-------------------------------------------------|
| 24/7 Readiness            | 10     | Survives pod restarts, handles scaling, no SPOF |
| Cross-Channel Continuity  | 10     | Customer identified across channels, history preserved |
| Monitoring                | 5      | Channel-specific metrics, alerts configured     |

### Business Value (15 pts)
| Criteria             | Points | Requirements                                    |
|----------------------|--------|-------------------------------------------------|
| Customer Experience  | 10     | Channel-appropriate responses, escalation, sentiment |
| Documentation        | 5      | Deployment guide, API docs, form integration guide |

### Innovation (10 pts)
| Criteria                | Points | Requirements                         |
|-------------------------|--------|--------------------------------------|
| Creative Solutions      | 5      | Novel approaches, enhanced web form UX |
| Evolution Demonstration | 5      | Clear incubation → specialization progression |

---

## Final Challenge: 24-Hour Multi-Channel Test

After deployment, the FTE must survive:
- **Web Form:** 100+ submissions over 24 hours
- **Email:** 50+ Gmail messages processed
- **WhatsApp:** 50+ WhatsApp messages processed
- **Cross-Channel:** 10+ customers via multiple channels
- **Chaos Testing:** Random pod kills every 2 hours

### Metrics Validation
- Uptime > 99.9%
- P95 latency < 3 seconds (all channels)
- Escalation rate < 25%
- Cross-channel customer identification > 95%
- No message loss

---

## FAQ

- **External CRM needed?** No. PostgreSQL IS your CRM.
- **Real Gmail/WhatsApp accounts?** Use sandbox/dev APIs for development.
- **Full website needed?** No. Only the Web Support Form component.
- **Skip a channel?** Web Form is required. Gmail/WhatsApp partial implementations acceptable with documented limitations.

---

## Reference Links

- [Agent Maturity Model](https://agentfactory.panaversity.org/docs/General-Agents-Foundations/agent-factory-paradigm/the-2025-inflection-point#the-agent-maturity-model)
- [OpenAI Agents SDK Documentation](https://openai.github.io/openai-agents-python/)
- [Model Context Protocol Specification](https://spec.modelcontextprotocol.io/)
- [Gmail API Documentation](https://developers.google.com/gmail/api)
- [Twilio WhatsApp API](https://www.twilio.com/docs/whatsapp)
