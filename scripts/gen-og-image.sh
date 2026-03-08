#!/bin/bash
# Generate OG social share card images using HTML + Chrome screenshot
# Usage: gen-og-image.sh "Headline" "Subtitle" output.png [--tag "TAG"]
#
# Examples:
#   gen-og-image.sh "The Pentagon Wants AI Without a Permission Layer." "Anthropic said no." /tmp/og.png
#   gen-og-image.sh "Cursor Is Dead." "Long live the agents." /tmp/og.png --tag "ANALYSIS"

set -euo pipefail

HEADLINE="$1"
SUBTITLE="${2:-}"
OUTPUT="${3:-/tmp/og-image.png}"
TAG=""

shift 3 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag) TAG="$2"; shift 2 ;;
    *) shift ;;
  esac
done

TMPHTML=$(mktemp /tmp/og-XXXXX.html)

# Escape for HTML
H_ESC=$(echo "$HEADLINE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
S_ESC=$(echo "$SUBTITLE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
T_ESC=$(echo "$TAG" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

# Build tag HTML
TAG_HTML=""
if [ -n "$TAG" ]; then
  TAG_HTML="<span class=\"tag\">$T_ESC</span>"
fi

# Build subtitle HTML
SUB_HTML=""
if [ -n "$SUBTITLE" ]; then
  SUB_HTML="<p class=\"subtitle\">$S_ESC</p>"
fi

cat > "$TMPHTML" << HTMLEOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap');
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    width: 1200px; height: 630px;
    background: #0a0a0a;
    font-family: 'Inter', -apple-system, sans-serif;
    display: flex; flex-direction: column; justify-content: center;
    padding: 60px 80px;
    position: relative; overflow: hidden;
  }
  body::before {
    content: ''; position: absolute; top: -100px; left: -100px;
    width: 400px; height: 400px;
    background: radial-gradient(circle, rgba(68,170,153,0.15) 0%, transparent 70%);
    pointer-events: none;
  }
  .accent-line {
    position: absolute; top: 0; left: 0; right: 0; height: 4px;
    background: linear-gradient(90deg, #44aa99 0%, rgba(68,170,153,0.3) 60%, transparent 100%);
  }
  .tag {
    display: inline-block; font-size: 13px; font-weight: 600;
    letter-spacing: 0.12em; text-transform: uppercase; color: #44aa99;
    border: 1px solid rgba(68,170,153,0.4); border-radius: 6px;
    padding: 6px 14px; margin-bottom: 28px;
  }
  .headline {
    font-size: 54px; font-weight: 800; line-height: 1.1;
    color: #e8e8e8; max-width: 950px; letter-spacing: -0.02em;
  }
  .subtitle {
    font-size: 24px; font-weight: 400; line-height: 1.4;
    color: #9a9a9a; margin-top: 24px; max-width: 800px;
  }
  .footer {
    position: absolute; bottom: 40px; left: 80px; right: 80px;
    display: flex; align-items: center; justify-content: space-between;
  }
  .brand { display: flex; align-items: center; gap: 10px; }
  .logo-box {
    width: 28px; height: 28px; border: 1.5px solid #44aa99;
    border-radius: 4px; display: flex; align-items: center; justify-content: center;
  }
  .brand-name { font-size: 15px; font-weight: 600; color: #555; letter-spacing: 0.04em; }
  .url { font-size: 14px; color: #44aa99; font-weight: 500; }
</style>
</head>
<body>
  <div class="accent-line"></div>
  $TAG_HTML
  <h1 class="headline">$H_ESC</h1>
  $SUB_HTML
  <div class="footer">
    <div class="brand">
      <div class="logo-box">
        <svg viewBox="0 0 16 16" fill="none" width="16" height="16">
          <rect x="1.5" y="1.5" width="13" height="13" stroke="#44aa99" stroke-width="1.5" fill="none"/>
          <line x1="1.5" y1="8" x2="14.5" y2="8" stroke="#44aa99" stroke-width="1.5"/>
          <line x1="8" y1="1.5" x2="8" y2="5.5" stroke="#44aa99" stroke-width="1.5"/>
          <line x1="8" y1="10.5" x2="8" y2="14.5" stroke="#44aa99" stroke-width="1.5"/>
        </svg>
      </div>
      <span class="brand-name">PERMISSION PROTOCOL</span>
    </div>
    <span class="url">permissionprotocol.com</span>
  </div>
</body>
</html>
HTMLEOF

node -e "
const { chromium } = require('/opt/homebrew/lib/node_modules/openclaw/node_modules/playwright-core');
(async () => {
  const browser = await chromium.launch({ executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1200, height: 630 });
  await page.goto('file://$TMPHTML');
  await page.waitForTimeout(800);
  await page.screenshot({ path: '$OUTPUT', type: 'png' });
  await browser.close();
})();
"

rm -f "$TMPHTML"
echo "OK: $OUTPUT ($(wc -c < "$OUTPUT") bytes)"
