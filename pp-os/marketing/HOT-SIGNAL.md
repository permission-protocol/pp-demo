# HOT SIGNAL — April 5th, 2026

## 🚨 Incident: Claude Code Malware Campaign & Source Leak
**Source:** [Wired](https://www.wired.com/story/security-news-this-week-hackers-are-posting-the-claude-code-leak-with-bonus-malware/), [Dark Reading](https://www.darkreading.com/application-security/source-code-leaks-highlight-lack-supply-chain-oversight)

**Summary:** 
Hackers are running sponsored Google ads leading to fake Claude Code installation guides. These guides contain a "one-liner" installation command that downloads malware instead of the Anthropic agent. Concurrently, reports of a Claude source code leak are circulating, allegedly involving a misconfigured GitHub Action that allowed attackers to capture credentials and push malicious code.

**Why it matters for PP:** 
This is a prime example of the "Authority Gap." Users are eager to deploy agents (Claude Code) and are bypassing security checks to get them running. PP's "Authority over Assessment" is the solution—verifying the identity of the signer (Anthropic) and the integrity of the agent *before* it gets access to the terminal/repo.

---

## 🚀 Tool: Optio — Automated Ticket-to-Merge
**Source:** [GitHub - jonwiggins/optio](https://github.com/jonwiggins/optio) (Show HN)

**Summary:** 
Optio is a new orchestration system that turns tickets into merged PRs using isolated K8s pods running Claude Code or Codex. It monitors CI checks, review status, and handles "self-healing" (auto-resuming agents on failures).

**Why it matters for PP:** 
Optio is the "engine," but it lacks a "governor." It automates the *merge* based on "merge readiness," but who defines "ready"? This is the perfect integration point for Permission Protocol—providing the audit receipt and human-approval gate before Optio triggers the final `squash-merge`.

---

## 📊 Discussion: "AI Slop" Resistance
**Source:** [The Decoder](https://the-decoder.com/study-maps-developer-frustration-over-ai-slop-as-a-tragedy-of-the-commons-in-software-development/)

**Summary:** 
Large engineering teams are moving from "AI optimism" to "AI restriction." New policies include PR size limits (<500 LOC) for AI code and mandatory "double code reviews" by external teams.

**Why it matters for PP:** 
"Restriction" is a sign of missing infrastructure. Teams are using blunt instruments (size limits) because they lack granular control (policy gates). PP's "Evidentiary UX" can provide the signals needed to trust AI PRs without arbitrary LOC caps.
