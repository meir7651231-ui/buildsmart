// ⚛️ אטום-Dart (דרגת-חוזה) · batchRejectHe
// תפקיד: הודעת-דחייה עברית ל-scope רחב-מדי (מעל תקרת-האצווה).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:456-457 (‏_batchRejectHe; פרטי-במקור; חוק-4).
// אחים: ה-const-האח `kStudioMaxBatch` (מודול-חיצוני, אינו בטיוטה) הופך לשקע `maxBatch`
//       (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע; כדפוס branch_label/letters). ערך-המקור לא נגיש ⇒ שקע.
// טוהר: dart:core בלבד.

/// הודעת-דחייה: '$count יעדים (מעל התקרה $maxBatch)'. verbatim edit_intent.dart:456-457.
String batchRejectHe(int count, {required String Function(String) term, required int maxBatch}) =>
    '${term('hshynvy-nrchb-mdy')}$count${term('yadym-mal-htkrh')}$maxBatch${term('tsmtsm-at-htvvch')}';
