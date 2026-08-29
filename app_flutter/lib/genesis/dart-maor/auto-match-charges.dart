// ⚛️ אטום-Dart (דרגת-חוזה) · autoMatchCharges — שיוך אוטומטי של חיובי-סנכרון לתומכים.
// מוצא: maor/src/lib/nedarimSync.ts:427-448 · המקור: new/atoms/auto-match-charges.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה אינדקס מפתח→supId מכל התומכים (הראשון-במערך גובר על מפתח כפול),
//        ואז לכל חיוב עובר על מפתחות keysOf בסדר-החוזק (ext→id→ph→em) —
//        המפתח הראשון-שנמצא באינדקס מכריע. חיוב בלי-התאמה לא בפלט. סדר-פלט=סדר-חיובים.
// שקע (חוק-1): keysOf({extId?, idNum?, zeout?, phone?, email?}) → List<String>
//        (מפתחות מנורמלים בסדר-חוזק יורד). במקור קריאת-שכן שהוזרקה כפרמטר.
// קלט: charges[] ({toremId?, zeout?, phone?, email?, …}) · supporters[] ({id, extId?, …}) · keysOf.
// פלט: List של {supId, charge} — charge = אותה רפרנס בדיוק של אובייקט-החיוב.
//
// הערות-המרה (מקור→Dart):
//  · אובייקטי-JS (sp, c) ⇒ Map<String, Object?>; גישת-שדה .extId ⇒ ['extId'].
//  · Map.has/get/set של JS ⇒ containsKey/[] של Dart.
//  · truthiness `if (hit)` / `if (supId)` של JS ⇒ `!= null` (ה-supId-ים הם ids
//    לא-ריקים, כך שאין הבדל התנהגותי מול falsy-של-מחרוזת-ריקה).
//  · אין locale/פורמט/getMonth/מוטביליות-בעייתית — var הפכו ל-final היכן שלא-משתנים.

/// Auto-matches sync charges to existing supporters. Verbatim behaviour of the
/// JS source `autoMatchCharges`. `keysOf` is an injected socket returning the
/// normalized match keys (strongest-first) for a given object.
List<Map<String, Object?>> autoMatchCharges(
  List<Map<String, Object?>> charges,
  List<Map<String, Object?>> supporters,
  List<String> Function(Map<String, Object?>) keysOf,
) {
  final idx = <String, Object?>{}; // מפתח → supId (ראשון גובר)
  for (final sp in supporters) {
    for (final k in keysOf({
      'extId': sp['extId'],
      'idNum': sp['idNum'],
      'phone': sp['phone'],
      'email': sp['email'],
    })) {
      if (!idx.containsKey(k)) idx[k] = sp['id'];
    }
  }
  final out = <Map<String, Object?>>[];
  for (final c in charges) {
    Object? supId;
    // סדר keysOf: ext → id → ph → em ⇒ הראשון-שנמצא = המפתח-החזק-ביותר.
    for (final k in keysOf({
      'extId': c['toremId'],
      'zeout': c['zeout'],
      'phone': c['phone'],
      'email': c['email'],
    })) {
      final hit = idx[k];
      if (hit != null) {
        supId = hit;
        break;
      }
    }
    if (supId != null) out.add({'supId': supId, 'charge': c});
  }
  return out;
}
