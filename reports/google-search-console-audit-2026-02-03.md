# Google Search Console Audit Report
**Date:** February 3, 2026  
**Property:** xdares.com (domain property)  
**Audited by:** Charles Goldberg  
**Goal:** Identify indexing issues and opportunities for xdares-seo-growth goal

---

## Executive Summary

✅ **Good News:**
- Google Search Console properly configured and monitoring
- 172 total web search clicks showing initial traction
- HTTPS implementation working correctly (4 good, 0 poor)
- Breadcrumbs schema working (2 valid)
- Review snippets working (2 valid)
- One page showing increased impressions: `truth-or-dare-adults`

🚨 **Critical Issues Found:**
- **755 pages with server errors (5xx)** - Major indexing blocker
- **1,789 pages not indexed** vs only 382 indexed pages  
- **FAQ schema markup issues** - 2 pages missing mainEntity field
- **489 pages with canonical tag issues** - Duplicate content problems

---

## Performance Overview

- **Total web search clicks:** 172
- **Trending page:** https://blog.xdares.com/truth-or-dare-adults/ (increased impressions)
- **Core Web Vitals:** No data yet (insufficient traffic)
- **HTTPS status:** ✅ 4 good, 0 poor

---

## Critical Issues Breakdown

### 1. Server Errors (5xx) - 755 Pages ⚠️
**Impact:** HIGH - Pages cannot be indexed due to server failures

**Examples of affected URLs:**
- `https://blog.xdares.com/blog/category/adult-dares/`
- `https://xdares.com/blog/52-insanely-fun-ideas-to-dare-to-friends-online-ready-for-the-ultimate-dare-challenge`
- `https://xdares.com/blog/100-mind-blowing-online-truth-dare-questions-challenges-that-promise-non-stop-fun`

**Analysis:** Most affected pages appear to be the junk content that should have been cleaned up. These are likely the 236 posts that were supposed to be noindexed but are still throwing server errors instead.

**Recommended Action:** 
1. Verify these are the cleanup posts that should be removed/noindexed
2. Fix server errors or properly remove these pages
3. Monitor for legitimate pages affected

### 2. Indexing Issues - 1,789 Not Indexed ⚠️

**Breakdown by reason:**
- **Server error (5xx):** 755 pages (see above)
- **Alternate page with proper canonical tag:** 489 pages (duplicate content)  
- **Crawled - currently not indexed:** 323 pages (low quality signal)
- **Discovered - currently not indexed:** 148 pages (crawl budget/quality)
- **Excluded by 'noindex' tag:** 48 pages (expected - cleanup posts)
- **Page with redirect:** 21 pages (redirect chains)
- **Blocked by robots.txt:** 3 pages (configuration issue)
- **Soft 404:** 2 pages (content issues)

**Priority Actions:**
1. Fix server errors (highest priority)
2. Review canonical tag implementation for 489 pages
3. Investigate why 323 crawled pages aren't being indexed

### 3. FAQ Schema Issues - 2 Pages ⚠️

**Issue:** Missing field "mainEntity" in FAQ structured data
**Status:** Not Started (validation pending)
**Impact:** MEDIUM - Prevents rich snippets for FAQ content

**Previously Fixed:** Duplicate FAQPage field issue (now 0 pages affected)

**Recommended Action:**
1. Identify the 2 pages with missing mainEntity
2. Update FAQ schema markup to include proper mainEntity structure
3. Request revalidation in GSC

---

## Recommendations by Priority

### Immediate (Critical) 🔴
1. **Fix server errors (5xx) for 755 pages** - Contact hosting provider (10Web) to investigate
2. **Resolve canonical tag issues** - Review 489 pages for proper canonical implementation
3. **Fix FAQ schema** - Add missing mainEntity field to 2 affected pages

### Short-term (High Impact) 🟡  
1. **Investigate indexing quality issues** - Review why 323 crawled pages aren't indexed
2. **Fix redirect chains** - Clean up 21 pages with redirect issues
3. **Monitor core web vitals** - Once traffic increases, optimize performance

### Ongoing (Optimization) 🟢
1. **Track performance improvements** - Monitor the trending truth-or-dare-adults page
2. **Validate schema markup** - Ensure all structured data is working correctly
3. **Monitor crawl budget** - Watch for improvements as issues are fixed

---

## Positive Signals

✅ **What's Working:**
- Domain property correctly configured
- Sitemap auto-generation via Rank Math
- HTTPS implementation solid
- Breadcrumbs schema functioning
- Review snippets schema working
- Initial organic traction (172 clicks)

✅ **Recent Success:**
- `truth-or-dare-adults` page showing increased impressions
- No major technical SEO blocking issues in site structure
- Clean URL structure for new posts

---

## Next Steps

1. **Coordinate with hosting provider** to resolve 5xx server errors
2. **Review WordPress configuration** for canonical tags and redirects
3. **Fix FAQ schema markup** on the 2 problematic pages
4. **Schedule follow-up audit** in 7 days to track improvements
5. **Monitor indexing progress** as issues are resolved

---

## Files Created
- This report: `reports/google-search-console-audit-2026-02-03.md`
- Next: Contact 10Web support for server error investigation

---

*This audit completes task-024 of the xdares-seo-growth goal. The findings will inform prioritization of technical fixes in upcoming tasks.*