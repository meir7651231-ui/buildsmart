# INSP-0023 — Courier Persona Skeleton (Phase 0)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Second of three Phase-0 skeletons. Replaces the tiny placeholder
CourierView with the same dashboard skeleton structure as Store:
header + 4 verbatim section names + "בבנייה" tag per row.

Reuses the shared `.dash__*` CSS block introduced in INSP-0022.

## Changes
- **`app/src/views/courier.tsx`** — full replace (~30 lines).

## Section labels (verbatim from legacy)
| emoji | title | source |
|---|---|---|
| 🛻 | הרכב שלי היום           | index.html:18005 |
| 📦 | משלוחים ממתינים לאיסוף | index.html:18019 |
| 🚚 | משלוחים פעילים         | index.html:7762 |
| 🧰 | פורטל השליח             | index.html:18043 |

Header text "שליח" — verbatim from role-pick-btn `<b>` at
index.html:4105.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — FAB positions untouched.
- **R2** PASS — Persona default view (same slot as Home/Manager/Store).
- **R3** PASS — Flat content; no dial.
- **R4** PASS — 3 separate spans per row (icon + title + tag).
- **R6/R8** PASS — Verbatim labels.
- **R7** PASS — smoke regression unaffected.

## Stuck-loop Scan
No recurring finding IDs from INSP-0016..0022.

## Out of scope (Phase 0)
- Vehicle picker (signal + filter logic)
- Real shipment list rendering
- Stage advancement (ready → pickup → transit → delivered)
- Courier portal sub-screen
- Split-shipment support
