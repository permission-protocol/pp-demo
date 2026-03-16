# PRD: idea-057 — Fix escape control characters in enrichment JSON response

**Issue:** permission-protocol/app#22
**Priority:** P2
**Repo:** permission-protocol/app
**Size:** S

## Problem
The enrichment endpoint returns diff patches containing unescaped control characters (tabs, newlines in code). This causes `jq` and strict JSON parsers to fail:
```bash
curl /api/v1/deploy-requests/{id}/enrichment | jq .
# Error: Invalid string: control characters from U+0000 through U+001F must be escaped
```

## User Journey
1. Developer/agent calls enrichment API
2. Response contains raw diff patches with control chars (U+0000–U+001F)
3. `jq`, strict JSON parsers, and some HTTP clients choke
4. Browsers handle it fine (lenient parsing), so it went unnoticed

## Requirements

### Must Have
- Sanitize all string values in the enrichment response that may contain control characters
- Target file: `src/lib/enrichment/enrich.ts`
- Specifically handle diff/patch strings before including in response
- Ensure `curl ... | jq .` works without errors

### Implementation
- Find where patch/diff content is included in the response object
- Apply a sanitizer that escapes or strips control characters (U+0000–U+001F except \n, \r, \t which JSON.stringify handles)
- Option A: Run `JSON.stringify()` on patch strings (handles escaping natively)
- Option B: Regex replace `/[\x00-\x08\x0B\x0C\x0E-\x1F]/g` with empty string or unicode escape

### Must NOT Do
- Don't change the response schema or field names
- Don't modify non-enrichment endpoints
- Don't strip legitimate newlines/tabs from the response structure

## Acceptance Criteria
- [ ] `curl /api/v1/deploy-requests/{id}/enrichment | jq .` parses without error
- [ ] Diff content is still readable and accurate
- [ ] No regression in browser rendering of enrichment data
