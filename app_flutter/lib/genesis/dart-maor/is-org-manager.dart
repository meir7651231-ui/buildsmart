// ⚛️ אטום-Dart (דרגת-חוזה) · isOrgManager — האם המייל הוא מנהל-הארגון (השוואה מנורמלת).
// מוצא: maor/src/components/platform/lib.ts:124-128 · המקור: new/atoms/is-org-manager.mjs
// חוזה: new/atoms/is-org-manager.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: המנהל השמור (org.manager) עובר trim+toLowerCase; המייל הנבדק עובר דרך
//        שקע-הנירמול; שוויון ⇒ true. ארגון בלי מנהל (חסר/ריק) ⇒ תמיד false (המגן !!m).
// שקע (חוק-1): normEmail — מנרמל-מייל (במקור trim().toLowerCase()), הוזרק כפרמטר.
// קלט: email (String) · org (Map — {manager?: String}) · normEmail (String→String).
// פלט: bool.
//
// הערת-המרה (מקור→Dart):
//   • `org.manager ?? ''` (nullish של JS: null/undefined⇒'') ⇒ `(org['manager'] as String?) ?? ''`
//     — מפתח-חסר ב-Map מחזיר null, זהה ל-undefined כאן (הערך תמיד מחרוזת-או-חסר לפי החוזה).
//   • `!!m` (truthiness של מחרוזת ב-JS) ⇒ `m.isNotEmpty` (מחרוזת-ריקה = falsy).
//   • `===` על מחרוזות ⇒ `==` ב-Dart (השוואת-ערך).
//   אין locale/פורמט/getMonth/מוטביליות; ה-trim/toLowerCase של Dart תואמים ל-JS על ASCII-מייל.

/// Returns whether [email] is the organisation's delegated manager (org.manager),
/// comparing both sides normalised: the stored manager via trim+toLowerCase and
/// the checked email via the injected [normEmail] socket. An org with no manager
/// (missing or blank) is always false. Verbatim behaviour of the JS `isOrgManager`.
bool isOrgManager(
  String email,
  Map<String, dynamic> org,
  String Function(String) normEmail,
) {
  final m = ((org['manager'] as String?) ?? '').trim().toLowerCase();
  return m.isNotEmpty && normEmail(email) == m;
}
