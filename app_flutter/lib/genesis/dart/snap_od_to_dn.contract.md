# חוזה · snapOdToDn

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/features/catalog_config/dn_scale.dart:37-56

## התנהגות
Snap an outer-diameter magnitude to the nearest [kDnRungs] step.

## אימות
בדיקת-Golden (`snap_od_to_dn_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/snap_od_to_dn_test.dart`.
