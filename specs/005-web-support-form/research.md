# Research: Web Support Form

**Feature**: 005-web-support-form
**Date**: 2026-03-06

## R1: Frontend Framework — Next.js 15 App Router

**Decision**: Next.js 15 with App Router, TypeScript, React 19
**Rationale**: Constitution specifies Next.js for the Web Support Form. App Router is the default in Next.js 15 and provides Server Components (for the page shell) and Client Components (for interactive form). React 19 ships with Next.js 15.
**Alternatives considered**:
- Pages Router: Legacy, no benefit for this use case
- Standalone React (Vite): Would work but loses SSR/routing benefits and doesn't match constitution

### Key Patterns
- **Server Components**: `app/page.tsx` and `app/embed/page.tsx` are server-rendered shells that import the client `<SupportForm>` component
- **Client Components**: All interactive components use `'use client'` directive — form inputs, chat thread, polling hooks
- **Environment variables**: `NEXT_PUBLIC_API_URL` for the backend URL (must have `NEXT_PUBLIC_` prefix to be available client-side)

## R2: Styling — Tailwind CSS

**Decision**: Tailwind CSS v4 (latest compatible with Next.js 15)
**Rationale**: Utility-first CSS eliminates the need for a component library. Responsive design via built-in breakpoint prefixes (`sm:`, `md:`, `lg:`). Excellent accessibility support with focus-visible utilities.
**Alternatives considered**:
- shadcn/ui: Would add components on top of Tailwind — overkill for 8 components
- CSS Modules: More boilerplate, less consistent responsive patterns
- Styled Components: SSR complexity with App Router

### Tailwind v4 Setup (differs from v3)
- Install: `npm install tailwindcss @tailwindcss/postcss postcss`
- No `tailwind.config.js` needed — configuration is CSS-first via `@theme` directives
- No `@tailwind base/components/utilities` — use `@import "tailwindcss"` in globals.css
- PostCSS config uses `@tailwindcss/postcss` as the plugin (not `tailwindcss`)
- Automatic content detection — no `content: [...]` array needed

## R3: Markdown Rendering

**Decision**: `react-markdown` with `remark-gfm` plugin
**Rationale**: react-markdown renders markdown as React components (no `dangerouslySetInnerHTML`). XSS-safe by default — HTML in markdown is escaped unless explicitly allowed. Supports GFM (GitHub Flavored Markdown) for tables, strikethrough, task lists. ~30KB gzipped.
**Alternatives considered**:
- `marked` + `DOMPurify`: Produces HTML strings requiring `dangerouslySetInnerHTML` — XSS risk if sanitizer misconfigured
- `markdown-it`: Similar HTML-string approach; heavier bundle
- Custom parser: Unnecessary complexity

## R4: Testing Strategy

**Decision**: Vitest + React Testing Library + @testing-library/jest-dom + @axe-core/react
**Rationale**: Vitest is faster than Jest for Vite/Next.js projects, has native ESM support, and compatible API. React Testing Library tests components from the user's perspective. @axe-core/react runs automated accessibility audits.
**Alternatives considered**:
- Jest: Slower cold start, requires more configuration for ESM/TypeScript
- Playwright: Better for E2E but heavier setup; RTL sufficient for component + integration tests
- Cypress: Similar to Playwright — E2E focus, not needed for component tests

### Test Categories
1. **Component tests**: Render each component in isolation, verify props/state/output
2. **Hook tests**: `renderHook` from RTL for custom hooks (polling, conversation state, cooldown)
3. **Integration tests**: Full `<SupportForm>` with mocked `fetch` — submit, poll, display response
4. **Accessibility tests**: axe-core audit on rendered components

## R5: Polling Pattern

**Decision**: Custom `useJobPolling` hook with `setTimeout` chain (not `setInterval`)
**Rationale**: `setTimeout` chain is more predictable — each poll waits for the previous to complete before scheduling the next. Respects `retry_after` from the API response. Easy to cancel via `clearTimeout` in cleanup. No external library needed.
**Alternatives considered**:
- `setInterval`: Doesn't account for response time; can stack requests if server is slow
- SWR `refreshInterval`: Lightweight (4KB), built-in dedup/focus-awareness, but adds a dependency for a single polling use case
- React Query `refetchInterval`: More powerful (~12KB) but overkill
- Server-Sent Events: Backend doesn't support SSE; would require backend changes

### Polling Flow
1. Submit → receive `job_id` + `retry_after`
2. After `retry_after` seconds → `GET /api/jobs/{job_id}`
3. If `status === "processing"` → schedule next poll using response's `retry_after`
4. If `status === "completed"` → extract response, stop polling
5. If `status === "failed"` → extract error, stop polling
6. If network error → retry up to 3 times, then show error
7. If elapsed > 5 minutes → treat as timeout, stop polling

## R6: CORS Configuration

**Decision**: No changes needed — already configured
**Rationale**: FastAPI backend already has `CORSMiddleware` with `allow_origins=["*"]`, `allow_methods=["*"]`, `allow_headers=["*"]`. This allows the Next.js dev server (localhost:3000) and embedded iframes from any origin to call the API.
**Alternatives considered**: None needed — existing configuration is sufficient.

## R7: Embed Strategy

**Decision**: Dedicated `/embed` route rendered in iframe
**Rationale**: An iframe provides complete style isolation — the host page's CSS cannot affect the form. The `/embed` route renders the `<SupportForm>` without the main page layout (no header/footer/nav). Website owners add `<iframe src="https://domain/embed" />`.
**Alternatives considered**:
- Web Component (Shadow DOM): Better integration but significantly more complex build pipeline; cross-browser Shadow DOM + React hydration is fragile
- Script tag injection: No style isolation; conflicts with host page inevitable
