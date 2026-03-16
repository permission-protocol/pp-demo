#!/bin/bash
# Publish a blog post to permissionprotocol.com
# Usage: publish-blog.sh <slug> <title> <description> <image-path> <content-html-file>
#
# Example:
#   publish-blog.sh "cursor-is-dead" "Cursor Is Dead" "How a $29B company..." image.png content.html
#
# This script:
# 1. Clones the repo
# 2. Creates the blog HTML from template
# 3. Copies the image
# 4. Updates blog index
# 5. Commits, pushes, creates PR, merges

set -euo pipefail

SLUG="$1"
TITLE="$2"
DESC="$3"
IMAGE="$4"
CONTENT="$5"
TAG="${6:-Opinion}"

REPO_DIR=$(mktemp -d)/pp-site
MONTH=$(date +"%b %Y")
DATE_ISO=$(date +"%Y-%m")

echo "=== Cloning repo..."
git clone --depth 1 git@github.com:permission-protocol/site.git "$REPO_DIR" 2>&1 | tail -1

echo "=== Copying image..."
cp "$IMAGE" "$REPO_DIR/public/blog/${SLUG}.png"

echo "=== Generating blog HTML..."
# Read content HTML (just the article body, no wrapper)
BODY=$(cat "$CONTENT")

# Get nav/footer template from existing post
NAV=$(sed -n '/<nav>/,/<\/nav>/p' "$REPO_DIR/public/blog/signer-of-record-gap.html")
FOOTER=$(sed -n '/<footer>/,/<\/footer>/p' "$REPO_DIR/public/blog/signer-of-record-gap.html")

cat > "$REPO_DIR/public/blog/${SLUG}.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${TITLE} | Permission Protocol</title>
  <meta name="description" content="${DESC}">
  <meta property="og:title" content="${TITLE}">
  <meta property="og:description" content="${DESC}">
  <meta property="og:type" content="article">
  <meta property="og:url" content="https://permissionprotocol.com/blog/${SLUG}">
  <meta property="og:image" content="https://permissionprotocol.com/blog/${SLUG}.png">
  <meta property="og:image:width" content="1920">
  <meta property="og:image:height" content="1080">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:site" content="@PermissionPrtcl">
  <meta name="twitter:title" content="${TITLE}">
  <meta name="twitter:description" content="${DESC}">
  <meta name="twitter:image" content="https://permissionprotocol.com/blog/${SLUG}.png">
  <link rel="stylesheet" href="../styles.css?v=14">
</head>
<body class="dark-brand-page">
${NAV}
  <div class="nav-overlay" id="nav-overlay"></div>
  <main>
    <article class="blog-post">
      <a href="/blog" class="blog-back-link">← Back to Blog</a>
      ${BODY}
    </article>
  </main>
${FOOTER}
  <script src="/main.js?v=5"></script>
</body>
</html>
HTMLEOF

echo "=== Updating blog index..."
# Create the new card HTML
NEW_CARD="                    <article class=\"blog-card\">
                        <div class=\"blog-meta\">
                            <time datetime=\"${DATE_ISO}\">${MONTH}</time>
                            <span class=\"blog-tag\">${TAG}</span>
                        </div>
                        <h2 class=\"blog-title\">
                            <a href=\"/blog/${SLUG}\">${TITLE}</a>
                        </h2>
                        <p class=\"blog-excerpt\">${DESC}</p>
                        <a href=\"/blog/${SLUG}\" class=\"blog-link\">Read the piece</a>
                    </article>"

# Insert after blog-grid opening
cd "$REPO_DIR"
python3 -c "
import re
with open('public/blog/index.html') as f:
    html = f.read()
# Insert new card after first blog-grid div
card = '''$NEW_CARD'''
html = html.replace('<div class=\"blog-grid\">', '<div class=\"blog-grid\">\n' + card + '\n', 1)
# Update count
html = re.sub(r'<span class=\"stat-number\">(\d+)</span>', lambda m: f'<span class=\"stat-number\">{int(m.group(1))+1}</span>', html, count=1)
with open('public/blog/index.html', 'w') as f:
    f.write(html)
print('Index updated')
"

echo "=== Creating PR..."
git checkout -b "blog/${SLUG}"
git add "public/blog/${SLUG}.html" "public/blog/${SLUG}.png" "public/blog/index.html"
git commit -m "blog: ${TITLE}"
git push origin "blog/${SLUG}" 2>&1 | tail -2
PR_URL=$(gh pr create --title "blog: ${TITLE}" --body "Auto-published blog post: ${TITLE}" 2>&1)
echo "PR: $PR_URL"

echo "=== Merging..."
gh pr merge --squash 2>&1 || echo "(merge may need manual approval)"

echo ""
echo "✅ Published: https://permissionprotocol.com/blog/${SLUG}"
