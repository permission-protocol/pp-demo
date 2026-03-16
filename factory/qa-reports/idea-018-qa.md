# QA Report: idea-018 — 30-second onboarding wizard — GitHub App install → first gate in 3 clicks
**Date:** 2026-03-13 19:51 UTC
**PR:** https://github.com/permission-protocol/app/pull/100
**Retry:** #0

## Automated Checks
- [ ] TypeScript: FAILED (119 errors)
```
permission-protocol-sdk/packages/examples/minimal-agent.ts(10,34): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
permission-protocol-sdk/packages/examples/minimal-agent.ts(25,19): error TS7006: Parameter 'receipt' implicitly has an 'any' type.
permission-protocol-sdk/packages/sdk/__tests__/hash.test.ts(14,31): error TS2307: Cannot find module '../../spec/golden-vectors.json' or its corresponding type declarations.
permission-protocol-sdk/packages/sdk/src/types.ts(8,10): error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'.
reference-demo/src/index.ts(23,34): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
reference-demo/src/output.ts(7,55): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
reference-demo/src/scenarios/invalid-receipt.ts(14,59): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
reference-demo/src/scenarios/invalid-receipt.ts(62,43): error TS18046: 'error' is of type 'unknown'.
reference-demo/src/scenarios/message.ts(8,54): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
reference-demo/src/scenarios/prod-write.ts(8,54): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
reference-demo/src/scenarios/spend.ts(8,54): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
reference-demo/src/scenarios/trust-tests.ts(20,96): error TS2307: Cannot find module '@permission-protocol/sdk' or its corresponding type declarations.
reference-demo/src/scenarios/trust-tests.ts(189,36): error TS18046: 'error' is of type 'unknown'.
reference-demo/src/scenarios/trust-tests.ts(190,39): error TS18046: 'error' is of type 'unknown'.
scripts/evaluate-company-memory.ts(115,5): error TS2322: Type 'boolean | undefined' is not assignable to type 'boolean'.
scripts/evaluate-company-memory.ts(138,5): error TS2322: Type 'boolean | undefined' is not assignable to type 'boolean'.
src/app/api/ceo/plan-tick/route.ts(13,33): error TS2304: Cannot find name 'requireAuthorizedCompanyAccess'.
src/app/api/dashboard/setup-state/route.ts(17,33): error TS2304: Cannot find name 'requireAuthorizedCompanyAccess'.
src/app/api/delegated-accounts/[id]/route.ts(32,27): error TS2552: Cannot find name 'getDelegatedAccount'. Did you mean 'deleteDelegatedAccount'?
src/app/api/delegated-accounts/feature/route.ts(26,27): error TS2552: Cannot find name 'isDelegatedAccountsEnabled'. Did you mean 'setDelegatedAccountsEnabled'?
```
- [x] Lint: clean
