# WasteHero Design System Tokens

Source of truth for all design tokens. Synced from Figma file `WasteHero Design System` (file key `SoMkCuI8zdqg7bo9hzeYmp`).

---

## 1. Colors

Synced from Figma nodes `244:14270` (light) and `244:14277` (dark). Figma token paths use slash syntax (`bg/default`); this doc uses the CSS-friendly equivalent (`--bg-default`).

### Brand

| Token | Light | Dark | Source | Use |
|---|---|---|---|---|
| `--brand-navy` | `#1B2344` | `#1B2344` | ws-navy-1000 | Primary brand dark |
| `--brand-sky` | `#75BDEA` | `#75BDEA` | ws-sky-1000 | Primary brand accent |

### Semantic Tokens

#### Backgrounds

| Token | Light | Dark | Source (Light / Dark) | Use |
|---|---|---|---|---|
| `--bg-default` | `#FFFFFF` | `#1B2344` | neutral-0 / ws-navy-1000 | Default page/surface background |
| `--bg-hover` | `#F4F4F6` | `#323957` | ws-navy-50 / ws-navy-900 | Hover state |
| `--bg-active` | `#F1F8FD` | `#323957` | ws-sky-100 / ws-navy-900 | Active/selected |
| `--bg-muted` | `#D1D3DA` | `#494F69` | ws-navy-200 / ws-navy-800 | Muted/disabled backgrounds |

#### Text

| Token | Light | Dark | Source (Light / Dark) | Use |
|---|---|---|---|---|
| `--text-primary` | `#1B2344` | `#FFFFFF` | ws-navy-1000 / neutral-0 | Primary text, headings |
| `--text-secondary` | `#5F657C` | `#BBBDC7` | ws-navy-700 / ws-navy-300 | Secondary text, captions |
| `--text-muted` | `#8D91A1` | `#8D91A1` | ws-navy-500 / ws-navy-500 | Disabled, placeholder text |
| `--text-inverse` | `#FFFFFF` | `#1B2344` | neutral-0 / ws-navy-1000 | Text on inverse-colored surfaces |
| `--text-link` | `#0069A8` | `#75BDEA` | sky-700 / ws-sky-1000 | Hyperlinks |

#### Icons

| Token | Light | Dark | Source (Light / Dark) | Use |
|---|---|---|---|---|
| `--icon-default` | `#8D91A1` | `#8D91A1` | ws-navy-500 / ws-navy-500 | Default icon color |
| `--icon-active` | `#75BDEA` | `#75BDEA` | ws-sky-1000 / ws-sky-1000 | Active/selected icon color |

#### Borders

| Token | Light | Dark | Source (Light / Dark) | Use |
|---|---|---|---|---|
| `--border-default` | `#E8E9EC` | `#323957` | ws-navy-100 / ws-navy-900 | Default borders, dividers |
| `--border-strong` | `#D1D3DA` | `#494F69` | ws-navy-200 / ws-navy-800 | Emphasized borders |
| `--border-focus` | `#75BDEA` | `#75BDEA` | ws-sky-1000 / ws-sky-1000 | Focus ring color |

#### Actions -- _pending in Figma_

Action tokens appear in the Figma color documentation but are **not yet bound to real values** -- all rows reference `ws-navy/200` as a placeholder and are rendered at 50% opacity. Until Figma defines them, use these project-local values:

| Token | Value | Use |
|---|---|---|
| `--action-primary` | `#3B82F6` | Primary buttons, CTAs |
| `--action-primary-hover` | `#2563EB` | Primary button hover |
| `--action-primary-text` | `#FFFFFF` | Text on primary buttons |
| `--action-secondary` | `#F5F5F5` | Secondary button fill |
| `--action-secondary-hover` | `#E5E5E5` | Secondary button hover |
| `--action-secondary-text` | `#171717` | Text on secondary buttons |

#### Status -- _pending in Figma_

Status tokens are placeholder in Figma (same pattern as actions). Project-local values:

| Token | Value | Use |
|---|---|---|
| `--status-success` | `#22C55E` | Success states |
| `--status-success-bg` | `#F0FDF4` | Success background |
| `--status-error` | `#EF4444` | Error states |
| `--status-error-bg` | `#FEF2F2` | Error background |
| `--status-warning` | `#F59E0B` | Warning states |
| `--status-warning-bg` | `#FFFBEB` | Warning background |

