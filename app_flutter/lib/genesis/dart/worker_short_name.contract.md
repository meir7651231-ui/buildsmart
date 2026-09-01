# חוזה · workerShortName

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/data/persona_data.dart:159-161

## התנהגות
Display name — `שלום, {name}` strips the trailing ` (עובד)` (§4.2).

## אימות
בדיקת-Golden (`worker_short_name_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/worker_short_name_test.dart`.
