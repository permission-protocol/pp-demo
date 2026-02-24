# PostHog Traffic Spike Analysis — Feb 23, 2026

**Issue:** #222 — Investigate PostHog traffic spike (92 pageviews, 23x normal)

## Data Summary

### Daily Pageviews (Feb 18–24)
| Date | Pageviews |
|------|-----------|
| Feb 18 | 0 |
| Feb 19 | 0 |
| Feb 20 | 0 |
| Feb 21 | 0 |
| Feb 22 | 4 |
| **Feb 23** | **92** |
| Feb 24 (partial) | 29 |

### Audience (Feb 23)
- **Unique users (DAU):** 5
- **Unique sessions:** 13
- **Avg pages/user:** ~18.4 (very high depth)

### Referrer Breakdown (Feb 23)
| Referrer | Pageviews |
|----------|-----------|
| www.permissionprotocol.com | 46 |
| $direct (no referrer) | 41 |
| Vercel preview (blog branch) | 3 |
| www.google.com | 2 |

### Page Breakdown (Feb 23)
| Page | Views |
|------|-------|
| / (homepage) | 71 |
| /request-access | 9 |
| /deploy-gate | 7 |
| /install | 3 |
| /architecture | 1 |
| /receipt-model | 1 |

### UTM Parameters
None — no tracked campaign links used.

## Verdict

**This is targeted human traffic, NOT organic SEO.**

Key signals:
1. **Only 5 unique users** driving 92 pageviews = ~18 pages/person. That's deliberate exploration, not casual browsing.
2. **41 direct + 46 internal nav** = people arrived without tracked referrer (DM, Slack, iMessage, email) then explored extensively.
3. **No UTM tags** = untracked share (likely Rod sharing with specific people or personal testing).
4. **9 visits to /request-access** = 18% of sessions hit the conversion page. High intent.
5. **2 Google referrals** = first organic signal (tiny but real).

## Strategic Interpretation

The spike is almost certainly:
- Rod sharing the site with 3–5 specific people for review/feedback
- OR Charles/Rod personal testing sessions
- High page depth (18.4 pages/user) suggests genuine interest or thorough review

**What this is NOT:** Organic SEO, viral social, or any distribution channel working autonomously.

## Recommendations

1. **Track future shares** — use UTM links when Rod shares (e.g., `?utm_source=direct-share&utm_medium=dm`)
2. **2 Google referrals = first SEO signal** — worth watching. Check which pages they landed on.
3. **9 /request-access views = conversion signal** — did anyone actually submit? Check form submissions.
4. **Baseline is ~4 pageviews/day** (Feb 22) — today (Feb 24) at 29 suggests the shared audience is still exploring.

## Analysis Date
February 24, 2026 — run by Charles
