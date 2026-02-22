# Task-025: Structured Data Markup Plan

**Created:** 2026-02-03 23:00 MST  
**Status:** ⏸️ BLOCKED - Server unreachable  
**Blocker:** blog.xdares.com is not responding (connection timeout)

---

## Objective

Add Article and Breadcrumb schema markup to blog.xdares.com to improve rich snippets in Google search results, supporting the goal of growing blog traffic from ~100/month to 5,000/month.

## Target Posts

| Post ID | Topic | Slug (estimated) |
|---------|-------|------------------|
| 2268 | Adults | TBD |
| 2281 | Couples | TBD |
| 2284 | Text | TBD |
| 2289 | Drinking | TBD |

## Credentials (Retrieved)

- **WordPress Admin:** https://blog.xdares.com/wp-admin
- **Username:** cgoldber82@gmail.com
- **Password:** Retrieved from 1Password ✓
- **App Password:** yYD2 tcd5 lZXJ oxta aHWV UGl3 (for API access)

## Implementation Plan

### Option A: Use WordPress Plugin (Recommended)

1. **Install Yoast SEO or Rank Math** (if not already installed)
   - Both have built-in schema markup support
   - Navigate to wp-admin → Plugins → Add New
   - Search for "Yoast SEO" or "Rank Math"
   - Install and activate

2. **Configure Article Schema**
   - Yoast: Settings → Content Types → Posts → Schema → Article
   - Rank Math: Schema → Global Schema → Article
   - Enable for all blog posts

3. **Configure Breadcrumb Schema**
   - Yoast: Settings → Breadcrumbs → Enable → Add to theme
   - Rank Math: General Settings → Breadcrumbs → Enable

4. **Verify on Target Posts**
   - Edit each post (2268, 2281, 2284, 2289)
   - Check schema settings in post editor sidebar
   - Ensure Article type is set correctly

### Option B: Manual JSON-LD (If No Plugin)

Add to theme's functions.php or use Code Snippets plugin:

```php
function xdares_article_schema() {
    if (is_single()) {
        global $post;
        $schema = array(
            '@context' => 'https://schema.org',
            '@type' => 'Article',
            'headline' => get_the_title(),
            'author' => array(
                '@type' => 'Person',
                'name' => get_the_author()
            ),
            'datePublished' => get_the_date('c'),
            'dateModified' => get_the_modified_date('c'),
            'image' => get_the_post_thumbnail_url($post->ID, 'full'),
            'publisher' => array(
                '@type' => 'Organization',
                'name' => 'Xdares',
                'logo' => array(
                    '@type' => 'ImageObject',
                    'url' => get_site_url() . '/wp-content/uploads/logo.png'
                )
            ),
            'mainEntityOfPage' => get_permalink()
        );
        echo '<script type="application/ld+json">' . json_encode($schema) . '</script>';
    }
}
add_action('wp_head', 'xdares_article_schema');

function xdares_breadcrumb_schema() {
    if (is_single()) {
        $schema = array(
            '@context' => 'https://schema.org',
            '@type' => 'BreadcrumbList',
            'itemListElement' => array(
                array(
                    '@type' => 'ListItem',
                    'position' => 1,
                    'name' => 'Home',
                    'item' => get_site_url()
                ),
                array(
                    '@type' => 'ListItem',
                    'position' => 2,
                    'name' => 'Blog',
                    'item' => get_site_url() . '/blog'
                ),
                array(
                    '@type' => 'ListItem',
                    'position' => 3,
                    'name' => get_the_title()
                )
            )
        );
        echo '<script type="application/ld+json">' . json_encode($schema) . '</script>';
    }
}
add_action('wp_head', 'xdares_breadcrumb_schema');
```

### Testing Steps

1. **Google Rich Results Test**
   - https://search.google.com/test/rich-results
   - Test each target URL after implementation
   - Should show Article and Breadcrumb validity

2. **Schema Markup Validator**
   - https://validator.schema.org/
   - Paste page URL to verify JSON-LD

3. **Check Google Search Console**
   - Enhancements → Articles
   - Enhancements → Breadcrumbs
   - Look for errors/warnings

## Rollback Plan

If issues arise:
- **Plugin route:** Deactivate the schema features in plugin settings
- **Manual route:** Remove the code from functions.php or deactivate snippet

## Next Steps When Server Recovers

1. Confirm blog.xdares.com is accessible
2. Check if Yoast SEO or Rank Math is already installed
3. If yes, configure schema settings
4. If no, install preferred plugin
5. Test with Rich Results Test
6. Update task status

---

**Note:** This task can be resumed when the server is back online. Monitor 10Web dashboard or try accessing the site again later.
