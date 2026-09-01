# חוזה · `plug`

**מוצא:** `buildsmart/app_flutter/lib/features/fittings/engine/fitting_dims.dart:122-128` (מנוע-אביזרים PP-R, פורט 1:1 מ-`pure_engine.py`).

## חתימה
```dart
Map<String, double> plug(int od, {
  required Map<String, double> Function(int) base,
  required double Function(double) r1,
})
```

## שקעים (fn-sockets · חוק-3)
| שקע | סוג | תפקיד השכן |
|-----|-----|-----------|
| `base` | `Map<String,double> Function(int)` | הבסיס האוניברסלי לכל אביזר-ריתוך (OD·wall·ID·B·C·F) |
| `r1` | `double Function(double)` | עיגול half-to-even לספרה-עשרונית אחת |

## התנהגות
מחשב את מפת-הממדים של **פקק** (plug): מרחיב את הבסיס בשני שדות — `A` (אורך-כולל) = `r1(F + 0.4·OD)` ו-`cap` (אורך-הכיפה) = `r1(0.4·OD)`. מחזיר את מפת-הבסיס עם שני השדות הנוספים.

## טוהר
אפס-import, אפס-state, אפס-IO. base ו-r1 הוזרקו כשקעים.