### Color Primitives

#### ws-navy

| Token | Hex |
|---|---|
| `--ws-navy-50` | `#F4F4F6` |
| `--ws-navy-100` | `#E8E9EC` |
| `--ws-navy-200` | `#D1D3DA` |
| `--ws-navy-300` | `#BBBDC7` |
| `--ws-navy-400` | `#A4A7B4` |
| `--ws-navy-500` | `#8D91A1` |
| `--ws-navy-600` | `#767B8F` |
| `--ws-navy-700` | `#5F657C` |
| `--ws-navy-800` | `#494F69` |
| `--ws-navy-900` | `#323957` |
| `--ws-navy-1000` | `#1B2344` |

#### ws-sky

| Token | Hex |
|---|---|
| `--ws-sky-50` | `#F8FCFE` |
| `--ws-sky-100` | `#F1F8FD` |
| `--ws-sky-200` | `#E3F2FB` |
| `--ws-sky-300` | `#D6EBF9` |
| `--ws-sky-400` | `#C8E5F7` |
| `--ws-sky-500` | `#BADEF5` |
| `--ws-sky-600` | `#ACD7F2` |
| `--ws-sky-700` | `#9ED1F0` |
| `--ws-sky-800` | `#91CAEE` |
| `--ws-sky-900` | `#83C4EC` |
| `--ws-sky-1000` | `#75BDEA` |

#### blue

| Token | Hex |
|---|---|
| `--blue-50` | `#EFF6FF` |
| `--blue-100` | `#DBEAFE` |
| `--blue-200` | `#BFDBFE` |
| `--blue-300` | `#93C5FD` |
| `--blue-400` | `#60A5FA` |
| `--blue-500` | `#3B82F6` |
| `--blue-600` | `#2563EB` |
| `--blue-700` | `#1D4ED8` |
| `--blue-800` | `#1E40AF` |
| `--blue-900` | `#1E3A8A` |

#### neutral

| Token | Hex |
|---|---|
| `--neutral-0` | `#FFFFFF` |
| `--neutral-50` | `#FAFAFA` |
| `--neutral-100` | `#F5F5F5` |
| `--neutral-200` | `#E5E5E5` |
| `--neutral-300` | `#D4D4D4` |
| `--neutral-400` | `#A3A3A3` |
| `--neutral-500` | `#737373` |
| `--neutral-600` | `#525252` |
| `--neutral-700` | `#404040` |
| `--neutral-800` | `#262626` |
| `--neutral-900` | `#171717` |

#### orange

| Token | Hex |
|---|---|
| `--orange-50` | `#FFF7ED` |
| `--orange-100` | `#FFEDD5` |
| `--orange-200` | `#FED7AA` |
| `--orange-300` | `#FDBA74` |
| `--orange-400` | `#FB923C` |
| `--orange-500` | `#F97316` |
| `--orange-600` | `#EA580C` |
| `--orange-700` | `#C2410C` |
| `--orange-800` | `#9A3412` |
| `--orange-900` | `#7C2D12` |

#### red

| Token | Hex |
|---|---|
| `--red-50` | `#FEF2F2` |
| `--red-100` | `#FEE2E2` |
| `--red-400` | `#F87171` |
| `--red-500` | `#EF4444` |
| `--red-600` | `#DC2626` |
| `--red-800` | `#991B1B` |

#### green

| Token | Hex |
|---|---|
| `--green-50` | `#F0FDF4` |
| `--green-100` | `#DCFCE7` |
| `--green-400` | `#4ADE80` |
| `--green-500` | `#22C55E` |
| `--green-600` | `#16A34A` |
| `--green-800` | `#166534` |

#### amber

| Token | Hex |
|---|---|
| `--amber-50` | `#FFFBEB` |
| `--amber-100` | `#FEF3C7` |
| `--amber-400` | `#FBBF24` |
| `--amber-500` | `#F59E0B` |
| `--amber-600` | `#D97706` |
| `--amber-800` | `#92400E` |

### Dark Mode / Hero Surfaces

- Background: `#1B2344` (ws-navy-1000 / `--brand-navy`) for ALL large background surfaces: heroes, full-bleed sections, footers, nav bars. **Never use pure black `#000000` for large backgrounds.**
- Text on dark: `#FFFFFF` (`--text-primary` in dark mode, or `--text-inverse` in light mode when placed on a dark surface).
- Accent on dark: `#75BDEA` (ws-sky-1000 / `--brand-sky`)

