const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/pp/deploy-requests/[requestId]/page.tsx';
let code = fs.readFileSync(file, 'utf8');

const anchor = '  return (\n    <>\n      {!isDecisionFlowLayout ? (';

const newCode = `  if (isDecisionFlowLayout) {
    return (
      <div className="flex min-h-[100dvh] w-full flex-col items-center justify-start bg-[#000000] px-4 py-8 sm:py-16 sm:px-6">
        <div className="w-full max-w-xl space-y-8">
          
          {/* Header */}
          <div className="space-y-2">
            <h1 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">This action is blocked</h1>
            <p className="text-lg text-[#A1A1AA]">Approval required to proceed.</p>
          </div>

          {/* Core Block */}
          <div className="space-y-6 rounded-3xl border border-[#27272A] bg-[#09090B] p-6 sm:p-8">
            
            {/* Action & Requester */}
            <div className="space-y-4">
              <div>
                <div className="text-xs font-semibold uppercase tracking-wider text-[#71717A]">Action</div>
                <div className="mt-1 text-base text-white">{reviewTitle || 'Merge pull request into main'}</div>
              </div>
              <div>
                <div className="text-xs font-semibold uppercase tracking-wider text-[#71717A]">Requested by</div>
                <div className="mt-1 text-base text-white">@{request?.prAuthor || contextDetails?.commitSummary?.author || request?.createdByRef || 'username'}</div>
              </div>
            </div>

            <div className="h-px bg-[#27272A]" />

            {/* Risk (Dominant) */}
            <div className="space-y-3">
              <div className="inline-flex items-center gap-2 rounded-full border border-red-500/30 bg-red-500/10 px-3 py-1 text-sm font-bold tracking-wide text-red-500">
                <AlertTriangle className="h-4 w-4" /> HIGH RISK
              </div>
              <ul className="space-y-2 text-sm text-[#E4E4E7]">
                <li className="flex items-center gap-2"><div className="h-1.5 w-1.5 rounded-full bg-red-500" /> Changes production code</li>
                <li className="flex items-center gap-2"><div className="h-1.5 w-1.5 rounded-full bg-red-500" /> Impacts live users</li>
                {isAiBlocked && enrichment?.jakeReview?.watchFor.map((item, i) => (
                  <li key={i} className="flex items-center gap-2"><div className="h-1.5 w-1.5 rounded-full bg-red-500" /> {item}</li>
                ))}
              </ul>
            </div>

            <div className="h-px bg-[#27272A]" />

            {/* Commitment & Identity */}
            <div className="space-y-4 rounded-2xl border border-amber-500/20 bg-amber-500/5 p-4 sm:p-5">
              <div className="space-y-2">
                <div className="text-sm font-semibold text-amber-500">If you approve:</div>
                <ul className="space-y-1.5 text-sm text-amber-200/80">
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5" /> This change will execute</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5" /> You will be recorded as the signer</li>
                </ul>
              </div>
              <div className="pt-2">
                <div className="text-xs text-amber-500/70">Signing as</div>
                <div className="mt-0.5 text-sm font-medium text-amber-200">{session?.user?.name || 'Rodrigo Carvalho'} (@{session?.user?.username || 'rod'})</div>
              </div>
            </div>
            
            {/* Action Buttons */}
            <div className="space-y-3 pt-2">
              <Button
                onClick={() => void handleApprove()}
                disabled={approveDisabled}
                className="h-14 w-full rounded-xl bg-white text-base font-bold text-black hover:bg-gray-200 disabled:bg-white/50 disabled:text-black/50 transition-all active:scale-[0.98]"
              >
                <CheckCircle2 className="mr-2 h-5 w-5" />
                {decisionState.status === 'submitting' && decisionState.action === 'approve' ? 'Approving...' : 'Approve & Sign'}
              </Button>
              <Button
                variant="outline"
                onClick={() => void handleDeny()}
                disabled={decisionState.status === 'submitting'}
                className="h-14 w-full rounded-xl border-[#27272A] bg-transparent text-base font-medium text-white hover:bg-[#27272A] hover:text-white transition-all active:scale-[0.98]"
              >
                <XCircle className="mr-2 h-5 w-5 text-red-500" />
                {decisionState.status === 'submitting' && decisionState.action === 'deny' ? 'Rejecting...' : 'Reject'}
              </Button>
            </div>
          </div>

          <div className="text-center text-xs font-medium tracking-wide text-[#71717A] uppercase">
            Signed approval required for all protected actions.
          </div>
        </div>
      </div>
    );
  }

${anchor}`;

if (code.includes(anchor)) {
  code = code.replace(anchor, newCode);
  fs.writeFileSync(file, code);
  console.log("Successfully injected V2 UI copy!");
} else {
  console.log("Failed to find anchor.");
}
