const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/components/waitlist-form.tsx';
let content = fs.readFileSync(file, 'utf8');

// Remove the garbage at the top
content = content.replace(/^if \(!response\.ok \|\| !data\.success \|\| !data\.title\) \{/, '');

// Apply the actual replacement
content = content.replace(
  'if (!response.ok || !data.success || typeof data.summary !== "string") {',
  'if (!response.ok || !data.success || !data.title) {'
);

fs.writeFileSync(file, content);
