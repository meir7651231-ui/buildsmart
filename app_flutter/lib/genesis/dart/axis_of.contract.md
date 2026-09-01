# חוזה · `axisOf` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:218-230` (‏`_axisOf`).

## תפקיד
מיפוי סוג-ConfigOp לצַיר-העריכה שלו (מחרוזת).

## חתימה
```dart
String axisOf(ConfigOp op)   // ConfigOp sealed: SetText/SetEmoji/SetHidden/SetOrder/SetStyle/SetAction (מוטבע inline)
```

## התנהגות (עוגן edit_intent.dart:218-230)
switch לפי-טיפוס: SetText⇒'text' · SetEmoji⇒'emoji' · SetHidden⇒'hidden' · SetOrder⇒'order' · SetStyle⇒'style' · SetAction⇒'action'.

## דוגמאות-מחייבות
| # | op | ⇒ |
|---|-----|---|
| 1 | SetText() | 'text' |
| 2 | SetEmoji() | 'emoji' |
| 3 | SetHidden() | 'hidden' |
| 4 | SetOrder() | 'order' |
| 5 | SetStyle() | 'style' |
| 6 | SetAction() | 'action' |

## שקעים
אין (היררכיית ConfigOp הוטבעה inline כמחלקות-סמן; השדות המקוריים לא נדרשים ל-switch לפי-טיפוס).

## DoD
```
dart run --enable-asserts new/dart/axis_of_test.dart  ⇒ exit 0 + "OK axisOf: 6 asserts passed"
```
