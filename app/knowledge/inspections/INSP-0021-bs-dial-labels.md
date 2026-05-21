# INSP-0021 — BsDial Labels Aligned to Legacy

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
The BS logo (top-right FAB) opens `BsDial` — a 5-tile dial of personas.
This dial is our R3-compliant translation of the legacy "מי אתה?"
role-drawer at index.html:4083-4115 (opened by the welcome-hamburger
3-stripe icon).

Two of the 5 tile labels were shortened in our app; this commit
restores them to the verbatim legacy `<b>` text per role.

## Changes
Only `app/src/components/bs/bs-dial.tsx` — TILES array:

| persona | before | after | verbatim source |
|---|---|---|---|
| contractor | קבלן          | קבלן          | index.html:4090 |
| manager    | מנהל          | **מנהל המערכת** | index.html:4095 |
| store      | חנות          | **חנות ספק**    | index.html:4100 |
| courier    | שליח          | שליח          | index.html:4105 |
| worker     | עובד          | עובד          | index.html:4110 |

Plus a one-line `@legacy` comment above the array.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — FAB position untouched.
- **R3** PASS — BsDial still a `<ul class="bsdial">` dial.
- **R4** PASS — Each tile keeps circle + label (two separate spans).
- **R6/R8** PASS — All 5 labels verbatim from legacy.
- **R7** PASS — `smoke-settings.mjs` 21/21 still green.

## Stuck-loop Scan
No recurring finding IDs from INSP-0014–0020.

## Out of scope (intentionally deferred)
- Per-tile subtitles (legacy `<small>` text under each `<b>` role) —
  would add a third pill element per tile, conflicting with R4
  (circle + label, two elements only). Needs design decision.
- Drawer header "מי אתה?" + "בחר תפקיד כדי להיכנס" + footer
  "הדגמה — כל התצוגות חולקות מאגר נתונים אחד" — would add chrome
  rows to the dial.
- Visual swap "BS" text → 3-stripe hamburger glyph — R1-sensitive
  FAB change.
