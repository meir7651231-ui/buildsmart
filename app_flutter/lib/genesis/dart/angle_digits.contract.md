# חוזה · angleDigits

- **מוצא:** `buildsmart/app_flutter/lib/features/catalog_config/product_chips.dart:256-263` (הפונקציה הפרטית `_angleDigits`).
- **חתימה:** `String angleDigits(String s)`
- **התנהגות (חוק-4, verbatim):** `RegExp(r'\d+').firstMatch(s)?.group(0) ?? s` — רצף-הספרות הראשון במחרוזת, או המחרוזת המקורית כשאין ספרות.
- **טוהר:** אפס import (רק `RegExp` מ-dart:core).
- **אימות:** `dart analyze` נקי + `dart run --enable-asserts angle_digits_test.dart` עובר.
