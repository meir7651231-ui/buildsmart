# חוזה · `decode` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/offline_order_queue.dart:320-345`
(‏`_decode`, פרטי-במקור ⇒ public).

**שקעים:** `OfflineOrderIntent.fromJson`⇒`fromJson` · `debugPrint`⇒`log` (חוק-3,
מסיר תלות ב-Flutter/foundation). ייבוא `dart:convert` בלבד (שפה/סטנדרט, מותר). גנרי על `T`.

## חתימה
```dart
List<T> decode<T>(String? raw, {
  required T Function(Map<String, dynamic>) fromJson,
  required void Function(String) log,
})
```

## קלט
- `raw` — מחרוזת-JSON או null.
- `fromJson` — **שקע**: בניית ישות ממפה.
- `log` — **שקע**: לוג-אזהרה (במקור `debugPrint`).

## פלט / התנהגות (עוגני-שורה)
- `:321` — `raw==null || raw.isEmpty` ⇒ `[]` (מסלול-נפוץ, בלי-לוג).
- `:322-333` — לולאה על `jsonDecode(raw) as List`: כל פריט מנוסה ב-try פנימי;
  פריט-פגום (‏`e as Map` נכשל / fromJson זורק) ⇒ **מדולג** + `log('...skipped corrupt intent: $err')`.
- `:337-340` — jsonDecode או `as List` נכשל (מטען-פגום-כולו) ⇒ `[]` + `log('...corrupt queue payload (dropped): $e')`.
- **לעולם לא זורק** (fault-tolerant).

## דוגמאות
| # | raw | ⇒ | log |
|---|-----|---|-----|
| 1 | `null` | `[]` | — |
| 2 | `''` | `[]` | — |
| 3 | `'[{"id":1},{"id":2}]'` | `[1, 2]` | — |
| 4 | `'[{"id":1}, 5]'` | `[1]` | skipped corrupt intent (פריט 5 אינו Map) |
| 5 | `'not json'` | `[]` | corrupt queue payload |
| 6 | `'{"a":1}'` | `[]` | corrupt queue payload (‏Map אינו List) |
| 7 | `'[]'` | `[]` | — |

(‏fromJson-הבדיקה: `m['id'] as int`.)

## שקעים
- `fromJson`, `log` — מוזרקים. הבדיקה סופרת קריאות-`log` ומאמתת את הרשימה.

## DoD
```
dart run --enable-asserts new/dart/decode_test.dart  ⇒ exit 0 + "OK decode: N asserts passed"
```
