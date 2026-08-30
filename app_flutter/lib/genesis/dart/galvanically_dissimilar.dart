// ⚛️ אטום-Dart (דרגת-חוזה) · galvanicallyDissimilar
// מוצא: install_engine.dart:158-164 (origin/main — ‏_galvanicallyDissimilar; חוק-4, verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט — Set.intersection).
//       שתי קבוצות-החומרים (copperGroup/ironGroup) = דאטה-קבוע פנימי (מונחי-חומר, לא סוד).
//
// אין שקע: הפונקציה טהורה לחלוטין — קלט Iterable<String> של תוויות-חומר, פלט bool.
//
// התנהגות (מקור:158-164): קורוזיה גלוונית מחייבת רקורד-דיאלקטרי **רק** בין קבוצות-
//   מתכת שונות: קבוצת-נחושת (נחושת/פליז) מול קבוצת-ברזל (פלדה/נירוסטה). מפגש
//   באותה-קבוצה (נחושת↔פליז) בטוח-גלוונית ואסור לסמן. מחזיר true רק כששתי הקבוצות
//   נוכחות ב-[mats]. (מתקן את הקודמת שדרשה 'נחושת' ספציפית — פספסה פליז↔פלדה —
//   והשמיטה נירוסטה כליל.)
//
// קלט:  mats — Iterable<String> של תוויות-חומר (HDPE/PEX/נחושת/פליז/פלדה/נירוסטה…).
// פלט:  bool — האם יש חצייה בין קבוצת-נחושת לקבוצת-ברזל.

/// True only when [mats] contains BOTH a copper-group metal (נחושת/פליז) and an
/// iron-group metal (פלדה/נירוסטה) — verbatim install_engine.dart:158-164.
bool galvanicallyDissimilar(Iterable<String> mats, {required String Function(String) term}) {
  final copperGroup = {term('nchvsht'), term('plyz')};
  final ironGroup = {term('pldh'), term('nyrvsth')};
  final s = mats.toSet();
  return s.intersection(copperGroup).isNotEmpty &&
      s.intersection(ironGroup).isNotEmpty;
}
