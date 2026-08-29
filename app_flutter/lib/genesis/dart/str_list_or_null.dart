// ⚛️ אטום-Dart (דרגת-חוזה) · strListOrNull
// מוצא: buildsmart/app_flutter/lib/domain/connection_schema.dart:35 (‏_strListOrNull; חוק-4).
//        פרטי-במקור (`_`) — גולגל לאטום top-level, גוף verbatim (הוסרה רק תחילית `_`).
// אחים-שסוקטו: הטיוטה כוללת גם `_numMap` (‏:36-38) ו-`_sizeTable` (‏:39-45) —
//        אטומים נפרדים; **לא** הועתקו לכאן (רק היעד `_strListOrNull` מקודם).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). אין שכנים/const.
//
// קלט:  v — ערך-JSON גולמי כלשהו (Object?).
// פלט:  אם v הוא List ⇒ רק איברי-ה-String שבו (whereType<String>().toList()).
//        אחרת (כולל null / לא-List) ⇒ **null** (הבחנה מ-strList שמחזיר `[]`).

/// The `String` elements of [v] when it is a `List`, else `null`.
/// Verbatim behaviour of connection_schema.dart:35 (the `?`-variant — a MISSING
/// key stays `null`, distinct from an empty-but-present list).
List<String>? strListOrNull(Object? v) =>
    v is List ? v.whereType<String>().toList() : null;
