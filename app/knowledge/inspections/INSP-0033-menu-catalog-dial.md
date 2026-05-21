# INSP-0033 — Menu FAB Tab "קטלוג" → Dial Submenu

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Wires the קטלוג tab (previously `closeMenu()` only) to a dial with 11 category leaves verbatim from legacy `CATALOG` @ index.html:6047-6057.

## Changes
1. **submenu-settings.tsx** (lines 1076–1122):
   - Added `CatalogCat` type with `id`, `emoji`, `title` fields.
   - Added `CATALOG_CATS` array: 11 entries (ברזים וכיורים / אסלות / ... / אביזרים נלווים).
   - Added `CatalogSubmenu()` component: renders each entry as `<li class="dial__item dial__item--sub">` with circle (emoji) + label, calls `showToast('בבנייה')` on tap.

2. **menu-speed-dial.tsx** (lines 25, 99, 167):
   - Imported `CatalogSubmenu`.
   - Set `TAB_HAS_SUBMENU.catalog = true` (was `false`).
   - Added render: `{active === 'catalog' && <CatalogSubmenu />}`.

## Legacy Verification (R6/R8)
All 11 entries match verbatim — both `cat` (title) and `icon` (emoji):

| Order | Legacy (index.html:6047–6057) | Implementation | Match |
|---|---|---|---|
| 1 | `cat:'ברזים וכיורים',icon:'🚰'` | `emoji:'🚰', title:'ברזים וכיורים'` | ✓ |
| 2 | `cat:'אסלות',icon:'🚽'` | `emoji:'🚽', title:'אסלות'` | ✓ |
| 3 | `cat:'מקלחות ואמבטיות',icon:'🚿'` | `emoji:'🚿', title:'מקלחות ואמבטיות'` | ✓ |
| 4 | `cat:'חימום מים',icon:'♨️'` | `emoji:'♨️', title:'חימום מים'` | ✓ |
| 5 | `cat:'מטבח',icon:'🍽️'` | `emoji:'🍽️', title:'מטבח'` | ✓ |
| 6 | `cat:'ניקוז וצנרת',icon:'🕳️'` | `emoji:'🕳️', title:'ניקוז וצנרת'` | ✓ |
| 7 | `cat:'גופי תברואה',icon:'🚾'` | `emoji:'🚾', title:'גופי תברואה'` | ✓ |
| 8 | `cat:'אביזרי קצה וחיבורים',icon:'🔗'` | `emoji:'🔗', title:'אביזרי קצה וחיבורים'` | ✓ |
| 9 | `cat:'בנייה ומחיצות',icon:'🧱'` | `emoji:'🧱', title:'בנייה ומחיצות'` | ✓ |
| 10 | `cat:'גמר',icon:'🎨'` | `emoji:'🎨', title:'גמר'` | ✓ |
| 11 | `cat:'אביזרים נלווים',icon:'🧰'` | `emoji:'🧰', title:'אביזרים נלווים'` | ✓ |

## Rule Checks

- **R1** PASS: FAB positions untouched (menu FAB unchanged, all 5 TABS slots preserved).
- **R2** PASS: No window; dial renders in existing `<ul class="dial">` slot, reuses existing backdrop.
- **R3** PASS: Dial pattern established; catalog leaf opens submenu with 11 circle+label rows.
- **R4** PASS: Each leaf = circle `<span>` (with nested emoji span) + label `<span>` (title), separate elements with independent styles.
- **R6** PASS: All 11 `{cat, icon}` pairs verbatim from legacy (strictest match).
- **R7** PASS: No invented content; toast action `'בבנייה'` matches ProjectsSubmenu placeholder pattern.
- **R8** PASS: Circle emojis + Hebrew labels rendered correctly RTL.

## Findings (Automated Check)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Stuck-loop Scan
Reviewed last 3 inspections (INSP-0032, INSP-0031, INSP-0030):
- All verdicts: GO (0/0/0 findings each).
- No recurring finding IDs across 21 inspections (INSP-0021–INSP-0032).

✅ **No stuck-loop detected.**

## Pattern Match
`CatalogSubmenu` follows `ProjectsSubmenu` architecture exactly:
- Data array with `id` + display fields.
- Reverse sort for visual top-first reading.
- `<li class="dial__item dial__item--sub">` with animation stagger.
- `<button class="dial__btn">` with `role="menuitem"`.
- Circle + label rendering per R4.
- Placeholder toast on tap (pending full catalog implementation).

---

**קטלוג — Ready to commit.**
