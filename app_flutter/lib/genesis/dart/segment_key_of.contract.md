# חוזה · `segmentKeyOf` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/intel/segments.dart:43-49`
(‏`segmentKeyOf`). שאר-הטיוטה (‏`ActorSegment`, `segmentsByActor`, `retentionCohorts`)
אינו היעד. הקובץ אינו קיים עוד ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
String segmentKeyOf({String? uid, String? actorKey, String anonymousKey = 'anonymous'})
```

## שקעים (חוק-3)
- `uid` / `actorKey` — שני-השדות מ-`IntelEvent` (טיפוס-שכן גדול, פורק לשדות).
- `anonymousKey` — `kAnonymousSegmentKey` (const-שכן לא-ניתן-לשחזור; ברירת-מחדל מייצגת).

## פלט / התנהגות (עוגני-שורה)
- `segments.dart:44-45` — `uid != null && uid.isNotEmpty` ⇒ `uid`.
- `:46-47` — אחרת `actorKey != null && actorKey.isNotEmpty` ⇒ `actorKey`.
- `:48` — אחרת ⇒ `anonymousKey`.
- ריק (`''`) נחשב כחסר (`isNotEmpty` שקר) ⇒ ממשיך לשלב הבא.

## דוגמאות (anonymousKey='anonymous')
| # | uid | actorKey | ⇒ |
|---|-----|----------|---|
| 1 | `'u1'` | `'a1'` | `'u1'` (uid מנצח) |
| 2 | `null` | `'a1'` | `'a1'` |
| 3 | `''` | `'a1'` | `'a1'` (uid ריק ⇒ מדולג) |
| 4 | `null` | `null` | `'anonymous'` |
| 5 | `''` | `''` | `'anonymous'` (שניהם ריקים) |
| 6 | `'u1'` | `null` | `'u1'` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/segment_key_of.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/segment_key_of_test.dart  ⇒ exit 0 + "OK segmentKeyOf: N asserts passed"
```
