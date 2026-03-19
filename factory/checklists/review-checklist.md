# Factory Code Review Checklist
# Version: 1.0 (2026-03-16)
# Adapted from gstack /review checklist for TypeScript/Next.js/Prisma stack.
# Used by: factory/scripts/review.sh
# This file is the SINGLE SOURCE OF TRUTH for what the paranoid review checks.
# Update this file to change review criteria — no script changes needed.

## Pass 1 — CRITICAL (blocks QA)

### Prisma/DB Safety
- Raw SQL with string interpolation (`prisma.$executeRaw` or `$queryRaw` without parameterized template literals)
- Missing `where` clause on `update`, `updateMany`, `delete`, `deleteMany` (accidental global mutation)
- Multi-step DB mutations without a `prisma.$transaction` wrapper (partial writes on failure)
- N+1 queries: Prisma `findMany` followed by per-record `findUnique` in a loop (should use `include` or `select` with relations)
- `upsert` on a field without a unique constraint (silent duplicates under concurrency)

### Auth & Trust Boundaries
- New API route (`app/api/...`) without auth check (missing `getServerSession` or auth middleware)
- User input from request body/params passed directly to Prisma without Zod/schema validation
- Missing CSRF protection on mutation endpoints (POST/PUT/DELETE without token verification)
- LLM-generated output (AI text, parsed JSON) stored to DB without format validation (email regex, URL parse, string length)
- Direct object reference: user A can access user B's data by manipulating IDs in the URL/params (missing ownership check)

### Race Conditions & Concurrency
- Status transitions without optimistic locking or atomic `WHERE old_status = X` (concurrent updates can skip or double-apply)
- `findFirst` → conditional `create` without unique constraint (TOCTOU: two requests create duplicates)
- Shared mutable state at module level in API routes (variables outside the handler function that persist between requests)
- Background job / webhook handler that doesn't check for duplicate delivery (idempotency key missing)

### Type Safety at Boundaries
- `as any` cast on data from external sources (API responses, webhooks, user input, DB results)
- Non-null assertion `!` on user-controlled or externally-sourced data
- Missing Zod/schema validation on API route input (`req.body` used raw)
- Environment variable used directly without type check (`process.env.X` assumed to be string without fallback)
- `JSON.parse()` without try/catch on external input

## Pass 2 — INFORMATIONAL (noted in report, doesn't block)

### Error Handling
- Bare `catch(e)` that swallows the error without logging or re-throwing
- `catch(e) { return NextResponse.json({ error: "Something went wrong" })` — generic message hiding the real error from logs
- Missing React error boundary on new page components
- API route returns 200 status code on error conditions (should be 4xx/5xx)
- Try/catch around Prisma without handling specific error types (`PrismaClientKnownRequestError`)

### Code Quality
- Same logic duplicated in 2+ files (utility function should be extracted)
- Unused imports or variables (dead code)
- `console.log` left in production code paths (should be structured logger or removed)
- TODO/FIXME/HACK comment without linked GitHub issue
- Magic numbers or string constants used in multiple places without named constant
- Commented-out code blocks (should be deleted, not commented)

### Test Gaps
- New API route with no corresponding test file
- Edge case described in PRD acceptance criteria with no test
- Error/failure path with no negative test
- New Prisma model/relation without seed or fixture data
- Assertions that check existence but not correctness (e.g., `expect(result).toBeDefined()` without checking values)

### Performance
- Prisma query inside a loop (should be batched with `findMany` + `where: { id: { in: ids } }`)
- Large data fetch without pagination (`findMany` without `take`/`skip` on user-facing endpoints)
- Missing database index on fields used in `where` clauses (check schema.prisma)
- Synchronous heavy computation in API route (should be background job)
- Image/asset URLs without optimization (next/image not used, or raw URLs for large files)

### Frontend
- Inline `style={{}}` objects created on every render (should be extracted or use CSS modules)
- Missing `key` prop in `.map()` renders, or using array index as key on dynamic lists
- `useEffect` with missing or incorrect dependency array
- Client component (`"use client"`) that could be a server component
- Large component (>200 lines) that should be split

## Suppressions — DO NOT flag these
- Pre-existing issues that exist on `main` but are NOT in the PR diff
- Style-only differences (formatting, import order, whitespace)
- TypeScript `any` in test files or test fixtures
- `console.log` in development-only code paths (behind `NODE_ENV` check)
- Type assertions in test setup code
- TODOs that reference a specific issue number (already tracked)
- Patterns that match the existing codebase convention even if not ideal (consistency > perfection)
