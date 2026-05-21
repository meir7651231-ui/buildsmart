# INSP-0036 — Home → 🤖 Deepening (9 AI tools)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Adds children to the `🤖 בינה מלאכותית ואוטומציה` entry in `HOME_LEAVES`
+ drill state walker for the home tab.

## 9 New Leaves (verbatim — ic + t from each openAIHub item)
| emoji | title | source |
|---|---|---|
| 📦 | חיזוי מלאי | `aiPredictStock` @ :21125 |
| 📷 | סורק ברקוד | `aiBarcodeScan` @ :21126 |
| 🎙️ | דיבור למשימה | `aiVoiceTask` @ :21127 |
| 💡 | חלופות זולות | `aiAlternatives` @ :21128 |
| 📐 | סריקת תוכניות | `aiPlanScan` @ :21129 |
| 🔗 | התאמה משולשת | `aiThreeWay` @ :21130 |
| 🌦️ | אוטומציית מזג אוויר | `aiWeather` @ :21131 |
| 🔧 | זיהוי בלאי | `aiWearDetect` @ :21132 |
| 📊 | Analytics חכם | `aiAnalytics` @ :21133 |

Both `ic` (emoji) and `t` (title) used verbatim from each openAIHub item.
The `s` (subtitle) field is dropped — our dial doesn't render subtitles
per R4 (circle + label only, two elements).

## Changes
Only `app/src/components/menu/submenu-settings.tsx`:
- `HomeItem` type extended with optional `children`.
- Added `homeDrillPath` signal, `walkHome()` helper.
- `HomeSubmenu` now renders anchors + walks the tree (same pattern as
  `CartSubmenu`).

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- R1 PASS · R2 PASS · R3 PASS · R4 PASS · R6/R8 PASS · R7 PASS.

## Stuck-loop Scan
No recurring finding IDs from INSP-0024..0035.
