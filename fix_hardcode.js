const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/components/waitlist-form.tsx';
let content = fs.readFileSync(file, 'utf8');

const regex = /const \[summary, setSummary\] = useState<any>\(null\);\s*\/\/\s*\{[\s\S]*?\}\);\n/g;
content = content.replace(regex, 'const [summary, setSummary] = useState<any>(null);\n');

fs.writeFileSync(file, content);
