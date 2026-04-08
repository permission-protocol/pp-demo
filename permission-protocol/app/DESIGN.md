# Design System Strategy

## 1. Overview & Creative North Star: "The Sovereign Logic"
This design system is built for the high-stakes world of AI governance and cryptographic certainty. Our Creative North Star is **The Sovereign Logic**. It moves away from the "friendly SaaS" trope of rounded corners and bright pops of color, leaning instead into a sophisticated, terminal-chic aesthetic that signals authority, precision, and developer-first utility.

The experience is defined by **Intentional Asymmetry** and **Tonal Depth**. By utilizing a radical contrast between the obsidian-deep background (`#131313`) and the luminescent emerald primary (`#4EDE3`), we create a "Heads-Up Display" (HUD) feel. We break the template look by rejecting standard borders and grid-aligned boxes in favor of overlapping layers, subtle grid-pattern overlays, and expansive vertical rhythm that mimics an editorial spread more than a generic dashboard.

---

## 2. Colors: Obsidian & Neon Precision
Our palette is rooted in the dark mode experience. Color is never decorative; it is functional and semantic.

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to define sections. Layout boundaries must be achieved through background shifts. For example:
- A main content area on `surface` (`#131313`) transitions to a footer or sidebar on `surface-container-low` (`#1C1B1B`).
- Cards should be defined by `surface-container-highest` (`#353534`) sitting on a `surface` background.

### Surface Hierarchy & Nesting
Treat the UI as physical layers of tech-black obsidian. Use the `surface-container` tiers to define "importance" through perceived proximity:
1. **Base:** `surface` (#131313) - The infinite canvas.
2. **Inlay:** `surface-container-low` (#1C1B1B) - Large sectioning.
3. **Raised:** `surface-container-highest` (#353534) - High-priority interactive cards.

### The "Glass & Gradient" Rule
To elevate the "terminal" aesthetic, floating elements (modals, dropdowns) should use **Glassmorphism**. Apply `surface-container` colors at 80% opacity with a `backdrop-filter: blur(12px)`.

**Signature Textures:** Primary CTAs should not be flat. Use a subtle linear gradient from `primary` (`#4EDE3`) to `primary-container` (`#10B981`) at a 135-degree angle to provide a "lit from within" look.

---

## 3. Typography: Editorial Brutalism
The pairing of **Space Grotesk** and **Inter** creates a tension between futuristic industrialism and human-readable clarity.

* **Display & Headlines (Space Grotesk):** Use this for all impactful messaging. The wide apertures and geometric construction signal a modern, high-tech identity.
* **Body & Titles (Inter):** Reserved for technical documentation, data, and long-form reading. Inter provides the "Professional Trust" necessary for a protocol-level product.
* **Monospace Utility (Space Mono):** Specifically for code snippets and "terminal-chic" accents (like labels and timestamps).

**Hierarchy Strategy:** Use extreme scale. A `display-lg` headline should be surrounded by significant whitespace (`spacing-24`), immediately followed by a `body-md` description to create an "Editorial" look that feels premium and intentional.

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows are too "soft" for a terminal-inspired system. We use **Tonal Layering**.

* **The Layering Principle:** Depth is achieved by "stacking." Place a `surface-container-lowest` card on a `surface-container-low` section to create a "recessed" or "cut-out" feel.
* **Ambient Shadows:** When an element must float (e.g., a "Receipt" popover), use a highly diffused shadow: `box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4)`. The shadow color is not grey; it is a darkened version of the background.
* **The "Ghost Border" Fallback:** If a border is required for accessibility, it must be a "Ghost Border." Use `outline-variant` (`#3C4A42`) at 20% opacity. Never use 100% opaque borders.
* **Grid Overlays:** For hero sections or code areas, use a subtle 24px repeating grid pattern in `outline-variant` at 5% opacity to reinforce the "developer-centric" theme.

---

## 5. Components

### Buttons
* **Primary:** Gradient of `primary` to `primary-container`. High-contrast `on-primary` text. `rounded-md` (0.375rem).
* **Secondary:** Ghost style. No background, `outline-variant` ghost border (20% opacity), text in `primary`.
* **Tertiary:** All-caps `label-md` using Space Mono. No background or border.

### The "Receipt" Card
A signature component for Permission Protocol.
* **Background:** `surface-container-highest` with a 10% opacity `primary` glow.
* **Header:** `title-sm` with a "Verified" badge using `primary` text and a tiny emerald pulse animation.
* **Content:** No dividers. Use `spacing-4` to separate data points.

### Code Snippets
* **Container:** `surface-container-lowest` (`#0E0E0E`).
* **Syntax Highlighting:** Use `primary` for functions, `secondary` for strings, and `on-surface-variant` for comments.
* **Edge Case:** Add a "Copy" button in the top right that only appears on hover to keep the interface clean.

### Input Fields
* **Style:** Underline-only or subtle `surface-container-low` fill.
* **Focus State:** The bottom border transforms into a `primary` glow. No heavy "blue glow" standard; keep it sharp and narrow.

---

## 6. Do's and Don'ts

### Do
* **Do** use `Space Mono` for small metadata (timestamps, IDs, version numbers).
* **Do** use intentional asymmetry—offset your text columns to the left while leaving the right for abstract "terminal" graphics.
* **Do** utilize `primary` (`#4EDE3`) as a "laser pointer"—it should only appear where the user needs to act or where success is confirmed.

### Don't
* **Don't** use dividers or lines to separate list items. Use background alternating shifts or white space.
* **Don't** use standard "Success Green." Stick strictly to the emerald/teal tokens provided.
* **Don't** use large border-radii. Keep it "professional" with `md` (0.375rem) or `sm` (0.125rem). Avoid `full` (pill-shape) except for tiny status tags.
* **Don't** overcrowd. The sophisticated "Protocol" look requires 20% more whitespace than a standard consumer app.