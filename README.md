<p align="center">
  <img src="https://img.shields.io/badge/❌_No_Receipt-No_Merge-red?style=for-the-badge" alt="No Receipt → No Merge">
</p>

<h1 align="center">Permission Protocol Demo</h1>

<p align="center">
  <strong>Try to merge without approval. You can't.</strong>
</p>

<p align="center">
  <img src="assets/demo.gif" alt="Permission Protocol Demo" width="700">
</p>

<p align="center">
  <a href="https://github.com/permission-protocol/pp-demo/pull/1">
    <img src="https://img.shields.io/badge/🔴_LIVE_DEMO-PR_%231_Blocked-critical?style=flat-square" alt="Live Demo">
  </a>
  <img src="https://img.shields.io/badge/🛡️_Deploy_Gate-Enabled-success?style=flat-square" alt="Deploy Gate Enabled">
  <a href="https://permissionprotocol.com">
    <img src="https://img.shields.io/badge/Permission_Protocol-Visit-blue?style=flat-square" alt="Permission Protocol">
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Repos_Protected-3-blueviolet?style=flat-square" alt="Repos Protected">
  <img src="https://img.shields.io/badge/Approvals_Issued-12-blue?style=flat-square" alt="Approvals Issued">
</p>

---

## ⚡ Quickstart (3 minutes)

<p align="center">
  <a href="https://github.com/permission-protocol/pp-demo/generate">
    <img src="https://img.shields.io/badge/Use_This_Template-→-green?style=for-the-badge" alt="Use Template">
  </a>
</p>

1. Click **"Use this template"** above
2. Add your `PP_API_KEY` secret ([get one here](https://app.permissionprotocol.com))
3. Open a PR → Watch it fail → Approve → Merge

**You're protected.** No setup files. No config. Just works.

---

## 🎬 See It In Action

```
┌─────────────────────────────────────────────────────────────┐
│  PR #1: test: Trigger PP deploy gate                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ❌ Deploy Gate — FAILED                                    │
│                                                             │
│  ═══════════════════════════════════════════════════════   │
│    🔐 PERMISSION PROTOCOL - Deploy Authorization Required   │
│  ═══════════════════════════════════════════════════════   │
│                                                             │
│  ❌ NO RECEIPT - Approval required                          │
│                                                             │
│  This PR changes protected deployment files.                │
│  A human must approve before merge.                         │
│                                                             │
│  👉 APPROVE HERE: https://app.permissionprotocol.com/...    │
│                                                             │
│  After approval, re-run this workflow.                      │
│  ═══════════════════════════════════════════════════════   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**[→ View the actual blocked PR](https://github.com/permission-protocol/pp-demo/pull/1)**

---

## The Problem

Your AI agent just pushed to main.  
It passed CI.  
It deployed to production.

**Who approved it?**

Not a human. Not a policy. **Nobody.**

---

## The Solution

```
No Receipt → No Merge
```

Every deploy requires a cryptographic receipt. Signed by a human. Auditable forever.

---

## How It Works

```
   PR opened
       │
       ▼
┌──────────────────┐
│  CI runs check   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌─────────────────────┐
│ Receipt exists?  │────▶│  ✅ Merge allowed   │
└────────┬─────────┘ YES └─────────────────────┘
         │ NO
         ▼
┌──────────────────┐
│  ❌ CI FAILS     │
│  Shows approval  │
│  link in logs    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Human approves   │
│ in PP dashboard  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Re-run CI        │
│ ✅ Now passes    │
└──────────────────┘
```

---

## Try It Yourself

### 1. Fork this repo
[![Fork](https://img.shields.io/badge/Fork_This_Repo-→-green?style=for-the-badge)](https://github.com/permission-protocol/pp-demo/fork)

### 2. Set up Permission Protocol
See [SETUP.md](./SETUP.md) for full instructions.

### 3. Open a PR touching `deploy/`
```bash
git checkout -b test-gate
echo "# test" >> deploy/config.yml
git commit -am "test: trigger gate"
git push origin test-gate
# Open PR → Watch it fail → Approve → Watch it pass
```

---

## Protected Paths

Any PR touching these paths requires PP approval:

| Path | Why |
|------|-----|
| `deploy/*` | Production configuration |
| `.github/workflows/*` | CI/CD pipeline |

---

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
  "approver": "you@company.com",
  "signature": "0x...",
  "expiresAt": "2026-02-21T00:00:00Z"
}
```

Immutable. Auditable. Cryptographically signed.

---

<p align="center">
  <a href="https://permissionprotocol.com/#waitlist">
    <img src="https://img.shields.io/badge/Get_Permission_Protocol-Request_Access-black?style=for-the-badge" alt="Get Access">
  </a>
</p>

<p align="center">
  <sub>Built by <a href="https://permissionprotocol.com">Permission Protocol</a> · The Signer of Record for Autonomous Systems</sub>
</p>
