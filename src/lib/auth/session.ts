const SESSION_EXPIRY = 24 * 60 * 60; // 24 hours

export function createSession(userId: string) {
  return {
    userId,
    expiresAt: Date.now() + SESSION_EXPIRY * 1000,
  };
}