> `--text-inverse` flips with theme: `#FFFFFF` in light mode, `#1B2344` in dark mode. It's the "text color that contrasts with `--bg-default`'s opposite theme." Use `--text-primary` for normal body text in either theme.

---

## 2. Typography

Synced from Figma node `244:14606` (Text styles). Source of truth for all type tokens.

### Typefaces

| Token | Font | Fallback | Use |
|---|---|---|---|
| `fontFamily/brand` | Geist | -apple-system, sans-serif | Headings |
| `fontFamily/body` | Geist | -apple-system, sans-serif | Body copy, labels, inputs, navigation |
| `fontFamily/mono` | Geist Mono | ui-monospace, SFMono-Regular, monospace | Code, technical values |

> **Important:** Load Geist and Geist Mono from `cdn.jsdelivr.net/npm/geist@1.3.1`. Always apply `-webkit-font-smoothing: antialiased` and `-moz-osx-font-smoothing: grayscale`.

### Font Weights

| Token | Value |
|---|---|
| `fontWeight/regular` | 400 |
| `fontWeight/medium` | 500 |
| `fontWeight/semibold` | 600 |

### Type Styles -- Headings

| Token | Family | Weight | Size | Line Height | Letter Spacing |
|---|---|---|---|---|---|
| `heading/display` | brand (Geist) | 400 (Regular) | 96px | 1.2 | -2% |
| `heading/h1` | brand (Geist) | 600 (SemiBold) | 64px | 1.2 | -3% |
| `heading/h2` | brand (Geist) | 500 (Medium) | 48px | 1.2 | -2% |
| `heading/h3` | brand (Geist) | 600 (SemiBold) | 24px | 1.0 | -2% |

### Type Styles -- Body

| Token | Family | Weight | Size | Line Height | Letter Spacing |
|---|---|---|---|---|---|
| `body/lg` | body (Geist) | 400 (Regular) | 20px | 1.5 | 0 |
| `body/base-strong` | body (Geist) | 600 (SemiBold) | 16px | 1.5 | 0 |
| `body/base-medium` | body (Geist) | 500 (Medium) | 16px | 1.5 | 0 |
| `body/base` | body (Geist) | 400 (Regular) | 16px | 1.5 | 0 |
| `body/sm` | body (Geist) | 400 (Regular) | 14px | 1.5 | 0 |
| `body/overline` | body (Geist) | 400 (Regular) | 12px | 1.0 | 1% (uppercase) |
| `body/mono` | mono (Geist Mono) | 400 (Regular) | 12px | 1.0 | 1% |

> Letter spacing values are percentages of font size. In CSS, express as `em` values: -2% → `-0.02em`, 1% → `0.01em`.

### Project Component Type Utilities

These are local CSS conventions used in the dashboard prototype -- **not** Figma variables. Prefer the Figma tokens above for new work. Existing dashboard components may continue using these sizes for density reasons.

| Class | Size | Weight | Use |
|---|---|---|---|
| Button | 14px | 600 | Primary/secondary buttons |
| Button Small | 12px | 600 | Compact buttons |
| Label | 13px | 600 | Form labels |
| Input | 13px | 400 | Input field text |
| Nav | 13px | 500 | Navigation items |
| Badge | 11px | 600 | Badges, pills |

### CSS Quick Reference

```css
body {
  font-family: 'Geist', -apple-system, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* heading/display */
.heading-display {
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 96px;
  font-weight: 400;
  line-height: 1.2;
  letter-spacing: -0.02em;
}

/* heading/h3 */
.heading-h3 {
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 24px;
  font-weight: 600;
  line-height: 1;
  letter-spacing: -0.02em;
}

/* body/overline */
.overline {
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 12px;
  font-weight: 400;
  line-height: 1;
  letter-spacing: 0.01em;
  text-transform: uppercase;
}

/* body/mono */
.mono {
  font-family: 'Geist Mono', ui-monospace, monospace;
  font-size: 12px;
  font-weight: 400;
  line-height: 1;
  letter-spacing: 0.01em;
}
```

---

## 3. Spacing

### Scale

