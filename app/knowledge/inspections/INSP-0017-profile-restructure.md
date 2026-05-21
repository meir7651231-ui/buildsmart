# INSP-0017 — Profile Restructure (10 sections, names only)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅

## Context
Earlier the bottom menu tab "הגדרות" opened the settings dial directly.
That dial corresponds to **only section #9** of the legacy
profile/identity tab. The other 9 sections were missing. This commit
restructures so the bottom tab navigates to a `ProfileView` placeholder
containing all 10 section names + footer; the settings dial is reached
via the "הגדרות מתקדמות" row inside the page.

## Scope
- **New** `src/views/profile.tsx` — 8 placeholder rows, 1 settings link,
  1 footer.
- **New** signal value `'profile'` in `AppView` + `openSettingsDial()`
  helper in `app-store.ts`.
- **Updated** `menu-speed-dial.tsx` — `TAB_HAS_SUBMENU.settings = false`,
  `VIEW_MAP.settings = 'profile'`.
- **Updated** `app.tsx` — added `case 'profile'`.
- **Updated** `smoke-settings.mjs` — new `openSettings()` helper goes
  via Profile → "הגדרות מתקדמות". 21/21 still PASS.
- **Updated** `global.css` — `.profile__*` styles.

## Findings
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — no FAB changes.
- **R3** PASS — Profile is a page (not drawer/sheet/modal). Settings
  dial unchanged; still a dial when invoked from "הגדרות מתקדמות".
- **R6/R8** PASS — all 8 section headers + footer verbatim from
  index.html:6545-6680 (`refreshIdentity`).
- **R7** PASS — `smoke-settings.mjs` 21/21 after rewire.

## Stuck-loop Scan
No recurring finding IDs from INSP-0014, INSP-0015, INSP-0016.

## What's still placeholder
Each of the 8 sections is currently just a row with the section name
and a "בבנייה" tag. Full implementation per section (HERO card, STATS
tiles, RANKS ladder, ACHIEVEMENTS grid, etc.) will follow.
