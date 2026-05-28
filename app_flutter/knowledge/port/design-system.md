# BuildSmart — Visual Design System (port reference)

> **Scope.** This doc captures **how BuildSmart LOOKS** so a Flutter port can match it pixel-for-feel.
> The earlier deep-docs captured *what* exists (functions, data, strings). This one is the **visual layer**:
> tokens (color/type/space/radius/shadow/motion), component-style specs (dial/card/sheet/chip/button/tabbar/appbar),
> the full animation catalog, and RTL/theme/a11y rules.
>
> **Sources read (no edits made):**
> - Prototype `/home/user/buildsmart/index.html` — two `<style>` blocks. Main block = lines **14–4019** (~3,900 CSS rules). Second block lives inside a JS template string for the financial-report sub-document (line 19752). All values below are from the main block unless noted.
> - Preact `/home/user/buildsmart/app/src/styles/tokens.css` (60 lines) + `global.css` (2,126 lines) — the production design tokens + dial styling.
> - Flutter `/home/user/buildsmart/app_flutter/lib/theme/tokens.dart` + `app_theme.dart`, plus `lib/widgets/dial.dart`, `lib/widgets/toast.dart` — for the parity table at the end.
>
> **Key cross-source fact:** the prototype `:root` and the Preact `tokens.css` `:root` are **byte-identical** in their token values (same hex, same shadow). The Preact build is a faithful CSS extraction of the prototype. The Flutter theme **diverges** (orange brand, no dark default) — see the final parity table.

---

## 0. The single most important visual fact

**The prototype's brand color is TEAL `#1f6f6b`, not orange.** Amber `#f2a516` is the *secondary/accent* (badges, "current" states, CTAs-of-attention). The Flutter `tokens.dart` currently hard-codes `brand = 0xFFFF7A18` (orange) and *comments* that it is "ported from --brand" — it is **not**; `--brand` is teal in both prototype and Preact. This is the largest single visual mismatch and is called out again in §10.

