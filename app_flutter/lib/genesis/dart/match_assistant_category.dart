// ⚛️ אטום-Dart (דרגת-חוזה) · matchAssistantCategory
// תפקיד: מקרקע [reply] לקטגוריית-עוזר אמת — מדויק גובר, אחרת הקטגוריה-הארוכה-ביותר המוכלת; null אם אין.
// מוצא: buildsmart/app_flutter/lib/logic/assistant_intent.dart:60-81 (‏matchAssistantCategory; חוק-4).
// אחים: `assistantCategories()` (קריאה-לשכן) קופלה לשקע-נתון `categories` (חוק-3 — הקבוצה מוזרקת;
//       ההתנהגות זהה בהינתן הרשימה). אין private-אח נוסף.
// טוהר: dart:core בלבד; אפס import, אפס state.

/// מקרקע [reply] לקטגוריה מתוך [categories] (= `assistantCategories()` verbatim).
/// מעבר-מדויק ראשון; אחרת המוכל-הארוך-ביותר (קטגוריה עלולה להיות תת-מחרוזת של אחרת);
/// reply-ריק ⇒ null. verbatim assistant_intent.dart:60-81 (assistantCategories ⇒ שקע).
String? matchAssistantCategory(
  String reply, {
  required List<String> categories,
}) {
  final r = reply.trim();
  if (r.isEmpty) return null;
  final cats = categories;
  for (final c in cats) {
    if (r == c) return c;
  }
  // Longest contained match (a category name may be a substring of a longer one);
  // first-match could grab a shorter prefix category on a wrapped reply.
  String? best;
  for (final c in cats) {
    if (r.contains(c) && (best == null || c.length > best.length)) {
      best = c;
    }
  }
  return best;
}
