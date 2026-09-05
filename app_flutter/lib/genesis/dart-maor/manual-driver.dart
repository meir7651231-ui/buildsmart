// ⚛️ אטום-Dart (דרגת-חוזה) · manualDriver — הנהג-הידני (קישור-חיוג tel:).
// מוצא: maor/src/lib/telephony/driver.ts (הוטמע ממקור tel.ts) · המקור: new/atoms/manual-driver.mjs
// טוהר: top-level נקי, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: אובייקט-נהג קבוע (id/label/capabilities) + callHref שמייצר קישור-חיוג
//        מטלפון-שמור דרך telHref: מנקה לספרות/‎+‎; אם נותרו <6 ספרות ⇒ null.
//
// הערות-המרה (מקור→Dart · תוקן מטיוטת-המנוע):
//   • המנוע פלט replaceFirst — שגוי: JS `.replace(/…/g,'')` הוא **גלובלי** ⇒ replaceAll.
//     (בלי זה '050-123-4567' היה מוריד רק את המקף-הראשון.)
//   • ‏callHref נשמר כערך-פונקציה במפה (כמו במקור); JSON.stringify משמיט פונקציות,
//     לכן הצילום לא כולל אותו — נשמר זהה בבדיקת-הזהב.
//   • ‏`phone || ''` של JS ⇒ `phone ?? ''` (הקלט מוקלד String?); אין locale/getMonth/מוטביליות.

/// קישור-חיוג מטלפון שמור: מנקה לספרות/‎+‎; קצר-מדי (<6 ספרות) ⇒ null.
/// התנהגות-verbatim של telHref במקור-ה-JS.
String? telHref(String? phone, Map<String, String> T) {
  final cleaned = (phone ?? '').replaceAll(RegExp(r'[^\d+]'), '');
  final digits = cleaned.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 6) return null; // קצר מדי = לא מספר-חיוג תקין
  return T['k1']! + cleaned;
}

/// בורר-הנהג הפעיל — כרגע ידני-בלבד (downstream). callHref = ערך-פונקציה (כמו במקור).
/// מפעל-T (הכרעה 16) — מקביל ל-makeManualDriver(T) בצד-ה-JS.
Map<String, dynamic> makeManualDriver(Map<String, String> T) => {
  'id': T['k2']!,
  'label': T['k3']!,
  'capabilities': {'autoDial': false, 'record': false, 'screenPop': true},
  'callHref': (String? phone) => telHref(phone, T),
};
