const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/app/page.tsx';
let content = fs.readFileSync(file, 'utf8');

// Replace Hero Headline
content = content.replace(
  /Your AI copilot\n\s*<span className="block bg-gradient-to-r from-flame via-ember to-blush bg-clip-text text-transparent">\n\s*for every merge\n\s*<\/span>/g,
  `Swipe to Ship\n                <span className="block bg-gradient-to-r from-flame via-ember to-blush bg-clip-text text-transparent">\n                  Not a Dashboard\n                </span>`
);

// We need to move the SwipeDemo *above* the WaitlistForm on mobile.
// Let's wrap WaitlistForm, Counter, etc., in a div, and insert a mobile SwipeDemo above it.
content = content.replace(
  /<div className="mt-8 flex max-w-4xl flex-col gap-4 lg:flex-row lg:items-start">/g,
  `<div className="mt-8 mb-8 block lg:hidden"><SwipeDemo /></div>\n              <div className="mt-8 flex max-w-4xl flex-col gap-4 lg:flex-row lg:items-start">`
);

// Hide the second SwipeDemo on mobile
content = content.replace(
  /<div data-reveal className="relative">/g,
  `<div data-reveal className="relative hidden lg:block">`
);

// Fix social proof margin
content = content.replace(
  /<div className="mt-6 flex flex-wrap gap-3 text-sm text-paper\/56">/g,
  `<div className="mt-6 flex flex-wrap gap-3 text-sm text-paper/56 hidden sm:flex">`
);

fs.writeFileSync(file, content);
console.log("Patched!");
