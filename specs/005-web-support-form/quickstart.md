# Quickstart: Web Support Form

**Feature**: 005-web-support-form
**Date**: 2026-03-06

## Prerequisites

- Node.js 20+ installed
- Backend running at `http://localhost:8000` (see root README)
- `uv` available (for backend dev server)

## Setup

```bash
# From repo root
cd web

# Install dependencies
npm install

# Copy environment file
cp .env.example .env.local
# Edit .env.local if backend is not at localhost:8000

# Start dev server
npm run dev
# → http://localhost:3000
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:8000` | Backend API base URL |

## Development Commands

```bash
npm run dev          # Start Next.js dev server (port 3000)
npm run build        # Production build
npm run start        # Start production server
npm run test         # Run all tests (Vitest)
npm run test:watch   # Run tests in watch mode
npm run lint         # ESLint check
```

## Manual Testing Scenarios

### 1. Basic Submit + Response
1. Open http://localhost:3000
2. Enter name, email, and a message
3. Click Submit
4. Verify: processing indicator appears
5. Verify: agent response appears in chat thread

### 2. Multi-turn Conversation
1. Complete scenario 1
2. Verify: name/email collapse into header bar
3. Type a follow-up message and submit
4. Verify: both exchanges visible in thread

### 3. Validation
1. Click Submit with all fields empty → inline errors appear
2. Enter invalid email → email validation error
3. Type 2001 characters → character counter shows limit exceeded, submit disabled

### 4. Error Recovery
1. Stop the backend server
2. Submit a message → error displayed with "Try Again"
3. Restart backend, click "Try Again" → message resubmitted

### 5. Embed Mode
1. Open http://localhost:3000/embed
2. Verify: form renders without page header/footer
3. Complete a full submit + response cycle

### 6. Mobile Responsiveness
1. Open Chrome DevTools → Toggle Device Toolbar
2. Select iPhone SE (375px)
3. Verify: single-column layout, touch-friendly inputs

### 7. Keyboard Navigation
1. Tab through all form fields
2. Press Enter to submit
3. Verify: focus moves to chat thread after response arrives

## Project Structure

```
web/
├── src/
│   ├── app/           # Next.js App Router pages
│   ├── components/    # React components
│   ├── hooks/         # Custom React hooks
│   ├── lib/           # API client + types
│   └── __tests__/     # All tests
├── package.json
├── next.config.ts
├── tailwind.config.ts
└── vitest.config.ts
```
