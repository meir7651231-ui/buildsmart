// חוט · donationsPath — נתיב אוסף-התרומות הנפרד (מסלול-B). חוזה: donations-path.contract.md
// המרה מ-JS (new/atoms/donations-path.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// מוצא: maor/src/lib/cloud-diff.ts:67-69.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// השכנים colPath/donationsCol הוזרקו כשקעים (חוק-1/חוק-3 — אפס import פנימי,
// קריאה-לשכן = פרמטר-שקע). המקור: `return colPath(slug, cloudRoot, donationsCol);`
//
// קלט:  slug — מזהה-ארגון (String) · cloudRoot — האם נתיבי-שורש (bool) ·
//        colPath — שקע-בונה-נתיב (slug, cloudRoot, col) ⇒ String ·
//        donationsCol — שם-אוסף-התרומות (String).
// פלט:  נתיב-אוסף-התרומות, String — בדיוק מה שהשקע colPath מחזיר.
//
// הערת-המרה: אין locale/פורמט/getMonth/מוטביליות/truthiness מעורבים — האטום רק
// מעביר את הארגומנטים לשקע ומחזיר את תוצאתו verbatim. הטיפוס של השקע מקובע
// לחתימת-השכן colPath(String, bool, String) ⇒ String (כמו במקור-ה-JS).

/// Separate donations-collection path (route-B). Delegates verbatim to the
/// injected `colPath` socket with the donations collection name. Verbatim
/// behaviour of the JS source new/atoms/donations-path.mjs.
String donationsPath(
  String slug,
  bool cloudRoot,
  String Function(String slug, bool cloudRoot, String col) colPath,
  String donationsCol,
) {
  return colPath(slug, cloudRoot, donationsCol);
}
