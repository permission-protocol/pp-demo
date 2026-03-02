#!/usr/bin/env python3
"""
Generate PP-branded quote cards for LinkedIn/Twitter posts.

Usage:
  python3 quote-card.py "Your quote text here" output.png
  python3 quote-card.py "Your quote text here" output.png --accent "key phrase"
  python3 quote-card.py "Your quote text here" output.png --accent "key phrase" --size twitter
"""

import sys
import os
import textwrap
from PIL import Image, ImageDraw, ImageFont

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_DIR = os.path.join(SCRIPT_DIR, "..", "assets")
FONTS_DIR = os.path.join(ASSETS_DIR, "fonts")

# Brand colors
BG_COLOR = (21, 21, 32)          # #151520
ACCENT_COLOR = (255, 107, 91)     # #FF6B5B coral
TEXT_COLOR = (255, 255, 255)      # white
MUTED_COLOR = (138, 138, 154)    # #8A8A9A
GLOW_COLOR = (255, 107, 91, 15)  # subtle coral glow

# Sizes
SIZES = {
    "linkedin": (1200, 628),   # 1.91:1
    "twitter": (1200, 675),    # 16:9
    "square": (1080, 1080),    # Instagram-style
}


def load_fonts(quote_len):
    """Load fonts with size based on quote length."""
    if quote_len < 80:
        quote_size = 52
    elif quote_len < 140:
        quote_size = 44
    elif quote_len < 200:
        quote_size = 36
    else:
        quote_size = 30

    bold = ImageFont.truetype(os.path.join(FONTS_DIR, "Inter-Bold.ttf"), quote_size)
    medium = ImageFont.truetype(os.path.join(FONTS_DIR, "Inter-Medium.ttf"), 16)
    regular = ImageFont.truetype(os.path.join(FONTS_DIR, "Inter-Regular.ttf"), 18)
    return bold, medium, regular, quote_size


def wrap_text(text, font, max_width, draw):
    """Word-wrap text to fit within max_width."""
    words = text.split()
    lines = []
    current_line = ""

    for word in words:
        test_line = f"{current_line} {word}".strip()
        bbox = draw.textbbox((0, 0), test_line, font=font)
        if bbox[2] - bbox[0] <= max_width:
            current_line = test_line
        else:
            if current_line:
                lines.append(current_line)
            current_line = word

    if current_line:
        lines.append(current_line)

    return lines


def draw_accent_line(draw, line, x, y, font, accent_phrase):
    """Draw a line with accent coloring on a specific phrase."""
    if accent_phrase and accent_phrase.lower() in line.lower():
        # Find the accent phrase position (case-insensitive)
        lower_line = line.lower()
        lower_accent = accent_phrase.lower()
        idx = lower_line.find(lower_accent)

        before = line[:idx]
        accent = line[idx:idx + len(accent_phrase)]
        after = line[idx + len(accent_phrase):]

        cx = x
        if before:
            draw.text((cx, y), before, font=font, fill=TEXT_COLOR)
            bbox = draw.textbbox((0, 0), before, font=font)
            cx += bbox[2] - bbox[0]

        draw.text((cx, y), accent, font=font, fill=ACCENT_COLOR)
        bbox = draw.textbbox((0, 0), accent, font=font)
        cx += bbox[2] - bbox[0]

        if after:
            draw.text((cx, y), after, font=font, fill=TEXT_COLOR)
    else:
        draw.text((x, y), line, font=font, fill=TEXT_COLOR)


def generate_card(quote, output_path, accent_phrase=None, size="linkedin"):
    """Generate a quote card."""
    width, height = SIZES.get(size, SIZES["linkedin"])

    # Create image
    img = Image.new("RGB", (width, height), BG_COLOR)
    draw = ImageDraw.Draw(img, "RGBA")

    # Load logo
    logo_path = os.path.join(ASSETS_DIR, "icon-128px.png")
    has_logo = os.path.exists(logo_path)
    if has_logo:
        logo = Image.open(logo_path).convert("RGBA")
        logo = logo.resize((24, 24), Image.LANCZOS)

    # Margins
    margin_x = 80
    max_text_width = width - margin_x * 2

    # Load fonts
    bold_font, badge_font, regular_font, quote_size = load_fonts(len(quote))

    # Calculate quote dimensions first for vertical centering
    lines = wrap_text(quote, bold_font, max_text_width, draw)
    line_height = quote_size + 12
    total_quote_height = len(lines) * line_height

    # Badge height
    badge_text = "PERMISSION PROTOCOL"
    badge_bbox = draw.textbbox((0, 0), badge_text, font=badge_font)
    badge_h = badge_bbox[3] - badge_bbox[1]
    pill_padding_y = 7
    pill_total_h = badge_h + pill_padding_y * 2

    # Attribution height
    attr_height = 30

    # Total content height: badge + gap + quote + gap + attribution
    gap1 = 32  # badge to quote
    gap2 = 24  # quote to attribution
    content_height = pill_total_h + gap1 + total_quote_height + gap2 + attr_height
    # Center vertically, with slight upward bias for optical balance
    start_y = max(40, (height - content_height) // 2 + 10)

    # Current Y cursor
    cy = start_y

    # Draw badge: "PERMISSION PROTOCOL"
    badge_w = badge_bbox[2] - badge_bbox[0]
    pill_padding_x = 12
    logo_space = 32 if has_logo else 0
    pill_x1 = margin_x
    pill_y1 = cy
    pill_x2 = pill_x1 + badge_w + pill_padding_x * 2 + logo_space
    pill_y2 = cy + pill_total_h

    draw.rounded_rectangle(
        [pill_x1, pill_y1, pill_x2, pill_y2],
        radius=4,
        outline=(255, 107, 91, 140),
        width=1
    )

    if has_logo:
        logo_y = pill_y1 + (pill_total_h - 24) // 2
        img.paste(logo, (pill_x1 + pill_padding_x, logo_y), logo)

    draw.text(
        (pill_x1 + pill_padding_x + logo_space, pill_y1 + pill_padding_y),
        badge_text,
        font=badge_font,
        fill=ACCENT_COLOR
    )

    cy = pill_y2 + gap1

    # Draw quote text
    for line in lines:
        if accent_phrase:
            draw_accent_line(draw, line, margin_x, cy, bold_font, accent_phrase)
        else:
            draw.text((margin_x, cy), line, font=bold_font, fill=TEXT_COLOR)
        cy += line_height

    cy += gap2

    # Draw attribution
    attr_text = "permissionprotocol.com"
    # Clamp so it doesn't overlap bottom bar
    attr_y = min(cy, height - 36)
    draw.text(
        (margin_x, attr_y),
        attr_text,
        font=regular_font,
        fill=(160, 160, 175)
    )

    # Accent bar at bottom
    draw.rectangle(
        [0, height - 6, width, height],
        fill=ACCENT_COLOR
    )

    img.save(output_path, "PNG", quality=95)
    print(f"Generated: {output_path} ({width}x{height})")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Generate PP quote cards")
    parser.add_argument("quote", help="Quote text")
    parser.add_argument("output", help="Output PNG path")
    parser.add_argument("--accent", help="Phrase to highlight in coral", default=None)
    parser.add_argument("--size", choices=SIZES.keys(), default="linkedin", help="Card size")
    args = parser.parse_args()

    generate_card(args.quote, args.output, args.accent, args.size)
