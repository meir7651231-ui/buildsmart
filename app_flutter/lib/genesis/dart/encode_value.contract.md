# אטום · `encodeValue`

מוצא: `buildsmart/app_flutter/lib/data/edge/firestore_rest.dart:27-48`

## חתימה
```dart
Map<String, dynamic> encodeValue(Object? v)
Map<String, dynamic> encodeFields(Map<String, Object?> data) // מוטבע verbatim
```

## חוזה
מקודד ערך-Dart בודד ל-`value`-typed של Firestore-REST:

| Dart | פלט |
|---|---|
| `null` | `{nullValue: null}` |
| `bool` | `{booleanValue: v}` |
| `int` | `{integerValue: "v"}` (מחרוזת — חוזה ה-API) |
| `double` | `{doubleValue: v}` |
| `String` | `{stringValue: v}` |
| `DateTime` | `{timestampValue: ISO8601-UTC}` |
| `List` | `{arrayValue:{values:[...]}}` (רקורסיבי) |
| `Map` | `{mapValue:{fields:{...}}}` (דרך `encodeFields`) |
| אחר | `{stringValue: v.toString()}` (שמרני — לא זורק) |

## טוהר
טהור-קוֹדֶק, בלי רשת/IO (הרשת מופרדת במקור). `encodeFields` הדדי-רקורסיבי עם
`encodeValue` — מוטבע verbatim.
