# Internal Linking Optimization Plan
**Created:** 2026-02-03 19:00 MST  
**Status:** Ready to execute when blog.xdares.com accessible  
**Task ID:** task-022

## Executive Summary
This plan details strategic internal linking between the new blog posts to distribute page authority and improve user navigation. The blog is currently unreachable (ERR_CONNECTION_TIMED_OUT), so this plan will be executed when connectivity is restored.

---

## Posts to Interlink

### New Content Posts (Published 2026-02-03/04)
| Post ID | Title | URL | Status |
|---------|-------|-----|--------|
| 2268 | 500+ Truth or Dare Questions for Adults [2026] | /truth-or-dare-questions-for-adults/ | Cornerstone |
| 2281 | 100+ Dirty Dares for Couples | /dirty-dares-for-couples/ | Supporting |
| 2284 | 200+ Truth or Dare Questions Over Text | /elementor-2284/ | Supporting |
| 2289 | Truth or Dare Drinking Game | *(URL TBD - check when live)* | Supporting |

### Cornerstone Content (Existing)
- Xdares App homepage CTAs (already present in posts)
- Related Posts widget (Elementor - auto-generated)

---

## Internal Linking Matrix

### From: 500+ Truth or Dare Questions for Adults (ID 2268) - CORNERSTONE
**Add links TO:**
| Target Post | Anchor Text | Placement |
|-------------|-------------|-----------|
| Dirty Dares for Couples (2281) | "dirty dares for couples" or "spice things up" | In the Adults/18+ section |
| Questions Over Text (2284) | "play over text" or "texting version" | In the introduction or "How to Play" section |
| Drinking Game (2289) | "drinking game version" or "party rules" | In the Party section or Rules area |

### From: 100+ Dirty Dares for Couples (ID 2281)
**Add links TO:**
| Target Post | Anchor Text | Placement |
|-------------|-------------|-----------|
| Adults Questions (2268) | "500+ questions for adults" or "complete collection" | In introduction - link to full list |
| Questions Over Text (2284) | "play remotely" or "long-distance couples" | In a section about different ways to play |
| Drinking Game (2289) | "add drinks" or "drinking version" | In tips/variations section |

### From: 200+ Truth or Dare Questions Over Text (ID 2284)
**Add links TO:**
| Target Post | Anchor Text | Placement |
|-------------|-------------|-----------|
| Adults Questions (2268) | "adult questions" or "in-person version" | When mentioning face-to-face play |
| Dirty Dares for Couples (2281) | "couples dares" or "romantic challenges" | In flirty/romantic section |
| Drinking Game (2289) | "drinking rules" or "party version" | In variations/advanced play section |

### From: Truth or Dare Drinking Game (ID 2289)
**Add links TO:**
| Target Post | Anchor Text | Placement |
|-------------|-------------|-----------|
| Adults Questions (2268) | "500+ questions" or "complete question list" | Reference for more questions |
| Dirty Dares for Couples (2281) | "couples dares" or "spicy challenges" | In dares section |
| Questions Over Text (2284) | "remote play" or "virtual drinking games" | In variations for remote play |

---

## Implementation Checklist

### Pre-Execution
- [ ] Verify blog.xdares.com is accessible
- [ ] Confirm all 4 posts are published and live
- [ ] Get actual URLs for all posts (especially 2289 which may have changed)

### Execution Steps (Per Post)
1. **Login to WordPress admin** (https://blog.xdares.com/wp-admin)
2. **Edit post** using Elementor (Posts → All Posts → Edit with Elementor)
3. **Find appropriate section** based on placement recommendations above
4. **Add internal link:**
   - Select anchor text
   - Add link (use Link icon or Ctrl+K)
   - Paste target URL
   - Set to open in same tab (not new tab - keeps users on site)
5. **Update/Publish post**
6. **Document link added** (for rollback purposes)

### Post-Execution
- [ ] Clear any caching (10Web/Cloudflare if applicable)
- [ ] Test all links work correctly
- [ ] Update this document with completed links

---

## Links Added Log (For Rollback)

*Fill in during execution:*

### Post 2268 (Adults Questions)
| Link Added | Target URL | Anchor Text | Section Location |
|------------|-----------|-------------|------------------|
| *(pending)* | | | |

### Post 2281 (Dirty Dares)
| Link Added | Target URL | Anchor Text | Section Location |
|------------|-----------|-------------|------------------|
| *(pending)* | | | |

### Post 2284 (Over Text)
| Link Added | Target URL | Anchor Text | Section Location |
|------------|-----------|-------------|------------------|
| *(pending)* | | | |

### Post 2289 (Drinking Game)
| Link Added | Target URL | Anchor Text | Section Location |
|------------|-----------|-------------|------------------|
| *(pending)* | | | |

---

## Rollback Procedure

If links need to be removed:
1. Open each post in Elementor editor
2. Find linked text (Ctrl+F for "href" in text editor mode)
3. Remove hyperlink (select text → unlink)
4. Update post
5. Clear cache

---

## SEO Best Practices Applied

1. **Natural anchor text** - Using descriptive phrases, not "click here"
2. **Contextual placement** - Links appear where they make sense topically
3. **Reasonable quantity** - 3 links per post (not over-optimized)
4. **Hub structure** - Cornerstone post (2268) receives most links
5. **Same-tab links** - Keeps users on site, reduces bounce rate

---

## Expected Impact

- **Page Authority Distribution:** Links from cornerstone (2268) will boost newer posts
- **User Navigation:** Readers can easily find related content
- **Crawl Efficiency:** Search engines discover all related content faster
- **Time on Site:** More internal navigation increases engagement metrics
- **Topical Relevance:** Strengthens the "truth or dare" topic cluster

---

*Plan created by Goal Executor subagent (task-022)*  
*Execute when blog connectivity restored*
