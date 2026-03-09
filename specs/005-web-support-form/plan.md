# Implementation Plan: Web Support Form

**Branch**: `005-web-support-form` | **Date**: 2026-03-06 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-web-support-form/spec.md`

## Summary

Build a Next.js 15 App Router frontend that provides a customer support chat form. The form collects name, email, and message, submits to the existing FastAPI `POST /api/chat` (HTTP 202 async), polls `GET /api/jobs/{job_id}` for results, and displays AI agent responses in a chat-like thread with markdown rendering. Includes an embeddable iframe mode, full WCAG 2.1 AA accessibility, responsive mobile-first layout, and comprehensive tests.

## Technical Context

**Language/Version**: TypeScript 5.x on Node.js 20+
**Primary Dependencies**: Next.js 15 (App Router), React 19, Tailwind CSS, react-markdown (markdown rendering)
**Storage**: Client-side state only (React useState/useReducer) — no database or local storage
**Testing**: Vitest + React Testing Library + @axe-core/react (accessibility)
**Target Platform**: Modern browsers (Chrome, Firefox, Safari, Edge — last 2 versions)
**Project Type**: Web frontend (Next.js app within existing Python monorepo)
**Performance Goals**: Form submission to visual feedback < 1 second; total flow < 60 seconds
**Constraints**: Must integrate with existing FastAPI backend at configurable API URL via environment variable; CORS already configured with `allow_origins=["*"]`
**Scale/Scope**: Single-page form + embed page, ~8–10 components, ~5 custom hooks

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Agent-First Architecture | N/A | Frontend does not modify agent logic |
| II. PostgreSQL as CRM | N/A | Frontend has no direct DB access |
| III. Channel-Agnostic Core | PASS | Frontend sends `channel: "web"` — normalisation happens at backend |
| IV. Async-First | PASS | Uses async polling pattern matching backend's 202 + job polling design |
| V. Secrets-Free Codebase | PASS | API URL via `NEXT_PUBLIC_API_URL` env var; no secrets in source |
| VI. Structured Observability | PASS | Frontend logs to browser console in development; backend handles structured logging |
| VII. Graceful Degradation | PASS | All error states handled (network, timeout, expired job) with retry mechanisms |

**Gate result**: PASS — no violations. This feature is a frontend addition that integrates with the existing backend via REST API.

## Project Structure

### Documentation (this feature)

```text
specs/005-web-support-form/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/sp.tasks)
```

### Source Code (repository root)

```text
web/
├── public/                        # Static assets
├── src/
│   ├── app/
│   │   ├── layout.tsx             # Root layout (html, body, fonts, Tailwind)
│   │   ├── page.tsx               # Main support form page (Server Component shell)
│   │   ├── embed/
│   │   │   └── page.tsx           # Embed route — form without page chrome
│   │   └── globals.css            # Tailwind directives + custom styles
│   ├── components/
│   │   ├── SupportForm.tsx        # Top-level form orchestrator (client component)
│   │   ├── ChatThread.tsx         # Message list display
│   │   ├── ChatMessage.tsx        # Single message bubble (customer or agent)
│   │   ├── MessageInput.tsx       # Textarea + submit button + char counter
│   │   ├── CustomerHeader.tsx     # Collapsed name/email bar (follow-up mode)
│   │   ├── InitialForm.tsx        # Name + email + message fields (first submission)
│   │   ├── StatusIndicator.tsx    # Processing spinner / error / health status
│   │   └── MarkdownRenderer.tsx   # Sanitized markdown display for agent responses
│   ├── hooks/
│   │   ├── useJobPolling.ts       # Poll GET /api/jobs/{id} with retry_after
│   │   ├── useConversation.ts     # Conversation state management (messages array)
│   │   ├── useHealthCheck.ts      # GET /health on mount
│   │   └── useCooldown.ts         # 10-second post-submit throttle
│   ├── lib/
│   │   ├── api.ts                 # API client (submitChat, getJobStatus, healthCheck)
│   │   └── types.ts               # TypeScript interfaces (Message, Job, ChatRequest, etc.)
│   └── __tests__/
│       ├── components/            # Component unit tests
│       ├── hooks/                 # Hook unit tests
│       └── integration/           # Full flow integration tests
├── next.config.ts                 # Next.js configuration
├── postcss.config.mjs             # PostCSS config (@tailwindcss/postcss plugin)
├── tsconfig.json                  # TypeScript configuration
├── vitest.config.ts               # Test configuration
├── package.json                   # Dependencies and scripts
└── .env.example                   # NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Structure Decision**: The frontend lives in `web/` at the repository root, adjacent to the existing `api/`, `agent/`, and `database/` directories. This follows the constitution's architecture (`Next.js Web Form → FastAPI`) and keeps the monorepo clean. No separate backend directory needed — the backend already exists.
