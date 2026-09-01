# חוזה · baseColor

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/screens/lipskey_products_screen.dart:796-800`
**אטום:** `new/dart/base_color.dart` — `String baseColor(ColorProduct product)`

## קלט
- `product` — `ColorProduct`: `nameHe` (String — שם-המוצר בעברית).

## פלט
`String` — כל תת-מילות-הצבע-הבסיסי בשם (מילה שנמצאת ב-`_kColorWords` ואינה ב-`_kColorModifiers`), מחוברות ברווח לפי סדר-הופעה. '' כשאין צבע.

## הטבעות (verbatim מהמקור)
- `_kColorWords` — נגזר מ-`kLipskeyColors` (lipskey_catalog.dart:484-487) בנוסחת lipskey_products_screen.dart:1776-1778 (תת-מילים אורך ≥2). כולל: לבן·שחור·מט·פרגמון·אפור·ניקל·מוברש·גרפיטי·זהב·נחושת·כרום·אפורה·כחול·אדום.
- `_kColorModifiers = {'מוברש','מט'}` (lipskey_products_screen.dart:1783).

## התנהגות
1. פיצול `nameHe` ב-`\s+` (:797).
2. סינון: מילה ב-`_kColorWords` **וגם לא** ב-`_kColorModifiers` (:799).
3. `join(' ')` (:800).
> הערה: 'מט' נמצא ב-`_kColorWords` (אורך 2) אך גם ב-`_kColorModifiers` ⇒ מסונן החוצה (finish, לא base).

## דוגמאות מספריות (מוכחות ב-base_color_test.dart)
| # | nameHe | פלט | הערה |
|---|--------|-----|------|
| 1 | `ברז שחור מט` | `שחור` | 'שחור'=base · 'מט'=modifier מסונן (:799) |
| 2 | `ברז ניקל מוברש` | `ניקל` | 'מוברש' מסונן |
| 3 | `ברז זהב` | `זהב` | base יחיד |
| 4 | `ברז כרום גדול` | `כרום` | 'גדול' לא-צבע ⇒ מושמט |
| 5 | `ברז` | `` (ריק) | אין מילת-צבע |

## עדשה-עוינת
- 'מט' חבר בשתי הקבוצות — נבלע כ-modifier, לא כ-base (#1).
- מילים שאינן-צבע נופלות (הסינון positive על `_kColorWords`) (#4).
- אפס-צבע ⇒ מחרוזת-ריקה, לא null (#5).
