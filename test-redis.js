const { Redis } = require('ioredis');
const redis = new Redis({ maxRetriesPerRequest: null, enableReadyCheck: false, retryStrategy: () => null });
redis.ping().then(console.log).catch(console.error).finally(() => redis.quit());
