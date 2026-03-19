# QA Report: {{IDEA_ID}} — {{TITLE}}

| Field | Value |
|-------|-------|
| **Date** | {{DATE}} |
| **Idea** | {{IDEA_ID}} |
| **PR** | {{PR_URL}} |
| **Branch** | {{BRANCH}} |
| **Repo** | {{REPO}} |
| **Retry** | #{{RETRY_COUNT}} |

## Health Score: {{SCORE}}/100 — {{GRADE}}

| Category | Weight | Score | Deductions |
|----------|--------|-------|------------|
| TypeScript | 25% | {{TSC_SCORE}}/100 | {{TSC_DEDUCTIONS}} |
| Tests | 20% | {{TEST_SCORE}}/100 | {{TEST_DEDUCTIONS}} |
| Code Review | 20% | {{REVIEW_SCORE}}/100 | {{REVIEW_DEDUCTIONS}} |
| Lint | 10% | {{LINT_SCORE}}/100 | {{LINT_DEDUCTIONS}} |
| File Coverage | 10% | {{COVERAGE_SCORE}}/100 | {{COVERAGE_DEDUCTIONS}} |
| Build Health | 15% | {{BUILD_SCORE}}/100 | {{BUILD_DEDUCTIONS}} |

**Action:** {{ACTION}}
- 🟢 95+ = auto-merge candidate
- 🟡 80-94 = flag for review
- 🟠 60-79 = needs attention
- 🔴 <60 = reject, needs rework

## Top Issues

1. {{TOP_ISSUE_1}}
2. {{TOP_ISSUE_2}}
3. {{TOP_ISSUE_3}}

## Automated Checks

### TypeScript
{{TSC_RESULT}}

### Lint
{{LINT_RESULT}}

### Tests
{{TEST_RESULT}}

### File Coverage
{{COVERAGE_RESULT}}

## Code Review (Paranoid)

### CRITICAL Findings
{{CRITICAL_FINDINGS}}

### INFORMATIONAL Findings
{{INFORMATIONAL_FINDINGS}}

## Diff Summary
Files changed: {{FILE_COUNT}}
```
{{DIFF_STAT}}
```

## PRD Acceptance Criteria
{{ACCEPTANCE_CRITERIA}}

## Ship Readiness

| Metric | Value |
|--------|-------|
| Health score | {{SCORE}}/100 |
| Critical findings | {{CRITICAL_COUNT}} |
| Informational findings | {{INFO_COUNT}} |
| TSC errors | {{TSC_ERRORS}} |
| Test failures | {{TEST_FAILURES}} |
| Verdict | {{VERDICT}} |
