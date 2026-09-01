# חוזה · `auditTrail` / `renderAuditTrail`

## תפקיד
הופך את **רשימת-רשומות-החסימה** של מנוע-בטיחות-העריכה (`SafetyVerdict.blocked`)
לעקבת-ביקורת: `auditTrail` מחזיר **רשימת-שורות** (שורה לכל רשומה), ו-`renderAuditTrail`
מחבר אותן ל**בלוק-טקסט אחד** מופרד-`\n`. שתי פונקציות טהורות, אפס IO.
מקור: `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:489-495` (חוק-4).

## חתימה
```dart
List<String> auditTrail<E>(
  List<E> blocked, {
  required String Function(E) auditLine,
});

String renderAuditTrail<E>(
  List<E> blocked, {
  required String Function(E) auditLine,
});
```
- `auditTrail`: `[for (final e in blocked) auditLine(e)]` — סדר נשמר, שורה לכל אלמנט.
- `renderAuditTrail`: `auditTrail(blocked, auditLine: auditLine).join('\n')` — בלי שורה-נגררת.

## שקעים (חוק-3 — קריאה-לשכן / קריאת-שדה ⇒ פרמטר)
| שקע | מקורו במקור | טיפוס | הערה |
|------|-------------|-------|------|
| `blocked` | `verdict.blocked` (שדה על `SafetyVerdict`) | `List<E>` | ערך-השדה מוזרק ישירות; המחלקה-הגדולה `SafetyVerdict` לא הוטבעה |
| `auditLine` | `auditLine(e)` (אטום-אח `audit_line`, :484-488) | `String Function(E)` | מרנדר רשומה-בודדת; המיפוי שייך לאטום-audit_line |

טיפוס-האלמנט `BlockedEntry` (עוטף `ConfigOp` — היררכיה-אטומה בת 6 גרסאות) **לא הוטבע**;
האלמנט נשאר גנרי `<E>` כדי לשמור טוהר בלי לזייף את ההיררכיה.

## דוגמאות-מחייבות (מקריאת-הקוד)
נניח שקע-רינדור מייצג המשחזר את פורמט `audit_line` (`'⛔ ' + e`):
| # | blocked | auditTrail | renderAuditTrail |
|---|---------|-----------|------------------|
| 1 | `['a','b']` | `['⛔ a','⛔ b']` | `'⛔ a\n⛔ b'` |
| 2 | `[]` (ריק) | `[]` | `''` (מחרוזת ריקה — join על ריק) |
| 3 | `['solo']` | `['⛔ solo']` | `'⛔ solo'` (בלי `\n`) |
| 4 | `['x','y','z']` | `['⛔ x','⛔ y','⛔ z']` | `'⛔ x\n⛔ y\n⛔ z'` |

## אינווריאנטים
- **שימור-סדר:** השורות בסדר האלמנטים ב-`blocked` (list-comprehension).
- **1:1:** בדיוק שורה אחת לכל אלמנט; אורך-הפלט == `blocked.length`.
- **join('\n') נקי:** מפריד יחיד בין שורות, בלי שורה-מובילה/נגררת. ריק ⇒ `''`, יחיד ⇒ ללא `\n`.
- **שקוף-לרינדר:** `auditTrail` אינו נוגע בתוכן-השורה — כל ההיגיון בשקע `auditLine`.
- דטרמיניסטי, ללא `Date.now`/אקראיות/IO.
