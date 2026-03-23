const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/components/waitlist-form.tsx';
let content = fs.readFileSync(file, 'utf8');

const hardcodedSummary = `
  const [summary, setSummary] = useState<any>({
    title: "PR #28871 in react",
    summary: "Touches 1 file (+88 -71). This looks fairly broad and is considered low risk.",
    risk: "Low risk",
    riskColor: "lime",
    files: "1 file",
    receipt: "Founders can approve this securely from their phone."
  });
`;

content = content.replace(/const \[summary, setSummary\] = useState<any>\(null\);/, hardcodedSummary);
fs.writeFileSync(file, content);
