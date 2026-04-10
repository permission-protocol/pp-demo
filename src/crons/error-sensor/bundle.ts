// Deterministic STUB
export async function buildIncidentBundle(ctx: any) {
  return {
    title: 'Incident Bundle: ' + ctx.incident.fingerprint,
    url: 'https://internal.dashboard/bundle/123',
    externalRef: ctx.incident.fingerprint,
    metadata: { generatedBy: 'stub' }
  };
}