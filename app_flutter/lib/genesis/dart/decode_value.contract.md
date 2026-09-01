# אטום · `decodeValue`

מוצא: `buildsmart/app_flutter/lib/data/edge/firestore_rest.dart:49-76`

## חתימה
```dart
Object? decodeValue(Map<String, dynamic> value)
Map<String, dynamic> decodeFields(Map<String, dynamic> fields) // מוטבע verbatim
```

## חוזה
מפענח `value`-typed בודד של Firestore-REST חזרה לערך-Dart (ההפך מ-`encodeValue`):

| מפתח | פלט |
|---|---|
| `nullValue` | `null` |
| `booleanValue` | `bool` |
| `integerValue` | `int.tryParse(...) ?? 0` |
| `doubleValue` | `num.toDouble()` |
| `stringValue` | `String` |
| `timestampValue` | `DateTime.tryParse(...)` |
| `arrayValue.values` | `List` (רקורסיבי) |
| `mapValue.fields` | `Map` (דרך `decodeFields`) |
| לא-מוכר | `null` |

## טוהר
טהור-קוֹדֶק, בלי רשת/IO. `decodeFields` הדדי-רקורסיבי עם `decodeValue` — מוטבע verbatim.
