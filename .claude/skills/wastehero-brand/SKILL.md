---
name: wastehero-brand
description: Apply WasteHero brand guidelines to any output -- HTML/CSS components, copy, data visualizations, presentations, or documents. Use whenever the task requires on-brand visual design, writing in WasteHero voice, or producing content that represents the WasteHero brand. Make sure to use this skill whenever building, editing, or reviewing any UI component, page, CSS, or JSX in this project -- even for small tweaks like changing a color or adding a button. Also use when writing any user-facing copy, dashboard text, or data visualization. If the task touches anything visual or textual in the WasteHero app, this skill applies.
---

# WasteHero Brand System Skill

You are building UI for a React + Vite prototype dashboard. All styles live in a single `src/styles.css` file (no CSS modules, no CSS-in-JS, no Tailwind). Components are plain `.jsx` files using `lucide-react` for icons.

## The Golden Rule

**Every color, font size, spacing value, radius, and shadow you write must come from the design system.** Before writing any CSS value, check `.claude/skills/wastehero-brand/wastehero-design-system.md`. That file is the single source of truth -- it defines every token you're allowed to use.

Read `.claude/skills/wastehero-brand/wastehero-design-system.md` at the start of every task that involves styling or UI work. Don't rely on memory -- the tokens are precise and mixing up `#494F69` with `#494E69` breaks the brand.

## Dark Mode is Not Optional

Every piece of CSS you write must work in both light and dark mode. The app toggles dark mode by adding a `.dark` class to `<body>`. Your CSS pattern is:

```css
.my-component {
  background: #FFFFFF;        /* light mode value */
  color: #1B2344;             /* light mode value */
}
body.dark .my-component {
  background: #1B2344;        /* dark mode value */
  color: #FFFFFF;             /* dark mode value */
}
```

The design system doc has a "Light / Dark" column for every semantic token. Use both values. If you add a light-mode style and forget the `body.dark` override, you've introduced a bug.

### Dark mode surface rule

Large backgrounds (page, sidebar, header, hero sections, modals) use `#1B2344` (ws-navy-1000) in dark mode. **Never use pure black `#000000`.**

## Colors

Use semantic tokens, not primitives, for UI work. The key mappings:

| Purpose | Light | Dark |
|---|---|---|
| Page background (`--bg-default`) | `#FFFFFF` | `#1B2344` |
| Hover background (`--bg-hover`) | `#F4F4F6` | `#323957` |
| Active/selected bg (`--bg-active`) | `#F1F8FD` | `#323957` |
| Muted bg (`--bg-muted`) | `#D1D3DA` | `#494F69` |
| Primary text (`--text-primary`) | `#1B2344` | `#FFFFFF` |
| Secondary text (`--text-secondary`) | `#5F657C` | `#BBBDC7` |
| Muted/placeholder (`--text-muted`) | `#8D91A1` | `#8D91A1` |
| Inverse text (`--text-inverse`) | `#FFFFFF` | `#1B2344` |
| Link (`--text-link`) | `#0069A8` | `#75BDEA` |
| Default border (`--border-default`) | `#E8E9EC` | `#323957` |
| Strong border (`--border-strong`) | `#D1D3DA` | `#494F69` |
| Focus ring (`--border-focus`) | `#75BDEA` | `#75BDEA` |
| Default icon (`--icon-default`) | `#8D91A1` | `#8D91A1` |
| Active icon (`--icon-active`) | `#75BDEA` | `#75BDEA` |
| Brand accent (`--brand-sky`) | `#75BDEA` | `#75BDEA` |
| Primary action (pending in Figma) | `#3B82F6` | `#3B82F6` |

For the full set including status colors, actions, and primitives, see the design system doc.

## Typography

**Two fonts: Geist (body + headings) and Geist Mono (code/technical).** Loaded from CDN in `index.html`. Always declare the full stack:

```css
font-family: 'Geist', -apple-system, sans-serif;
font-family: 'Geist Mono', ui-monospace, monospace;
```

Figma type tokens -- use these for all new work:

| Token | Size | Weight | Line Height | Letter Spacing |
|---|---|---|---|---|
| `heading/display` | 96px | 400 | 1.2 | -0.02em |
| `heading/h1` | 64px | 600 | 1.2 | -0.03em |
| `heading/h2` | 48px | 500 | 1.2 | -0.02em |
| `body/lg` | 20px | 400 | 1.5 | 0 |
| `body/base-strong` | 16px | 600 | 1.5 | 0 |
| `body/base-medium` | 16px | 500 | 1.5 | 0 |
| `body/base` | 16px | 400 | 1.5 | 0 |
| `body/sm` | 14px | 400 | 1.5 | 0 |
| `body/overline` | 12px | 400 | 1.0 | 0.01em (uppercase) |
| `body/mono` | 12px | 400 (Geist Mono) | 1.0 | 0.01em |

**Weights available:** 400 (Regular), 500 (Medium), 600 (SemiBold). Never use 700/800 -- not in the Figma scale.

**Heading mapping for dashboard UI:** Figma has no headings smaller than 48px, so use `heading/h2` for page titles and stat values. Everything else comes from the body scale.

Always include `-webkit-font-smoothing: antialiased` and `-moz-osx-font-smoothing: grayscale` on body (already set in this project, but verify if creating a standalone page).

## Spacing and Radius

Use values from the spacing scale: 2, 4, 6, 8, 12, 16, 20, 24, 28, 32, 40, 48, 64, 80, 96px.

Border radius: 2px (xs), 4px (sm), 8px (md), 12px (lg), 16px (xl), 9999px (full/pill).

