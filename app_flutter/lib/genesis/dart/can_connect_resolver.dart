// ⚛️ אטום-Dart (דרגת-חוזה) · canConnectResolver
// מוצא: buildsmart/app_flutter/lib/domain/connection_resolver.dart:211-222
//        (‏ConnectionResolver.canConnect — ה-resolver מונחה-החוקות; חוק-4 — verbatim).
//        ⚠️ הקובץ אינו בעץ-העבודה של buildsmart — חולץ מ-git (‏b4cdcefd ≡
//        origin/claude/align-main, ‏md5 ‏0b34f3fa… — אותו עוגן כמו end_pair*).
// שם-מובחן (מסלול-4): ‏can_connect.dart הקיים = install_engine.dart:498-521 —
//        גוף אחר-מהותית (bool, ‏name-inference); כאן ה-canConnect של ה-resolver
//        (‏ConnectResult, איטרציית-ends) ⇒ ‏can_connect_resolver. לא-כפול.
// טוהר: פונקציית top-level גנרית, אפס import, אפס סטייט — הכול מוזרק.
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • `_endPairMemoized(endA, endB)` (‏:215) ⇒ שקע `endPairMemoized` — מעריך-
//     הזוג-הממוטמן של הקופסה (האטום-האח end_pair_memoized.dart + end_pair.dart).
//   • `_noRule` (‏:197-198 — const ConnectResult(mates:false, methodLabelHe:''))
//     ⇒ שקע `noRule` — R גנרי אינו נושא const; הקופסה מזריקה את הערך.
//   • `a.ends` / `b.ends` ⇒ שקע-ריאדר `ends` · ‏`r.mates` / `r.severity != null`
//     (‏:216-217) ⇒ שקעי-ריאדר `mates` / `hasMissSeverity`
//     (התקדים: end_pair_memoized.dart — S/E/R גנריים, אפס טיפוס-מוטבע).
//
// קלט:  a, b — שני מפרטי-המוצר (S גנרי) · ends · endPairMemoized · mates ·
//       hasMissSeverity · noRule.
// פלט:  R — התוצאה ה-mating-הראשונה; אחרת ה-miss-הראשון (severity!=null);
//       אחרת noRule. ‏ends ריק ⇒ noRule, אפס קריאות-שקע.

/// ‏connection_resolver.dart:211-222 verbatim: ‏a.ends חיצוני, ‏b.ends פנימי,
/// ה-mate הראשון מנצח ומוחזר מיד; ‏size-miss ראשון נלכד פעם-אחת; אף חיבור ⇒
/// ‏`firstMiss ?? noRule` — "לא מתחבר" מתועד, לעולם-לא-חריגה (‏:207-210).
R canConnectResolver<S, E, R>(
  S a,
  S b, {
  required List<E> Function(S) ends,
  required R Function(E endA, E endB) endPairMemoized,
  required bool Function(R) mates,
  required bool Function(R) hasMissSeverity,
  required R noRule,
}) {
  R? firstMiss;
  for (final endA in ends(a)) {
    for (final endB in ends(b)) {
      final r = endPairMemoized(endA, endB);
      if (mates(r)) return r;
      if (firstMiss == null && hasMissSeverity(r)) firstMiss = r;
    }
  }
  return firstMiss ?? noRule;
}
