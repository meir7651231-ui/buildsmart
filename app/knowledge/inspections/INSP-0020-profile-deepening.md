# INSP-0020 — Profile Dial Deepening (real identity data)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (initial 0/0/1 MINOR on R4 → fix → re-check GO 0/0/0)

## Scope
User asked to deepen the settings: "אני רוצה לראות אותו שלם". The 6
level-3 placeholder toasts now wire real data, and 2 of them become
branches with sub-leaves:

```
כרטיס קבלן
 ├ אתה במצב הדגמה  → toast: full demo-banner copy (verbatim)
 ├ המספרים שלך  (branch)
 │   ├ הזמנות               → toast: count
 │   ├ אתרים פעילים          → toast: count (PROJECTS.length=3)
 │   ├ עצי מוצרים            → toast: count
 │   └ אביזרים שהעץ הציל     → toast: count
 └ סך הרכש דרך BuildSmart  → toast: formatIls(0) = "₪0"

דרגות הקבלן
 ├ ההטבה שלך  → toast: current rank + perk + progress to next
 ├ הישגים  (branch — 6 leaves with lock/unlock states)
 │   ├ הזמנה ראשונה         (locked)
 │   ├ 10 הזמנות            (locked)
 │   ├ ריבוי אתרים          (UNLOCKED: sites=3, sites>=3 → dial__circle--on)
 │   ├ חובב עץ מוצרים        (locked)
 │   ├ לא שוכח כלום          (locked)
 │   └ מחזור ₪10K            (locked)
 └ מועדון BuildSmart  → toast: hub description
```

## Changes
- **New** `src/data/identity.ts` — RANKS (4) · identityStats (demo
  values: sites=PROJECTS.length, others=0) · currentRank · nextRank ·
  identityAchievements (6) · formatIls. All verbatim from
  index.html:6499-6608.
- **submenu-settings.tsx**:
  - PROFILE_TREE has new `המספרים שלך` (4 leaves) and `הישגים` (6
    leaves) sub-branches.
  - PROFILE_LEAVES map: 14 leaf bindings with action() + isActive() for
    achievements.
  - PROFILE_LEAF_ICONS map: holds the emoji glyphs so they sit in the
    circle, not the label (R4).
  - `achToast(idx)` helper for the 6 achievement leaves.
  - ProfileTreeSubmenu now resolves leaf binding and toggles
    dial__circle--on when isActive=true.
- **global.css**: `.dial__circle-emoji` style (20px, centered).

## Findings (Inspector subagent)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 (was 1, resolved) |

## Resolved MINOR
**`r4-emoji-in-label`** (initial review). Labels carried emoji prefixes
("📦 הזמנות"). Fixed by moving emoji into a separate
`.dial__circle-emoji` slot inside the circle, leaving the label as
plain Hebrew text. Two-element structure now respected per R4.

## Rule Checks
- **R2** PASS — no page-swap.
- **R3** PASS — all rendering inside `<ul class="dial">`.
- **R4** PASS — circle holds icon (emoji or SVG); label holds text.
- **R6/R8** PASS — all strings + emoji verbatim from legacy.
- **R7** PASS — smoke 21/21 stays green.

## Stuck-loop Scan
No recurring finding IDs from INSP-0014–0019.

## Process note
Inspector subagent ran **before** this markdown report, both for the
initial pass and the post-fix re-check.