| Token | Value |
|---|---|
| `--space-px` | 1px |
| `--space-0` | 0 |
| `--space-0-5` | 2px |
| `--space-1` | 4px |
| `--space-1-5` | 6px |
| `--space-2` | 8px |
| `--space-3` | 12px |
| `--space-4` | 16px |
| `--space-5` | 20px |
| `--space-6` | 24px |
| `--space-7` | 28px |
| `--space-8` | 32px |
| `--space-10` | 40px |
| `--space-12` | 48px |
| `--space-16` | 64px |
| `--space-20` | 80px |
| `--space-24` | 96px |

### Border Radius

| Token | Value |
|---|---|
| `--radius-xs` | 2px |
| `--radius-sm` | 4px |
| `--radius-md` | 8px |
| `--radius-lg` | 12px |
| `--radius-xl` | 16px |
| `--radius-2xl` | 20px |
| `--radius-full` | 9999px |

---

## 4. Shadows

**Shadows are opt-in, not default.** Only apply a shadow when the Figma node for the specific component shows one. Don't add shadows based on component type alone — a dropdown or card with no elevation in Figma gets no shadow.

When Figma does show elevation, map to the matching token — never invent new values.

| Token | Definition | Use (only when Figma shows elevation) |
|---|---|---|
| `--shadow-xs` | `0 1px 2px rgba(0,0,0,0.04)` | Subtle elevation |
| `--shadow-sm` | `0 2px 8px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)` | Cards, dropdowns |
| `--shadow-md` | `0 8px 24px rgba(0,0,0,0.08), 0 2px 4px rgba(0,0,0,0.04)` | Modals, popovers |
| `--shadow-lg` | `0 16px 40px rgba(0,0,0,0.1), 0 4px 8px rgba(0,0,0,0.04)` | Large overlays |
| `--shadow-xl` | `0 24px 48px -8px rgba(0,0,0,0.12), 0 8px 16px rgba(0,0,0,0.06)` | Hero elements |
| `--shadow-card` | `0 2px 8px rgba(0,0,0,0.04), 0 0 0 1px rgba(0,0,0,0.04)` | Card containers |

### Focus styles

Inputs, textareas, and selects use a **border-only** focus state — swap the border to `--border-focus` (`#75BDEA`). No outer ring, no box-shadow. This keeps focus visually aligned with the sky-blue border tokens used across the form system.

```css
input:focus,
textarea:focus {
  border-color: #75BDEA;
  outline: none;
}
```

---

## 5. Voice & Copy

### Brand Personality

- **Direct** -- Say what you mean. No fluff, no filler. Lead with the value.
- **Sharp** -- Short sentences. Strong verbs. Active voice always.
- **Expert** -- We know waste management. Use the right terminology confidently.
- **Human** -- Warm but never corporate. We're people talking to people.

### Do / Don't

| Do | Don't |
|---|---|
| "See exactly how your waste collection routes perform." | "Leveraging next-generation AI-powered solutions..." |
| "WasteHero tracks every pickup so you can optimize what actually matters." | "Our comprehensive, robust platform enables teams to synergize..." |
| "Your routes are underperforming. Here's why, and how to fix it." | "We are excited to announce our groundbreaking new feature..." |

### Punctuation & Formatting Rules

- **En dash** (--) for ranges and pauses: "10--20 pickups". Never use em dash (--)
- **Sentence case** for headlines: "Smart waste starts here" not "Smart Waste Starts Here"
- **Oxford comma**: "routes, containers, and pickups"
- **Product name always capitalized**: WasteHero
- **CTA copy**: short imperatives -- "Get a demo" / "Start free" / "See it live" / "Book a call"
- **Never**: "Click here to learn more about our platform"
- **Banned words**: synergize, robust, comprehensive, seamless, leverage (as a verb), supercharge, groundbreaking, revolutionary

### Positioning Language

WasteHero owns the **smart waste management** category. Always:
- Lead with outcomes: efficiency, cost savings, sustainability -- not features
- Reference real metrics: collection rates, route optimization, fill levels
- Speak to waste management professionals as peers, not prospects

---

## 6. Components

### Badge / Pill

