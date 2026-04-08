# Consequence Engine Gold Standard Test Set

This file contains 30 PR fixtures for testing the deterministic outcome router and LLM consequence brief engine.

## Rubric
- **Deterministic Outcome:** Must match the expected outcome (cleared/approval_required/denied).
- **Consequence Brief:** 
  - Is `potentialConsequence` specific (not "code change")?
  - Is it user/business/prod-facing?
  - Is evidence tied to the diff?
  - Are `verifyBefore` items sharp?
  - Does it avoid generic filler?

---

## 1-10: Expected CLEARED

### 1. README update
**Files:** `README.md`
**Outcome:** cleared

### 2. Documentation typo fix
**Files:** `docs/setup.md`
**Outcome:** cleared

### 3. CSS/Styling change
**Files:** `src/styles/main.css`
**Outcome:** cleared

### 4. Static image addition
**Files:** `public/images/logo.png`
**Outcome:** cleared

### 5. Rename local variable (refactor)
**Files:** `src/utils/math.ts` (internal rename only)
**Outcome:** cleared

### 6. New unit test
**Files:** `src/utils/math.test.ts`
**Outcome:** cleared

### 7. Translation update
**Files:** `locales/en.json`
**Outcome:** cleared

### 8. UI Copy update
**Files:** `src/components/Button.tsx` (text change only)
**Outcome:** cleared

### 9. Markdown CHANGELOG update
**Files:** `CHANGELOG.md`
**Outcome:** cleared

### 10. Helper function addition (low risk)
**Files:** `src/lib/string-utils.ts` (pure function, no side effects)
**Outcome:** cleared

---

## 11-20: Expected APPROVAL_REQUIRED

### 11. Auth session expiry change
**Files:** `src/lib/auth/session.ts`
**Outcome:** approval_required

### 12. New API endpoint (public)
**Files:** `src/app/api/v1/users/route.ts`
**Outcome:** approval_required

### 13. Dependency update (major)
**Files:** `package.json` (major version bump)
**Outcome:** approval_required

### 14. GitHub Action workflow change
**Files:** `.github/workflows/deploy.yml`
**Outcome:** approval_required

### 15. Billing logic update
**Files:** `src/lib/billing/stripe.ts`
**Outcome:** approval_required

### 16. Database migration (non-destructive)
**Files:** `prisma/migrations/.../migration.sql` (ADD COLUMN)
**Outcome:** approval_required

### 17. IAM/Role permission change
**Files:** `src/lib/auth/roles.ts`
**Outcome:** approval_required

### 18. Infra change (Terraform)
**Files:** `infra/main.tf`
**Outcome:** approval_required

### 19. Production environment variable access
**Files:** `src/lib/config.ts` (reading new secret)
**Outcome:** approval_required

### 20. Large refactor (50+ files)
**Files:** many files
**Outcome:** approval_required

---

## 21-30: Expected DENIED

### 21. Hardcoded Stripe secret
**Files:** `src/lib/stripe.ts` (contains `sk_live_...`)
**Outcome:** denied

### 22. Hardcoded GitHub PAT
**Files:** `src/lib/github.ts` (contains `ghp_...`)
**Outcome:** denied

### 23. Destructive migration (DROP TABLE)
**Files:** `prisma/migrations/.../migration.sql` (DROP TABLE "User")
**Outcome:** denied

### 24. Destructive migration (DROP COLUMN)
**Files:** `prisma/migrations/.../migration.sql` (ALTER TABLE "Account" DROP COLUMN "secret")
**Outcome:** denied

### 25. Auth bypass (manual override)
**Files:** `src/middleware.ts` (contains `if (process.env.BYPASS_AUTH) return next()`)
**Outcome:** denied

### 26. PII exposure without auth
**Files:** `src/app/api/debug/users/route.ts` (returns all users without session check)
**Outcome:** denied

### 27. CI/CD secret logging
**Files:** `.github/workflows/debug.yml` (echoes secrets to logs)
**Outcome:** denied

### 28. CORS allow-all in production
**Files:** `src/app/api/config.ts` (Access-Control-Allow-Origin: *)
**Outcome:** denied

### 29. Hardcoded database credentials
**Files:** `src/lib/db.ts` (contains connection string with password)
**Outcome:** denied

### 30. Secret committed to public assets
**Files:** `public/config.json` (contains API keys)
**Outcome:** denied
