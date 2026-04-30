# Apollo.io Runbook

## 1. Account Setup
- **Signup URL:** [https://www.apollo.io/sign-up](https://www.apollo.io/sign-up)
- **Free Tier Limits:** 
  - 10,000 email credits/mo
  - 250 emails sent/day
  - Connect 1 mailbox (use your dedicated outreach domain)
- **When to upgrade:** Upgrade to Basic ($59/mo) when you need to send >250 emails/day or need advanced rules/A-B testing.

## 2. Import Prospects
1. Go to **Search** > **People**.
2. Click **Import** (top right) > **Bulk Import from CSV**.
3. Upload `apollo-import-ready.csv`.
4. Map the columns:
   - First Name → First Name
   - Last Name → Last Name
   - Title → Title
   - Company → Company
   - Company Domain → Account Website
   - LinkedIn URL → LinkedIn Profile URL
   - Email → Email
   - Custom Field 1 → Create a new custom field called `LI_PilotHook`
5. Click **Import**.

## 3. Verify Emails (For missing/guessed ones)
1. In your **Saved** contacts list, select all imported records without verified emails.
2. Click **Find Email**. Apollo will use its internal database and waterfall enrichment to verify.

## 4. Sequence Setup
1. Go to **Engage** > **Sequences** > **New Sequence**.
2. Name it "Sprint 5: Permission Protocol Alpha".
3. **Add Step 1:** Automatic Email (Day 1). Paste Email 1 from `apollo-email-sequence.md`.
4. **Add Step 2:** Automatic Email (Day 4). Paste Email 2 from `apollo-email-sequence.md`.
5. **Add Step 3:** Automatic Email (Day 8). Paste Email 3 from `apollo-email-sequence.md`.

## 5. Launch
1. Go to the Sequence's **Contacts** tab.
2. Click **Add Contacts**.
3. Select your imported list.
4. Click **Start Sequence**.

**Estimated Setup Time:** ~30 minutes to first send.
