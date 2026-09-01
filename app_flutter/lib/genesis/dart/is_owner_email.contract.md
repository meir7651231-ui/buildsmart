# חוזה · isOwnerEmail

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/data/board_accounts_local.dart:102-104

## התנהגות
True when [email] (trimmed, case-insensitive) is an owner account allowed to
enter the manager board. Pure → unit-testable.

## אימות
בדיקת-Golden (`is_owner_email_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/is_owner_email_test.dart`.
