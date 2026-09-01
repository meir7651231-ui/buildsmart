# חוזה · csvIsComment

- **מוצא:** `buildsmart/app_flutter/lib/data/csv_kernel.dart:39-43`.
- **חתימה:** `bool csvIsComment(List<String> cells)`
- **התנהגות (חוק-4, verbatim):** `cells.isNotEmpty && cells.first.trimLeft().startsWith('#')` — האם התא הראשון (לאחר קיצוץ רווחים משמאל) פותח ב-'#'. רשומה ריקה ⇒ false.
- **טוהר:** אפס import.
- **אימות:** `dart analyze` נקי + `dart run --enable-asserts csv_is_comment_test.dart` עובר.
