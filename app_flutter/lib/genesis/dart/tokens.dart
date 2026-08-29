// ⚛️ אטום-Dart (דרגת-חוזה) · tokens
// מוצא: buildsmart/app_flutter/lib/logic/equipment_stock_join.dart:42-51 (‏_tokens; חוק-4).
//        פרטי-במקור (`_`) — גולגל לאטום top-level, גוף verbatim (הוסרה רק תחילית `_`).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). אין שכנים/const.
//
// קלט:  normalized — מחרוזת מנורמלת (בד"כ אחרי lower/trim במעלה-הזרם).
// פלט:  מחרוזת-ריקה ⇒ `const []`; אחרת ⇒ פיצול על תו-רווח יחיד `' '` (split).
//        `split(' ')` **שומר** אסימונים-ריקים (רווח-כפול/רווח-מוביל ⇒ '' באמצע/בקצה).

/// Whitespace-split of [normalized] into tokens; empty string ⇒ empty list.
/// Verbatim behaviour of equipment_stock_join.dart:42-51 (`split(' ')` — NO
/// empty-token collapsing; the caller normalises spacing upstream).
List<String> tokens(String normalized) =>
    normalized.isEmpty ? const [] : normalized.split(' ');
