# חוזה · stringField

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/config/org_config.dart:242-245

## התנהגות
A string field: a String rides, anything else drops to '' (per-field
tolerance — a garbled slug never costs its siblings).

## אימות
בדיקת-Golden (`string_field_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/string_field_test.dart`.
