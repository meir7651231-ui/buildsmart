# חוזה · colorModifier

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/screens/lipskey_products_screen.dart:802-808`
**אטום:** `new/dart/color_modifier.dart` — `String? colorModifier(ColorProduct product)`

## קלט
- `product` — `ColorProduct`: `nameHe` (String — שם-המוצר בעברית).

## פלט
`String?` — מילת-ה-finish הראשונה בשם שנמצאת ב-`_kColorModifiers`, או `null` אם אין.

## הטבעות (verbatim מהמקור)
- `_kColorModifiers = {'מוברש','מט'}` (lipskey_products_screen.dart:1783).

## התנהגות
1. פיצול `nameHe` ב-`\s+` (:804-805).
2. `firstWhere` על מילה ב-`_kColorModifiers`, `orElse` ⇒ '' (:806).
3. '' ⇒ `null`, אחרת המילה (:807).

## דוגמאות מספריות (מוכחות ב-color_modifier_test.dart)
| # | nameHe | פלט | עוגן |
|---|--------|-----|------|
| 1 | `ברז שחור מט` | `מט` | :806 |
| 2 | `ברז ניקל מוברש` | `מוברש` | :806 |
| 3 | `ברז זהב` | `null` | :807 (orElse '') |
| 4 | `ברז` | `null` | :807 |
| 5 | `ברז מוברש שחור מט` | `מוברש` | firstWhere = הראשון (:806) |

## עדשה-עוינת
- `firstWhere` ⇒ ה-modifier **הראשון** לפי סדר-מילים, גם כשיש שניים (#5).
- היעדר-modifier ⇒ '' פנימי שמומר ל-`null` (לא מחרוזת-ריקה כלפי-חוץ) (#3,#4).
