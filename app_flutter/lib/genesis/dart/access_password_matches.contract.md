# חוזה · `accessPasswordMatches`

**מוצא:** `buildsmart/app_flutter/lib/config/access_lock.dart:58-66`.

## חתימה
```dart
bool accessPasswordMatches(String storedHash, String entered, {
  required String Function(String) hashAccessPassword,
})
```

## שקעים (fn-sockets · חוק-3)
| שקע | סוג | תפקיד השכן |
|-----|-----|-----------|
| `hashAccessPassword` | `String Function(String)` | גיבוב סיסמת-גישה → hex SHA-256 (עם salt-אפליקציה); סיסמה-ריקה ⇒ '' (סנטינל "אין נעילה") |

## חוק-6 (סוד מוזרק)
אין סוד צרוב באטום: ה-hash-השמור (`storedHash`), הקלט (`entered`) ופונקציית-הגיבוב עצמה — כולם מוזרקים מבחוץ.

## התנהגות
- `storedHash` ריק ⇒ `true` (השער לא-פעיל, כל קלט פותח).
- אחרת: `true` רק כאשר `hashAccessPassword(entered) == storedHash`.

## טוהר
אפס-import, אפס-state, אפס-IO, אפס-crypto מקומי. הגיבוב הוזרק כשקע.
