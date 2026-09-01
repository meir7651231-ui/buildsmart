// ⚛️ אטום-Dart (דרגת-חוזה) · invoiceTitle
// תפקיד: כותרת-מסמך — 'קבלה — <id>' כאשר receipt=true, אחרת 'חשבונית — <id>'.
// מוצא: buildsmart/app_flutter/lib/logic/invoice.dart:45-47 (‏invoiceTitle; חוק-4 — verbatim).
//        ⚠️ קובץ-המקור נמחק מהעץ-החי (find ריק 2026-08-26) — הטיוטה במחצב היא מקור-האמת.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). הקריאה-לשכן `order.id` (קריאת-שדה
//        מטיפוס Order הגדול) קופלה לשקע `orderId` (חוק-3) — Order לא-inline. אינטרפולציה = שפה/סטנדרט.
//
// קלט:  orderId — שקע: מזהה-ההזמנה (במקור `order.id`).
//        receipt — האם קבלה (true) או חשבונית (false).
// פלט:  String — `'קבלה — <orderId>'` או `'חשבונית — <orderId>'` (מפריד = מקף-אם ' — ').

/// Invoice/receipt document title. Verbatim of invoice.dart:45-47 with `order.id`
/// injected as the `orderId` socket (law-3; Order is a large neighbour type).
String invoiceTitle(String orderId, {required String Function(String) term, required bool receipt}) =>
    '${receipt ? term('kblh') : term('chshbvnyt')} — $orderId';
