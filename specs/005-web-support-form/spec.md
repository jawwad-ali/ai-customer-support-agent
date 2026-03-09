# Feature Specification: Web Support Form

**Feature Branch**: `005-web-support-form`
**Created**: 2026-03-06
**Status**: Draft
**Input**: User description: "Build a complete Next.js Web Support Form — a standalone, embeddable customer support widget that integrates with the existing FastAPI async backend."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Submit a Support Request (Priority: P1)

A customer visits the support page (or sees an embedded widget on any page) and fills out a form with their name, email, and message describing their issue. They submit the form and see a visual indicator that their request is being processed. Within seconds, the AI agent's response appears in the same interface.

**Why this priority**: This is the core value proposition — without form submission and response display, nothing else matters. It directly maps to the hackathon's 10-point "Web Support Form" scoring criterion: "Complete form with validation, submission, status."

**Independent Test**: Can be fully tested by opening the form, filling in valid data, submitting, and verifying the response appears. Delivers the complete support interaction cycle.

**Acceptance Scenarios**:

1. **Given** the form is displayed, **When** a customer fills in name, email, and message and clicks Submit, **Then** the form sends the request to the backend and displays a "processing" indicator within 1 second.
2. **Given** a request has been submitted, **When** the backend completes processing, **Then** the agent's response is displayed in the conversation area without requiring a page refresh.
3. **Given** a request has been submitted, **When** the customer waits for a response, **Then** the system polls for the result automatically every 5 seconds until the response arrives or an error occurs.

---

### User Story 2 - Conversation Thread with Follow-ups (Priority: P2)

After receiving an initial response, the customer can type a follow-up message in the same interface. The conversation is displayed as a chat-like thread showing all messages (customer and agent) in chronological order, so the customer can have a back-and-forth exchange without leaving the page.

**Why this priority**: A single question-answer cycle is useful, but real customer support often requires multi-turn conversations. This transforms the form from a one-shot tool into a proper support channel.

**Independent Test**: Can be tested by submitting an initial message, receiving a response, then submitting a follow-up and verifying both exchanges appear in the thread.

**Acceptance Scenarios**:

1. **Given** the customer has received a response from the agent, **When** the UI transitions to follow-up mode, **Then** the name and email fields collapse into a header bar showing the customer's name and email, and only the message input remains active.
2. **Given** the customer is in follow-up mode, **When** they type a follow-up message and submit, **Then** the new message appears in the thread and a new processing cycle begins.
2. **Given** multiple messages have been exchanged, **When** the customer views the conversation, **Then** all messages are displayed in chronological order with clear visual distinction between customer messages and agent responses.
3. **Given** a follow-up is being processed, **When** a previous message is still visible, **Then** the full conversation history remains visible while the new response loads.

---

### User Story 3 - Input Validation and Error Recovery (Priority: P2)

Customers are prevented from submitting incomplete or invalid data. If something goes wrong (network error, server error, timeout), they receive a clear, friendly error message and can retry without losing their entered data.

**Why this priority**: Validation prevents bad requests from reaching the backend and errors are inevitable in production — graceful handling is essential for a reliable 24/7 support channel.

**Independent Test**: Can be tested by attempting to submit with missing fields, invalid email, and by simulating network/server failures.

**Acceptance Scenarios**:

1. **Given** the form is displayed, **When** the customer clicks Submit with empty required fields, **Then** inline validation messages appear next to each invalid field and the form is not submitted.
2. **Given** the customer enters an invalid email format, **When** they attempt to submit, **Then** a validation message indicates the email format is incorrect.
3. **Given** the form has been submitted, **When** the backend returns an error or the network is unavailable, **Then** a user-friendly error message is displayed with a "Try Again" button.
4. **Given** an error has occurred, **When** the customer clicks "Try Again", **Then** the form retains their previously entered data and resubmits the request.
5. **Given** a request has been processing for more than 5 minutes, **When** the polling detects a timeout, **Then** a timeout message is displayed with a retry option.

---

### User Story 4 - Responsive and Accessible Experience (Priority: P2)

Customers using the form on any device (mobile phone, tablet, desktop) have a usable, well-formatted experience. Customers using screen readers or keyboard-only navigation can complete the full support interaction.

