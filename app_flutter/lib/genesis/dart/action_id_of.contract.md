# חוזה · `actionIdOf` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:287-302` (‏`_actionIdOf`).

## תפקיד
חילוץ מזהה-פעולה ממפה-op מפוענחת: `m['action']` כ-String לא-ריק (מקוצץ), או כ-Map עם `kind` String לא-ריק (מקוצץ); אחרת null.

## חתימה
```dart
String? actionIdOf(Map<String, dynamic> m)
```

## התנהגות (עוגן edit_intent.dart:287-302)
- `a is String` ⇒ `t=a.trim()`; `t.isEmpty ? null : t`.
- `a is Map` ⇒ `k=a['kind']`; `k is String && k.trim().isNotEmpty ? k.trim() : null`.
- אחרת ⇒ null.

## דוגמאות-מחייבות
| # | m | ⇒ |
|---|---|---|
| 1 | {action:'setText'} | 'setText' |
| 2 | {action:'  pad  '} | 'pad' |
| 3 | {action:''} | null |
| 4 | {action:'   '} | null |
| 5 | {action:{kind:' k '}} | 'k' |
| 6 | {action:{kind:'  '}} | null |
| 7 | {action:{x:1}} | null |
| 8 | {action:{kind:5}} | null |
| 9 | {} | null |
| 10 | {action:42} | null |

## שקעים
אין.

## DoD
```
dart run --enable-asserts new/dart/action_id_of_test.dart  ⇒ exit 0 + "OK actionIdOf: 10 asserts passed"
```
