# INSP-0016 — Sites/Projects View Wiring (placeholder)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (initial NO-GO CRITICAL → fix → **re-check GO 0/0/0**)

**Process note:** The first markdown GO was issued without re-running
the Inspector subagent after the CRITICAL fix. Re-check performed
afterwards confirms GO; also validates the INSP-0017 addition
(`settings → profile` in VIEW_MAP) does not reintroduce the original
silent-routing CRITICAL — profile is properly handled in app.tsx.

## Scope
Wire the menu `הפרויקטים` tab to a new `SitesView` placeholder that
lists the 3 project names verbatim from the legacy.

- **New** `src/data/projects.ts` — `PROJECTS` array (3 items),
  verbatim from index.html:6447-6451.
- **New** `src/views/sites.tsx` — `<SitesView>` header + list of names.
- **New** signal `currentView` + `setView()` in `app-store.ts`. Type
  `AppView = 'home' | 'catalog' | 'sites' | 'cart'`.
- **New** routing in `app.tsx` — contractor persona switches inner
  view based on `currentView` (home + sites only for now).
- **New** wiring in `menu-speed-dial.tsx` — `הפרויקטים` tap calls
  `setView('sites')` + `closeMenu()`. `home` tab also wired.
- **New** CSS — `.sites__*` classes in `global.css`.

## Findings
| Severity | Count |
|---|---|
| CRITICAL | 0 (was 1, resolved) |
| MAJOR | 0 |
| MINOR | 0 |

## Resolved
**CRITICAL (fixed):** `incomplete-view-routing` — first pass mapped
catalog/cart tabs to `setView('catalog'/'cart')` even though those
views weren't built; the default branch fell back to `<HomeView>` so
the route would silently desync. Fix: `VIEW_MAP` now only includes
`home` and `projects`. Catalog/cart taps still call `closeMenu()` but
do **not** change `currentView` — they stay on whatever view was
active. Inspector re-check passes.

## Rule Checks
- **R1** PASS — no FAB changes.
- **R3** PASS — `SitesView` is a top-level page swap, not a
  drawer/sheet/modal.
- **R6/R8** PASS — `PROJECTS[]` strings are verbatim from
  index.html:6447-6451. Header "הפרויקטים שלי" and sub
  "בבנייה — לעת עתה שמות בלבד מהאב-טיפוס" are dev-authored
  placeholder labels (explicitly scoped — full UI comes in a later cut).

## Playwright Verification
- Tap `פתח תפריט` → `הפרויקטים` → view shows 3 names verbatim,
  header `הפרויקטים שלי`, sub `בבנייה — לעת עתה שמות בלבד מהאב-טיפוס`.
- Re-open menu → tap `בית` → returns to HomeView.

## Regression
`node app/smoke-settings.mjs` → **21/21 PASS** (R7 + all settings
branches still work after the new router).

## Stuck-loop Scan
No recurring finding IDs from INSP-0013, INSP-0014, INSP-0015.
