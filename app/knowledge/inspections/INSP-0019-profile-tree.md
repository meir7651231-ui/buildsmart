# INSP-0019 — Profile Dial as 3-Level Tree

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/1 — single documented MINOR)

## Scope
User asked to consolidate the settings tab. The flat 8-leaf ProfileSubmenu
is replaced with a tree:

```
Level 1 (top)          : הגדרות-פרופיל · הגדרות מתקדמות
Level 2 (profile root) : כרטיס קבלן · דרגות הקבלן
Level 3 (card)         : אתה במצב הדגמה · המספרים שלך · סך הרכש דרך BuildSmart
Level 3 (ranks)        : ההטבה שלך · הישגים · מועדון BuildSmart
```

## Changes
- **app-store.ts**: `SettingsLevelId` gains `'top'` value (was `'profile' | 'advanced'`); new `profilePath` signal; helpers `enterProfile` / `exitProfile` / `pushProfilePath` / `popProfilePathTo` / `setSettingsLevel`. All settings/profile state resets on `setMenuTab` / `toggleMenu` / `closeMenu`.
- **submenu-settings.tsx**: removed old flat `ProfileSubmenu`. Added `SettingsTopSubmenu` (2 items), `PROFILE_TREE` constant, `walkProfile()` helper, and `ProfileTreeSubmenu` that walks the tree based on `profilePath`. Exports icon helpers for anchors.
- **menu-speed-dial.tsx**: `SettingsLevel` now switches on `level` value with three branches (top / profile-tree / advanced). Profile branch renders the top anchor + path anchors + `<ProfileTreeSubmenu>`.
- **smoke-settings.mjs**: navigation path unchanged — `openSettings()` still goes via "הגדרות" → "הגדרות מתקדמות". 21/21 PASS.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 1 |

### MINOR — `r6-user-authored-label`
The label `"הגדרות-פרופיל"` is **not** verbatim from the legacy. The
user explicitly authored this grouping label to consolidate the level-1
into 2 items. Documented as an intentional exception in
`submenu-settings.tsx` (PROFILE_TREE comment block). All other section
labels remain legacy-verbatim per R6/R8.

## Rule Checks
- **R2** PASS — no page-swap.
- **R3** PASS — every level renders inside `<ul class="dial">`.
- **R4** PASS — every row = circle + label (two elements).
- **R6/R8** PASS for all legacy strings; MINOR for the one user-authored
  label noted above.
- **R7** PASS — smoke 21/21 + in-app regression unaffected.

## Stuck-loop Scan
No recurring finding IDs from INSP-0014–0018.

## Process note
Inspector subagent ran **before** this markdown report (per the lesson
from INSP-0014/0015/0016).
