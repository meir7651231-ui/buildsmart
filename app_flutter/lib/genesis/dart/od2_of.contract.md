# חוזה · `od2Of`

מוצא: `buildsmart/app_flutter/lib/features/fittings/engine/catalog_map.dart:81-89`.

## חתימה
```dart
int? od2Of(LipskeyCatalogProduct p)
```

## התנהגות
מחזיר את **הקוטר-השני (הקטן)** של אביזר-מצרה, או `null` אם המוצר אינו דו-קוטרי.
מחפש דו-קוטר "‏NNxMM" קודם ב-`nameHe`, ואם אין — ב-`dims['מידה']`. שני-קטרים
זהים ‏(‏group(1)==group(2), למשל "50x50") ⇒ `null` (לא-מצרה אמיתית). מחזיר את
הקבוצה-השנייה (הקוטר הקטן) כ-int.

## מפל-מינימום
- `LipskeyCatalogProduct` — צורת-מינימום: `nameHe` (String) + `dims`
  (‏Map<String,dynamic>?). שאר ~20 השדות הושמטו.
- `_kReducer = RegExp(r'(\d{2,3})\s*[×xX]\s*(\d{2,3})')` הוטבע verbatim.

## שוליים
- אין-התאמה בשם ו-`dims` null ⇒ `null`.
- קטרים זהים ⇒ `null`.
- התאמה ב-`dims['מידה']` כשהשם ריק ⇒ הקוטר-השני.
