# API Integration Contract: Web Support Form

**Feature**: 005-web-support-form
**Date**: 2026-03-06

## Backend Endpoints Consumed

The frontend consumes three existing backend endpoints. No backend changes required.

### 1. POST /api/chat

Submit a customer support message.

**Request**:
```
POST {NEXT_PUBLIC_API_URL}/api/chat
Content-Type: application/json

{
  "name": "Ali",
  "email": "ali@test.com",
  "message": "How do I reset my password?",
  "channel": "web"
}
```

**Response (HTTP 202 Accepted)**:
```json
{
  "job_id": "a65c5987210846a08e4c57cc2cfa519e",
  "status": "processing",
  "retry_after": 5
}
```

**Error (HTTP 500)**:
```json
{
  "error": "Internal server error",
  "detail": "..."
}
```

### 2. GET /api/jobs/{job_id}

Poll for job result.

**Request**:
```
GET {NEXT_PUBLIC_API_URL}/api/jobs/{job_id}
```

**Response — Processing (HTTP 200)**:
```json
{
  "job_id": "a65c5987...",
  "status": "processing",
  "response": null,
  "error": null,
  "retry_after": 5
}
```

**Response — Completed (HTTP 200)**:
```json
{
  "job_id": "a65c5987...",
  "status": "completed",
  "response": "To reset your password, go to **Settings > Security**...",
  "error": null,
  "retry_after": null
}
```

**Response — Failed (HTTP 200)**:
```json
{
  "job_id": "a65c5987...",
  "status": "failed",
  "response": null,
  "error": "An error occurred while processing your request. Please try again.",
  "retry_after": null
}
```

**Response — Not Found (HTTP 404)**:
```json
{
  "error": "Job not found"
}
```

### 3. GET /health

Health check on initial load.

**Request**:
```
GET {NEXT_PUBLIC_API_URL}/health
```

**Response (HTTP 200)**:
```json
{
  "status": "healthy"
}
```

## Frontend API Client Contract

All backend calls go through `web/src/lib/api.ts`:

```typescript
// Submit a chat message — returns job_id for polling
async function submitChat(request: ChatRequest): Promise<JobAccepted>

// Poll job status — returns current state
async function getJobStatus(jobId: string): Promise<JobStatus>

// Check backend health — returns true/false
async function checkHealth(): Promise<boolean>
```

All functions:
- Use `fetch()` with `Content-Type: application/json`
- Read base URL from `process.env.NEXT_PUBLIC_API_URL`
- Throw typed errors on network failure or non-OK status
- Do NOT retry internally — callers handle retry logic

## Environment Variable

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NEXT_PUBLIC_API_URL` | Yes | `http://localhost:8000` | Backend API base URL (no trailing slash) |

## Embed Route Contract

The `/embed` page renders the same `<SupportForm>` component but:
- No page header, footer, or navigation
- Accepts optional query parameters: `?theme=light` (reserved for future)
- Designed to be loaded in an iframe: `<iframe src="https://domain/embed" width="400" height="600" />`
- Communicates with backend using the same API client (same-origin or CORS)
