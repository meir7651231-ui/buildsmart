# חוזה · `encode` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/offline_order_queue.dart:313-319`
(‏`_encode`). הקלט הפך גנרי, והקריאה `i.toJson()` הפכה לשקע `toJson` (חוק-3).
יבוא-סטנדרט מותר: `dart:convert` (חוק-1 — שפה/סטנדרט בלבד).

## חתימה
```dart
String encode<T>(List<T> intents, {required Map<String, dynamic> Function(T) toJson})
```

## קלט
- `intents` — רשימת ישויות (גנרית).
- `toJson` — **שקע** (חוק-3): במקור `i.toJson()` של `OfflineOrderIntent`.

## פלט / התנהגות (עוגני-שורה)
- `offline_order_queue.dart:314` — `jsonEncode(intents.map((i) => toJson(i)).toList())`:
  ‏JSON-array של המפות, **בסדר-הרשימה** (FIFO — נשמר).
- רשימה ריקה ⇒ `'[]'`.
- `jsonEncode` הוא סטנדרטי — מפתחות/ערכי-המפה מקודדים כרגיל (מחרוזות במרכאות וכו').

## דוגמאות מספריות (‏toJson stub = הזהות למפה)
| # | intents | ⇒ |
|---|---------|---|
| 1 | `[]` | `'[]'` |
| 2 | `[{id:1}]` | `'[{"id":1}]'` |
| 3 | `[{id:1},{id:2}]` | `'[{"id":1},{"id":2}]'` (סדר נשמר) |
| 4 | `[{a:'x',b:true}]` | `'[{"a":"x","b":true}]'` |

## שקעים
- `toJson` — הזרקת-סריאלייזר (חוק-3). הבדיקה מזריקה ישות-record + מפ-סריאלייזר סינתטי.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/encode_test.dart  ⇒ exit 0 + "OK encode: N asserts passed"
```
