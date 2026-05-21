# INSP-0038 — Profile → מועדון BuildSmart Deepening (7 rewards items)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Adds children to the `מועדון BuildSmart` node in PROFILE_TREE
(settings → הגדרות-פרופיל → דרגות הקבלן).

## 7 Leaves (verbatim — ic + t per openRewardsHub item)
| emoji | title | source |
|---|---|---|
| 🎯 | אתגרים חודשיים | `rwChallenges` @ :21464 |
| 🏆 | לוח מובילים | `rwLeaderboard` @ :21465 |
| 🌿 | תגי ירוק | `rwGreen` @ :21466 |
| 📍 | קופונים לפי מיקום | `rwCoupons` @ :21467 |
| 👥 | הזמן חבר | `rwReferral` @ :21468 |
| 💎 | מועדון VIP | `rwVIP` @ :21470 |
| 🎁 | מימוש הטבות | `rwRedeem` @ :21471 |

`rwAchievements` is explicitly **REFACTORED-removed** in the legacy
(`/* REFACTORED: rwAchievements removed — the profile screen already
renders the same achievements via identityAchievements(). */`). Our
implementation honors that removal — the achievements appear elsewhere
in the profile tree as their own branch.

## Changes
Single file: `app/src/components/menu/submenu-settings.tsx`:
- PROFILE_TREE: added 7 children to "מועדון BuildSmart" Node.
- PROFILE_LEAF_ICONS: added 7 emoji entries keyed by full path.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- R1 PASS · R2 PASS · R3 PASS · R4 PASS · R6/R8 PASS · R7 PASS.

## Stuck-loop Scan
No recurring finding IDs from INSP-0026..0037.
