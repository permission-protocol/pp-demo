const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/components/waitlist-form.tsx';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(
  /const \[summary, setSummary\] = useState\(""\);/,
  `const [summary, setSummary] = useState<any>(null);`
);

content = content.replace(
  /summary\?: string;/,
  `summary?: string;\n        title?: string;\n        risk?: string;\n        riskColor?: string;\n        files?: string;\n        receipt?: string;`
);

content = content.replace(
  /if \(!response\.ok \|\| !data\.success || typeof data\.summary !== "string"\) \{/,
  `if (!response.ok || !data.success || !data.title) {`
);

content = content.replace(
  /setSummary\(data\.summary\);/,
  `setSummary(data);`
);

const newCardRender = `
      {summaryError ? (
        <p className="mt-3 text-sm text-paper/55">{summaryError}</p>
      ) : summary ? (
        <div className="mt-6 mx-auto max-w-[26rem] h-auto rounded-[2.2rem] border border-white/[0.06] bg-[#0d0a12] p-4 shadow-card">
          <div className="flex items-center justify-between mb-4">
            <span className={\`rounded-full px-3 py-1 text-[0.65rem] uppercase tracking-[0.18em] \${summary.riskColor === 'lime' ? 'bg-lime/15 text-lime' : 'bg-amber/15 text-amber'}\`}>
              {summary.risk}
            </span>
            <span className="text-xs text-paper/30">{summary.files}</span>
          </div>
          <h3 className="font-display text-xl font-bold uppercase leading-[1.05] text-paper">{summary.title}</h3>
          <p className="mt-3 text-sm leading-6 text-paper/65">{summary.summary}</p>
          <div className="mt-6 rounded-2xl border border-white/[0.06] bg-black/30 p-3.5">
            <p className="text-[0.6rem] uppercase tracking-[0.2em] text-paper/30">Permission receipt</p>
            <p className="mt-1.5 text-xs leading-5 text-paper/60">{summary.receipt}</p>
          </div>
        </div>
      ) : (
        <p className="mt-3 text-sm text-paper/55">See a mock plain-English PR summary before you even join the beta.</p>
      )}
`;

content = content.replace(
  /<p className="mt-3 text-sm text-paper\/55">\s*\{\s*summaryError[\s\S]*?\}\s*<\/p>/m,
  newCardRender
);

fs.writeFileSync(file, content);
