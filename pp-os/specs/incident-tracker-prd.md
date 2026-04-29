# AI Agent Incident Tracker - PRD

## Overview
A public page on permissionprotocol.com that documents AI agent failures, exploits, and incidents. Similar to Oso's "Rogue Agents Registry" but positioned around what PP prevents.

## Goals
1. **SEO** - Rank for "AI agent incidents", "AI agent failures", "agent security"
2. **Thought Leadership** - Position PP as the authority on agent governance
3. **Sales Tool** - Reference in outreach: "Here's 6 incidents in 3 months"
4. **Content Marketing** - Weekly updates drive traffic and social shares

## Page Structure

### Header
- Title: "AI Agent Incident Tracker"
- Subtitle: "Documenting what happens when agents act without governance"
- CTA: "Prevent this with Permission Protocol →"

### Incident Cards
Each incident includes:
- **Date** (Month Year)
- **Company** affected
- **Agent/Tool** involved (Cursor, Claude Code, etc.)
- **What happened** (2-3 sentences)
- **Impact** (data loss, outage duration, etc.)
- **What PP would have prevented** (1 sentence)
- **Source link**

### Categories
- Uncontrolled Actions (agent acts without approval)
- Data Deletion (databases, files wiped)
- Unauthorized Deploys (code shipped without review)
- Data Exposure (sensitive info leaked)
- System Outages (services taken down)

## Initial Incidents to Include

### 1. PocketOS / Cursor (Apr 2026)
- Agent: Cursor + Claude Opus 4.6
- Impact: Production database + backups deleted in 9 seconds
- Source: @lifeof_jer on X

### 2. DataTalks.Club / Claude Code (Mar 2026)
- Agent: Claude Code
- Impact: 2.5 years of production data wiped via terraform destroy
- Source: Alexey Grigorev post-mortem

### 3. Meta AI Forum Post (Mar 2026)
- Agent: Internal Meta AI agent
- Impact: Sev 1 incident, sensitive data exposed for 2 hours
- Source: The Information

### 4. Vercel Unverified Deploy (Mar 2026)
- Agent: Vercel deployment agent
- Impact: Unverified third-party code shipped to production
- Source: @rauchg on X

### 5. AWS / Kiro Outage (Feb 2026)
- Agent: Amazon Q Developer / Kiro
- Impact: 13-hour AWS service outage
- Source: Financial Times

### 6. OpenClaw iMessage Flood (Feb 2026)
- Agent: OpenClaw
- Impact: 500+ unsolicited messages sent
- Source: Bloomberg

## Technical Implementation
- Static page or simple React component
- JSON data file for incidents (easy to update)
- RSS feed for new incidents
- Social sharing buttons per incident
- "Submit an incident" form for community reports

## Content Cadence
- Launch with 6 incidents
- Add 1-2 incidents per week as they surface
- Monthly roundup post on LinkedIn/Twitter

## Success Metrics
- Page views
- Time on page
- Backlinks from security/AI publications
- Mentions in outreach responses ("saw your incident tracker")
- Leads attributed to page

## Timeline
- Week 1: Design + initial 6 incidents
- Week 2: Launch + social promotion
- Ongoing: Weekly updates

## Owner
Rod (content) + Engineering (implementation)
