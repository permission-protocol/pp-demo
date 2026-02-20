# Permission Protocol Demo

**Try to merge without approval. You can't.**

> 🔴 **[See it live: PR #1](https://github.com/permission-protocol/pp-demo/pull/1)** — CI failed, waiting for approval

This repo demonstrates [Permission Protocol](https://permissionprotocol.com) — cryptographic authorization for autonomous deployments.

## What Happens

1. **Open a PR** that touches `deploy/` or `.github/workflows/`
2. **CI fails** with a link to approve
3. **Approve** the deploy request in PP
4. **CI passes** — merge unlocked

No receipt → No merge. That's it.

## The Problem This Solves

Your AI agent just pushed to main.  
It passed CI.  
It deployed to production.

**Who approved it?**

Not a human. Not a policy. Nobody.

Permission Protocol closes that gap.

## Try It

1. Fork this repo
2. [Connect it to PP](https://app.permissionprotocol.com)
3. Open a PR touching `deploy/config.yml`
4. Watch the gate block
5. Approve in PP
6. Watch the gate pass

## How It Works

```
PR opened
    ↓
CI runs pp-verify action
    ↓
┌─────────────────────────────────┐
│  Receipt exists?                │
│  ├─ YES → ✅ Merge allowed      │
│  └─ NO  → ❌ Blocked            │
│           └─ Creates request    │
│           └─ Shows approval URL │
└─────────────────────────────────┘
    ↓
Human approves in PP dashboard
    ↓
Re-run CI → ✅ Pass
```

## The Receipt

Every approval generates a cryptographic receipt:

```json
{
  "id": "rec_abc123",
  "status": "APPROVED",
  "scope": {
    "repo": "permission-protocol/pp-demo",
    "prNumber": 1,
    "headSha": "abc123",
    "capability": "deploy:production"
  },
  "signature": "0x...",
  "expiresAt": "2024-02-21T00:00:00Z"
}
```

Immutable. Auditable. Cryptographically signed.

---

**[Get Permission Protocol →](https://permissionprotocol.com)**
