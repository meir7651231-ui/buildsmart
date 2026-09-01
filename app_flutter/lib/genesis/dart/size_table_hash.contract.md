# חוזה · `sizeTableHash` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_schema.dart:60`
(‏`_sizeTableHash`). ה-data-classes השכנות (‏`ConnectorType`, `SystemDef`) אינן היעד.

## חתימה
```dart
int sizeTableHash(List<List<String>>? t)
```

## קלט
- `t` — טבלת-מידות, `List<List<String>>?` (nullable).

## פלט / התנהגות (עוגני-שורה)
- `connection_schema.dart:60` — `t == null ? 0 : Object.hashAll(t.map(Object.hashAll))`:
  - `null` ⇒ `0` (מַשְׂכֵּן-null יציב).
  - אחרת ⇒ `Object.hashAll` על רצף גיבובי-השורות, כל שורה `Object.hashAll` משלה.
- **רגיש-לסדר** (חיצוני ופנימי): החלפת סדר-שורות או סדר-איברים-בשורה ⇒ גיבוב אחר.
- **דטרמיניזם בתוך-ריצה בלבד:** `Object.hashAll` מערבב seed **אקראי פר-איזולט** ⇒ הערך
  המספרי אינו יציב בין תהליכים (נצפה: `[]` נתן `368148618` בריצה אחת ו-`292644716`
  באחרת). לכן החוזה מאפיין **יחסים**, לא goldens קבועים.

## דוגמאות (יחסיות — נבדקות בתוך אותה ריצה)
| # | t | ⇒ |
|---|---|---|
| 1 | `null` | `0` (מסלול ללא-גיבוב, יציב מוחלט) |
| 2 | `[['1/2','3/4']]` פעמיים | אותו int (דטרמיניזם-בתוך-ריצה) |
| 3 | `[['1/2','3/4']]` vs `[['3/4','1/2']]` | **שונה** (רגישות סדר-איברים) |
| 4 | `[['1/2','3/4']]` vs `[['1/2'],['3/4']]` | **שונה** (רגישות מבנה-שורות) |
| 5 | `[]` פעמיים | אותו int (יציב-בתוך-ריצה) |

## שקעים
- אין. עצמאי (חוק-1). `Object.hashAll`, `Iterable.map` = dart:core.

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/size_table_hash.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/size_table_hash_test.dart  ⇒ exit 0 + "OK sizeTableHash: N asserts passed"
```
