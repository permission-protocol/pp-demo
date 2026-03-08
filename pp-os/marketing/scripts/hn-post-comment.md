# HN Comment Posting — Browser Automation Guide

## Prerequisites
- HN credentials stored at `~/.openclaw/secrets/hn-credentials.json`
  Format: `{"username": "...", "password": "..."}`
- Browser tool available in session

## Login Flow
1. `browser navigate` to `https://news.ycombinator.com/login`
2. Fill username field
3. Fill password field  
4. Click "login" button
5. Verify login by checking for "logout" link in nav

## Post Comment Flow
1. Navigate to the target thread: `https://news.ycombinator.com/item?id={STORY_ID}`
2. Find the reply textarea (it's at the bottom of the page for top-level comments)
3. Type the comment text
4. Click "add comment" button
5. Verify comment appears on page
6. Screenshot for confirmation

## Reply to Specific Comment
1. Navigate to `https://news.ycombinator.com/item?id={COMMENT_ID}`
2. The reply box is directly on this page
3. Type and submit as above

## Session Persistence
- HN login cookies persist in browser profile
- After first login, subsequent runs may not need to re-login
- Check for "logout" link to verify session is active before posting

## Rate Limits
- HN has implicit rate limits — don't post more than 2-3 comments per hour
- New accounts may have stricter limits
- If you see "You're posting too fast" error, back off and retry next run
