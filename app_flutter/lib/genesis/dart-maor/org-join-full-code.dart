// חוט · org-join-full-code — קוד-הצטרפות-מלא: slug + '.' + code. חוזה: org-join-full-code.contract.md
// המרה מ-JS (new/atoms/org-join-full-code.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4, המקור קדוש).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core). אין שכן, אין locale/
//        getMonth/truthiness/מוטביליות — שרשור-מחרוזות טהור בלבד. שער חוק-6 (זהות): slug/code
//        מוזרקים כפרמטרים, לא מוטמעים — אין סוד באטום.
//
// המקור: `export function orgJoinFullCode(slug, code) { return slug + '.' + code; }`.
// שרשור-מחרוזות של JS ('+' על שתי מחרוזות) ≡ אינטרפולציה של Dart על שני String — זהה-ביט.
String orgJoinFullCode(String slug, String code) {
  return '$slug.$code';
}
