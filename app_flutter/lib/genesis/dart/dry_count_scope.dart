// ⚛️ אטום-Dart (דרגת-חוזה) · dryCountScope
// תפקיד: ספירה-יבשה של היקף-שידור (broadcast scope) לפני-בנייה — מרחיב token לרשימת-מזהים,
//        ואם מעל תקרת-האצווה מסרב מוקדם (רשימה-ריקה + סיבת-דחייה עברית). משמע edit_intent (סטודיו).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:484-495 (‏dryCountScope; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שסוקטו: `expandScope(token, registry)` ⇒ שקע `expandScope` (ה-registry נצרך רק שם,
//        לכן נבלע לתוך השקע) · `_batchRejectHe(n)` (בונה סיבת-דחייה עברית) ⇒ שקע `batchRejectHe`
//        (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע; גופו לא הופיע בטיוטה). טיפוס-התוצאה `ScopeCount`
//        (ctor פרטי `._`) הוטבע כ-record inline `({ids, total, rejectedReasonHe})`.
// אחים-שהוטבעו: `kStudioMaxBatch` — ערכו לא הופיע בטיוטה זו; הוסק **25** מהערת-אח
//        (edit_safety.dart draft: "the committed kStudioMaxBatch=25") והוטבע const inline + תועד.
//
// קלט:  token         — טוקן-ההיקף (String).
//       expandScope   — שקע: הרחבת-token לרשימת-מזהים (List<String> Function(String)).
//       batchRejectHe — שקע: בניית סיבת-דחייה עברית מ-n (String Function(int)).
// פלט:  record: `ids` (המזהים, ריק כשנדחה) · `total` (גודל-ההרחבה) · `rejectedReasonHe` (null אם בסדר).

/// Dry-count a broadcast scope: expand [token] to ids; over `kStudioMaxBatch`(=25)
/// ⇒ early refuse (empty ids + Hebrew reason). Verbatim behaviour of
/// edit_intent.dart:484-495 with `expandScope`/`_batchRejectHe` injected.
({List<String> ids, int total, String? rejectedReasonHe}) dryCountScope(
  String token, {
  required List<String> Function(String token) expandScope,
  required String Function(int n) batchRejectHe,
}) {
  const kStudioMaxBatch = 25; // הוסק (ראה כותרת): הערך-הקבוע של אצווה-מרבית באמירה.
  final expanded = expandScope(token);
  if (expanded.length > kStudioMaxBatch) {
    return (
      ids: const <String>[],
      total: expanded.length,
      rejectedReasonHe: batchRejectHe(expanded.length),
    );
  }
  return (ids: expanded, total: expanded.length, rejectedReasonHe: null);
}
