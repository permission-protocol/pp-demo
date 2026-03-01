#!/usr/bin/env python3
"""
QA Evidence Gatherer — fetches real evidence for unproven AC criteria.
Called by qa-test-runner.sh for each unproven criterion.

Input: JSON file with {ac, ac_lower, verify_url, workspace, body}
Output: JSON to stdout with {status, evidence}

Checks:
1. File existence (paths mentioned in AC)
2. URL content (fetch + pattern match)
3. CSS/color values in page source
4. OG/Twitter meta tags
5. Code blocks / receipt JSON
6. Section structure (H2 counts)
7. CTA links
8. "How to verify" curl commands from issue body
"""

import json
import os
import re
import sys
import urllib.request


def gather_evidence(ctx):
    ac = ctx["ac"]
    ac_lower = ctx["ac_lower"]
    verify_url = ctx.get("verify_url", "")
    workspace = ctx.get("workspace", "")
    body = ctx.get("body", "")
    
    status = "unproven"
    evidence = []
    
    # ── 1. File existence ──
    file_patterns = re.findall(r'`([a-zA-Z0-9_./-]+\.[a-z]+)`', ac)
    file_patterns += re.findall(r'(\S+\.(?:md|json|html|yml|yaml|txt|css|js))', ac)
    # Deduplicate
    file_patterns = list(dict.fromkeys(file_patterns))
    
    for fpath in file_patterns[:3]:
        for base in [workspace, os.path.join(workspace, "goals/xdares-seo-growth"), 
                     os.path.join(workspace, "pp-os"), "/tmp"]:
            full = os.path.join(base, fpath)
            if os.path.exists(full):
                size = os.path.getsize(full)
                try:
                    with open(full, "r", errors="replace") as fh:
                        snippet = fh.read(300).replace("\n", " ").strip()
                    evidence.append(f"File exists: {full} ({size}B). Preview: {snippet[:200]}")
                except:
                    evidence.append(f"File exists: {full} ({size}B)")
                status = "proven"
                break
    
    if status == "proven":
        # Check content requirements if any
        content_reqs = re.findall(r'contains?\s+(.+?)(?:\s+and|\s*$)', ac_lower)
        if content_reqs and file_patterns:
            for base in [workspace, os.path.join(workspace, "goals/xdares-seo-growth"),
                         os.path.join(workspace, "pp-os"), "/tmp"]:
                full = os.path.join(base, file_patterns[0])
                if os.path.exists(full):
                    try:
                        with open(full, "r", errors="replace") as fh:
                            content = fh.read()
                        for req in content_reqs:
                            if re.search(re.escape(req.strip()), content, re.IGNORECASE):
                                evidence.append(f"Content requirement '{req.strip()}' found")
                            else:
                                evidence.append(f"Content requirement '{req.strip()}' NOT found")
                    except:
                        pass
                    break
        return {"status": status, "evidence": evidence}
    
    # ── 2. URL content extraction ──
    # Extract URLs from AC text
    ac_urls = re.findall(r'https?://[^\s`\'"]+', ac.replace("`", ""))
    
    # Build URL from path + verify_url domain
    path_match = re.search(r'`(/[a-zA-Z0-9/_-]+)`', ac)
    if path_match and verify_url:
        base_domain = re.match(r'(https?://[^/]+)', verify_url)
        if base_domain:
            ac_urls.append(base_domain.group(1) + path_match.group(1))
    
    # If no URL but verify_url exists and AC mentions page content, use verify_url
    if not ac_urls and verify_url:
        content_keywords = ["render", "display", "show", "section", "template", "meta", 
                          "receipt", "cta", "link", "dark", "background", "visible"]
        if any(kw in ac_lower for kw in content_keywords):
            ac_urls.append(verify_url)
    
    page_html = None
    for url in ac_urls[:1]:
        try:
            req = urllib.request.Request(url)
            req.add_header("User-Agent", "QA-Test-Runner/1.0")
            resp = urllib.request.urlopen(req, timeout=15)
            page_html = resp.read().decode("utf-8", errors="replace")
            page_text = re.sub(r"<[^>]+>", " ", page_html)
            page_text = re.sub(r"\s+", " ", page_text).strip()
            evidence.append(f"Fetched {url}: HTTP {resp.getcode()}, {len(page_html)}B")
            evidence.append(f"Page text (500 chars): {page_text[:500]}")
        except Exception as e:
            evidence.append(f"URL fetch error for {url}: {str(e)[:100]}")
    
    if page_html:
        # ── OG/Twitter meta tags ──
        if "meta" in ac_lower and ("og" in ac_lower or "twitter" in ac_lower):
            og_tags = re.findall(
                r'<meta\s+(?:property|name)="((?:og|twitter):[^"]*)"[^>]*content="([^"]*)"',
                page_html, re.IGNORECASE
            )
            if og_tags:
                status = "proven"
                tag_list = ", ".join(f"{t[0]}={t[1][:30]}" for t in og_tags[:5])
                evidence.append(f"Found {len(og_tags)} OG/Twitter meta tags: {tag_list}")
            else:
                evidence.append("No OG/Twitter meta tags found in page source")
        
        # ── Receipt / code blocks ──
        if "receipt" in ac_lower and ("json" in ac_lower or "code" in ac_lower or "example" in ac_lower):
            code_blocks = re.findall(r"<(?:code|pre)[^>]*>(.*?)</(?:code|pre)>", page_html, re.DOTALL)
            json_like = [b for b in code_blocks if '"version"' in b or '"status"' in b or '"signature"' in b]
            if json_like:
                status = "proven"
                evidence.append(f"Found {len(json_like)} receipt-like code blocks. First: {json_like[0][:200]}")
            elif code_blocks:
                evidence.append(f"Found {len(code_blocks)} code blocks but none look like receipts")
            else:
                evidence.append("No code blocks found in page")
        
        # ── Section structure ──
        if "section" in ac_lower or "template" in ac_lower:
            h2s = re.findall(r"<h2[^>]*>(.*?)</h2>", page_html, re.IGNORECASE)
            h2_clean = [re.sub(r"<[^>]+>", "", h).strip() for h in h2s]
            if h2_clean:
                evidence.append(f"Found {len(h2_clean)} H2 sections: {', '.join(h[:40] for h in h2_clean[:8])}")
                if "5" in ac_lower or "five" in ac_lower:
                    if len(h2_clean) >= 5:
                        status = "proven"
                        evidence.append(f"Has {len(h2_clean)} sections (meets 5-section requirement)")
            else:
                evidence.append("No H2 sections found")
        
        # ── CTA links ──
        if "cta" in ac_lower or ("/install" in ac_lower and "link" in ac_lower):
            install_links = re.findall(r'href="([^"]*install[^"]*)"', page_html, re.IGNORECASE)
            if install_links:
                status = "proven"
                evidence.append(f"Found {len(install_links)} links to install: {install_links[:3]}")
            else:
                evidence.append("No /install links found")
        
        # ── CSS colors / visual rendering ──
        if any(kw in ac_lower for kw in ["render", "dark", "bg", "background", "visible", "contrast", "#"]):
            colors_in_ac = re.findall(r"#[0-9a-fA-F]{6}", ac)
            for color in colors_in_ac:
                if color.lower() in page_html.lower():
                    status = "proven"
                    evidence.append(f"Color {color} found in page source")
                else:
                    evidence.append(f"Color {color} NOT found in page source")
            
            if not colors_in_ac:
                # Check for inline styles with dark backgrounds
                dark_patterns = re.findall(
                    r'(?:background|background-color)\s*:\s*(#[0-9a-fA-F]{3,6}|rgb[^;]+)',
                    page_html, re.IGNORECASE
                )
                if dark_patterns:
                    evidence.append(f"Background colors found: {', '.join(dark_patterns[:5])}")
        
        # ── Blog post at specific path (published check) ──
        if "published" in ac_lower or "blog post" in ac_lower:
            if len(page_html) > 500:
                title_match = re.search(r"<h1[^>]*>(.*?)</h1>", page_html, re.IGNORECASE)
                if title_match:
                    status = "proven"
                    evidence.append(f"Published page found with title: {title_match.group(1)[:100]}")
    
    # ── 3. "How to verify" curl commands ──
    if status == "unproven" and body:
        verify_section = re.search(
            r"How to verify.*?\n(.*?)(?=\n## |\Z)", body, re.DOTALL | re.IGNORECASE
        )
        if verify_section:
            curl_cmds = re.findall(r"`(curl\s[^`]+)`", verify_section.group(1))
            for cmd in curl_cmds:
                try:
                    curl_url_match = re.search(r"https?://\S+", cmd)
                    grep_match = re.search(r"grep\s+(?:-i\s+)?['\"]?([^'\"|\\s]+)", cmd)
                    if curl_url_match:
                        req = urllib.request.Request(curl_url_match.group())
                        req.add_header("User-Agent", "QA-Test-Runner/1.0")
                        resp = urllib.request.urlopen(req, timeout=15)
                        content = resp.read().decode("utf-8", errors="replace")
                        if grep_match:
                            pattern = grep_match.group(1)
                            matches = re.findall(pattern, content, re.IGNORECASE)
                            if matches:
                                status = "proven"
                                evidence.append(
                                    f"curl verify: found '{pattern}' {len(matches)} times in {curl_url_match.group()}"
                                )
                            else:
                                evidence.append(
                                    f"curl verify: '{pattern}' NOT found in {curl_url_match.group()}"
                                )
                        else:
                            evidence.append(f"curl verify: HTTP {resp.getcode()} from {curl_url_match.group()}")
                except Exception as e:
                    evidence.append(f"Curl verify error: {str(e)[:100]}")
    
    return {"status": status if status != "unproven" or evidence else "unproven", "evidence": evidence}


if __name__ == "__main__":
    ctx_file = sys.argv[1]
    with open(ctx_file) as f:
        ctx = json.load(f)
    
    result = gather_evidence(ctx)
    print(json.dumps(result))