Common patterns: cards get 8px radius, buttons get 8px radius, badges get 4px radius, avatars get 9999px.

## Shadows

**Shadows are opt-in, not default.** Only apply a shadow when the Figma spec for the specific component shows one. Never add a shadow just because the component type (card, dropdown, modal) typically has one elsewhere — check the node.

When a Figma node does show a shadow, match the following tokens rather than inventing new values:

| When Figma shows elevation on… | Token |
|---|---|
| Cards | `0 2px 8px rgba(0,0,0,0.04), 0 0 0 1px rgba(0,0,0,0.04)` |
| Dropdowns | `0 2px 8px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)` |
| Modals/popovers | `0 8px 24px rgba(0,0,0,0.08), 0 2px 4px rgba(0,0,0,0.04)` |

### Focus styles

Inputs, textareas, and selects use a **border-only** focus — swap the border to `--border-focus` (`#75BDEA`), no outer ring, no `box-shadow`. This keeps focus visually aligned with the sky-blue border system.

```css
input:focus,
textarea:focus {
  border-color: #75BDEA;
  outline: none;
}
```

## Components

### Buttons

```css
/* Primary: blue bg, white text */
background: #3B82F6; color: #FFFFFF; border: none;
padding: 12px 24px; border-radius: 8px;
font-size: 14px; font-weight: 600;

/* Secondary: light bg, dark text, border */
background: #F5F5F5; color: #171717;
border: 1px solid #E8E9EC;
/* same padding/radius/font as primary */
```

### Cards

**When to use:** Standalone discrete data objects — a notification item, a dashboard metric tile, a summary widget. Max 1 level of nesting.

**When NOT to use — use these instead:**
- Auth pages (`/login`, `/reset`, etc.) → `AuthLayout` wraps the form directly. No card inside it.
- Main app pages → `LayoutWithFiltersV2`, `LayoutWithDividerv3`, or `LayoutWithBreadCrumbV2` from `src/layouts/`. These are the real page containers.
- Sections within a page → `<Divider>` + `<Row>`/`<Col>`. Use `gray100` (`#F5F5F5`) background on filter bars, not a card.
- Full-page forms → form sits directly inside the layout wrapper, no card around it.

If you are building a page and find yourself wrapping the whole thing in a card, stop — use the appropriate layout wrapper instead.

```css
background: #FFFFFF; /* dark: #1B2344 */
border: 1px solid #E8E9EC; /* dark: #323957 */
border-radius: 8px;
padding: 24px;
/* Shadow only if the Figma node shows elevation — see Shadows section */
```

### Badges

Typography from `body/overline` (12px / 400 / 0.01em / uppercase):

```css
background: #F1F8FD; /* ws-sky-100 */
border: 1px solid #E8E9EC;
border-radius: 4px;
padding: 4px 10px;
font-family: 'Geist', -apple-system, sans-serif;
font-size: 12px;
font-weight: 400;
line-height: 1;
letter-spacing: 0.01em;
text-transform: uppercase;
color: #1B2344;
```

## Icons

Use `lucide-react`. Import by name: `import { Bell } from 'lucide-react'`.

**Do not pass inline `color` props to sidebar nav icons** -- their color is controlled by CSS. Default icon color is `#8D91A1`, active is `#75BDEA`. Dark mode uses the same `#8D91A1` default (Figma bound both themes to ws-navy-500).

Static assets (logo, avatar) live in `src/assets/`. Never use Figma CDN URLs for icons -- they expire.

## Data Visualization

Charts use `react-chartjs-2` and `Chart.js`. Config lives in `src/data/chartConfig.js`. Key rules:

- Blue spectrum palette only (ws-sky and blue scales)
- `#75BDEA` for the primary/highlighted data series
- 4px border radius on bars, 8px on chart containers
- Flat fills only -- no gradients
- Geist for all chart text: headlines use `heading/h2` (48px/500/-0.02em), axis labels and value pills use `body/overline` (12px/400/0.01em/uppercase)
- White background for chart area
- Charts remount on dark mode toggle via `key={isDark}`

## Copy and Voice

When writing any user-facing text (headings, labels, empty states, tooltips, error messages):

- **Direct and sharp.** Short sentences. Active voice. Lead with the value.
- **Sentence case** for headlines: "Smart waste starts here" not "Smart Waste Starts Here"
- **Oxford comma**: "routes, containers, and pickups"
- **En dash** (--) for ranges, never em dash
- **Never use**: synergize, robust, comprehensive, seamless, leverage (verb), supercharge, groundbreaking, revolutionary
- **CTA copy**: short imperatives -- "Get a demo", "Start free", "See it live"

## Project Structure Reminders

- All CSS goes in `src/styles.css` -- one file, no modules
- Routes defined in `src/App.jsx`
- Global state (dark mode, sidebar, notifications, search) in `src/context/AppContext.jsx`
- Layout shell is `DashboardLayout.jsx` (Header + Sidebar + Outlet)
- Nav structure is data-driven from `src/data/navigation.js`

## Checklist Before You Finish

After writing any UI code, mentally run through:

1. Did I use only design system colors? (no random hex values)
2. Did I add `body.dark` overrides for every color/background/border?
3. Are font sizes and weights from the type scale?
4. Are spacing values from the spacing scale?
5. Are border radii from the radius scale?
6. If I added a shadow, did the Figma node actually show one? (shadows are opt-in per node, not default)
7. For icons, am I using lucide-react and letting CSS control colors?
8. For copy, is it sentence case, active voice, no banned words?
