# חוזה · `writeFilteredMode`

מוצא: `buildsmart/app_flutter/lib/data/edge/filtered_mode.dart:19-31`.

## חתימה
```dart
void writeFilteredMode(EdgeKvStore store, {required bool on})
```

## התנהגות
כותב את דגל "מצב-מסונן" לאחסון-מפתח-ערך המוזרק, בצורה קנונית-מינימלית:
- `on == true` ⇒ `store.write(kFilteredModeKey, '1')`.
- `on == false` ⇒ `store.remove(kFilteredModeKey)` (כבוי = מחיקת-מפתח, לא '0').

## מפל-מינימום
- `EdgeKvStore` — הממשק המופשט הוטבע verbatim (read/write/remove); חוזה-ה-KV
  מוזרק ⇒ נבדק עם fake-מגובה-מפה.
- `kFilteredModeKey = 'bs_filtered_mode_v1'` הוטבע verbatim.

## שוליים
- כיבוי על מפתח-שאינו-קיים ⇒ remove ללא-תופעה (no-op בטוח).
- הדלקה חוזרת ⇒ אותו ערך '1'.