**Why this priority**: The hackathon spec requires the form to handle 100+ submissions over 24 hours from diverse users and devices. Accessibility ensures no customer is excluded.

**Independent Test**: Can be tested by using the form on various viewport sizes and by navigating with keyboard only and screen reader.

**Acceptance Scenarios**:

1. **Given** a customer on a mobile device (viewport < 640px), **When** they view the form, **Then** the layout adapts to a single-column view with touch-friendly input sizes and spacing.
2. **Given** a customer using only a keyboard, **When** they navigate the form, **Then** they can tab through all fields, submit the form, and read responses using standard keyboard interactions.
3. **Given** a customer using a screen reader, **When** they interact with the form, **Then** all form fields have proper labels, errors are announced, and status changes (processing, completed, failed) are communicated via live regions.

---

### User Story 5 - Embeddable Widget (Priority: P3)

A website owner can embed the support form into any existing webpage by adding a single script tag or iframe snippet. The widget renders in a contained area without affecting the host page's styles or layout.

**Why this priority**: The hackathon spec calls for a "standalone, embeddable component." While the full-page version is the primary deliverable, embeddability extends the form's utility to any website.

**Independent Test**: Can be tested by creating a plain HTML page, adding the embed snippet, and verifying the form loads and works correctly within the host page.

**Acceptance Scenarios**:

1. **Given** a website owner adds the embed snippet to their HTML page, **When** the page loads, **Then** the support form renders within the designated area.
2. **Given** the form is embedded in a host page, **When** the customer submits a support request, **Then** the full submission and polling flow works identically to the standalone version.
3. **Given** the form is embedded via iframe, **When** the host page has its own styles, **Then** the form's appearance is not affected by the host page's CSS.

---

### Edge Cases

- What happens when the customer submits the same message multiple times rapidly? The form should disable the submit button during processing to prevent duplicate submissions.
- What happens when the customer's network drops after submission but before receiving a response? The polling should detect the failure and show an error with a retry option.
- What happens when a job expires (1-hour TTL)? The form should display a message indicating the session has expired and invite the customer to start a new conversation.
- What happens when the customer enters extremely long messages? The form should enforce a reasonable character limit (2000 characters) with a visible counter.
- What happens when the backend is completely unavailable? The health check should detect this and display a "service temporarily unavailable" message.
- What happens when the customer refreshes the page during a conversation? The conversation history is lost (client-side only) and the form resets to its initial state. This is acceptable for the current scope.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The form MUST collect three required fields: customer name, customer email address, and message text.
- **FR-002**: The form MUST validate all fields on the client side before submission — name must not be empty, email must be a valid format, message must not be empty and must not exceed 2000 characters.
- **FR-003**: The form MUST submit requests to the existing `POST /api/chat` endpoint with fields mapped to `name`, `email`, `message`, and `channel` (hardcoded to `"web"`).
- **FR-004**: The form MUST handle the HTTP 202 async response by extracting the `job_id` and automatically polling `GET /api/jobs/{job_id}` at the interval specified by `retry_after` (default 5 seconds).
- **FR-005**: The form MUST display distinct visual states for: idle, submitting, processing (with animation), completed (showing the response), and failed (showing error with retry action).
- **FR-006**: The form MUST support multi-turn conversation by allowing follow-up messages after receiving a response, displaying all messages in a chat-like threaded layout.
- **FR-007**: The form MUST be fully responsive, adapting from mobile (< 640px) through tablet to desktop layouts.
- **FR-008**: The form MUST meet WCAG 2.1 Level AA accessibility standards — proper labels, keyboard navigation, focus management, ARIA live regions for status updates, and sufficient color contrast (4.5:1 for text).
- **FR-009**: The form MUST be embeddable on external websites via an iframe with a dedicated embed route.
- **FR-010**: The form MUST disable the submit button while a request is in flight to prevent duplicate submissions.
- **FR-011**: The form MUST display a character counter for the message field showing remaining characters out of the 2000-character limit.
- **FR-012**: The form MUST handle timeout scenarios (processing > 5 minutes) by displaying a timeout message with a retry option.
- **FR-013**: The form MUST handle network errors gracefully, preserving entered data and offering a retry mechanism.
- **FR-014**: The form MUST auto-scroll to the latest message in the conversation thread when a new response arrives.
- **FR-015**: The form MUST include a health check indicator that verifies backend availability via `GET /health` on initial load.
- **FR-016**: The form MUST enforce a 10-second cooldown after each submission — the submit button remains disabled during this period to prevent rapid-fire spam.
- **FR-017**: After the first submission, the form MUST collapse the name and email fields into a compact header bar and transition to a message-only input for follow-up messages.
- **FR-018**: The form MUST render agent responses as markdown — supporting bold, italic, lists, links, and code blocks — while sanitizing any raw HTML to prevent XSS.

