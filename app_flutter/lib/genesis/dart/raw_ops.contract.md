# חוזה · `rawOps` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:303-313`
(‏`_rawOps`, פרטי-במקור ⇒ פורסם `rawOps`, כלל-הגלגול). אפס שקע — אטום טהור מעל
`dart:core` (List/Map).

## חתימה
```dart
List<Object?> rawOps(Object? decoded)
```

## קלט
- `decoded` — `Object?`. בד"כ תוצאת `jsonDecode` (List / Map / null / מספר / מחרוזת).

## פלט / התנהגות (עוגני-שורה)
- `edit_intent.dart:304` — `if (decoded is List) return decoded;` — רשימה עוברת כמות-שהיא.
- `edit_intent.dart:305-310` — `decoded is Map`:
  - `ops = decoded['ops']`; `if (ops is List) return ops;` — מחזיר את רשימת-`ops`.
  - אחרת `if (decoded['op'] != null) return <Object?>[decoded];` — אובייקט-פעולה-בודד
    עטוף ברשימה בת-איבר-אחד.
- `edit_intent.dart:312` — `return const <Object?>[];` — כל שאר המקרים.
- **סדר-הכרעה מהמקור:** List גובר; בתוך Map — `ops` (אם רשימה) גובר על `op`;
  Map ריק / ללא-`ops`-רשימה / `op == null` ⇒ ריק.

## דוגמאות מספריות
| # | decoded | ⇒ |
|---|---------|---|
| 1 | `[1, 2, 3]` | `[1, 2, 3]` (רשימה-ישירה) |
| 2 | `{'ops': [4, 5]}` | `[4, 5]` (רשימת-ops) |
| 3 | `{'op': 'x', 'v': 1}` | `[{'op': 'x', 'v': 1}]` (פעולה-בודדת עטופה) |
| 4 | `{'foo': 1}` | `[]` (מפה ללא ops/op) |
| 5 | `42` | `[]` (לא List ולא Map) |
| 6 | `null` | `[]` |

## עדשה-עוינת
| # | decoded | ⇒ | הסבר |
|---|---------|---|------|
| 7 | `[]` | `[]` | רשימה-ריקה עוברת (זהות-הפניה — אותה רשימה) |
| 8 | `{'ops': [], 'op': 1}` | `[]` | `ops` הוא List (ריק) ⇒ גובר, מוחזר ריק **לפני** בדיקת `op` |
| 9 | `{'ops': 'notalist'}` | `[]` | `ops` אינו List; `op` הוא null ⇒ נופל ל-const [] |
| 10 | `{'op': null}` | `[]` | `op == null` ⇒ לא עוטף |
| 11 | `{'op': false}` | `[{'op': false}]` | `false != null` ⇒ עוטף (רק null מסונן) |

## שקעים
- אין. List/Map/is — שפה (`dart:core`).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/raw_ops.dart                    ⇒ "No issues found!"
dart run --enable-asserts new/dart/raw_ops_test.dart  ⇒ exit 0 + "OK rawOps: N asserts passed"
```
