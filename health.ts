export function healthCheck(): { status: string; timestamp: string } {
  return {
    status: 'healthy',
    timestamp: new Date().toISOString(),
  };
}
