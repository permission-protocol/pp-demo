const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/app/api/summarize/route.ts';
let content = fs.readFileSync(file, 'utf8');

const newSummarizeFunction = `function summarizeDiff(diffText: string, prUrl: string, parsed: any) {
  const fileCount = diffText.split("\\ndiff --git ").length - 1;
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
    summary: \`Mock AI Summary: Touches \${fileCount} file\${fileCount === 1 ? "" : "s"} (+\${additions} -\${deletions}). This looks \${sizeDescriptor} and is considered \${riskLabel.toLowerCase()}. A quick human review of the changed edge cases is recommended.\`,
    risk: riskLabel,
    riskColor: riskColor,
    files: \`\${fileCount} file\${fileCount === 1 ? "" : "s"}\`,
    receipt: "Founders can approve this securely from their phone."
  };
}`;

content = content.replace(/function summarizeDiff[\\s\\S]*?return \`Mock AI summary.*?\\`;\\n}/, newSummarizeFunction);

content = content.replace(
  /summary: summarizeDiff\\(diffText, parsed\\.normalizedUrl\\),/,
  `...summarizeDiff(diffText, parsed.normalizedUrl, parsed),`
);

fs.writeFileSync(file, content);
console.log("Patched API!");
