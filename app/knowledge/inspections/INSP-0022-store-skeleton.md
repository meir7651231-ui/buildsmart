# INSP-0022 — Store Persona Skeleton (Phase 0)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
First of three Phase-0 skeletons (Store · Courier · Worker). Replaces
the tiny placeholder StoreView with a structured dashboard skeleton:
header + 4 verbatim section names + "בבנייה" tag per row.

No state, no actions, no localStorage, no internal tab navigation —
pure JSX. Future phases will add data, signals, and interactions.

## Changes
- **`app/src/views/store.tsx`** — full replace (~30 lines). Header
  with 🏪 emoji + "חנות ספק" + sub. Static SECTIONS array with the 4
  legacy tab labels verbatim.
- **`app/src/styles/global.css`** — added shared `.dash__*` block
  (`.dash`, `.dash__head`, `.dash__emoji`, `.dash__title`, `.dash__sub`,
  `.dash__sections`, `.dash__section`, `.dash__section-ic`,
  `.dash__section-t`, `.dash__section-tag`). Will be reused by Courier
  and Worker skeletons in the next two commits.

## Section labels (verbatim @ index.html:4260-4263)
| emoji | title |
|---|---|
| 🏠 | בית |
| 📥 | הזמנות |
| 📦 | מלאי |
| 🧰 | פורטל |

Header text "חנות ספק" — verbatim from role-pick-btn `<b>` at
index.html:4100. Sub text "בבנייה — לעת עתה כותרות sections בלבד"
is a dev-authored placeholder label, scoped to Phase 0.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — FAB positions untouched.
- **R2** PASS — Not a new window. Persona default views are the
  existing pattern (HomeView for contractor, ManagerView for manager).
- **R3** PASS — No dial introduced; flat content view.
- **R4** PASS — Each section row has 3 separate spans: icon + title +
  tag. Emoji lives in `.dash__section-ic`, not inside the label text.
- **R6/R8** PASS — All section labels + emoji + header verbatim from
  legacy.
- **R7** PASS — `smoke-settings.mjs` 21/21 unaffected.

## Stuck-loop Scan
No recurring finding IDs from INSP-0015..0021.

## Out of scope (Phase 0)
- Store login screen (3-store picker) — needs state
- Tab navigation between the 4 sections — needs internal state
- Real data (SYS_ORDERS, STORE_STOCK) — needs data files
- Actions (advance order, toggle stock) — needs signals
- Smoke tests — added after interactions exist
