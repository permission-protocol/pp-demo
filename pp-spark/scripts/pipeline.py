#!/usr/bin/env python3
"""
PP Signer Gap Engine — Core Pipeline (Jobs 1-3)
Discovers workflows, detects signer gaps, scores records.

Usage:
  python3 pipeline.py                    # full run
  python3 pipeline.py --category doctrine  # only process doctrine corpus
  python3 pipeline.py --dry-run          # show prompts without calling model
"""

import argparse
import json
import sys
from utils import (
    query_model, extract_json, load_corpus, record_id,
    append_record, load_records, dedupe_title
)

# ─── System Prompt ───

SYSTEM = """You are a security analyst specializing in AI authorization failures.
You work for Permission Protocol (PP), which builds enforcement infrastructure 
for autonomous AI systems. PP's core thesis: between decision and execution, 
there must be authority. The system that acts cannot be the system that authorizes itself.

Your job: find workflows where AI systems can take consequential actions without 
a valid external signer of record, then design the receipt and enforcement point 
that should exist.

Always output valid JSON. Be specific and concrete, not abstract."""


# ─── Job 1: Discover Workflows ───

DISCOVER_PROMPT = """/no_think
You MUST return ONLY a JSON array. No markdown. No explanation. No headers. Just JSON.

Task: Extract workflows where AI can take consequential actions.

From the source material below, find 5-10 workflows where an AI system can:
- Deploy code to production
- Move money (refunds, payments)
- Access/export customer data
- Change infrastructure or config
- Send external communications
- Delete or revoke access

Return this exact JSON format (array of objects):
[
  {{
    "workflow": "short name",
    "description": "1-2 sentences",
    "actor": "who performs the action",
    "action": "the specific consequential action",
    "target_system": "what gets affected",
    "claimed_authority": "what the actor thinks authorizes them",
    "source": "which document this came from"
  }}
]

IMPORTANT: Output ONLY the JSON array. Start with [ and end with ]. No other text.

SOURCE MATERIAL:
{corpus}"""


# ─── Job 2: Detect Signer Gaps ───

DETECT_PROMPT = """/no_think
You MUST return ONLY a JSON object. No markdown. No explanation. Just JSON.

You are analyzing this workflow for a signer gap — a case where 
execution could proceed without a valid external signer of record.

WORKFLOW:
{workflow_json}

For this workflow, determine:
1. Could execution proceed without explicit external authorization?
2. What evidence exists BEFORE the action (not after)?
3. What evidence is MISSING?
4. How could the current controls be bypassed?
5. What is the blast radius if this goes wrong?
6. Where should Permission Protocol insert an enforcement point?
7. What receipt fields are needed to prove authorization?

Return a single JSON object with these exact fields:
{{
  "record_id": "{rid}",
  "title": "one-line description of the signer gap",
  "workflow": "workflow name",
  "action_taken": "specific action",
  "actor": "who acts",
  "claimed_authority": "what they think authorizes them",
  "actual_required_authority": "what should actually be required",
  "current_evidence": ["list of evidence that exists before action"],
  "evidence_gap": ["list of missing evidence"],
  "bypass_path": ["list of realistic bypass methods"],
  "blast_radius": "description of worst case",
  "why_internal_auth_fails": "why self-authorization is insufficient",
  "pp_insertion_point": "where PP should enforce",
  "required_receipt_fields": ["list of fields for the receipt"],
  "required_enforcement_surface": ["list of enforcement surfaces"]
}}

Be specific and concrete. Real scenarios, not hypotheticals.
Return ONLY the JSON object."""


# ─── Job 3: Score ───

SCORE_PROMPT = """/no_think
You MUST return ONLY a JSON object. No markdown. No explanation. Just JSON.

Score this signer gap record on each dimension from 0-10.
Be harsh. Most records should score 4-7. Only exceptional ones get 8+.

RECORD:
{record_json}

SCORING CRITERIA:
- severity: How bad is the blast radius? (0=trivial, 10=catastrophic)
- product_leverage: Could PP build a product feature from this? (0=no, 10=defines a new receipt type)
- demo_value: Would this make a compelling 90-second demo? (0=boring, 10=jaw-dropping)
- gtm_value: Does this identify a buyer and their pain? (0=abstract, 10=obvious sales conversation)
- novelty: Is this a fresh scenario or obvious/overused? (0=everyone knows this, 10=nobody talks about this)
- testability: Can we validate this quickly? (0=needs enterprise access, 10=can demo today)
- virality: Would people share this? (0=niche, 10=every CTO forwards this)
- ops_value: Does this apply to our own internal operations? (0=no, 10=we should fix this today)

Also compute:
- priority_score = severity*1.5 + product_leverage*2.0 + demo_value*1.5 + gtm_value*1.5 + novelty*1.0 + testability*1.0 + virality*0.5 + ops_value*0.5

Return ONLY a JSON object with these fields plus a "recommended_next_step" string."""