### Key Entities

- **Message**: A single unit of communication in the conversation thread. Has a direction (customer or agent), text content, timestamp, and status (sent, processing, completed, failed).
- **Conversation**: An ordered collection of messages within a single session. Maintained on the client side. Resets on page refresh.
- **Job**: A reference to a backend processing task. Has a job_id, status (processing, completed, failed), response text (when completed), and error text (when failed). Mapped 1:1 to a customer message submission.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Customers can submit a support request and receive an AI-generated response in a single, uninterrupted flow — from form fill to response display — within 60 seconds under normal conditions.
- **SC-002**: Customers can complete a multi-turn conversation (3+ exchanges) without page refreshes, with all messages visible in the thread.
- **SC-003**: The form is fully usable on viewports from 320px to 1920px wide without horizontal scrolling or overlapping elements.
- **SC-004**: All interactive elements are reachable and operable via keyboard-only navigation, with visible focus indicators.
- **SC-005**: Screen reader users can complete the full support flow — field entry, submission, status awareness, and response reading — without sighted assistance.
- **SC-006**: 100% of error scenarios (network failure, server error, timeout, expired job) display a user-friendly message with a clear recovery action.
- **SC-007**: The form can be embedded in an external HTML page via iframe and functions identically to the standalone version.
- **SC-008**: All form components pass automated tests — unit tests for components, integration tests for the polling flow, and accessibility audits.

## Clarifications

### Session 2026-03-06

- Q: Should the form include spam/abuse protection given it's publicly accessible with no authentication? → A: Client-side throttle — disable submit for 10 seconds after each submission.
- Q: After first submission, how should the form handle name/email fields for follow-ups? → A: Collapse name/email into a header bar, show only the message input for follow-ups.
- Q: Should the form render agent responses as plain text or formatted content? → A: Markdown rendering — support bold, lists, links, code blocks.

## Assumptions

- The backend API (`POST /api/chat`, `GET /api/jobs/{job_id}`, `GET /health`) is already implemented and stable. The frontend only needs to integrate with these existing endpoints.
- Conversation history is maintained on the client side only (in component state). Server-side persistence of conversation threads is out of scope for this feature.
- The backend handles CORS headers to allow cross-origin requests from the embedded widget. If not currently configured, cross-origin support will need to be added to the backend as a dependency.
- The `channel` field is always `"web"` for this form. Channel selection is not user-facing.
- No user authentication is required — the form is publicly accessible. The customer identifies themselves via name and email fields.
- The embed mode uses an iframe pointing to a dedicated `/embed` route that renders the form without the full page layout (no header/footer).
- Page refresh clears conversation history. This is an acceptable limitation for the current scope.

## Scope Boundaries

### In Scope

- Web application with form page and embed page
- Client-side form validation
- Async submission + polling integration with existing backend
- Chat-like conversation thread UI
- Responsive layout (mobile-first)
- Accessibility (WCAG 2.1 AA)
- Embeddable iframe mode
- Error handling and retry mechanisms
- Component and integration tests

### Out of Scope

- Server-side conversation persistence (conversation resets on page refresh)
- User authentication or login
- File/image attachment uploads
- Real-time WebSocket updates (polling is the chosen mechanism, matching the backend design)
- Email notifications to the customer after the session
- Analytics or tracking
- Internationalization (i18n) — English only
- Dark mode (single theme only)

## Dependencies

- **Backend API**: `POST /api/chat`, `GET /api/jobs/{job_id}`, `GET /health` endpoints (Feature 004, already implemented)
- **CORS Configuration**: Backend must allow cross-origin requests from the frontend's origin (may require adding cross-origin middleware if not already present)
