# Permission Protocol: Design Partner Quick-Start Guide

Welcome to the future of agentic authority. Permission Protocol (PP) is the cryptographic enforcement layer that prevents your AI agents from taking unauthorized actions in production.

This guide will get you gated and secure in less than 5 minutes.

---

## 1. Install the Deploy Gate
The **Deploy Gate** is a GitHub Action that intercepts every PR and blocks the merge until a human (you) explicitly authorizes the deployment through the Permission Protocol dashboard.

Add this to your `.github/workflows/deploy.yml` (or your production deployment workflow):

```yaml
jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - name: Permission Protocol Deploy Gate
        uses: permission-protocol/deploy-gate@v1
        with:
          api-key: ${{ secrets.PP_API_KEY }}
          tenant-id: ${{ secrets.PP_TENANT_ID }}
```

**What happens next:** Every time an agent (or human) opens a PR, a new "Deploy Request" will appear in your PP dashboard. The merge will remain blocked by a red status check until authorized.

---

## 2. Connect the GitHub App
To allow Permission Protocol to automatically update your PR status and trigger the final merge after you approve, you must install the PP GitHub App.

1. Navigate to [app.permissionprotocol.com/settings/github](https://app.permissionprotocol.com/settings/github).
2. Click **Install GitHub App**.
3. Select the repositories you want to protect.
4. PP will now handle the status check handshake and auto-merge orchestration.

---

## 3. Your First Approval
When a PR is opened, you will receive a notification (Slack/Discord/Telegram).

1. Click the link to land on your **Approval Dashboard**.
2. **Review the AI Enrichment:** PP automatically generates a "risk-aware" summary of the changes. You don't need to read the diff to understand the blast radius.
3. **Check the Signals:** Look for the environment badge (Production/Staging) and risk indicators.
4. **Approve:** Click the **Approve & Merge** button.

---

## 4. The Authority Audit Trail
Every approval generates a **Cryptographic Receipt**.

- **Immutable:** Proof that a specific human authorized a specific set of code changes at a specific time.
- **Enriched:** The receipt contains the AI summary and risk assessment as it existed at the moment of approval.
- **Audit-Ready:** Perfect for compliance, incident response, and SOC2 audits.

View your receipts at `app.permissionprotocol.com/audit`.

---

## Support
Stuck? Rod is available in the shared Slack/Discord channel. We move fast, but we never merge without permission.
