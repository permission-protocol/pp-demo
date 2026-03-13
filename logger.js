// Structured logger utility
function log(level, message, context) {
  console.log(JSON.stringify({ level, message, context, ts: new Date().toISOString() }));
}
module.exports = { log };
