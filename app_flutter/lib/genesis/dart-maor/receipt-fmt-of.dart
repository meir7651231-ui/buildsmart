// ⚛️ אטום-Dart (דרגת-חוזה) · receiptFmtOf — הפורמט האפקטיבי למסירת-קבלה.
// מוצא: maor/src/lib/receipt.ts:234-237 · המקור: new/atoms/receipt-fmt-of.mjs —
//   `export function receiptFmtOf(config, ui, featureOn){
//      return featureOn(config, 'core.receipt.pdf') ? ui.receiptFmt : undefined; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: הבחירה השמורה של פורמט-הקבלה (ui.receiptFmt) מוחזרת רק כשדגל
//   'core.receipt.pdf' דלוק; כבוי ⇒ undefined (מתג-חירום), בלי לגעת בבחירה השמורה.
// שקעים (חוק-1+חוק-5 — השכן featureOn של מנוע-הדגלים הוזרק כפרמטר):
//   featureOn(config, key) ⇒ bool — האם הדגל דלוק (במקור featureOn מהקונפיג).
// קלט: config (מועבר כלשונו ל-featureOn) · ui (מילון עם receiptFmt?) · featureOn.
// פלט: dynamic — הבחירה (ui['receiptFmt']) כשדלוק; null (≡undefined) כשכבוי או חסרה בחירה.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • כלל-2 (null≠undefined): ב-JS `ui.receiptFmt` על {} = undefined; ב-Dart
//     `ui['receiptFmt']` על מילון-ריק = null — שתיהן falsy/היעדר, מיפוי נאמן.
//   • כלל-7 (truthiness): featureOn מחזיר bool בחוזה ⇒ `? :` ישיר, אפס _falsy.
//   • undefined של JS ⇒ null ב-Dart (ערך-ההיעדר של השפה).
//   • אפס locale/פורמט/getMonth/מודולו/מוטביליות — הבחירה השמורה נקראת, לא נכתבת.

/// Effective receipt-delivery format: returns the saved choice [ui]['receiptFmt']
/// only when the 'core.receipt.pdf' flag is on (via [featureOn]); off ⇒ null
/// (emergency switch), without mutating the saved choice.
/// Verbatim behaviour of the JS source `receiptFmtOf`.
dynamic receiptFmtOf(
  dynamic config,
  Map ui,
  bool Function(dynamic config, String key) featureOn,
) {
  return featureOn(config, 'core.receipt.pdf') ? ui['receiptFmt'] : null;
}
