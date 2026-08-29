// ⚛️ אטום-Dart (דרגת-חוזה) · softBatchWarnHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:373-376 (חוק-4).
//        האטום = הפונקציה בלבד; שאר-הטיוטה (‏_reasonToBlock) אינו היעד.
//        קובץ-המקור אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: dispatch טהור. הספים `kStudioSoftBatchWarn`/`kStudioMaxBatch` const-שכנים
//        לא-ניתנים-לשחזור (הקובץ נעלם + grep ריק) ⇒ הורמו לשקעים בשם (חוק-3),
//        ברירות-מחדל מוסקות מהשם ("soft warn" נמוך, "max batch" גבוה) ומתועדות.
//
// קלט:  opCount — מספר הפעולות באצווה.
// פלט:  אזהרה עברית **רק** בטווח `[softWarn, maxBatch]` (כולל שני-הקצוות); אחרת null.

/// The soft-batch advisory: a non-null Hebrew warning IFF
/// `softWarn <= opCount <= maxBatch` (both bounds inclusive), else `null`.
/// Verbatim behaviour of edit_safety.dart:373-376 with the two thresholds
/// injected (their literal values are unrecoverable — inferred defaults).
String? softBatchWarnHe(
  int opCount, {required String Function(String) term, 
  int softWarn = 5,
  int maxBatch = 20,
}) =>
    (opCount >= softWarn && opCount <= maxBatch)
        ? '${term('shym-lb')}$opCount${term('pavlvt-bbt-acht-apshr-lhmshyk-av-ltsmtsm')}'
        : null;
