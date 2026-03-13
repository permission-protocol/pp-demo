// Configuration validator
function validate(config) {
  const required = ['apiKey', 'endpoint', 'timeout'];
  const missing = required.filter(k => !config[k]);
  if (missing.length) throw new Error('Missing: ' + missing.join(', '));
  return true;
}
module.exports = { validate };
