# Image SEO Optimization Plan: blog.xdares.com
**Date:** 2026-02-03
**Task ID:** task-021
**Status:** BLOCKED - Site connectivity issues

---

## Executive Summary

This plan documents image SEO optimizations for blog.xdares.com. Implementation pending site connectivity restoration. The site has ShortPixel Image Optimizer installed which should handle compression automatically on upload.

---

## Current Infrastructure

### Installed Tools
- **ShortPixel Image Optimizer** - WordPress plugin (detected via worker process)
- **10Web Website Booster** - Built-in image optimization via hosting panel
- **Elementor** - Page builder with lazy loading support

### Existing Local Assets

| Current Filename | Size | Dimensions | Status |
|-----------------|------|------------|--------|
| couple-pillow-fight.jpg | 1.4MB | 1920x2887 | ⚠️ Oversized - needs compression |
| couple-date-night.jpg | 417KB | 1920x2880 | ⚠️ Oversized - needs compression |
| truth-or-dare-party-friends.jpg | 286KB | 1920x1080 | ✅ Acceptable size |

---

## Optimization Recommendations

### 1. Filename Conventions (SEO-Optimized)

**Before → After (with target keywords)**

| Current Name | Optimized Name | Target Post |
|--------------|----------------|-------------|
| couple-pillow-fight.jpg | dirty-dares-for-couples-pillow-fight.jpg | Dirty Dares for Couples |
| couple-date-night.jpg | truth-or-dare-date-night-questions.jpg | Couples posts |
| truth-or-dare-party-friends.jpg | truth-or-dare-questions-adults-party.jpg | Adults/Party posts |

### 2. Alt Text Recommendations

For each published post, update alt text using this formula:
```
[Primary Keyword] - [Descriptive context] | Xdares
```

**Examples:**

| Post | Image Alt Text |
|------|---------------|
| 500+ Truth or Dare Questions for Adults | "Truth or dare questions for adults - group of friends playing at house party" |
| Dirty Dares for Couples | "Dirty dares for couples - romantic couple on date night ready for fun challenges" |
| Truth or Dare Over Text | "Truth or dare over text - phone screen showing flirty messages between friends" |
| Truth or Dare Drinking Game | "Truth or dare drinking game questions - friends with drinks at party" |

### 3. Image Compression Targets

| Image Type | Max Width | Max File Size | Format |
|------------|-----------|---------------|--------|
| Featured image | 1200px | 150KB | WebP (JPEG fallback) |
| In-content image | 800px | 100KB | WebP (JPEG fallback) |
| Thumbnail | 400px | 50KB | WebP |

**Action:** Configure ShortPixel to auto-convert to WebP with JPEG fallback.

---

## Per-Post Image Audit Checklist

### Post: 500+ Truth or Dare Questions for Adults (ID 2268)
- [ ] Check featured image has keyword-rich filename
- [ ] Update alt text: "Truth or dare questions for adults - friends laughing at party game"
- [ ] Verify ShortPixel compression applied
- [ ] Confirm lazy loading enabled

### Post: Dirty Dares for Couples (ID 2281)
- [ ] Featured image filename includes "dirty-dares-couples"
- [ ] Alt text: "Dirty dares for couples - romantic couple having fun on date night"
- [ ] Verify WebP conversion
- [ ] Check mobile responsive sizing

### Post: Truth or Dare Over Text (ID 2284)
- [ ] Featured image filename includes "truth-or-dare-text"
- [ ] Alt text: "Truth or dare over text messages - smartphone showing flirty game questions"
- [ ] Verify compression

### Post: Truth or Dare Drinking Game (ID 2289)
- [ ] Featured image filename includes "drinking-game"
- [ ] Alt text: "Truth or dare drinking game - party friends with drinks playing challenges"
- [ ] Verify optimization

---

## Technical Implementation Steps

### When Site Accessible:

1. **Access ShortPixel Settings** (WP Admin → Settings → ShortPixel)
   - Enable "Create WebP versions"
   - Set compression level to "Lossy" (best size reduction)
   - Enable "Process thumbnails"
   - Enable "Process PDF to JPG"

2. **Run Bulk Optimization**
   - ShortPixel → Bulk Actions → Start Optimizing
   - This will compress all existing media library images

3. **Check 10Web Image Optimizer**
   - 10Web Dashboard → Website Booster → Image Optimizer
   - Verify auto-optimization is enabled
   - Run manual optimization if needed

4. **Update Alt Text** (WP Admin → Media Library)
   - For each image, click Edit
   - Add SEO-optimized alt text from recommendations above
   - Save changes

5. **Rename Media Files** (use Media File Renamer plugin if needed)
   - Or re-upload with correct filenames
   - Update post references

---

## Priority Images to Create/Optimize

### Missing Featured Images (may need sourcing)

| Post/Page | Recommended Image | Keywords for Alt |
|-----------|-------------------|------------------|
| Truth or Dare Questions for Teens | Teen friends playing group game | truth or dare questions for teens |
| Would You Rather Questions | Friends pondering difficult choice | would you rather questions adults |
| Party Games for Adults | House party game night scene | party games for adults truth or dare |

### Stock Image Sources (Free)
- Unsplash: https://unsplash.com/s/photos/party-game
- Pexels: https://www.pexels.com/search/friends%20game/
- Pixabay: https://pixabay.com/images/search/party%20fun/

---

## Image SEO Best Practices (Quick Reference)

1. **Filenames**
   - Use hyphens between words (not underscores)
   - Include primary keyword
   - Be descriptive but concise
   - Avoid generic names (IMG_001.jpg)

2. **Alt Text**
   - Describe the image accurately
   - Include target keyword naturally
   - Keep under 125 characters
   - Don't stuff keywords

3. **File Size**
   - Aim for under 100KB for web images
   - Use WebP format when possible
   - Balance quality vs. file size

4. **Dimensions**
   - Max 1200px width for featured images
   - Use srcset for responsive images
   - Don't upload larger than needed

5. **Lazy Loading**
   - Enable for below-fold images
   - Keep hero image eager-loaded
   - Use native loading="lazy" attribute

---

## Metrics to Track

After optimization, monitor in Google Search Console:
- Core Web Vitals (LCP improvement from image optimization)
- Image search impressions
- Click-through rate changes

---

## Blockers

**Current Status:** Cannot access blog.xdares.com due to connectivity issues

**Evidence:**
- curl timeout after 13+ seconds
- Browser navigation fails with ERR_CONNECTION_TIMED_OUT
- 10Web hosting logs show site was serving requests as of 01:07 UTC (Feb 4)

**Resolution Needed:**
- Check 10Web hosting status
- Verify DNS resolution
- May need Rod to investigate from different network

---

*Generated by Goal Executor - Task #021*
*Plan ready for execution when site connectivity restored*
