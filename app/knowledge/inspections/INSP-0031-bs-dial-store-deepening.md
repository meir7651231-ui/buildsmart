# INSP-0031 — Store Deepening (Home + Portal leaves)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Adds children to 2 of 4 Store sections — 11 leaves total.

## בית (s-home) — 3 leaves
From `shStat()` calls in `renderStoreHome` @ index.html:17128-17132:
| emoji | title | source |
|---|---|---|
| 🔧 | בהכנה | `shStat(inPrep.length,'בהכנה','🔧',...)` |
| 📦 | מוכן לאיסוף | `shStat(ready.length,'מוכן לאיסוף','📦',...)` |
| 💰 | מחזור פעיל | `shStat('₪'+todayRevenue,'מחזור פעיל','💰',...)` |

## פורטל (s-portal) — 8 leaves
From the `items` array in `renderStorePortal` @ index.html:20762-20769:
| emoji | title |
|---|---|
| ⭐  | דירוג ספקים |
| ⏱️ | מעקב SLA |
| 🗺️ | אזורי הפצה |
| 📉  | הנחות כמות |
| 🏷️ | הפקת ברקודים |
| 🚛  | ניהול צי רכב |
| 💬  | צ׳אט עם קבלן |
| 🔄  | עדכון מלאי |

Both `ic` and `t` args of each item are verbatim — strictest match.

## Intentionally NOT deepened
- **s-orders** — filter chips (פעילות/לאישור/בהכנה/מוכנות) have labels but no verbatim emoji per stage.
- **s-stock** — filter chips (הכל/זמינים/אזלו) + 3 summary tiles, no verbatim emoji per item.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- R1 PASS · R2 PASS · R3 PASS · R4 PASS · R6/R8 PASS · R7 PASS.

## Stuck-loop Scan
No recurring finding IDs from INSP-0019..0030.

## חנות ספק — done (2 of 4 sections deepened, 2 deferred)
| Section | Status |
|---|---|
| 🏠 בית | ✅ 3 leaves |
| 📥 הזמנות | ⏳ deferred |
| 📦 מלאי | ⏳ deferred |
| 🧰 פורטל | ✅ 8 leaves |
