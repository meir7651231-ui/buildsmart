# אטום · `familyOf`

מוצא: `buildsmart/app_flutter/lib/features/fittings/engine/catalog_map.dart:34-49`

## חתימה
```dart
String? familyOf(LipskeyCatalogProduct p)
```

## חוזה
גשר קטלוג→מנוע: ממפה קטגוריית-מוצר לשם-משפחת-המנוע.

- `categoryHe` לא במפה `_kCategoryFamily` → `null` (fallback — לא כשל).
- `'מצמד'` מוכרע: שם עם **שני קטרים נבדלים** (regex `50×40`) → `'מצרה'`, אחרת `'מצמד'`.
  - קטרים זהים (`50x50`) נשארים `'מצמד'`.
- `'ברך 90°'` עם `'45'` בשם → `'ברך 45°'`.
- אחרת — הערך verbatim מהמפה.

## מוטבע verbatim (חוק-3/4)
- `_kCategoryFamily` (8 קטגוריות) + 8 consts `kPpr*`.
- `_kReducer` = `RegExp(r'(\d{2,3})\s*[×xX]\s*(\d{2,3})')`.
- `_is45(name)` = `name.contains('45')`.

## טוהר
דטרמיניסטי, בלי state/IO. `LipskeyCatalogProduct` מוטבע-מינימום (`categoryHe`+`nameHe`).
