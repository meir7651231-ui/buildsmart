// ⚛️ אטום-Dart (דרגת-חוזה) · matchAllClosed
// תפקיד: מחזיר את *כל* המפתחות מקבוצה-סגורה [closed] המוכלים ב-[reply] (לא רק הטוב-ביותר) —
//        הליבה-הטהורה ל-addition-a. ריק/אין-התאמה ⇒ קבוצה-ריקה; רק מפתחות-אמת לא-ריקים; לעולם לא זורק.
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:261-271 (‏_matchAllClosed; חוק-4).
// אחים: אין. private-במקור (`_matchAllClosed`) קודם לפונקציה top-level ציבורית `matchAllClosed`.
//       אפס-שקע: [closed] פרמטר-נתון.
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס-שכן.

/// כל מפתח מ-[closed] המוכל ב-[reply] (לא-רק-הטוב). reply-ריק ⇒ קבוצה-ריקה;
/// רק מפתחות לא-ריקים. verbatim registry_view.dart:261-271.
Set<String> matchAllClosed(Set<String> closed, String reply) {
  final r = reply.trim();
  if (r.isEmpty) return const <String>{};
  return {
    for (final k in closed)
      if (k.isNotEmpty && r.contains(k)) k,
  };
}
