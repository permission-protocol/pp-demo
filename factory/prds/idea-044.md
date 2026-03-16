# PRD: idea-044 — Complete Quickstart Page (5 Steps)

**Issue:** permission-protocol/site#197
**Priority:** P0
**Repo:** permission-protocol/site

## Problem
The quickstart page (`/developers/quickstart`) only shows 2 of 5 steps:
1. Install the SDK ✅
2. Configure your API key ✅
3. ❌ Missing
4. ❌ Missing
5. ❌ Missing

Developers hit a dead end after configuring their API key. "Now what?"

## User Journey
1. Marco (EM) tells his team "try Permission Protocol"
2. Dev goes to quickstart, installs SDK, configures key
3. **Current:** Page ends. Dev is confused.
4. **Expected:** Dev wraps their first action, triggers approval, sees receipt. 5 minutes.

## Requirements

### Must Have — Add Steps 3-5

**Step 3: Add your first approval guard**
```python
# Python tab
from permission_protocol import require_approval

@require_approval
def deploy_service():
    deploy("billing-api")

# Agent calls deploy_service()
# → Paused until authorized
```

```typescript
// TypeScript tab
import { requireApproval } from 'permission-protocol';

const deploy = requireApproval(async () => {
  await deployService("billing-api");
});

// Agent calls deploy()
// → Paused until authorized
```

**Step 4: Approve the action**
- Show what happens: notification appears in dashboard
- Screenshot or mockup of the approval screen
- "Click Approve to authorize the action"
- Mention: the action is blocked until this step completes

**Step 5: Verify the receipt**
- Show the receipt that gets returned
- Code to verify: `receipt.verified  # True`
- Link to the demo receipt: "See a live example →" `/r/demo`
- Mention: receipt is cryptographically signed, portable, auditable

### Style
- Match the existing step card design (numbered green circles, dark cards)
- Python/TypeScript tab switcher on each step (matching existing)
- Copy button on code blocks (matching existing)

### Must NOT Do
- Don't change existing Step 1 or Step 2 content
- Don't change page layout or styling system
- Don't add new dependencies

## Customer Test
A developer with zero PP knowledge follows the quickstart from top to bottom. In 5 minutes, they understand: install → configure → wrap → approve → receipt. No gaps, no confusion, no "now what?"

## Files Likely Touched
- `src/app/developers/quickstart/page.tsx` (or equivalent)
- Possibly content/copy files if content is externalized
