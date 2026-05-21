# INSP-0013 — Support Hub Wiring

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅

## Scope
15 new LEAF_BINDINGS for `שירות ותמיכה`:
- 6 L3 leaves: מוקד תמיכה · צ׳אטבוט · דיווח על באג · המרת מידות · סנכרון יומן · לוח דרושים
- 3 L4 leaves (מחשבון כמויות): אריחים · צבע · בטון
- 6 L4 leaves (סיור היכרות): מסך הבית · הזמנה · תקציב · משימות ואתר · מועדון BuildSmart · מוכנים!

## Findings
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R3** (no drawer/modal): PASS — all bindings call `showToast()` only.
- **R4** (circle + label): PASS — `SettingsTreeSubmenu` renderer unchanged.
- **R6** (verbatim labels): PASS — all leaf keys verified against index.html:22075–22090 (hub tiles), :22290 (calc tabs), :22375 (TOUR_STEPS).
- **R8** (no invention): PASS — every item present in legacy.

## Playwright Verification
`node /tmp/verify-support.mjs` → **8/8 PASS**

## Stuck-loop scan
No finding IDs from INSP-0009–0012 recur here.
