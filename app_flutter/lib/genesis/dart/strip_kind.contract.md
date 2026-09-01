# חוזה · `stripKind`

**מוצא:** `buildsmart/app_flutter/lib/data/variant_families.dart:41-46` (השכן `_stripKind`, private→public).

## חתימה
```dart
String stripKind(String name, AttrKind k, {required AttrKind? Function(String) kindOf})
```

## שקעים (fn-sockets · חוק-3)
| שקע | סוג | תפקיד השכן |
|-----|-----|-----------|
| `kindOf` | `AttrKind? Function(String)` | מסווג טוקן-מילה לסוג-מאפיין (מידה/צבע/דגם/תת-סוג) או `null` |

## טיפוסים מוטבעים (חוק-1)
- `enum AttrKind { size, color, model, subtype }` — עצמאי, אפס-cascade.

## התנהגות
מפצל `name` לפי רווחים, זורק כל מילה ריקה וכל מילה ש-`kindOf(w) == k`, ומאחד את השאר ברווח יחיד. התוצאה = "מסגרת" המוצר בלי המילים של סוג-המאפיין הנבחר.

## טוהר
פונקציה טהורה: אפס-import, אפס-state, אפס-IO. כל התלות באטום-חוץ הוזרקה כשקע.
