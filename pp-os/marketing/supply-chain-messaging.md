# Supply Chain + Runtime Authority Messaging

## The Stack Frame

Position PP as part of a **security stack for AI agents**, not a standalone tool:

```
Layer 1: Supply Chain Integrity (Vett, Snyk agent-scan)
  → Is this skill/code safe to install?

Layer 2: Runtime Authorization (Permission Protocol)  
  → Is this action authorized to execute?

Layer 3: Observability (existing tools)
  → What happened after execution?
```

PP owns Layer 2. We don't compete with Layer 1 or 3 — we complete them.

## Key Messages

### For Developer Audiences
- "Scanning your skills is necessary. It's not sufficient. A clean skill can still drop your production database if no one authorized the deploy."
- "Supply chain security tells you the code is safe. Permission Protocol tells you the action was authorized. You need both."

### For Security Audiences  
- "59 malicious agent skills found in the wild (Vett.sh research). But even clean skills need authorization gates. The attack surface isn't just malware — it's autonomous action without human oversight."

### For Content/Social
- **Thread hook:** "Everyone's talking about malicious AI agent skills. But here's what nobody's asking: even if the skill is clean, who authorized the deploy?"
- **Blog angle:** "The Two-Layer Problem: Why Scanning Agent Skills Isn't Enough"
- **LinkedIn:** Reference Vett's research + McKinsey breach as complementary proof points

## Integration with PP Strategy v2

This fits the "Authority Infrastructure" positioning perfectly:
- Supply chain = trust the code
- PP = trust the authorization
- UAR (Universal Action Receipt) = proof that both gates were passed

## Content Calendar Addition
- [ ] Blog: "The Two-Layer Problem" — positions PP alongside supply chain tools
- [ ] X thread: Reference Vett's 59 critical skills + PP's authorization angle
- [ ] If partnership lands: joint blog post or co-marketing
