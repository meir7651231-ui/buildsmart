# INSP-0034 — Menu FAB tab רכש → Dial (2 levels)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Last unwired menu FAB tab — `רכש` previously just called `closeMenu()`.
Now drills into a 2-level dial.

## Level 1 — 2 items (from `vs-btn` switch @ index.html:5061-5062 / 5103-5104)
| emoji | title | type |
|---|---|---|
| 🛒 | הסל שלי | leaf |
| 📦 | ההזמנות שלי | branch |

## Level 2 (under ההזמנות שלי) — 6 leaves
From `ca-svc-row` buttons in view-orders @ index.html:5074-5083 (each
button has `<span class="ca-svc-ic">EMOJI</span><span>LABEL</span>` —
strictest verbatim):
| emoji | title |
|---|---|
| 🔧 | השכרת כלים |
| 💰 | פקדונות |
| ↩️ | החזרה חדשה |
| 📨 | מכרז ספקים |
| 🧪 | גיליונות בטיחות |
| 📊 | השוואת מחירים |

## Changes
- **`submenu-settings.tsx`** — added `CartItem` type (with optional
  `children`), `CART_TOP` array, `cartDrillPath` signal, `walkCart()`
  helper, and `CartSubmenu` component. Tap on branch pushes drill
  path; tap on leaf shows toast.
- **`menu-speed-dial.tsx`** — `TAB_HAS_SUBMENU.cart = true`; render
  `<CartSubmenu />` when `active === 'cart'`.

## Limitation (documented)
`cartDrillPath` is a local signal in `submenu-settings.tsx`, not in
`app-store.ts`. Drill state persists across menu open/close until the
user explicitly navigates back. Acceptable for current scope; can be
moved to `app-store.ts` later if reset-on-close is needed.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- R1 PASS · R2 PASS · R3 PASS · R4 PASS · R6/R8 PASS · R7 PASS.

## Stuck-loop Scan
No recurring finding IDs from INSP-0022..0033.

## Menu FAB tabs — all 5 wired
| Tab | Submenu |
|---|---|
| בית | — (persona default surface) |
| קטלוג | ✅ 11 categories (INSP-0033) |
| הפרויקטים | ✅ 3 projects |
| **רכש** | ✅ 2 items + 6 sub-services (INSP-0034) |
| הגדרות | ✅ profile tree |
