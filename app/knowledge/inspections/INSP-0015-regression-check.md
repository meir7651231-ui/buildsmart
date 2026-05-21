# INSP-0015 — Regression Check after R9 + Support + Security

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅

## Scope
Verify R7 — `src/test/tests/tabs.tsx` and the full in-app regression
suite still pass after the wiring work (security, support, R9 account/payment).
Also expand `app/smoke-settings.mjs` to cover all wired branches.

## Findings
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 1 |

### MINOR (informational)
- **`unrelated-404`** — Console logs a single `404 Not Found` during
  page load (likely the PWA manifest icon or service-worker probe).
  Pre-existing, unrelated to settings wiring. No regression caused.

## In-app regression (`runRegression()` via manager view)
```
Summary: ✅ כל הבדיקות עברו
כפתורים: 21/21 · טאבים: 5/5 · מוצרים: 202/202 ·
התנהגות: 6/6 · סנכרון: 1/1 · זהויות: 1/1
```
**236/236 PASS.** R7 satisfied.

## Tabs detail (R7 — required by RULES.md)
- ✅ קבלן · קטלוג — 1/1
- ✅ מנהל · לוח-בקרה — 1/1
- ✅ חנות — 1/1
- ✅ שליח — 1/1
- ✅ עובד — 1/1

## Smoke suite expansion (`app/smoke-settings.mjs`)
Expanded from 12 → 21 tests. New coverage:
- payment (R9 inline input → אשראי)
- security encryption toast + RBAC קבלן toast
- support/מוקד תמיכה toast
- support/מחשבון/בטון toast
- support/סיור/מסך הבית toast
- account.name (R9 → אבי)
- account.phone (R9 → 054-…)
- Esc cancels (business not saved)

All 21 pass.

## Stuck-loop scan
No recurring finding IDs from INSP-0012, INSP-0013, INSP-0014.

## Pre-existing TS errors
`vite.config.ts` + `worker.tsx` still emit errors under
`npx tsc -b --noEmit`. Vite build is clean. Tracked as open MINOR in
`wip-menu-wiring.md`. Not blocking.
