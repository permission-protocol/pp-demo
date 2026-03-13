# PP Signer Gap Engine — v0

## What This Is
A system that continuously discovers where AI systems can act without proper authorization,
then turns the best findings into usable PP assets (demos, product requirements, GTM angles, content).

## Stack
- **Model:** Qwen3-32B on DGX Spark (100.111.31.56) via Ollama
- **Pipeline:** 4 Python jobs (ingest → detect → score → render)
- **Schedule:** systemd timers / cron on Spark
- **Review:** Charles (me) reviews output during heartbeats, converts top records into artifacts
- **Feedback:** Rod reacts ✅/❌ on weekly digest in Discord #spark-digest

## Architecture
```
PP Corpus → Chunk/Ingest → Qwen3-32B → Signer Gap Records → Score → Daily Packet
                                                                        ↓
                                                              Charles reviews
                                                                        ↓
                                                         Product issues / Demo scripts /
                                                         GTM memos / Blog drafts
                                                                        ↓
                                                              Rod approves (✅/❌)
```

## Folder Structure
- `corpus/` — raw source material (doctrine, product docs, incidents, etc.)
- `prompts/` — the 4 job prompts
- `records/` — signer_gaps.jsonl (append-only output)
- `packets/` — daily and weekly markdown summaries
- `scripts/` — Python pipeline code
- `ratings.jsonl` — Rod's feedback for calibration

## Running
```bash
# On Spark:
python3 scripts/pipeline.py    # runs jobs 1-3
python3 scripts/packet.py      # renders daily packet
```

## Success Criteria (30 days)
1. Rod finds ≥2 actionable items per week in the digest
2. ≥3 signer gap scenarios converted into real product/demo/GTM decisions
3. Corpus has grown with new incidents and workflows
