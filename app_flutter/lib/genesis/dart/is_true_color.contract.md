# חוזה · isTrueColor

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/features/word_finder/color_truth.dart:23-27

## התנהגות
Whether [color] is a genuine colour (in [kTrueColors]) rather than a metal
finish miscoded into the catalog's colour field.

## אימות
בדיקת-Golden (`is_true_color_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/is_true_color_test.dart`.
