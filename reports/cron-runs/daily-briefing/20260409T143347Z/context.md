## Focus
Path: /Users/moltbot/.openclaw/workspace/FOCUS.md

```
# FOCUS.md — 28-Day Sprint Filter

**Period:** March 8 → April 4, 2026  
**Single wedge:** AI coding agents (Codex, Cursor, Claude Code) deploying code **without Permission Protocol**

---

## The Question

Before doing ANY task, ask:

> **"Does this directly help AI coding agents use Permission Protocol's deploy-gate?"**

If no → it's paused. If yes → do it.

---

## Success Criteria

- 5+ external users with deploy-gate installed
- 1+ completing the full flow (install → request → approve → deploy)

---

## In Scope

- Deploy-gate product (webhook, review surface, API)
- Demo video of the deploy-gate flow
- Dogfooding on PP + Xdares repos
- Finding + onboarding design partners (AI agent users, devs)
- GitHub App for one-click repo connection (Phase B)
- Show HN post (Week 3)

## Out of Scope (Paused)

- Scout pipeline / outreach to general founders
- Marketing content, social posting (unless directly about deploy-gate)
- Xdares SEO / blog publishing
- Any new features unrelated to deploy-gate
- Brand polish, website redesign, etc.

---

## Week Plan

| Week | Focus |
|------|-------|
| 1 (Mar 8-14) | Deploy-gate perfection + demo video + dogfood on our repos |
| 2 (Mar 15-21) | Find 10 potential users, get 3 to try. Design partner deadline. |
| 3 (Mar 22-28) | Iterate on user feedback. Show HN. |
| 4 (Mar 29-Apr 4) | 5+ active users. Decision: double down or pivot. |

---

## Paused Crons (13 total)

scout-response-monitor, scout-delivery, scout-followup, scout-outreach-draft, scout-research, scout-active-learning, scout-campaign-monitor, marketing-publisher, marketing-engagement-monitor, marketing-content-draft, marketing-active-learning, unified-engagement

---

_Created: 2026-03-07. Update weekly with sprint progress._
```

## PP Status
Path: /Users/moltbot/.openclaw/workspace/pp-os/STATUS.md

```
# PP Status — Last Updated: 2026-04-09 08:20 AM MDT

## Active Right Now
- **Mode:** Week 5 Sprint — Outreach & Polish V2 (Apr 9–15)
- **Sprint Goal:** 10 active external installations + Product Hunt launch.
- **Outreach Drought:** Day 48. 🔴 CRITICAL. Zero installs. Signer Decision required.
- **Onboarding status:** OPTIMIZED (Zero-auth confirmation page + headless provisioning).

## P0 — Requires Action Today

### 🔴 ROD ACTION REQUIRED
- **OUTREACH DROUGHT (Day 48)** — Stale drafts pending >24h:
    - `idea-092` (Sycamore/Sri Viswanath)
    - `Trent AI Outreach` (Eno Thereska)
- **Loom Recording** — Script provided in #wedges. Ready to record on `demo-repository`.
- **Homepage Review** — Final site branch `feat/consequence-engine-site` ready for review.

### Charles (READY to execute)
- **Site Deploy** — Push `feat/consequence-engine-site` once Rod approves.
- **Outreach Send** — Ship Sycamore/Trent AI once Loom is done.
- **Test PR** — Open a PR in a fresh repo to verify headless provisioning.

## BLOCKED (needs Rod)
- **idea-092** — Sycamore/Sri Viswanath outreach (approval pending — Day 48)
- **idea-098** — Trent AI/Eno Thereska outreach (approval pending — Day 48)
- **idea-085** — PostHog/Stripe conversion audit (GA4 token expired)
- **idea-082** — X API write permissions (tier upgrade)
- **idea-086** — Paperclip port 3100 on pp-scout-sfo2 (SSH needed)

## Backlog
- **idea-042** — Actionable error UX: every error has a fix path (M)
- **idea-080** — Fix PostHog generic event names (S)
- **idea-084** — MCP Guard v0.2 spec (M)

## Recent Decisions
- (Apr 8) Consequence Engine SHIPPED. 5-day sprint compressed into 1 day.
- (Apr 8) Denied status = hard stop (no authorize button). Path: fix code.
- (Apr 8) Per-repo comment quieting. First 5 cleared PRs comment, then silent.
- (Apr 7) Critical Fix Pattern established: every high-impact bug fix requires a persistent monitoring script and a daily cron.

## Recently Shipped
- Consequence Engine (Engine, Router, Routing, Receipts, Design v2) ✅
- PR #314: Launch alerts ✅
- Onboarding smoke test script ✅
- PKCS#8 GitHub App auth fix ✅
```

## Heartbeat Rules
Path: /Users/moltbot/.openclaw/workspace/HEARTBEAT.md