def run_discover(corpus_text: str, dry_run: bool = False) -> list[dict]:
    """Job 1: Extract workflows from corpus."""
    print("\n=== JOB 1: DISCOVER WORKFLOWS ===")
    prompt = DISCOVER_PROMPT.format(corpus=corpus_text[:15000])

    if dry_run:
        print(f"[DRY RUN] Would send {len(prompt)} chars to model")
        return []

    response = query_model(prompt, system=SYSTEM, temperature=0.4)
    workflows = extract_json(response)

    if not workflows or not isinstance(workflows, list):
        print(f"[WARN] Failed to extract workflows. Raw response:\n{response[:500]}")
        return []

    print(f"  Found {len(workflows)} workflows")
    for w in workflows:
        print(f"  - {w.get('workflow', '?')}: {w.get('action', '?')[:60]}")

    return workflows


def run_detect(workflows: list[dict], existing_records: list[dict], dry_run: bool = False) -> list[dict]:
    """Job 2: Detect signer gaps in extracted workflows."""
    print(f"\n=== JOB 2: DETECT SIGNER GAPS ({len(workflows)} workflows) ===")
    records = []

    for i, wf in enumerate(workflows):
        title_guess = f"{wf.get('actor', 'AI')} {wf.get('action', 'acts')}"
        if dedupe_title(title_guess, existing_records + records):
            print(f"  [{i+1}] SKIP (duplicate): {title_guess[:60]}")
            continue

        rid = record_id()
        prompt = DETECT_PROMPT.format(
            workflow_json=json.dumps(wf, indent=2),
            rid=rid
        )

        if dry_run:
            print(f"  [{i+1}] [DRY RUN] Would analyze: {wf.get('workflow', '?')}")
            continue

        print(f"  [{i+1}] Analyzing: {wf.get('workflow', '?')}...")
        response = query_model(prompt, system=SYSTEM, temperature=0.3)
        record = extract_json(response)

        if record and isinstance(record, dict):
            record["record_id"] = rid  # ensure our ID
            record["source_workflow"] = wf
            record["created_at"] = __import__("datetime").datetime.now(
                __import__("datetime").timezone.utc
            ).isoformat()
            records.append(record)
            print(f"  → Detected: {record.get('title', '?')[:60]}")
        else:
            print(f"  [WARN] Failed to extract record for {wf.get('workflow', '?')}")

    print(f"  Total new records: {len(records)}")
    return records


def run_score(records: list[dict], dry_run: bool = False) -> list[dict]:
    """Job 3: Score signer gap records."""
    print(f"\n=== JOB 3: SCORE RECORDS ({len(records)} records) ===")
    scored = []

    for i, rec in enumerate(records):
        prompt = SCORE_PROMPT.format(record_json=json.dumps(rec, indent=2))

        if dry_run:
            print(f"  [{i+1}] [DRY RUN] Would score: {rec.get('title', '?')[:60]}")
            continue

        print(f"  [{i+1}] Scoring: {rec.get('title', '?')[:60]}...")
        response = query_model(prompt, system=SYSTEM, temperature=0.2)
        scores = extract_json(response)

        if scores and isinstance(scores, dict):
            rec.update(scores)
            scored.append(rec)
            ps = scores.get("priority_score", 0)
            print(f"  → Priority: {ps:.1f} | Next: {scores.get('recommended_next_step', '?')[:50]}")
        else:
            print(f"  [WARN] Failed to score: {rec.get('title', '?')[:40]}")
            scored.append(rec)  # keep unscored record

    # Sort by priority
    scored.sort(key=lambda r: r.get("priority_score", 0), reverse=True)
    return scored


def main():
    parser = argparse.ArgumentParser(description="PP Signer Gap Engine Pipeline")
    parser.add_argument("--category", help="Corpus category to process (doctrine, product, incidents, website)")
    parser.add_argument("--dry-run", action="store_true", help="Show prompts without calling model")
    parser.add_argument("--max-workflows", type=int, default=10, help="Max workflows to process per run")
    args = parser.parse_args()

    # Load corpus
    print("Loading corpus...")
    corpus = load_corpus(category=args.category)
    print(f"  Loaded {len(corpus)} chars")

    if not corpus:
        print("[ERROR] No corpus found. Add files to pp-spark/corpus/")
        sys.exit(1)

    # Load existing records for deduplication
    existing = load_records()
    print(f"  Existing records: {len(existing)}")

    # Job 1: Discover
    workflows = run_discover(corpus, dry_run=args.dry_run)
    if args.max_workflows:
        workflows = workflows[:args.max_workflows]

    if not workflows and not args.dry_run:
        print("[DONE] No workflows found.")
        return

    # Job 2: Detect
    records = run_detect(workflows, existing, dry_run=args.dry_run)

    if not records and not args.dry_run:
        print("[DONE] No new signer gaps detected.")
        return

    # Job 3: Score
    scored = run_score(records, dry_run=args.dry_run)

    # Save
    if not args.dry_run:
        for rec in scored:
            append_record(rec)

    print(f"\n=== PIPELINE COMPLETE ===")
    print(f"  New records: {len(scored)}")
    if scored:
        top = scored[0]
        print(f"  Top record: {top.get('title', '?')}")
        print(f"  Priority: {top.get('priority_score', '?')}")
        print(f"  Next step: {top.get('recommended_next_step', '?')}")


if __name__ == "__main__":
    main()