Second-most-important fact: the prototype/Preact **default (un-attributed) theme is LIGHT** (`--bg:#f6f6f4`, near-white). There is a full **dark** palette behind `:root[data-theme="dark"]`, and a **high-contrast** palette behind `html[data-contrast="high"]`. The phone *frame* and `body` backdrop in the prototype are dark (it's a device mock), but the *screen* (`.screen`) paints `--bg` = light. Flutter chose light scaffold (`0xFFF5F6FA`) which is the right call for the default look, but its dark theme is a different palette (`0xFF0E1116` vs `#14171a`).

---

## 1. Design tokens — colors

### 1.1 Default (light) palette — `:root`

| Token | Hex | Role | Notes |
|---|---|---|---|
| `--ink` | `#16191d` | primary text, toast bg, "chip.on" bg | near-black, slightly cool |
| `--bg` | `#f6f6f4` | screen background, input fills, inset wells | warm off-white |
| `--card` | `#ffffff` | cards, sheets, dial circles/pills, tabbar | pure white |
| `--brand` | `#1f6f6b` | **primary brand (teal)**, statusbar, appbar, FAB, active states, links, prices | the identity color |
| `--brand-dark` | `#155551` | pressed brand, gradients, `inset 0 -3px 0` button base | |
| `--amber` | `#f2a516` | accent: badges, "current" stage, search FAB, attention CTAs | secondary |
| `--amber-deep` | `#d98a00` | pressed amber, amber text-on-light | |
| `--grey` | `#8b8d8f` | secondary/muted text, placeholders, meta | |
| `--line` | `#e9e6df` | hairline borders, dividers, sheet grip, progress track | warm grey |
| `--danger` | `#d6492f` | destructive actions, bell badge, reset-to-defaults | |
| `--ok` | `#1f8a4c` | success, in-cart check, valid field, free-price | green |
| `--shadow` | `0 14px 34px -20px rgba(22,25,29,.42)` | the canonical card drop-shadow | very soft, large-blur, negative-spread |

**Hard-coded non-token colors that recur** (not in `:root`, used inline throughout):
- `#1a1d22` — dark ink used as **text-on-amber** (badges, amber FAB, amber CTAs). Slightly different from `--ink`.
- `#102b34` / `#14323c` / `#143842` — deep-teal-ink used for **text on glass** (product names, category names, chips over the photo background in the Preact glass theme). Preact-only; the prototype mostly uses `--ink`.
- `#45575e` / `#2a3e46` / `#5a5c5e` — muted slate for sub-labels on glass / pending prices (Preact glass + prototype meta).
- `#9b9da0` — dark-theme grey echoed as a literal in a few spots (timestamps).
- `#1f6feb` (blue) + `#5a7493` (disabled blue) — the **regression "Run tests" button** in the Preact manager view. The only blue in the system; an intentional "this is a dev tool" tint.
- `#0a0d10` / `#0c0d0f` — near-black for the camera/video tile and the device frame.
- Status greens/reds in the regression panel: pass `#1b8a4e`, fail `#c43b3b` (slightly different from `--ok`/`--danger`).

### 1.2 Dark palette — `:root[data-theme="dark"]`

| Token | Light | **Dark** |
|---|---|---|
| `--ink` | `#16191d` | `#f1f2f3` |
| `--bg` | `#f6f6f4` | `#14171a` |
| `--card` | `#ffffff` | `#1e2226` |
| `--brand` | `#1f6f6b` | `#3a9e99` (lighter teal) |
| `--brand-dark` | `#155551` | `#5fc3bd` (note: *lighter* than brand in dark, inverted) |
| `--grey` | `#8b8d8f` | `#9b9da0` |
| `--line` | `#e9e6df` | `#2e3338` |
| `--shadow` | `…rgba(22,25,29,.42)` | `0 14px 34px -20px rgba(0,0,0,.7)` (heavier) |
| `--amber`, `--amber-deep`, `--danger`, `--ok` | *unchanged* | *unchanged* (amber/danger/ok carry over) |

The dark "mdpulse" ring animation uses the dark brand `rgba(58,214,196,…)` (= `#3ad6c4`-ish) — a hint that dark-mode brand pulses are tuned to the lighter teal.

### 1.3 High-contrast palette — `html[data-contrast="high"]`

Overrides tokens: `--ink:#000; --grey:#222; --line:#000; --bg:#fff; --card:#fff; --brand:#005a55; --brand-dark:#003d3a;` plus `body{background:#fff}`, card borders bumped to `border-width:2px`, and `*:focus-visible{outline:3px solid #005a55}`. So high-contrast = pure black/white, darker teal, thicker borders.

---

## 2. Design tokens — typography

### 2.1 Font families
- **Display / headings:** `'Heebo'` (`--font-display: 'Heebo', system-ui, -apple-system, sans-serif`). Used for every title, name, price, button label, badge, chip — anything bold/structural. The prototype writes `font-family:'Heebo'` literally on dozens of selectors.
- **Body:** `'Rubik'` (`--font-body: 'Rubik', system-ui, -apple-system, sans-serif`). The `body` default; used for paragraphs, hints, input text.
- Both are Google web fonts loaded in the page head. Flutter ships **only `Heebo`** as `fontFamily` (no Rubik) — see parity table.

### 2.2 Weight scale (observed)
Heebo is used at **900** (extra-heavy: brand-name, totals, big numbers, sheet titles), **800** (heavy: most titles, buttons, prices, badges), **700** (bold: labels, names, chips, dial labels), **600/500** (Rubik body emphasis / muted). Rubik body default ≈ **400–500**. There is no 100–300 usage.

### 2.3 Size scale (px, observed across components)
The type ramp is dense and component-specific (no shared `--font-size-*` tokens). Representative ladder:

| px | Typical use |
|---|---|
| 8.5–9 | micro hints (`qw-hint`), tab labels (`9px`), tiny metadata |
| 10–10.5 | kind-badges, very small meta, `sresult__kind` |
| 11–11.5 | meta lines, chips-small, hints, `np-time` |
| 12–12.5 | secondary text, sub-labels, most chips, `dial__label` (ssub/bsdial) |
| 13 | body-default-ish, `dial__label` (menu/search), eyebrow, search hint |
| 14 | section titles, search field input, toast, list names, body emphasis |
| 15 | CTAs, login input, primary buttons, stepper qty, sinput field |
| 16 | sheet/empty titles, big buttons, `psheet__cta`, `titleMedium` |
| 17–18 | appbar brand-name (18, weight 900), sheet `h3` (18/900), store-sheet title |
| 20 | product-sheet name, role-drawer title, stepper plus glyph |
| 22 | foot total (22/900), product-sheet emoji buttons |
| 24 | product-sheet price (24/800), statusbar-area icons, bsdial circle emoji |
| 26 | persona-placeholder title |
| 28 | category bubble emoji |
| 30–38 | list thumbs / product image emoji (38) |
| 70 | product-sheet hero emoji |
| 90/96 | splash logo box / persona-placeholder emoji |

### 2.4 Line-height & letter-spacing
- Body/paragraph line-height clusters at **1.45–1.6** (`np-text` 1.45, hints 1.55, taglines 1.6, placeholder hints 1.6).
- Tight display line-height **1.2–1.3** for names/heroes.
- Letter-spacing: brand-name `-0.3px` (prototype) / `-0.5px` logo (Preact), `float--name` `-0.2px`, CTAs `+0.2px`, eyebrow `+0.5px`, `persona-placeholder__soon` `+0.3px`. Generally near-zero, slightly negative on big display, slightly positive on small all-caps-ish labels.

---

## 3. Spacing scale

4-px base unit. Identical in prototype intent, Preact `tokens.css`, and Flutter `BsTokens`.

| Token | Value | Flutter |
|---|---|---|
| `--space-1` | 4px | `BsTokens.space1` |
| `--space-2` | 8px | `space2` |
| `--space-3` | 12px | `space3` |
| `--space-4` | 16px | `space4` |
| `--space-5` | 24px | `space5` |
| `--space-6` | 32px | `space6` |

Component padding mostly composes from these (e.g. content padding `… +78px` top / `space-4` sides / `… +110px` bottom), but **many prototype components use raw odd px** (9, 11, 13, 14, 17, 18, 22, 26) that don't snap to the scale — the prototype was hand-tuned, the token scale was retrofitted. When porting, prefer the token scale; treat odd values as "≈ nearest token" unless a tight layout depends on them.

---

## 4. Border-radius scale

| Token | Value | Used for |
|---|---|---|
| `--radius-sm` | 8px | small inner elements, kind chips, hint boxes |
| `--radius-md` | 14px | cards, buttons, search field, result rows, CTAs |
| `--radius-lg` | 20px | larger panels (regression), toast |
| (pill) | `999px` | all pills/chips/labels/badges, FAB-adjacent, search input bar |
| (circle) | `50%` | FABs, dial circles, category bubbles, avatars, step buttons |

Raw-px radii that recur in the prototype (not tokenized): **9–12px** for icon tiles/logo-marks (`logo-mark` 9, `iconbtn` 11, `np-ic` 9, `search__emoji` 12), **16–18px** for cards/heroes (`cat-bar` 16, `stage-card`/`project-hero` 18), **22–26px** for sheet tops (`sheet__panel` 22, prototype `.sheet` **26 26 0 0**), **24px** for product-sheet hero image & store-search field, **34px** screen corner, **46px** device frame. Flutter tokens expose `radiusPill 999`, `radiusCard 16`, `radiusCircle 24` (FAB inner).

---

## 5. Shadows & elevation

The system favors **soft, large-blur, negatively-spread** shadows (the "−20px / −14px / −8px" spread that pulls the shadow in so only a diffuse halo shows). Catalog:

| Name | Value | Where |
|---|---|---|
| Canonical card (`--shadow`) | `0 14px 34px -20px rgba(22,25,29,.42)` | generic cards |
| FAB (teal) | `0 12px 28px -10px rgba(31,111,107,.6), 0 4px 8px -2px rgba(0,0,0,.18)` | `.fab` |
| FAB (amber search) | `0 12px 28px -10px rgba(242,165,22,.6), …` | `.fab--search` |
| Dial circle | `0 6px 18px -8px rgba(0,0,0,.35)` | `.dial__circle`, `.trail__circle`, `.ssub__icon`, `.bsdial__circle` |
| Dial label pill | `0 4px 12px -6px rgba(0,0,0,.3)` | `.dial__label`, `.trail__label`, `.ssub__label`, `.bsdial__label`, `.dial__input` |
| Category bubble (glass) | `0 6px 18px -8px rgba(22,25,29,.35), inset 0 1px 0 rgba(255,255,255,.6)` | `.cat__bubble` (note inset highlight) |
| Product card (glass) | `0 12px 28px -14px rgba(15,35,45,.45), inset 0 1px 0 rgba(255,255,255,.6)` | `.product` |
| Search input bar | `0 14px 34px -16px rgba(15,18,21,.55), 0 4px 10px -2px rgba(15,18,21,.22)` | `.sinput` |
| Notif panel / sheet | `0 16px 40px -12px rgba(0,0,0,.4)` | `.notif-panel` |
| Splash logo | `0 20px 50px -16px rgba(0,0,0,.5)` | `.splash-logo` |
| Drawer | `-12px 0 40px -12px rgba(0,0,0,.4)` | `.role-drawer` (side, RTL: shadow on inline-end) |
| Button **inset base** | `inset 0 -3px 0 var(--brand-dark)` (teal) / `inset 0 -3px 0 var(--amber-deep)` (amber) | `.btn-primary`/`.btn-amber` — the "physical key" look; pressing removes it + `translateY(2px)` |

Flutter flattens these to two `BoxShadow`s: `circleShadow` (`Color(0x59000000)`, blur 18, offset 0,6, spread −8 → matches dial circle) and `labelShadow` (`0x4D000000`, blur 12, offset 0,4, spread −6 → matches dial label). The FAB-colored glows and the inset-key button shadow are **not** ported.

---

## 6. Motion — full animation catalog

### 6.1 Easing & duration conventions
- **Standard transition:** `transform .12s–.2s ease` for press/scale feedback; `.18s ease` for color/background on dials.
- **Press feedback:** active state = `transform: scale(0.92–0.98)` (circles/cards), or `translateY(2px)` (buttons), reverting on release. Floating header `.float:active{scale(.94)}`.
- **Signature spring (dial):** `cubic-bezier(0.2, 0.9, 0.3, 1.2)` — the slight overshoot (1.2 > 1) that gives dial items their "pop". Used by `dial-in`, `bsdial-in`, `trail__btn`, `ssub__row`. Flutter mirrors this as `BsTokens.dialCurve = Cubic(0.2, 0.9, 0.3, 1.2)`.
- **Sheet spring:** `cubic-bezier(.2,.8,.2,1)` (smoother, no overshoot) for the full `rise` sheet.
- **Reduce-motion:** `:root[data-reduce-motion="1"] *{animation:none!important;transition:none!important}` (prototype) and a softer Preact variant that collapses durations to `0.001ms` (`:root[data-reduce-motion='true']`). Also a text-size `zoom` hook in Preact (`data-text-size=small→0.92`, `large→1.1`).

### 6.2 @keyframes (prototype + Preact), exhaustive

| Keyframe | Duration / easing | From → To | Used by |
|---|---|---|---|
| **`dial-in`** (Preact) | `.28s cubic-bezier(.2,.9,.3,1.2) backwards` | `opacity:0; translateY(16px) scale(.7)` → `opacity:1; translateY(0) scale(1)` | `.dial__item`, `.trail__btn` |
| `dial-in` @ `.24s` (Preact) | `.24s` same curve | (same) | `.ssub__row` (sub-rows slightly faster) |
| **`bsdial-in`** (Preact) | `.26s cubic-bezier(.2,.9,.3,1.2) backwards` | `opacity:0; translateY(-8px)` → `opacity:1; translateY(0)` | `.bsdial__item` (drops **down** from the top-left logo, hence negative Y) |
| **`sheet-in`** (Preact) | `.22s ease-out` | `translateY(8%) opacity:.6` → `translateY(0) opacity:1` | `.sheet__panel` |
| **`fade-in`** (Preact) | `.2s ease-out` | `opacity:0 → 1` | `.dial__backdrop` |
| **`toast-in`** (Preact) | `.22s ease` | `opacity:0 translateX(-50%) translateY(6px)` → `…translateY(0)` | `.toast` |
| **`fade`** (proto) | `.25s ease` | `opacity:0 translateY(8px)` → `1 / 0` | `.overlay` |
| **`rise`** (proto) | `.34s cubic-bezier(.2,.8,.2,1)` | `translateY(100%)` → `translateY(0)` | `.sheet` (full bottom-sheet) |
| **`detailIn`** (proto) | — | `opacity:0 → 1` | detail panels |
| **`splashIn`** (proto) | `.6s ease` | `opacity:0 translateY(12px)` → `1 / 0` | splash screen |
| **`ux-fade`** (proto) | `.26s ease` | `opacity:.4 translateY(8px)` → `1 / 0` | `.ux-trans` page transitions |
| **`ux-shimmer`** (proto) | `1.3s infinite` | `background-position:200% → -200%` | skeleton loaders (gradient `--bg/--line/--bg`) |
| **`burstIn`** (proto) | staggered `.05s` steps | `opacity:0 scale(.5) translateY(6px)` → `1 / scale(1) / 0` | burst chips (nth-child delays .05→.2s) |
| **`bellring`** (proto) | `.8s ease` | rotate 0→16→-13→9→-6→3→0deg | notification bell on new alert |
| **`dayFlash`** (proto) | `1.6s ease` | box-shadow ring amber `0→3px→0` at 30/70% | stage-card "today" flash |
| **`pulse`** (proto) | `1.8s infinite` | box-shadow ring teal `0→9px→0` (`rgba(31,111,107,.5)→0`) | `.pulse` live-dot (eyebrow) |
| **`mdpulse`** (proto) | `1.8s infinite` | box-shadow ring **dark-teal** `rgba(58,214,196,.55)→0` 0→7px | dashboard live indicator |
| **`splitPulse`** (proto) | `1.8s ease-in-out infinite` | box-shadow ring **amber** `rgba(242,165,22,.45)→0` 0→6px | split-shipment "fresh" pill |
| **`laser`** (proto) | `2.2s ease-in-out` | `top:0 → 100% → 0` | barcode scanner laser line |
| **`pop`** (proto) | `.4s cubic-bezier(.2,1.4,.4,1) forwards` | `scale(0)` → `scale(1)` (with `translate(50%,-50%)`) | scanner detect-dot (strong overshoot 1.4) |
| **`spin`** (proto) | `.7s linear infinite` | `rotate(360deg)` | loading spinners |

Non-keyframe transitions worth porting: notif-panel `max-height .25s + opacity .2s` (accordion reveal), role-drawer `transform .26s ease` (slide-in), progress bars `width .2s–.7s ease`, search-stage `transform .26s ease`.

---

## 7. Component-style specs

### 7.1 Status bar + app bar (prototype chrome)
- **Statusbar:** `height:42px`, `background:var(--brand)` (teal), text `#fff` 13px/600, dots = 4×4px white circles. This is the faux-iOS status row inside the device mock.
- **App bar:** `background:var(--brand)`, padding `4px 18px 16px`, white text. Brand block: 32×32 white `logo-mark` (radius 9) holding an 18×18 teal SVG, + `brand-name` Heebo **900** 18px (the "Smart" portion colored amber via `span{color:var(--amber)}`). Right side: 37×37 `iconbtn` tiles at `rgba(255,255,255,.14)` radius 11, badges (`cart-count` amber `#1a1d22` text, `bell-badge` red `#fff`) positioned `top:-5px left:-5px` with a 2px `--brand` border ring.
- **Preact reimagining (production):** there is **no solid app bar**. Instead a **floating header over a photo background** (`.screen__bg` = `/bathroom.jpg` with a top-light/bottom-dark gradient overlay). Three floats: `.float--logo` (46px teal circle, Heebo 900), `.float--name` (centered white pill, `rgba` brand), `.float--cart` (46px **glass** circle: `rgba(255,255,255,.38)` + `backdrop-filter: blur(14px) saturate(1.15)` + `1px rgba(255,255,255,.55)` border, `#143842` icon). Floats sit at `top: env(safe-area-inset-top)+12px`, `z-index:65`.

### 7.2 Tab bar (prototype bottom nav)
`background:var(--card)`, `border-top:1px solid var(--line)`, `padding:9px 2px 22px` (the 22px bottom = home-indicator inset). Each `.tab` is `flex:1`, column, gap 3, color `--grey`; icon 20×20; label `9px/600`. Active `.tab.on{color:var(--brand)}`. Badge `.tdot` = amber pill (`min-width:15px`, radius 9, `#1a1d22` text) offset top-right (`top:-3px; left:50%; translateX(7px)`).
**Note:** the *new* app (Preact + Flutter) abolishes the tab bar under **R1/R2** — navigation is via 5 FABs + dials. The tabbar spec is reference for the legacy look only.

### 7.3 Cards (two idioms)
1. **Solid card (prototype / opaque surfaces):** `background:var(--card)`, `border:1px solid var(--line)`, `border-radius:14–18px`, `box-shadow:var(--shadow)`. Examples: `stage-card`, `plist`, `md-line`, `cat-bar`, `reg__card`. Locked/disabled → `opacity:.62`.
2. **Glass card (Preact over the photo bg):** `background:rgba(255,255,255,.30–.42)`, `backdrop-filter: blur(14–18px) saturate(1.15–1.2)`, `border:1px solid rgba(255,255,255,.55)`, `box-shadow: …rgba(15,35,45,.45) + inset 0 1px 0 rgba(255,255,255,.6)` (the inset top highlight is what sells the "frosted glass" look). Examples: `.product`, `.mgr__head`, `.reg`, `.sresult`. **Text on glass is deep-teal `#102b34`/`#14323c` with a white text-shadow** for legibility. Selected/in-cart glass card gets a green ring: `box-shadow: 0 0 0 1px rgba(31,138,76,.85), …`.

### 7.4 Dial (the core BuildSmart primitive — R4)
**Law:** every dial row is **two separate elements** — a **circle** + a **label pill** — never one merged chip. Gap between them = **8px** (`--space-2`) in the menu dial, **10px** in the BS/search sub-rows. Rows stack `flex-direction: column-reverse` so they **rise from the FAB**, gap `12px` (`--space-3`) between rows.

| Part | Spec |
|---|---|
| `.dial__circle` | 48×48, `border-radius:50%`, `background:var(--card)`, `color:var(--brand)`, `box-shadow: 0 6px 18px -8px rgba(0,0,0,.35)`, centered icon |
| icon inside | SVG **22×22** (`.dial__circle svg`); sub-rows shrink circle to **42×42** + icon **19×19** (`.dial__item--sub`) |
| emoji inside | `.dial__circle-emoji{font-size:20px; line-height:1}` |
| `.dial__label` | `background:var(--card)`, `color:var(--ink)`, `padding:6px 12px`, `border-radius:999px`, Heebo **700** **13px**, `box-shadow: 0 4px 12px -6px rgba(0,0,0,.3)`, `white-space:nowrap` |
| press | `.dial__btn:active .dial__circle{transform:scale(.92)}` |
| **active / breadcrumb anchor** | BOTH circle **and** label go brand: `.dial__circle--active`/`.dial__label--active` → `background:var(--brand); color:#fff` |
| **leaf "on" (toggle/selection)** | ONLY the circle tints: `.dial__circle--on{background:var(--brand); color:#fff}`; label stays white — this is the visual cue distinguishing a *selected leaf* from a *breadcrumb anchor* |
| **danger row** | tint only (no fill): `.dial__item--danger .dial__circle{color:var(--danger)}` + label text danger |
| **inline edit (R9)** | `.dial__input` replaces the label pill: same pill shape/padding/font/shadow, plus `border:2px solid var(--brand)`, `width:180px`, placeholder `rgba(0,0,0,.35)` |
| animation | `dial-in .28s cubic-bezier(.2,.9,.3,1.2) backwards`, staggered |

Search rail (`.trail__*`) and BS dial (`.bsdial__*`) are the **same recipe** with cosmetic deltas: search-rail circles `transition: background/color .18s` and tint active to brand; BS-dial circles default to `font-size:24px` emoji (personas), active circle gets a **teal glow** `0 6px 22px -6px rgba(31,111,107,.7)` and brand fill, label brand-fills when `.is-active`. Sub-rows (`.ssub__*`) label is **12px** with `padding:6px 13px`, full row tints on `.is-on`.

### 7.5 Backdrop / scrim (R2 budget: opacity ≤ 0.45, blur ≤ 3px)
Multiple scrims exist; all sit **under** the dial/sheet and animate in via `fade`/`fade-in`:

| Selector | Color | Blur | Notes |
|---|---|---|---|
| `.dial__backdrop` (Preact menu) | `rgba(15,18,21,.35)` | `blur(2px)` | the R2-compliant menu scrim |
| `.sheet__backdrop` (Preact) | `rgba(15,18,21,.40)` | `blur(2px)` | product sheet |
| `.spanel__backdrop` (Preact search) | `rgba(15,18,21,.42)` | `blur(2px)` | search panel |
| `.overlay` (prototype legacy) | `rgba(16,18,21,.55)` | `blur(3px)` | **0.55 — exceeds the new R2 budget**; legacy full-sheet only |
| `.role-drawer-scrim` (proto) | `rgba(0,0,0,.45)` | — | legacy drawer |

**Porting rule:** new Flutter scrims must stay ≤ `0.45` opacity and ≤ `3px` blur. The Flutter camera sheet already uses `Colors.black.withValues(alpha: 0.45)` — at the ceiling, compliant.

### 7.6 Sheet (bottom sheet)
- **Preact `.sheet__panel`:** `background:var(--card)`, top corners `22px`, padding `space-2 / space-4 / safe-area+space-5`, `max-height:86dvh`, `animation: sheet-in .22s ease-out`. Handle (`.sheet__handle`): 42×4, radius 2, `background:var(--line)`, centered.
- **Prototype `.sheet`:** `background:var(--bg)`, top corners **26px**, `max-height:90%`, `animation: rise .34s cubic-bezier(.2,.8,.2,1)` from `translateY(100%)`. Grip 42×5, radius 3. Footer (`.sheet-foot`) pinned, `border-top:1px solid var(--line)`, `background:var(--card)`; total row uses Heebo **900** 22px.
- **R2/R3 caveat:** full bottom-sheets are the *legacy/product-detail* pattern. New settings/menu features must be **dials, not sheets**.

### 7.7 Buttons
- **`.btn` base:** `width:100%`, no border, `border-radius:14px`, `padding:15px`, Heebo **800** 15px, centered with 8px gap, 18×18 SVGs.
- **`.btn-primary`:** `background:var(--brand)`, `#fff`, **`box-shadow: inset 0 -3px 0 var(--brand-dark)`** (key-press look); `:active{transform:translateY(2px); box-shadow:none}`.
- **`.btn-amber`:** `background:var(--amber)`, `#1a1d22`, `inset 0 -3px 0 var(--amber-deep)`, same active.
- **`.btn-line`:** outline variant, `:active{background:var(--bg)}`.
- **Stepper add (`.stepper__add`):** teal pill-ish (radius 10), Heebo 800 12px, `:active → --brand-dark`. Step buttons 32×32 circles, plus = brand-filled, `:active{scale(.92)}`.
- **CTA (`.psheet__cta`):** full-width brand, radius 14, Heebo 800 16px, `letter-spacing:.2px`, glow `0 10px 24px -8px rgba(31,111,107,.5)`.

### 7.8 Chips / pills / badges
- **Prototype `.chip`:** `padding:8px 14px`, `border-radius:20px`, 12.5px/600, `border:1px solid var(--line)`, `background:var(--card)`, `color:#5a5c5e`. Active `.chip.on` → **ink-filled** (`background:var(--ink); color:#fff`). (Note: prototype chips fill with *ink*, not brand.)
- **Store chips (Preact):** `padding:7px 14px`, radius 999, `background:var(--card)`, `color:var(--muted)`; active → brand fill, weight 600.
- **Glass chips (`.scope-chip`, `.sresult-chip`):** translucent white + blur, `#102b34` text; active → brand fill + `--brand-dark` border.
- **Badges:** pill (radius 10), amber-on-`#1a1d22` (cart/tab) or brand/danger-on-white; min-width 20, 2px ring matching the surface behind. State pills (`stage-state`, `adm-pill`): tinted bg `rgba(brand/amber/…,.12–.18)` + matching text, radius 6–10, 10–11px/700.
- **Kind chips (search):** 10px/800, `padding:3px 8px`, radius 999, tinted by type — product teal `#1f6f6b`, category `#d98a00`, screen `#45575e`.

### 7.9 Inputs
`border:1.5–2px solid var(--line)`, `border-radius:11–14px`, `padding:12–15px`, Heebo, `background:var(--bg)`, **`text-align:right; direction:rtl`**. Focus: `outline:none; border-color:var(--brand)` (or Preact `box-shadow:0 0 0 1.5px var(--brand)`). Valid state (registration): `border-color:var(--ok)` + a scaling green check (`scale(0)→scale(1)` over `.2s`). Search input bar `.sinput` is a floating white **pill** (radius 999, height 52) beside the FAB.

### 7.10 Toast (R3-safe, non-blocking)
- **Preact `.toast`:** fixed, `bottom: safe-area+96px`, centered (`left:50%; translateX(-50%)`), `background:var(--ink)`, `color:var(--bg)`, `padding:12px 24px`, `border-radius:20px` (`--radius-lg`), 14px/500, `max-width:280px`, `z-index:200`, `animation: toast-in .22s ease`.
- **Prototype `.toast`:** `bottom:96px`, `background:var(--ink)`, `#fff`, radius 12, 12.5px/600, has a 7px amber `.dot`; shows via `.show{opacity:1; translateY(0)}` over `.3s`.

---

## 8. RTL specifics

- The app is **Hebrew-first, RTL**. Inputs explicitly set `direction:rtl; text-align:right`. Lists/rows use `text-align:right`.
- **Logical properties everywhere** in Preact: `inset-inline-start` / `inset-inline-end`, `margin-inline`, `padding-inline` — so the same CSS flips correctly. E.g. FABs: search = `inset-inline-start:18px`, menu = `inset-inline-end:18px` (in RTL the menu FAB ends up bottom-left visually). `.float--logo` `inset-inline-start:14px`, `.float--cart` `inset-inline-end:14px`. Product check badge, float badge → `inset-inline-start`.
- Dial direction: `.dial__btn{flex-direction:row-reverse}` so the **circle hugs the inline-end wall** and the label sits inboard; search-rail uses plain `row` (it lives on the inline-start wall). BS-dial uses `row` from the top-left.
- The legacy prototype uses physical `left`/`right` in places (`.role-drawer{right:0}`, `.notif-panel{left:14px}`, `.login-or::before{right:0}`) — these assume the RTL device frame; when porting, convert to logical/`Directionality`-aware equivalents.
- Flutter: drive everything off `Directionality(textDirection: TextDirection.rtl)` + `EdgeInsetsDirectional`; the dial widget already builds `Row`s start-aligned (`CrossAxisAlignment.start`).

---

## 9. Theming, safe-area, responsive, accessibility

- **Theme switching:** attribute-driven — `:root[data-theme="dark"]`, `html[data-contrast="high"]`, `:root[data-reduce-motion="1"]`, `:root[data-text-size="small|large"]` (Preact). No CSS `prefers-color-scheme`/`prefers-reduced-motion` media queries are relied on; the app sets the attributes itself from its settings store (so theme is a user choice, not OS-driven). The only `@media` rules are `@media print` (delivery-note A4 print sheet) — no responsive breakpoints; the layout is a **fixed 390×800 phone** in the mock and a single mobile column in production.
- **Safe area:** pervasive `env(safe-area-inset-top|bottom)` math. Content top pad = `safe-top + 78px` (clears floats), bottom = `safe-bottom + 110px` (clears FABs). FABs sit at `safe-bottom + 20px`; dials at `safe-bottom + 96px`; toast at `safe-bottom + 96px`. Flutter must wrap in `SafeArea` / read `MediaQuery.padding` and reproduce these offsets.
- **Reduce-motion:** collapses all animation/transition to none (proto) or 0.001ms (Preact). Flutter should gate the dial stagger and sheet slides behind a `reduceMotion` setting.
- **Focus-visible (keyboard a11y):** `button/a/select/input/[tabindex]:focus-visible{outline:2.5px solid var(--brand); outline-offset:2px; border-radius:6px}`; high-contrast bumps to `3px solid #005a55`. (Web concern; Flutter gets focus rings from Material, but custom dial `InkWell`s should expose `Semantics(button:true, label:…)` — the Flutter `DialRow` already does.)
- **Tap target sizing:** circles 48 (dial) / 60 (FAB) / 44 (qty/avatar) / 37 (iconbtn) — mostly ≥ the 44px guideline; the 32px stepper buttons and 9px tab labels are the small exceptions.
- **Tap highlight:** `-webkit-tap-highlight-color:transparent` globally (no blue flash); feedback is the explicit `scale`/`translateY` active states.

---

## 10. → Flutter match status

Comparison of the current Flutter theme (`lib/theme/tokens.dart`, `app_theme.dart`, `widgets/dial.dart`, `widgets/toast.dart`) against the prototype/Preact design system above.

| Dimension | Prototype / Preact (truth) | Flutter today | Match? |
|---|---|---|---|
| **Brand color** | **teal `#1f6f6b`** (`--brand`) | **orange `0xFFFF7A18`** (`BsTokens.brand`), mislabeled "ported from --brand" | ❌ **WRONG** — biggest gap. Flutter FAB/dial-active/prices render orange; should be teal. (`brandDark 0xFFE85F00` should be `#155551`.) |
| Brand-dark | `#155551` (light) / `#5fc3bd` (dark) | `0xFFE85F00` | ❌ orange variant |
| Amber accent | `#f2a516` / `#d98a00` | **absent** from `BsTokens` | ❌ missing — no token for badges/"current"/amber CTAs/search-FAB color |
| Default theme | **light** (`--bg #f6f6f4`, card `#fff`) | light (scaffold `0xFFF5F6FA`, cards white) | ✅ right *choice*; bg hex differs slightly (`#F5F6FA` cool vs `#f6f6f4` warm) |
| Light bg token | `#f6f6f4` | `bgLight 0xFFFAFAFA` (token) **but** scaffold hard-codes `0xFFF5F6FA` | ⚠️ inconsistent + both differ from truth |
| Ink (text) | `#16191d` | `inkLight 0xFF1A1A1A` token; theme uses `Colors.black87` | ⚠️ close, not exact |
| Muted/grey | `#8b8d8f` | `mutedLight 0xFF666666` | ⚠️ darker than truth |
| Line/divider | `#e9e6df` (warm) | not tokenized (uses Material default) | ❌ missing warm hairline |
| Danger / OK | `#d6492f` / `#1f8a4c` | **absent** from tokens | ❌ missing |
| Dark palette | `bg #14171a, card #1e2226, ink #f1f2f3, brand #3a9e99` | `bgDark 0xFF0E1116, cardDark 0xFF181D26, inkDark 0xFFF1F3F8` | ⚠️ **different dark palette** (Flutter darker/cooler; brand still orange) |
| High-contrast | token swap to black/white + teal `#005a55` + 2px borders | `highContrast` flag pushes text pure b/w + darker dividers | ⚠️ partial (no teal swap, no border-width bump) |
| **Spacing scale** | 4/8/12/16/24/32 | `space1..6` identical | ✅ exact |
| **Radius** | sm 8 / md 14 / lg 20 / pill 999 | `radiusPill 999, radiusCard 16, radiusCircle 24` | ⚠️ `radiusCard 16` vs CSS card 14; no sm/lg tokens |
| **Fonts** | Heebo (display) + **Rubik (body)** | `fontFamily:'Heebo'` only | ❌ **Rubik missing** — body text will render Heebo, slightly heavier/different |
| Type ramp | 9→90px component-specific; weights 900/800/700 | `bodyMedium 14, labelLarge 13/w700, titleMedium 16/w700` | ⚠️ only 3 styles defined; covers dial/title but not the full ramp |
| **Dial circle** | 48×48, white, brand icon, shadow `0 6px18px-8px /.35` | `dialCircle 48`, `circleShadow 0x59000000 b18 o(0,6) s-8` | ✅ shape+shadow match; **icon color renders orange** (brand mismatch) |
| Dial label pill | white pill, 6/12 pad, Heebo 700 13, shadow `.../.3` | `radiusPill`, pad `space3/6`, `labelLarge`, `labelShadow` | ✅ matches (modulo brand tint color) |
| Dial sub-row shrink | 42×42 / icon 19 for `--sub` | not implemented (single circle size) | ❌ missing the parent-vs-sub size distinction |
| Dial active vs on | active = circle **+** label brand; on = circle-only brand | `DialRow.active` tints **both** circle+label | ⚠️ only the "active/breadcrumb" case modeled; no circle-only "on" (leaf-selected) variant |
| **Dial-in animation** | `.28s cubic-bezier(.2,.9,.3,1.2)`, translateY(16)+scale(.7)→0, staggered | `dialIn 280ms`, `dialCurve Cubic(.2,.9,.3,1.2)`, slide `Offset(0,.3)→0` + fade, stagger `28ms` | ✅ **close parity** — though Flutter slides only (no `scale(.7)` zoom component) and uses fractional offset vs 16px |
| `bsdial-in` / `sheet-in` / `toast-in` / `fade-in` | distinct keyframes (see §6) | not individually ported | ❌ missing (BS-dial drop-down, sheet rise, toast rise, backdrop fade) |
| Decorative keyframes | bellring, pulse, mdpulse, splitPulse, laser, pop, spin, dayFlash, burstIn, shimmer | none | ❌ none ported (most belong to legacy/persona screens) |
| **Scrim budget (R2)** | ≤ 0.45 opacity, ≤ 3px blur; menu scrim `.35/2px` | camera sheet `black @ .45` (compliant); dial widget has no own scrim | ⚠️ compliant where present; verify each overlay host stays ≤ 0.45 + add blur ≤3px to match the frosted look |
| Glass / backdrop-filter cards | `rgba(255,255,255,.30–.42)` + `blur(14–18) saturate`+ inset highlight | not implemented (solid cards) | ❌ **the entire frosted-glass aesthetic over the photo bg is absent**; Flutter uses opaque Material cards |
| Photo background | `/bathroom.jpg` + gradient overlay behind content | none (flat scaffold) | ❌ missing |
| Button "key" shadow | `inset 0 -3px 0 brand-dark` + `translateY(2px)` press | Material FAB elevation 6; no inset-key buttons | ❌ stylistic miss |
| FAB | 60px circle, teal, colored glow shadow | `FloatingActionButtonThemeData` brand bg (orange), elevation 6 | ⚠️ size via Material default (56), **orange not teal**, no colored glow |
| Toast | ink bg, `--bg` text, radius 20, bottom+96, `.22s` rise | `SnackBar` floating, **`cardDark` bg** (dark grey), white text, pill radius, margin bottom 96 | ⚠️ position/shape close; **bg is dark-card not `--ink`**, text color hard-white not `--bg` |
| RTL | logical props throughout, rtl inputs | `DialRow` start-aligned; app-level Directionality assumed | ⚠️ verify global `Directionality.rtl` + `EdgeInsetsDirectional` everywhere |
| Safe-area offsets | content +78/+110, FAB +20, dial/toast +96 | relies on `SafeArea`/Material defaults | ⚠️ confirm the exact +offsets are reproduced |

### Summary of the gaps that most affect "the look"
1. **Brand is the wrong hue** (orange vs teal) — fix `BsTokens.brand → 0xFF1F6F6B`, `brandDark → 0xFF155551`; everything downstream (FAB, dial-active, prices, focus ring, statusbar/appbar if added) then reads correctly.
2. **Add the missing semantic tokens:** `amber 0xFFF2A516`, `amberDeep 0xFFD98A00`, `line 0xFFE9E6DF`, `danger 0xFFD6492F`, `ok 0xFF1F8A4C`, and align `ink/bg/grey/card` to the exact hex.
3. **Ship Rubik** for body text (keep Heebo for display) to match the dual-font system.
4. **Decide on the glass aesthetic:** the production Preact look is *frosted glass over a bathroom photo*. Flutter currently renders flat opaque cards. Matching the look requires a background image + `BackdropFilter(blur)` translucent cards + the inset top-highlight + deep-teal-on-glass text. This is the single biggest *visual* (not token) gap.
5. **Animation parity:** dial-in is close; add the `scale` component to fully match, and port `bsdial-in` (drop-down), `sheet-in`, `toast-in`, and the backdrop `fade-in`. Keep them all behind the reduce-motion flag.
6. **Dial states:** add the *circle-only "on"* variant (selected leaf) distinct from the *circle+label "active"* (breadcrumb anchor), and the sub-row 42px shrink, to preserve the legibility cues from §7.4.
7. **Toast color:** use ink bg + light text (not `cardDark`) for an exact match.

*(Decorative legacy keyframes — bellring, laser, pop, pulse/mdpulse/splitPulse, shimmer, dayFlash, burstIn — belong to prototype persona/dashboard screens that are placeholder-only under R2; port them lazily, per-screen, if/when those screens are built.)*
