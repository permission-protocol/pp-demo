import { Redis } from "ioredis";

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
  keyPrefix: string;
}

const TIER_LIMITS: Record<string, RateLimitConfig> = {
  standard: { windowMs: 60_000, maxRequests: 100, keyPrefix: "rl:std:" },
  enterprise: { windowMs: 60_000, maxRequests: 1000, keyPrefix: "rl:ent:" },
};

export function createRateLimiter(redis: Redis) {
  return async function rateLimit(req: any, res: any, next: any) {
    const tier = req.user?.tier ?? "standard";
    const config = TIER_LIMITS[tier];
    const key = `${config.keyPrefix}${req.user?.id ?? req.ip}`;
    const now = Date.now();

    const pipeline = redis.pipeline();
    pipeline.zremrangebyscore(key, 0, now - config.windowMs);
    pipeline.zadd(key, now.toString(), `${now}-${Math.random()}`);
    pipeline.zcard(key);
    pipeline.expire(key, Math.ceil(config.windowMs / 1000));

    const results = await pipeline.exec();
    const requestCount = results?.[2]?.[1] as number;

    if (requestCount > config.maxRequests) {
      res.status(429).json({
        error: "Rate limit exceeded",
        retryAfter: Math.ceil(config.windowMs / 1000),
      });
      return;
    }

    res.setHeader("X-RateLimit-Limit", config.maxRequests);
    res.setHeader("X-RateLimit-Remaining", config.maxRequests - requestCount);
    next();
  };
}
