// ⚛️ אטום-Dart (דרגת-חוזה) · setCloudScope — חישוב ערך תחום-הארגון (slug + cloudRoot) לנתיבי-הענן.
// מוצא: maor/src/lib/cloud.ts:79-99 · המקור: new/atoms/set-cloud-scope.mjs —
//        `export function setCloudScope(slug, cloudRoot) { return { slug, cloudRoot }; }`
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה אובייקט-scope חדש {slug, cloudRoot}. cloudRoot=true ⇒ נתיבי-שורש
// (ביט-זהה ללקוח-החי); false ⇒ נתיבי orgs/{slug}/ (ארגון-פלטפורמה, CLOUD2).
// במקור הערך הושם למשתנה-מודול scope — ההשמה וברירת-המחדל הבטוחה
// {slug:'default', cloudRoot:true} הן חיווט-קופסה (חוק-1/חוק-5); האטום רק מחשב.
//
// הערת-המרה (מקור→Dart):
//   • shorthand של JS (`{ slug, cloudRoot }`) ⇒ זוגות-מפתח מפורשים במפה.
//   • מפה חדשה בכל קריאה ⇒ אין מצב משותף שדולף בין קריאות (דוגמת-חוזה 3).
//   • הערכים עוברים כמות-שהם — אפס נרמול/trim (דוגמת-חוזה 4); dynamic משמר זאת.
//   • אין locale/תאריך/truthiness/מספרים — אף חוק-המרה מ-DART-PORTING-RULES לא נדרש כאן.

/// Cloud org-scope value — verbatim behavior of the JS source
/// new/atoms/set-cloud-scope.mjs. Returns a fresh {slug, cloudRoot} map;
/// the module-variable assignment and the safe default live in the box, not here.
Map<String, dynamic> setCloudScope(dynamic slug, dynamic cloudRoot) {
  return {'slug': slug, 'cloudRoot': cloudRoot};
}
