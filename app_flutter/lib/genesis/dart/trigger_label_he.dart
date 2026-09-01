// ⚛️ אטום-Dart (דרגת-חוזה) · triggerLabelHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:436-443 (חוק-4 — לוגיקה verbatim).
// אח-שהוזרק (חוק-3/דיבר-3): ה-const-list `kRuleTriggers` (נסרקת בלולאה, :437) הופכה
//        לשקע-פרמטר `triggers`. כל איבר נקרא רק דרך `.id` / `.labelHe` ⇒ הוטבע כ-record
//        `({String id, String labelHe})` (טיפוס-שכן-קטן ⇒ הטבעה inline, לא BLOCKED).
//        ערכי-kRuleTriggers עצמם אינם בטיוטה (מקור נעדר) ⇒ שקע, הבדיקה מזריקה נציגים.
//
// קלט:  id       — מזהה-טריגר/שדה-תנאי לחיפוש (String).
//       triggers — שקע: רשימת (id, labelHe) בסדר.
// פלט:  labelHe של האיבר הראשון ש-id-שלו שווה; אם אין ⇒ ה-id הגולמי (fallback).

/// Hebrew label for trigger/condition-field [id], or the raw [id] when absent.
/// Verbatim behaviour of rules_model.dart:436-443 with `kRuleTriggers` injected.
String triggerLabelHe(
  String id, {
  required List<({String id, String labelHe})> triggers,
}) {
  for (final t in triggers) {
    if (t.id == id) return t.labelHe;
  }
  return id;
}
