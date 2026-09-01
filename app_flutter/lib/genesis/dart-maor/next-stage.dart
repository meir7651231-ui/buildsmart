// ⚛️ אטום-Dart (דרגת-חוזה) · nextStage — השלב הבא בשרשרת מעקב-הטיפול (עין).
// מוצא: maor/src/lib/ayin.ts:56-61 · המקור: new/atoms/next-stage.mjs —
//        `export function nextStage(stage, stageIndex, AYIN_STAGES) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מקבל שלב, מחזיר את הבא-אחריו בסדר-השלבים; בשלב האחרון ⇒ null.
//        שלב לא-מוכר ⇒ מתנהג כשלב-הראשון (נפילת-האפס של stageIndex) ⇒ מחזיר את השני.
// שקעים (חוק-1 — קריאה-לשכן הוזרקה כפרמטר):
//   stageIndex(stage) ⇒ int — מיקום השלב בסדר (במקור indexOf; לא-נמצא ⇒ 0).
//   ayinStages       ⇒ List<String> — סדר-השלבים.
// קלט: stage (String) · שני השקעים. פלט: String? (השלב-הבא, או null בשלב האחרון).
//
// הערת-המרה (מקור→Dart): אין locale/פורמט/getMonth/truthiness מעורבים.
//   ה-JS `i < AYIN_STAGES.length - 1 ? AYIN_STAGES[i + 1] : null` הוא ביטוי-שלישוני
//   טהור על אינדקסים — מועתק כלשונו. פלט nullable ⇒ `String?`. אפס מוטביליות (final).

/// The next tracking-stage after [stage] in [ayinStages], or null at the last stage.
/// Verbatim behaviour of the JS source new/atoms/next-stage.mjs (`nextStage`).
/// [stageIndex] and [ayinStages] are injected sockets (חוק-1 — no internal imports).
String? nextStage(
  String stage,
  int Function(String) stageIndex,
  List<String> ayinStages,
) {
  final int i = stageIndex(stage);
  return i < ayinStages.length - 1 ? ayinStages[i + 1] : null;
}
