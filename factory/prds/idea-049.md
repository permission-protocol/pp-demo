# PRD: idea-049 — Color-Code Environment Badges

**Issue:** permission-protocol/app#124  
**Priority:** P2  
**Repo:** permission-protocol/app

## Problem
Environment label on deploy request detail is plain text, easy to miss. No visual differentiation between production and staging.

## Requirements
- Production badge: amber/warm background (`bg-amber-500/20 text-amber-400 border-amber-500/30`)
- Staging badge: blue/cool background (`bg-blue-500/20 text-blue-400 border-blue-500/30`)  
- Development badge: green (`bg-green-500/20 text-green-400 border-green-500/30`)
- Badge should be prominent — same visual weight as the status badge (Approved/Denied)
- Apply everywhere environment appears: detail page, queue list, dashboard activity

## Must NOT Do
- Don't change the data model
- Don't add new environment types

## QA Failure Notes (Retry #1)
**Failures:** typescript:1_errors
**TypeScript errors:**
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
```

