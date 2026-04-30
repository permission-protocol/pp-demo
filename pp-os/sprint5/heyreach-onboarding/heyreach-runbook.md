# HeyReach Onboarding Runbook

## 1. Account Setup & Connection
- **Signup URL:** [https://heyreach.io/](https://heyreach.io/)
- **Connect LinkedIn:** Follow the integration flow to securely connect your LinkedIn account.
- **🚨 Anti-Detection / Throttle Settings:**
  - LinkedIn is strict right now. Set connection limits to **max 30 connection requests/day**.
  - Throttle sends: **8-12 invites per 45 minutes**.
  - Enable "working hours" to only send during normal daytime (e.g., 9AM - 6PM MST).

## 2. Import Prospects
1. Navigate to **Campaigns** > **Leads**.
2. Click **Import Leads** > **CSV Upload**.
3. Upload `heyreach-import.csv`.
4. Map the fields:
   - First Name → First Name
   - Last Name → Last Name
   - LinkedIn URL → LinkedIn Profile URL
   - Personalization → Custom Variable 1 (we'll use this as `{{custom_1}}` in the message)

## 3. Campaign Creation
1. Go to **Campaigns** > **Create Campaign**.
2. Select **Smart Sequence**.
3. Target: Select your newly imported lead list.

## 4. Sequence Logic
1. **Step 1:** Connection Request. Add note. Paste the "Connection Note" from `heyreach-message-sequence.md` (Uses `{{custom_1}}`).
2. **Step 2:** Wait 3 days after connection acceptance.
3. **Step 3:** Send Message. Paste "Day 3" message from `heyreach-message-sequence.md`.
4. **Step 4:** Wait 4 days.
5. **Step 5:** Send Message. Paste "Day 7" message.
6. **Step 6:** Wait 7 days.
7. **Step 7:** Send Message. Paste "Day 14" message.

## 5. Launch
- Review the campaign flow.
- Click **Start Campaign**.

**Estimated Setup Time:** ~30 minutes to first send.
