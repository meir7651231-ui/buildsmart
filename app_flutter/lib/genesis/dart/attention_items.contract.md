# חוזה · `attentionItems` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/attention_engine.dart:81-154`.

## תפקיד
בונה רשימת פריטי-תשומת-לב מ-4 מקורות (הזמנות-ותיקות / אישורים / חופשות / בקשות-חשבון), ומחזיר crit-לפני-warn (חלוקה, לא מיון-פנימי).

## חתימה
```dart
List<AttentionItem> attentionItems(AttentionInput inp, {
  required String Function(String key, String fallback) termOf,
  required int orderCritDays,
  required int approvalsCritCount,
})
// AttentionSev{crit,warn} · AgingOrder{id,ageDays} · AttentionInput{agingOrders,pendingApprovals,pendingVacations,pendingAccountReqs}
// · AttentionItem{key,tag,title,sev,navTab} — כולם מוטבעים inline
```

## התנהגות (עוגן attention_engine.dart:81-154)
1. `aging` = agingOrders ממוינות ותק-יורד (`b.ageDays-a.ageDays`). עד-3 פריטים פרטניים (`order:<id>`, navTab 1, `ageDays>=orderCritDays ? crit : warn`). אם >3 ⇒ פריט-צבירה `order:more` warn "+N הזמנות נוספות".
2. `pendingApprovals>0` ⇒ פריט `approvals` navTab 3, ניסוח יחיד/רבים, `>=approvalsCritCount ? crit : warn`.
3. `pendingVacations>0` ⇒ `vacations` navTab 3 warn (יחיד/רבים).
4. `pendingAccountReqs>0` ⇒ `accountReqs` navTab 3 warn (יחיד/רבים).
5. תוצאה = `[...crit לפי סדר-הבנייה, ...warn לפי סדר-הבנייה]`.

## שקעים
- `termOf(key, fallback)` — במקור `termOf(cfg, key, fallback)` (מונחון על OrgConfig) ⇒ שקע (מנטרל OrgConfig).
- `orderCritDays`/`approvalsCritCount` — const-מודול `kAttnOrderCritDays`/`kAttnApprovalsCritCount` ⇒ שקעים.

## דוגמאות-מחייבות (termOf ⇒ fallback; orderCritDays=14, approvalsCritCount=3)
| # | קלט | קובע |
|---|------|------|
| 1 | 4 הזמנות (5,20,10,1) | 4 פריטים; ראשון `order:B` crit "הזמנה B ממתינה 20 ימים"; `order:more` "+1 הזמנות נוספות ממתינות" |
| 2 | pendingApprovals=1 | "משימה אחת ממתינה לאישור" warn navTab3 |
| 3 | pendingApprovals=5 | "5 משימות ממתינות לאישור" crit (‏5≥3) |
| 4 | vacations=2, accountReqs=1 | "2 בקשות חופשה ממתינות" + "בקשת חשבון אחת ממתינה" |
| 5 | הזמנה crit(30) + approvals crit(9) | סדר crit נשמר: order:X לפני approvals |
| 6 | AttentionInput() ריק | [] |
| 7 | ageDays==14 | crit (‏>=) |

## DoD
```
dart run --enable-asserts new/dart/attention_items_test.dart  ⇒ exit 0 + "OK attentionItems: 7 asserts passed"
```