```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  background: var(--ws-sky-100, #F1F8FD);
  border: 1px solid var(--border-default, #E8E9EC);
  border-radius: var(--radius-sm, 4px);
  /* body/overline */
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 12px;
  font-weight: 400;
  line-height: 1;
  letter-spacing: 0.01em;
  text-transform: uppercase;
  color: var(--text-primary, #1B2344);
}
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
.card {
  background: var(--bg-default, #FFFFFF);
  border: 1px solid var(--border-default, #E8E9EC);
  border-radius: var(--radius-md, 8px);
  padding: 24px;
  /* Apply box-shadow: var(--shadow-card) only if the Figma node shows elevation */
}
```

### Buttons

- **Primary**: `--action-primary` (#3B82F6) bg, white text, `--radius-md` (8px) radius
- **Secondary**: `--action-secondary` (#F5F5F5) bg, `--border-default` border, `--action-secondary-text` (#171717) text
- **Accent**: `--brand-sky` (#75BDEA) bg, white text

```css
.btn-primary {
  background: var(--action-primary, #3B82F6);
  color: var(--action-primary-text, #FFFFFF);
  border: none;
  padding: 12px 24px;
  border-radius: var(--radius-md, 8px);
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 14px;
  font-weight: 600;
  line-height: 1.4;
  cursor: pointer;
}
.btn-primary:hover { background: var(--action-primary-hover, #2563EB); }

.btn-secondary {
  background: var(--action-secondary, #F5F5F5);
  color: var(--action-secondary-text, #171717);
  border: 1px solid var(--border-default, #E8E9EC);
  padding: 12px 24px;
  border-radius: var(--radius-md, 8px);
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 14px;
  font-weight: 600;
  line-height: 1.4;
  cursor: pointer;
}
.btn-secondary:hover { background: var(--action-secondary-hover, #E5E5E5); }
```

---

## 7. Data Visualization

WasteHero data viz has a strict rule set. **Never deviate.**

### Rules

1. **Rounded corners** -- `--radius-sm` (4px) on bars, `--radius-md` (8px) on chart containers
2. **Blue spectrum palette** -- ws-sky and blue scales for fills
3. **Accent highlight** -- `#75BDEA` (brand-sky) for the primary data series or the most important value
4. **Label accent** -- ws-sky-100 (`#F1F8FD`) background with `--text-primary` text for pill callouts
5. **Geist** for chart headlines -- use `heading/h2` (48px, weight 500, letter-spacing -0.02em)
6. **Geist** for all axis labels, value callouts, tick marks, and pill tags -- use `body/overline` (12px, weight 400, letter-spacing 0.01em, uppercase)
7. **White background** (`#FFFFFF`) for chart area
8. **1px `--border-default`** on chart containers
9. **No gradients** in bars or lines -- flat fills only

### Color Ramp (light to dark)

```
#F1F8FD  --  ws-sky-100 (lightest tint / backgrounds)
#E3F2FB  --  ws-sky-200
#C8E5F7  --  ws-sky-400
#75BDEA  --  ws-sky-1000 (accent / highlight series)
#3B82F6  --  blue/500 (action blue)
#2563EB  --  blue/600
#1E40AF  --  blue/800
#1B2344  --  ws-navy-1000 (deepest)
```

### CSS Template

```css
.chart-container {
  background: var(--bg-default, #FFFFFF);
  border: 1px solid var(--border-default, #E8E9EC);
  border-radius: var(--radius-md, 8px);
  padding: 32px;
}
/* heading/h2 */
.chart-headline {
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 48px;
  font-weight: 500;
  line-height: 1.2;
  letter-spacing: -0.02em;
  color: var(--text-primary, #1B2344);
}
/* body/overline */
.chart-axis-label {
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 12px;
  font-weight: 400;
  line-height: 1;
  letter-spacing: 0.01em;
  text-transform: uppercase;
  color: var(--text-secondary, #5F657C);
}
/* body/overline */
.chart-value-pill {
  background: var(--ws-sky-100, #F1F8FD);
  color: var(--text-primary, #1B2344);
  font-family: 'Geist', -apple-system, sans-serif;
  font-size: 12px;
  font-weight: 400;
  line-height: 1;
  letter-spacing: 0.01em;
  text-transform: uppercase;
  padding: 4px 8px;
  border-radius: var(--radius-sm, 4px);
}
```

---

## 8. Logo Usage

- **On white**: Full color WasteHero wordmark (dark)
- **On dark**: White reversed wordmark
- **Minimum clear space**: equal to the height of the "W" in WasteHero on all sides
- **Never**: stretch, rotate, recolor, add effects, or place on busy backgrounds

