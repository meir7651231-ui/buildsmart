# חוזה · normHeader

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/data/csv_kernel.dart:32-34

## התנהגות
Header-cell normalization: stray BOMs out, trimmed, lowercased (English
aliases are case-insensitive; Hebrew is untouched by lowercase).

## אימות
בדיקת-Golden (`norm_header_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/norm_header_test.dart`.
