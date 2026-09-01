# חוזה · splitCsvLine

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/data/repositories/supplier_onboarding.dart:214-232

## התנהגות
Split ONE CSV line, honouring `"quoted, fields"` (a comma inside quotes is data).

## אימות
בדיקת-Golden (`split_csv_line_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/split_csv_line_test.dart`.
