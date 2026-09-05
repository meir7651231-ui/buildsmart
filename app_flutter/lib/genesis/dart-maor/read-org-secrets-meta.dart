// ⚛️ אטום-Dart (דרגת-חוזה) · readOrgSecretsMeta — מדדי-"מוגדר" של כספת-הסודות.
// מוצא: maor/src/lib/cloudConfig.ts:158-167 → new/atoms/read-org-secrets-meta.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). השכנים cloudDb/doc/getDoc
//        הוזרקו כאובייקט-שקעים fs (חוק-1 — אפס import פנימי).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: קורא את המסמך orgSecretsMeta/{slug} ומחזירו כמות-שהוא; failure-safe
//        מוחלט — מסמך-חסר / שגיאת-Rules / רשת / זריקה-סינכרונית ⇒ {} (מפה ריקה).
// קלט:  slug · fs (שקעי db · doc · getDoc).
// פלט:  Future<Map<String,dynamic>> — לעולם מפה, אף פעם לא זריקה ולא null.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • הבליעה (catch⇒{}) עוטפת גם את fs.doc הסינכרוני — כמו ה-try של המקור.
//  • snap.data() מוחזר כמות-שהוא (אותה הפניה) ⇒ identical נשמר (דוגמה 3).
//  • fs = מבנה-שקעים מפורש (המקבילה ל-destructuring של { db, doc, getDoc }).

typedef DocFn = dynamic Function(dynamic db, String col, String id);
typedef GetDocFn = Future<dynamic> Function(dynamic ref);

/// שקעי firebase/firestore המוזרקים (חוק-1) — המקבילה לאובייקט fs של ה-JS.
class Fs {
  final dynamic db;
  final DocFn doc;
  final GetDocFn getDoc;
  const Fs({required this.db, required this.doc, required this.getDoc});
}

/// Read the org-secrets "is-set" metadata document (orgSecretsMeta/{slug}) and
/// return it as-is; any failure (missing doc, Rules error, network, synchronous
/// throw from `doc`) is swallowed to an empty map. Verbatim behaviour of the JS
/// source new/atoms/read-org-secrets-meta.mjs.
Future<Map<String, dynamic>> readOrgSecretsMeta(String slug, Fs fs) async {
  try {
    final snap = await fs.getDoc(fs.doc(fs.db, 'orgSecretsMeta', slug));
    return (snap.exists() == true)
        ? snap.data() as Map<String, dynamic>
        : <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
}
