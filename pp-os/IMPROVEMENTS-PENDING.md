# IMPROVEMENTS-PENDING.md — Mar 24, 2026

The following improvements require your approval or additional access.

## [PP/Xdares] Automated CDN/Cache Purge Tooling
- **Problem**: The Xdares mobile age-gate has been blocked for days by 10Web/CDN caching. I have no direct tool to "bust" this cache programmatically when a fix is deployed.
- **Proposed Fix**: Create a dedicated `infra` skill or `scripts/purge-cache.sh` that uses 10Web and Cloudflare APIs to clear specific URL paths (e.g., `/`) after a deployment or environment change.
- **Status**: Pending Rod to provide API tokens for 10Web and Cloudflare.
- **Risk**: Low. Safe write operation.

## [PP] Browser Session Persistence (Login Automation)
- **Problem**: Launch day engagement (HN/X) was limited because I didn't have a logged-in session. Manual browser interaction is slow.
- **Proposed Fix**: Use Playwright's persistent context or `browser` tool profiles to store and reuse authenticated sessions for key launch-day domains (Hacker News, X, GitHub).
- **Status**: Pending Rod to log in once manually via the browser tool and confirm persistent profile storage.
- **Risk**: Moderate. Involves credentials and persistent sessions.

## [PP] Hot-fix Circuit Breaker
- **Problem**: Multiple attempts to fix the "checkbox bug" (synthetic click handling) in test tooling.
- **Proposed Fix**: Implement a `Circuit Breaker` protocol for test automation: if 3+ attempts to "fix" a UI element via synthetic clicks fail, the system should automatically fallback to `eval` (manually setting state) or request a developer review of the DOM implementation.
- **Status**: Ready to draft as a PR for `pp-os/testing`.
- **Risk**: Low.
