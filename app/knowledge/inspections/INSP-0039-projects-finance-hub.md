# INSP-0039 — Projects Tab + 📊 מרכז פיננסים (Finance Hub)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Projects tab now has 4 items at L1: 3 project name leaves +
`📊 מרכז פיננסים` branch with 10 children.

## Hub label
`📊 מרכז פיננסים` — verbatim from fin-hub-btn @ index.html:4609.

## 10 Sub-leaves (verbatim — ic + t per openFinanceHub item)
| emoji | title | source |
|---|---|---|
| 📈 | הצמדה למדד | `finIndex` @ :19489 |
| 🗓️ | תנאי תשלום | `finPayTerms` @ :19490 |
| 👷 | קבלני משנה | `finSubs` @ :19491 |
| ✅ | אישורי רכש | `finApprovals` @ :19492 |
| 🔔 | התראות חריגה | `finThresholds` @ :19493 |
| 📊 | ניתוח ROI | `finROI` @ :19494 |
| 🧾 | פיצול חשבוניות | `finInvoiceSplit` @ :19495 |
| ⏰ | פיצויים וקנסות | `finPenalties` @ :19496 |
| 📄 | דוחות PDF | `finReports` @ :19497 |
| 💱 | רכש במט״ח | `finFX` @ :19498 |

## Changes
Single file: `app/src/components/menu/submenu-settings.tsx`.
- Refactored `ProjectsSubmenu` to support drill (same pattern as
  CartSubmenu / HomeSubmenu): `projectsDrillPath` signal,
  `walkProjects()` helper, `projectItems()` combines PROJECTS leaves
  with FINANCE_HUB branch.
- Renderer chooses per-row icon: SVG `PROJECT_ICON` for the 3 project
  leaves (verbatim from legacy `setLink` rows), emoji span for the
  finance branch + its 10 children.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- R1 PASS · R2 PASS · R3 PASS · R4 PASS · R6/R8 PASS · R7 PASS.

## Stuck-loop Scan
No recurring finding IDs from INSP-0027..0038.