```
# HEARTBEAT.md Template

```markdown
# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.
```
```

## Heartbeat Check
Command: `bash "/Users/moltbot/.openclaw/workspace/scripts/heartbeat-check.sh"`

```
{
  "status": "watch",
  "alerts": [],
  "warnings": [
    "cron:scout-reddit-digest - 2 error(s): ?? ?? Message failed",
    "cron:governance-integrity-check - 1 error(s): cron: job execution timed out",
    "cron:pp-os-weekly-review - 1 error(s): cron: job execution timed out"
  ],
  "cron_errors": 3,
  "gateway_processes": 1,
  "disk_usage_pct": 12,
  "cooldown": "unknown"
}
```

## Thread State Validation
Command: `python3 "/Users/moltbot/.openclaw/workspace/ops/threads_manager.py" validate "/Users/moltbot/.openclaw/workspace/ops/threads.yaml"`

```
VALID 49 threads
```

## Workspace Git Status
Command: `git -C "/Users/moltbot/.openclaw/workspace" status --short --branch`

```
## log/2026-04-09
 M ACTIVE_CONTEXT.md
 m Xdares
 M company-os/governance/drift-log.jsonl
 M company-os/governance/scripts/governance-check.sh
 M company-os/governance/snapshots/gov_scan_latest.json
 M factory/.last_sentry_scan
 M factory/ideas.jsonl
 M factory/scripts/github-sensor.sh
 M factory/scripts/spec.sh
 M factory/thread-map.json
 M goals/xdares-seo-growth/state.json
 M logs/crons/daily-briefing.log
 M logs/crons/unified-hotline.log
 m mcp-guard
 M memory/2026-04-09.md
 M memory/heartbeat-state.json
 D node_modules/.bin/playwright
 D node_modules/.bin/playwright-core
 M node_modules/.package-lock.json
 D node_modules/@playwright/test/LICENSE
 D node_modules/@playwright/test/NOTICE
 D node_modules/@playwright/test/README.md
 D node_modules/@playwright/test/cli.js
 D node_modules/@playwright/test/index.d.ts
 D node_modules/@playwright/test/index.js
 D node_modules/@playwright/test/index.mjs
 D node_modules/@playwright/test/package.json
 D node_modules/@playwright/test/reporter.d.ts
 D node_modules/@playwright/test/reporter.js
 D node_modules/@playwright/test/reporter.mjs
 D node_modules/playwright-core/LICENSE
 D node_modules/playwright-core/NOTICE
 D node_modules/playwright-core/README.md
 D node_modules/playwright-core/ThirdPartyNotices.txt
 D node_modules/playwright-core/bin/install_media_pack.ps1
 D node_modules/playwright-core/bin/install_webkit_wsl.ps1
 D node_modules/playwright-core/bin/reinstall_chrome_beta_linux.sh
 D node_modules/playwright-core/bin/reinstall_chrome_beta_mac.sh
 D node_modules/playwright-core/bin/reinstall_chrome_beta_win.ps1
 D node_modules/playwright-core/bin/reinstall_chrome_stable_linux.sh
 D node_modules/playwright-core/bin/reinstall_chrome_stable_mac.sh
 D node_modules/playwright-core/bin/reinstall_chrome_stable_win.ps1
 D node_modules/playwright-core/bin/reinstall_msedge_beta_linux.sh
 D node_modules/playwright-core/bin/reinstall_msedge_beta_mac.sh
 D node_modules/playwright-core/bin/reinstall_msedge_beta_win.ps1
 D node_modules/playwright-core/bin/reinstall_msedge_dev_linux.sh
 D node_modules/playwright-core/bin/reinstall_msedge_dev_mac.sh
 D node_modules/playwright-core/bin/reinstall_msedge_dev_win.ps1
 D node_modules/playwright-core/bin/reinstall_msedge_stable_linux.sh
 D node_modules/playwright-core/bin/reinstall_msedge_stable_mac.sh
 D node_modules/playwright-core/bin/reinstall_msedge_stable_win.ps1
 D node_modules/playwright-core/browsers.json
 D node_modules/playwright-core/cli.js
 D node_modules/playwright-core/index.d.ts
 D node_modules/playwright-core/index.js
 D node_modules/playwright-core/index.mjs
 D node_modules/playwright-core/lib/androidServerImpl.js
 D node_modules/playwright-core/lib/bootstrap.js
 D node_modules/playwright-core/lib/browserServerImpl.js
 D node_modules/playwright-core/lib/cli/browserActions.js
 D node_modules/playwright-core/lib/cli/driver.js
 D node_modules/playwright-core/lib/cli/installActions.js
 D node_modules/playwright-core/lib/cli/program.js
 D node_modules/playwright-core/lib/cli/programWithTestStub.js
 D node_modules/playwright-core/lib/client/android.js
 D node_modules/playwright-core/lib/client/api.js
 D node_modules/playwright-core/lib/client/artifact.js
 D node_modules/playwright-core/lib/client/browser.js
 D node_modules/playwright-core/lib/client/browserContext.js
 D node_modules/playwright-core/lib/client/browserType.js
 D node_modules/playwright-core/lib/client/cdpSession.js
 D node_modules/playwright-core/lib/client/channelOwner.js
 D node_modules/playwright-core/lib/client/clientHelper.js
 D node_modules/playwright-core/lib/client/clientInstrumentation.js
 D node_modules/playwright-core/lib/client/clientStackTrace.js
 D node_modules/playwright-core/lib/client/clock.js
 D node_modules/playwright-core/lib/client/connect.js
 D node_modules/playwright-core/lib/client/connection.js
 D node_modules/playwright-core/lib/client/consoleMessage.js
 D node_modules/playwright-core/lib/client/coverage.js
 D node_modules/playwright-core/lib/client/debugger.js
 D node_modules/playwright-core/lib/client/dialog.js
 D node_modules/playwright-core/lib/client/disposable.js
 D node_modules/playwright-core/lib/client/download.js
 D node_modules/playwright-core/lib/client/electron.js
 D node_modules/playwright-core/lib/client/elementHandle.js
 D node_modules/playwright-core/lib/client/errors.js
 D node_modules/playwright-core/lib/client/eventEmitter.js
 D node_modules/playwright-core/lib/client/events.js
 D node_modules/playwright-core/lib/client/fetch.js
 D node_modules/playwright-core/lib/client/fileChooser.js
 D node_modules/playwright-core/lib/client/fileUtils.js
 D node_modules/playwright-core/lib/client/frame.js
 D node_modules/playwright-core/lib/client/harRouter.js
 D node_modules/playwright-core/lib/client/input.js
 D node_modules/playwright-core/lib/client/jsHandle.js
 D node_modules/playwright-core/lib/client/jsonPipe.js
 D node_modules/playwright-core/lib/client/localUtils.js
 D node_modules/playwright-core/lib/client/locator.js
 D node_modules/playwright-core/lib/client/network.js
 D node_modules/playwright-core/lib/client/page.js
 D node_modules/playwright-core/lib/client/platform.js
 D node_modules/playwright-core/lib/client/playwright.js
 D node_modules/playwright-core/lib/client/screencast.js
 D node_modules/playwright-core/lib/client/selectors.js
 D node_modules/playwright-core/lib/client/stream.js
 D node_modules/playwright-core/lib/client/timeoutSettings.js
 D node_modules/playwright-core/lib/client/tracing.js
 D node_modules/playwright-core/lib/client/types.js
 D node_modules/playwright-core/lib/client/video.js
 D node_modules/playwright-core/lib/client/waiter.js
 D node_modules/playwright-core/lib/client/webError.js
 D node_modules/playwright-core/lib/client/worker.js
 D node_modules/playwright-core/lib/client/writableStream.js
 D node_modules/playwright-core/lib/generated/bindingsControllerSource.js
 D node_modules/playwright-core/lib/generated/clockSource.js
 D node_modules/playwright-core/lib/generated/injectedScriptSource.js
 D node_modules/playwright-core/lib/generated/pollingRecorderSource.js
 D node_modules/playwright-core/lib/generated/storageScriptSource.js
 D node_modules/playwright-core/lib/generated/utilityScriptSource.js
 D node_modules/playwright-core/lib/generated/webSocketMockSource.js
 D node_modules/playwright-core/lib/inProcessFactory.js
 D node_modules/playwright-core/lib/inprocess.js
 D node_modules/playwright-core/lib/mcpBundle.js
 D node_modules/playwright-core/lib/mcpBundleImpl.js
 D node_modules/playwright-core/lib/outofprocess.js
 D node_modules/playwright-core/lib/protocol/serializers.js
 D node_modules/playwright-core/lib/protocol/validator.js
 D node_modules/playwright-core/lib/protocol/validatorPrimitives.js
 D node_modules/playwright-core/lib/remote/playwrightConnection.js
 D node_modules/playwright-core/lib/remote/playwrightPipeServer.js
 D node_modules/playwright-core/lib/remote/playwrightServer.js
 D node_modules/playwright-core/lib/remote/playwrightWebSocketServer.js
 D node_modules/playwright-core/lib/remote/serverTransport.js
 D node_modules/playwright-core/lib/server/android/android.js
 D node_modules/playwright-core/lib/server/android/backendAdb.js
 D node_modules/playwright-core/lib/server/artifact.js
 D node_modules/playwright-core/lib/server/bidi/bidiBrowser.js
 D node_modules/playwright-core/lib/server/bidi/bidiChromium.js
 D node_modules/playwright-core/lib/server/bidi/bidiConnection.js
 D node_modules/playwright-core/lib/server/bidi/bidiDeserializer.js
 D node_modules/playwright-core/lib/server/bidi/bidiExecutionContext.js
 D node_modules/playwright-core/lib/server/bidi/bidiFirefox.js
 D node_modules/playwright-core/lib/server/bidi/bidiInput.js
 D node_modules/playwright-core/lib/server/bidi/bidiNetworkManager.js
 D node_modules/playwright-core/lib/server/bidi/bidiOverCdp.js
 D node_modules/playwright-core/lib/server/bidi/bidiPage.js
 D node_modules/playwright-core/lib/server/bidi/bidiPdf.js
 D node_modules/playwright-core/lib/server/bidi/third_party/bidiCommands.d.js
 D node_modules/playwright-core/lib/server/bidi/third_party/bidiKeyboard.js
 D node_modules/playwright-core/lib/server/bidi/third_party/bidiProtocol.js
 D node_modules/playwright-core/lib/server/bidi/third_party/bidiProtocolCore.js
 D node_modules/playwright-core/lib/server/bidi/third_party/bidiProtocolPermissions.js
 D node_modules/playwright-core/lib/server/bidi/third_party/bidiSerializer.js
 D node_modules/playwright-core/lib/server/bidi/third_party/firefoxPrefs.js
 D node_modules/playwright-core/lib/server/browser.js
 D node_modules/playwright-core/lib/server/browserContext.js
 D node_modules/playwright-core/lib/server/browserType.js
 D node_modules/playwright-core/lib/server/callLog.js
 D node_modules/playwright-core/lib/server/chromium/appIcon.png
 D node_modules/playwright-core/lib/server/chromium/chromium.js
 D node_modules/playwright-core/lib/server/chromium/chromiumSwitches.js
 D node_modules/playwright-core/lib/server/chromium/crBrowser.js
 D node_modules/playwright-core/lib/server/chromium/crConnection.js
 D node_modules/playwright-core/lib/server/chromium/crCoverage.js
 D node_modules/playwright-core/lib/server/chromium/crDevTools.js
 D node_modules/playwright-core/lib/server/chromium/crDragDrop.js
 D node_modules/playwright-core/lib/server/chromium/crExecutionContext.js
 D node_modules/playwright-core/lib/server/chromium/crInput.js
 D node_modules/playwright-core/lib/server/chromium/crNetworkManager.js
 D node_modules/playwright-core/lib/server/chromium/crPage.js
 D node_modules/playwright-core/lib/server/chromium/crPdf.js
 D node_modules/playwright-core/lib/server/chromium/crProtocolHelper.js
 D node_modules/playwright-core/lib/server/chromium/crServiceWorker.js
 D node_modules/playwright-core/lib/server/chromium/defaultFontFamilies.js
 D node_modules/playwright-core/lib/server/chromium/protocol.d.js
 D node_modules/playwright-core/lib/server/clock.js
 D node_modules/playwright-core/lib/server/codegen/csharp.js
 D node_modules/playwright-core/lib/server/codegen/java.js
 D node_modules/playwright-core/lib/server/codegen/javascript.js
 D node_modules/playwright-core/lib/server/codegen/jsonl.js
 D node_modules/playwright-core/lib/server/codegen/language.js
 D node_modules/playwright-core/lib/server/codegen/languages.js
 D node_modules/playwright-core/lib/server/codegen/python.js
 D node_modules/playwright-core/lib/server/codegen/types.js
 D node_modules/playwright-core/lib/server/console.js
 D node_modules/playwright-core/lib/server/cookieStore.js
 D node_modules/playwright-core/lib/server/debugController.js
 D node_modules/playwright-core/lib/server/debugger.js
 D node_modules/playwright-core/lib/server/deviceDescriptors.js
 D node_modules/playwright-core/lib/server/deviceDescriptorsSource.json
 D node_modules/playwright-core/lib/server/dialog.js
 D node_modules/playwright-core/lib/server/dispatchers/androidDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/artifactDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/browserContextDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/browserDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/browserTypeDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/cdpSessionDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/debugControllerDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/debuggerDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/dialogDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/dispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/disposableDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/electronDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/elementHandlerDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/frameDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/jsHandleDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/jsonPipeDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/localUtilsDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/networkDispatchers.js
 D node_modules/playwright-core/lib/server/dispatchers/pageDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/playwrightDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/streamDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/tracingDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/webSocketRouteDispatcher.js
 D node_modules/playwright-core/lib/server/dispatchers/writableStreamDispatcher.js
 D node_modules/playwright-core/lib/server/disposable.js
 D node_modules/playwright-core/lib/server/dom.js
 D node_modules/playwright-core/lib/server/download.js
```

