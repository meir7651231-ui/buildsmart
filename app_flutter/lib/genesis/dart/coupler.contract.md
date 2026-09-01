# חוזה · `coupler`

**מוצא:** `buildsmart/app_flutter/lib/features/fittings/engine/fitting_dims.dart:72-77` (מנוע-אביזרים PP-R, פורט 1:1 מ-`pure_engine.py`).

## חתימה
```dart
Map<String, double> coupler(int od, {
  required Map<String, double> Function(int) base,
  required double Function(double) r1,
})
```

## שקעים (fn-sockets · חוק-3)
| שקע | סוג | תפקיד השכן |
|-----|-----|-----------|
| `base` | `Map<String,double> Function(int)` | הבסיס האוניברסלי לכל אביזר-ריתוך (OD·wall·ID·B·C·F) |
| `r1` | `double Function(double)` | עיגול half-to-even לספרה-עשרונית אחת (זהה ל-`round(x,1)` בפייתון) |

## התנהגות
מחשב את מפת-הממדים של **מצמד** (coupler): מרחיב את הבסיס בשדה `A` = `r1(2·F + 2)` — שני עומקי-שקע ועוד מעצור-מרכז. מחזיר את אותה מפת-בסיס (מוטציה במקום) עם `A` נוסף.

## טוהר
אפס-import, אפס-state, אפס-IO. שני החישובים ההנדסיים (base, r1) הוזרקו כשקעים.
