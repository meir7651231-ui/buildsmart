# חוזה · csvIsBlank

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/data/csv_kernel.dart:35-38

## התנהגות
A record whose every cell is whitespace — importers skip it silently.

## אימות
בדיקת-Golden (`csv_is_blank_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/csv_is_blank_test.dart`.
