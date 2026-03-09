# Component Contracts: Web Support Form

**Feature**: 005-web-support-form
**Date**: 2026-03-06

## Component Tree

```
app/page.tsx (Server Component)
└── SupportForm (Client Component — orchestrator)
    ├── [isFollowUpMode=false] InitialForm
    │   ├── name input
    │   ├── email input
    │   ├── MessageInput (textarea + char counter + submit)
    │   └── validation errors (inline)
    ├── [isFollowUpMode=true] CustomerHeader
    │   └── "Ali (ali@test.com)" collapsed bar
    ├── ChatThread
    │   └── ChatMessage[] (mapped from messages)
    │       └── MarkdownRenderer (agent messages only)
    ├── [isFollowUpMode=true] MessageInput
    │   ├── textarea + char counter
    │   └── submit button (with cooldown)
    └── StatusIndicator
        ├── health status (on mount)
        ├── processing spinner (during polling)
        └── error banner (on failure)
```

## Component Props & Responsibilities

### SupportForm
- **Props**: None (top-level orchestrator)
- **Directive**: `'use client'`
- **Responsibilities**:
  - Manages conversation state via `useConversation` hook
  - Runs health check via `useHealthCheck` hook on mount
  - Handles form submission → API call → polling cycle
  - Switches between InitialForm and follow-up mode
  - Displays StatusIndicator for errors and processing

### InitialForm
- **Props**: `onSubmit: (name: string, email: string, message: string) => void`, `isSubmitting: boolean`
- **Responsibilities**:
  - Renders name, email, message fields
  - Client-side validation (all three required, email format, message <= 2000 chars)
  - Shows inline validation errors
  - Disables submit while submitting
  - Character counter on message field

### CustomerHeader
- **Props**: `name: string`, `email: string`
- **Responsibilities**:
  - Displays collapsed bar showing customer identity
  - Visible only in follow-up mode

### ChatThread
- **Props**: `messages: Message[]`
- **Responsibilities**:
  - Renders list of ChatMessage components
  - Auto-scrolls to bottom when new messages arrive (via `useEffect` + `scrollIntoView`)
  - ARIA `role="log"` and `aria-live="polite"` for screen readers

### ChatMessage
- **Props**: `message: Message`
- **Responsibilities**:
  - Customer messages: right-aligned, plain text
  - Agent messages: left-aligned, rendered via MarkdownRenderer
  - Processing state: shows pulsing dots animation
  - Failed state: shows error with retry button
  - Timestamp display

### MessageInput
- **Props**: `onSubmit: (message: string) => void`, `disabled: boolean`, `maxLength: number`
- **Responsibilities**:
  - Textarea with character counter ("1847 / 2000")
  - Submit button (disabled during cooldown, processing, or empty input)
  - Submit on Enter (Shift+Enter for newline)
  - ARIA label for accessibility

### StatusIndicator
- **Props**: `isHealthy: boolean | null`, `isProcessing: boolean`, `error: string | null`
- **Responsibilities**:
  - Health check status (green dot = healthy, red dot = unavailable)
  - Processing spinner animation during polling
  - Error banner with retry action

### MarkdownRenderer
- **Props**: `content: string`
- **Responsibilities**:
  - Renders markdown string as React elements via react-markdown
  - Supports bold, italic, lists, links (open in new tab), code blocks
  - Sanitizes any raw HTML (XSS protection — react-markdown default behavior)

## Custom Hooks

### useConversation
```typescript
function useConversation(): {
  conversation: Conversation;
  addCustomerMessage: (content: string) => Message;
  updateMessageStatus: (id: string, status: Message['status'], response?: string, error?: string) => void;
  setCustomerInfo: (name: string, email: string) => void;
}
```

### useJobPolling
```typescript
function useJobPolling(
  jobId: string | null,
  onComplete: (response: string) => void,
  onError: (error: string) => void,
): {
  isPolling: boolean;
  elapsed: number;  // seconds since polling started
}
```
- Starts polling when `jobId` is set (non-null)
- Stops on completed/failed/timeout
- Timeout: 5 minutes (300 seconds)
- Network retry: up to 3 consecutive failures before giving up

### useHealthCheck
```typescript
function useHealthCheck(): {
  isHealthy: boolean | null;  // null = checking, true = healthy, false = unhealthy
}
```
- Calls `GET /health` once on mount
- Returns null during check, then true/false

### useCooldown
```typescript
function useCooldown(durationMs: number): {
  isCoolingDown: boolean;
  startCooldown: () => void;
}
```
- After `startCooldown()`, `isCoolingDown` is true for `durationMs` milliseconds
- Used for 10-second post-submit throttle (FR-016)
