# Improvements Pending Rod's Approval — March 18, 2026

## 🚨 Blockers
- **Metric Token Re-auth**: Google Analytics (GA4) and Search Console tokens have expired. 
  - **Impact**: No metrics collection for Xdares/PP.
  - **Action Required**: Rod needs to run `python3 scripts/xdares-metrics-auth.py` and follow the OAuth flow.
- **Model Confirmation Failure**: The system is failing to confirm `google/gemini-3.1-pro-preview` or `opus-4-6`, falling back to `gemini-3-flash-preview`.
  - **Impact**: Lower reasoning quality for complex tasks.
  - **Action Required**: Verify model availability/API keys in `openclaw config`.

## 📈 Strategic Suggestions
- **Competitive Response Campaign**: Draft a campaign around "Authority > Scanning" (governance over assessment) as discussed today.
- **Factory Pipeline Purge**: `idea-019` (Inline diff viewer) has been stuck for 127 hours. Recommend killing or re-scoping if no progress is made by tomorrow.
