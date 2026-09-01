# חוזה · pressureFromDims

- **מוצא:** `buildsmart/app_flutter/lib/data/polyroll_specs.dart:128-137` (הפונקציה הפרטית `_pressureFromDims`).
- **חתימה:** `String? pressureFromDims(LipskeyCatalogProduct p)`
- **התנהגות (חוק-4, verbatim):** קורא `p.dims?['PN']?.toString()`; אם לא-null ולא-ריק ⇒ `'PN$pn'`, אחרת null.
- **טוהר:** אפס import. `LipskeyCatalogProduct` הוטבע מ-`lipskey_catalog.dart:4` עם השדה היחיד הנקרא (`dims`).
- **אימות:** `dart analyze` נקי + `dart run --enable-asserts pressure_from_dims_test.dart` עובר.
