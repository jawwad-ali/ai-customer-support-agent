# Data Model: Web Support Form

**Feature**: 005-web-support-form
**Date**: 2026-03-06

## Overview

All data is client-side only (React component state). No database tables are created by this feature. The backend's existing PostgreSQL schema handles persistence via the agent tools.

## TypeScript Interfaces

### Message

A single unit in the conversation thread.

```typescript
interface Message {
  id: string;              // Client-generated UUID (crypto.randomUUID())
  role: "customer" | "agent";
  content: string;         // Plain text (customer) or markdown (agent)
  timestamp: Date;
  status: "sent" | "processing" | "completed" | "failed";
  jobId?: string;          // Backend job ID (set after submission)
  error?: string;          // Error message (when status === "failed")
}
```

**State transitions**:
```
Customer message: sent → processing → completed (agent response added)
                      ↘ failed (error displayed, retry available)
```

### Conversation

An ordered collection of messages for the current session.

```typescript
interface Conversation {
  messages: Message[];
  customerName: string;    // Set on first submission
  customerEmail: string;   // Set on first submission
  isFollowUpMode: boolean; // true after first response received
}
```

**Lifecycle**: Created when user submits first message. Cleared on page refresh.

### Job (API Response Types)

Maps to backend API responses.

```typescript
// POST /api/chat response (HTTP 202)
interface JobAccepted {
  job_id: string;
  status: "processing";
  retry_after: number;     // Seconds until next poll (default: 5)
}

// POST /api/chat?sync=true response (HTTP 200)
interface ChatResponse {
  response: string;
  correlation_id: string;
}

// GET /api/jobs/{job_id} response
interface JobStatus {
  job_id: string;
  status: "processing" | "completed" | "failed";
  response: string | null;
  error: string | null;
  retry_after: number | null;
}

// GET /health response
interface HealthStatus {
  status: string;
}
```

### ChatRequest

Outbound request to backend.

```typescript
interface ChatRequest {
  name: string;            // Customer name (from form)
  email: string;           // Customer email (from form)
  message: string;         // Message text
  channel: "web";          // Always "web" — hardcoded
}
```

### Form Validation

```typescript
interface ValidationErrors {
  name?: string;           // "Name is required"
  email?: string;          // "Email is required" | "Invalid email format"
  message?: string;        // "Message is required" | "Message exceeds 2000 characters"
}
```

## Component State Map

| Component | State | Source |
|-----------|-------|--------|
| SupportForm | conversation: Conversation | useConversation hook |
| SupportForm | isBackendHealthy: boolean | useHealthCheck hook |
| InitialForm | validationErrors: ValidationErrors | Local state |
| MessageInput | charCount: number | Derived from input length |
| MessageInput | isCoolingDown: boolean | useCooldown hook |
| StatusIndicator | pollingStatus: "idle" \| "polling" \| "done" | useJobPolling hook |

## No Database Changes

This feature adds zero database tables, columns, or migrations. All new data structures are TypeScript interfaces living in `web/src/lib/types.ts`.
