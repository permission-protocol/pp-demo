const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/app/api/summarize/route.ts';
let content = fs.readFileSync(file, 'utf8');

const newFn = `
function summarizeDiff(diffText: string, prUrl: string, parsed: any) {
  const fileCount = diffText.split("\\n" + "diff --git ").length - 1;
  const additions = diffText
    .split("\\n")
    .filter((line) => line.startsWith("+") && !line.startsWith("+++")).length;
  const deletions = diffText
    .split("\\n")
    .filter((line) => line.startsWith("-") && !line.startsWith("---")).length;

  const sizeDescriptor =
    additions + deletions > 120 ? "fairly broad" : additions + deletions > 40 ? "moderate" : "focused";
  const riskLabel =
    fileCount > 8 || additions + deletions > 200 ? "Medium risk" : "Low risk";
  const riskColor = riskLabel === "Low risk" ? "lime" : "amber";

  return {
    title: \`PR #\${parsed.number} in \${parsed.repo}\`,
    summary: \`Touches \${fileCount} file\${fileCount === 1 ? "" : "s"} (+\${additions} -\${deletions}). This looks \${sizeDescriptor} and is considered \${riskLabel.toLowerCase()}.\`,
    risk: riskLabel,
    riskColor: riskColor,
    files: \`\${fileCount} file\${fileCount === 1 ? "" : "s"}\`,
    receipt: "Founders can approve this securely from their phone."
  };
}
`;

const startIndex = content.indexOf('function summarizeDiff');
const endIndex = content.indexOf('export async function POST');

if (startIndex !== -1 && endIndex !== -1) {
  content = content.substring(0, startIndex) + newFn + '\\n' + content.substring(endIndex);
}

content = content.replace(
  /summary: summarizeDiff\(diffText, parsed\.normalizedUrl\),/,
  `...summarizeDiff(diffText, parsed.normalizedUrl, parsed),`
);

fs.writeFileSync(file, content);
