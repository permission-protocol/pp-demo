/**
 * Production API Rate Limiter
 * Sliding window algorithm for authenticated endpoints
 */

export interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
}

const DEFAULT_CONFIG: RateLimitConfig = {
  windowMs: 60_000,
  maxRequests: 100,
};

export class RateLimiter {
  private windows = new Map<string, number[]>();

  constructor(private config: RateLimitConfig = DEFAULT_CONFIG) {}

  check(clientId: string): { allowed: boolean; remaining: number } {
    const now = Date.now();
    const cutoff = now - this.config.windowMs;
    const timestamps = (this.windows.get(clientId) || []).filter(t => t > cutoff);

    if (timestamps.length >= this.config.maxRequests) {
      return { allowed: false, remaining: 0 };
    }

    timestamps.push(now);
    this.windows.set(clientId, timestamps);
    return { allowed: true, remaining: this.config.maxRequests - timestamps.length };
  }
}
