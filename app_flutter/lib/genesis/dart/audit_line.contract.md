# חוזה · `auditLine`

## תפקיד
מרנדר **רשומת-חסימה אחת** (`BlockedEntry`) לשורת-ביקורת בטקסט-רגיל — עקבת-החלטה
לצריכת מנוע-בטיחות-העריכה (`SafetyVerdict.blocked`). פונקציה טהורה, אפס IO.
מקור: `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:484-488` (חוק-4).

## חתימה
```dart
String auditLine({
  required String opTag,
  required String opId,
  required String reasonHe,
});
```
מחזירה: `'⛔ ' + opTag + ' · ' + opId + ' · ' + reasonHe`.
תבנית-התיחום `' · '` = רווח + נקודה-אמצעית (U+00B7) + רווח. הקידומת `'⛔ '` = U+26D4 + רווח.
אין escaping — הערכים מוזרקים verbatim (נאמנות-מקור).

## שקעים (חוק-3 — קריאה-לשכן ⇒ פרמטר)
| שקע | מקורו במקור | טיפוס | הערה |
|------|-------------|-------|------|
| `opTag` | `_opTag(e.op)` (אטום-אח `op_tag`, :474-483) | `String` | תוצאת-הקריאה; המיפוי ConfigOp→תגית שייך לאטום-op_tag |
| `opId` | `e.op.id` | `String` | מזהה-הרכיב שנחסם |
| `reasonHe` | `e.reasonHe` | `String` | נימוק-החסימה בעברית |

טיפוס-השכן `BlockedEntry` (עוטף `ConfigOp` — היררכיה-אטומה בת 6 גרסאות) **לא הוטבע**;
שלושת-השדות-הנצרכים דוססו לשקעים-סקלריים כדי לשמור טוהר בלי לזייף את ההיררכיה.

## דוגמאות-מחייבות (מקריאת-הקוד)
| # | opTag | opId | reasonHe | פלט |
|---|-------|------|----------|-----|
| 1 | `setText` | `nav.home` | `נעול לתפקיד` | `⛔ setText · nav.home · נעול לתפקיד` |
| 2 | `setHidden` | `btn.confirmOrder` | `רצפת-תפקיד` | `⛔ setHidden · btn.confirmOrder · רצפת-תפקיד` |
| 3 | `setOrder` | *(ריק)* | `r` | `⛔ setOrder ·  · r` (שני רווחים סביב-הריק) |
| 4 | `setStyle` | `id1` | `a · b` | `⛔ setStyle · id1 · a · b` (התו-המתחם בערך נשמר verbatim) |
| 5 | *(ריק)* | *(ריק)* | *(ריק)* | `⛔  ·  · ` |

## אינווריאנטים
- מבנה קבוע: תמיד קידומת `⛔ ` + שלושה שדות בסדר opTag·opId·reasonHe מופרדים ב-` · `.
- דטרמיניסטי, ללא Date.now/אקראיות/IO.
- שקוף-לתו-המתחם: `·` בתוך ערך אינו בורח (דוגמה 4).
