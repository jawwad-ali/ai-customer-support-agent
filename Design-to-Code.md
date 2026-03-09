# Pixel-Perfect UI Build — Instructions

## Your Role

You are a senior frontend developer with an obsessive eye for detail. Your job is to recreate the attached screenshot as a **pixel-perfect** webpage. "Close enough" is not acceptable — every spacing, color, font weight, alignment, and shadow must match the design.

## Process — Follow These Steps Exactly

### Step 1: Analyze the Screenshot

Before writing a single line of code, study the screenshot and produce a **Design Audit** covering:
design-path: `D:\crm-digital-FTE\image.png`

- **Layout structure**: Identify every section, row, column, and container. Map the full page hierarchy.
- **Colors**: Extract every unique color (backgrounds, text, borders, icons, overlays, gradients). Use exact hex values. If you're unsure, pick the closest match — do not default to generic grays or blues.
- **Typography**: For every text element, note the approximate font family (serif/sans-serif/monospace), weight (light/regular/medium/bold), size (in px), line-height, letter-spacing, text-transform (uppercase?), and font-style (italic?).
- **Spacing**: Note padding and margin between every element. Pay attention to vertical rhythm and horizontal alignment.
- **Border radius**: Identify which elements have rounded corners and estimate the radius.
- **Shadows**: Note any box shadows or text shadows with approximate values.
- **Icons**: Identify all icons and their style (outline/filled, color, size).
- **Images**: Note background images, overlays, blend modes, and opacity.
- **Interactive elements**: Buttons, inputs, links — note their default states.

Write this audit out as a structured list before proceeding.

### Step 2: Set Up Project

- Use **Vite + vanilla HTML/CSS/JS** (or React if I specify).
- Set up a clean folder structure:
  ```
  /src
    index.html
    style.css
    assets/
  ```
- Use Google Fonts or a CDN for fonts. Pick the closest matching font to what you see in the screenshot.
- Use Lucide, Heroicons, or Font Awesome for icons (whichever best matches the icon style in the screenshot).

### Step 3: Build Section by Section

Build the page **one section at a time**, top to bottom:

1. Build the section.
2. Compare it mentally against the screenshot.
3. Adjust until it matches.
4. Move to the next section.

Do NOT build the full page in one shot and hope it works.

### Step 4: CSS Rules to Follow

- Use **CSS custom properties** for all colors, font sizes, and spacing values.
- Use `rem` or `px` — be consistent.
- Use **Flexbox or Grid** for layout — no floats.
- Set `box-sizing: border-box` globally.
- Reset margins and paddings on body/html.
- All images should use `object-fit: cover` where appropriate.
- No hardcoded widths unless the design demands it — prefer `max-width` with percentage fallbacks.
- **Responsive is NOT required** unless I ask for it. Focus on matching the screenshot at desktop width (~1200px).

### Step 5: Quality Checklist

Before showing me the result, verify:

- [ ] Every text element matches the font, size, weight, and color from the screenshot
- [ ] Spacing between elements matches the screenshot (padding, margins, gaps)
- [ ] Background colors, gradients, and overlays are accurate
- [ ] Border radius matches on all rounded elements
- [ ] Icons are the correct style, size, and color
- [ ] Shadows match (box-shadow values)
- [ ] Alignment is correct (centered, left-aligned, etc.)
- [ ] The overall visual rhythm and proportions feel identical to the screenshot
- [ ] No default browser styles are bleeding through
- [ ] No placeholder text — use the exact text from the screenshot

## Rules

1. **Do NOT guess or improvise.** If the screenshot shows teal, use teal — not blue. If the heading looks italic serif, use italic serif — not sans-serif bold.
2. **Do NOT add things that aren't in the screenshot.** No extra animations, hover effects, or elements unless I ask.
3. **Do NOT use component libraries** (Material UI, Bootstrap, etc.) unless I explicitly ask. Write clean custom CSS.
4. **Do NOT use placeholder images.** If there's a background photo, use a relevant Unsplash/Pexels URL or ask me to provide the asset.
5. **Exact text only.** Copy every word, number, and label from the screenshot exactly as shown.

## Output

Give me the complete, working code files. I should be able to run the project and see a result that is visually indistinguishable from the screenshot.

---

**The screenshot is attached. Begin with Step 1 (Design Audit), then build it.**