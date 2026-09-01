# חוזה · `strList` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/trade_schema.dart:36-37` (`_strList`).

## תפקיד
מפענח-סובלני של רשימת-מחרוזות מ-JSON-חופשי: מחזיר את איברי-המחרוזת של רשימה
(שאר-הטיפוסים נשמטים), רשימה-ריקה כשהקלט אינו רשימה. לעולם לא זורק (סמנטיקת
המפענחים-הסובלניים ב-trade_schema.dart:31-42 — "missing/wrong type → default").

## חתימה
```dart
List<String> strList(Object? v)
```

## התנהגות (עוגן trade_schema.dart:36-37)
`v is List ? v.whereType<String>().toList() : const []`
- הקלט אינו `List` (null · num · String · Map · bool) ⇒ **`const []`**.
- הקלט `List` ⇒ `whereType<String>()` — מסנן לאיברי-`String` בלבד, **בסדר-המקור**,
  ואז `.toList()`. איברים לא-מחרוזתיים (num/null/Map/List-מקונן) נשמטים בשקט.

## דוגמאות-מחייבות
| # | v | ⇒ |
|---|---|---|
| 1 | `null` | `[]` |
| 2 | `['a','b','c']` | `['a','b','c']` |
| 3 | `['a', 1, 'b', null, 'c']` | `['a','b','c']` (לא-מחרוזת נשמט) |
| 4 | `[]` | `[]` |
| 5 | `[1, 2, 3]` | `[]` (אין מחרוזות) |
| 6 | `'abc'` (String, לא List) | `[]` |
| 7 | `42` | `[]` |
| 8 | `{'a':'b'}` (Map) | `[]` |
| 9 | `['', 'x']` | `['', 'x']` (מחרוזת-ריקה היא String תקין) |
| 10 | `['a', ['b'], 'c']` | `['a','c']` (List-מקונן נשמט) |

## שקעים
אין (dart:core בלבד — `List.whereType`/`Iterable.toList`).

## DoD
```
dart run --enable-asserts new/dart/str_list_test.dart  ⇒ exit 0 + "OK strList: N asserts passed"
```
