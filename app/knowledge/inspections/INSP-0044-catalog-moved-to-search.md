# INSP-0044 — Catalog Moved From Menu FAB → Search FAB

**Date:** 2026-05-23
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0 / 1 / 0)

## User request (verbatim)
> תחליף את הכפתור התפריט קטלוג תוסיף בתפריט של החיפוש ולא של התפריט

## Scope
Restructural — relocate the קטלוג entry. The 11-leaf catalog dial that
lived under the menu FAB's `catalog` tab is now a 5th tool inside the
search FAB rail, alongside `voice · barcode · filters · sort`.

The menu FAB drops from 5 tabs → 4 tabs.
The search FAB grows from 4 tools → 5 tools.

No legacy Hebrew labels changed — all 11 category strings are still
verbatim from `index.html:6046-6056`.

## File-level changes
| File | Change |
|---|---|
| `src/components/search/submenu-catalog.tsx` | **NEW** — `CatalogSubmenu()` rendering 11 `.ssub__row` buttons (was `.dial__item`). |
| `src/store/search-store.ts:16` | `ToolKind` gained `'catalog'` (5 members). |
| `src/components/search/tools-dial.tsx` | Added 5th tool `{id:'catalog', label:'קטלוג', icon: 2×2-grid SVG}`. |
| `src/components/search/search-panel.tsx` | Imports `CatalogSubmenu`, renders `{tool === 'catalog' && <CatalogSubmenu />}`. |
| `src/store/app-store.ts:83` | `MenuTab` narrowed: `'home' \| 'catalog' \| 'projects' \| 'cart' \| 'settings'` → `'home' \| 'projects' \| 'cart' \| 'settings'`. |
| `src/components/menu-speed-dial.tsx` | Removed `catalog` from `TABS`, `TAB_HAS_SUBMENU`, render switch + import. |
| `src/components/menu/submenu-settings.tsx` | Deleted dial-shaped `CatalogSubmenu` + `CATALOG_CATS` (49 → ~2 lines, redirect comment to new file). |
| `src/styles/global.css` | Added `.ssub__emoji` (font-size 20px, grid centered) — emoji rendering inside `.ssub__icon`. |
| `CLAUDE.md` | Documentation drift fix: "Menu FAB — 5 tabs" → "4 tabs", added "Search FAB — 5 כלים" line. |

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 1 — `CLAUDE.md` stale ("Menu FAB — 5 tabs"). **Fixed in this commit.** |
| MINOR | 0 |

## R-rule compliance
| Rule | Verdict |
|---|---|
| **R1** (5 FABs exactly) | ✅ unchanged — BS / search / BS-mode / menu / BS still 5 |
| **R2** (אין חלון) | ✅ catalog still a dial level — now lives inside `.spanel__rail` instead of `<ul class="dial">` |
| **R3** (settings = dial only) | ✅ not relevant — catalog isn't a setting |
| **R4** (circle + label) | ✅ `.ssub__row` already has separated `.ssub__icon` + `.ssub__label` |
| **R6/R8** (verbatim, no invention) | ✅ all 11 labels match `index.html:6046-6056` byte-for-byte |
| **R7** (regression) | ✅ `src/test/tests/tabs.tsx` still compiles + passes (tests views, not menu wiring) |
| **R9** (inline input) | ✅ not relevant — catalog has no editable leaves |

## Pre-flight
- `npx tsc -b --noEmit` → clean
- `npm run build` → built (`dist/assets/index-*.js` 219 KB)
- `node app/smoke-settings.mjs` → **21 / 21 PASS**

## Stuck-loop scan
No recurring finding IDs from INSP-0032..0043.
