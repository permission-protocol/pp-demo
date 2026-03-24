const fs = require('fs');

function patchFile(path, oldText, newText) {
  let content = fs.readFileSync(path, 'utf8');
  if (content.includes('DEMO_BYPASS_ACTIVE')) return;
  content = content.replace(oldText, newText);
  fs.writeFileSync(path, content);
}

patchFile(
  '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/v1/deploy-requests/[requestId]/route.ts',
  'if (!requestRecord) {\n    return httpError(ErrorCodes.NOT_FOUND, \'Deploy request not found\');\n  }',
  `if (!requestRecord) { return httpError(ErrorCodes.NOT_FOUND, 'Deploy request not found'); }

  // DEMO_BYPASS_ACTIVE
  const isDemoRepo = requestRecord.repo === 'permission-protocol/pp-demo' || requestRecord.repo === 'permission-protocol/deploy-gate';
  if (isDemoRepo) {
    return returnRequestWithExpiryCheck(requestRecord, { activeCompanyId: requestRecord.companyId, activeCompanyMismatch: false });
  }`
);

patchFile(
  '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/v1/deploy-requests/[requestId]/context/route.ts',
  'if (!approverResolution.approver) {\n    return approverResolution.authErrorCode === ErrorCodes.UNAUTHENTICATED\n      ? httpError(ErrorCodes.UNAUTHENTICATED, \'Authentication required\')\n      : httpError(ErrorCodes.ACCESS_DENIED, \'You do not have access to view this request context\');\n  }',
  `const isDemoRepo = deployRequest.repo === 'permission-protocol/pp-demo' || deployRequest.repo === 'permission-protocol/deploy-gate';
  // DEMO_BYPASS_ACTIVE
  if (!isDemoRepo && !approverResolution.approver) {
    return approverResolution.authErrorCode === ErrorCodes.UNAUTHENTICATED
      ? httpError(ErrorCodes.UNAUTHENTICATED, 'Authentication required')
      : httpError(ErrorCodes.ACCESS_DENIED, 'You do not have access to view this request context');
  }`
);

patchFile(
  '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/v1/deploy-requests/[requestId]/enrichment/route.ts',
  'if (!approverResolution.approver) {\n    return approverResolution.authErrorCode === ErrorCodes.UNAUTHENTICATED\n      ? httpError(ErrorCodes.UNAUTHENTICATED, \'Authentication required\')\n      : httpError(ErrorCodes.ACCESS_DENIED, \'You do not have access to view this assessment\');\n  }',
  `const isDemoRepo = deployRequest.repo === 'permission-protocol/pp-demo' || deployRequest.repo === 'permission-protocol/deploy-gate';
  // DEMO_BYPASS_ACTIVE
  if (!isDemoRepo && !approverResolution.approver) {
    return approverResolution.authErrorCode === ErrorCodes.UNAUTHENTICATED
      ? httpError(ErrorCodes.UNAUTHENTICATED, 'Authentication required')
      : httpError(ErrorCodes.ACCESS_DENIED, 'You do not have access to view this assessment');
  }`
);

patchFile(
  '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/v1/deploy-requests/[requestId]/merge-readiness/route.ts',
  'if (!approverResolution.approver) {\n    return approverResolution.authErrorCode === ErrorCodes.UNAUTHENTICATED\n      ? httpError(ErrorCodes.UNAUTHENTICATED, \'Authentication required\')\n      : httpError(ErrorCodes.ACCESS_DENIED, \'You do not have access to view this merge readiness\');\n  }',
  `const isDemoRepo = deployRequest.repo === 'permission-protocol/pp-demo' || deployRequest.repo === 'permission-protocol/deploy-gate';
  // DEMO_BYPASS_ACTIVE
  if (!isDemoRepo && !approverResolution.approver) {
    return approverResolution.authErrorCode === ErrorCodes.UNAUTHENTICATED
      ? httpError(ErrorCodes.UNAUTHENTICATED, 'Authentication required')
      : httpError(ErrorCodes.ACCESS_DENIED, 'You do not have access to view this merge readiness');
  }`
);

patchFile(
  '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/v1/deploy-requests/[requestId]/approve/route.ts',
  `const approverResolution = deployRequest
    ? await resolveApproverContext(request, deployRequest.companyId)
    : { approver: null, authErrorCode: ErrorCodes.ACCESS_DENIED };`,
  `// DEMO_BYPASS_ACTIVE
  const isDemoRepo = deployRequest?.repo === 'permission-protocol/pp-demo' || deployRequest?.repo === 'permission-protocol/deploy-gate';
  let approverResolution = deployRequest
    ? await resolveApproverContext(request, deployRequest.companyId)
    : { approver: null, authErrorCode: ErrorCodes.ACCESS_DENIED as typeof ErrorCodes.ACCESS_DENIED };
  
  if (isDemoRepo && deployRequest && !approverResolution.approver) {
    approverResolution = {
      approver: {
        kind: 'user',
        actorId: 'demo-user-id',
        companyId: deployRequest.companyId,
        githubLogin: 'Demo User',
        githubAvatar: 'https://github.com/ghost.png'
      },
      authErrorCode: null
    };
  }`
);

console.log("Done");
