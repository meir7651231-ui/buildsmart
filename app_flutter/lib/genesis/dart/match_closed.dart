// ⚛️ אטום-Dart (דרגת-חוזה) · matchClosed
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:180-200 (`_matchClosed`;
//        פרטי-במקור; חוק-4 — התנהגות זהה). מקדם `_matchClosed` ⇒ `matchClosed`.
// דדופ (הכרעה-5): גוף-קוד זהה-ביט מופיע גם ב-registry_view.dart:237-259 (רק ההערות שונות) —
//        אטום-אחד, שני-מקורות. העוטפים matchElementId/matchPropKey/matchValue/matchActionId/
//        matchComponentType (registry_view.dart:272-294) הם חיווט-קופסה מעל האטום (שקע=הקבוצה).
// טוהר: פונקציית top-level עצמאית, dart:core בלבד — אפס import, אפס שקע, אפס שכן.
//
// תפקיד: פותר-קבוצה-סגורה — ממפה תשובת-מודל חופשית ל-מפתח-אמת יחיד מתוך קבוצה-סגורה,
//        או null (fail-closed). מדויק-קודם, ואז המוכל-הארוך-ביותר (מפתח קצר שהוא תת-מחרוזת
//        של ארוך לא יאפיל על האמת). לעולם לא זורק.
//
// קלט:  closed — הקבוצה-הסגורה של המפתחות-האמיתיים (Set<String>).
//       reply  — תשובת-המודל החופשית (String).
// פלט:  מפתח-מתוך-closed (String) או null.
String? matchClosed(Set<String> closed, String reply) {
  final r = reply.trim();
  if (r.isEmpty) return null; // early guard — תשובה-ריקה נכשלת-סגור.
  // מדויק מנצח מיידית — קצר-מסך-קצר לפני סריקת-המוכל, כך שמפתח-מדויק-קצר לא מואפל
  // ע"י מפתח-ארוך שרק מכיל אותו.
  for (final k in closed) {
    if (r == k) return k;
  }
  // מוכל-הארוך-ביותר (המודל עשוי לעטוף במרכאות/פרוזה). מפתחות רבים הם תחיליות של
  // אחרים (faucet⊂kitchenFaucet); התאמה-ראשונה הייתה תופסת את התחילית הקצרה — הפגם-המרכזי.
  String? best;
  for (final k in closed) {
    if (k.isNotEmpty &&
        r.contains(k) &&
        (best == null || k.length > best.length)) {
      best = k;
    }
  }
  return best;
}
