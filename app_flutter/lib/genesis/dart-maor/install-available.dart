// ⚛️ אטום-Dart (דרגת-חוזה) · installAvailable — האם דיאלוג-התקנת-PWA זמין.
// מוצא: maor/src/lib/pwa.ts:32-34 · המקור: new/atoms/install-available.mjs —
//        `export function installAvailable(deferredInstall) { return deferredInstall !== null; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: האם נלכד אירוע beforeinstallprompt (Chrome/Edge) — ההחלטה: השקע אינו null.
// שקע (חוק-1): deferredInstall — האירוע-שנלכד או null. במקור זה משתנה-מודול
//        שמאזין-window ממלא; הלכידה (addEventListener+preventDefault) = חיווט-קופסה.
// קלט: deferredInstall (אובייקט-אירוע או null). פלט: bool.
//
// הערת-המרה (מקור→Dart · DART-PORTING-RULES כלל-2 — null≠undefined):
//   ה-JS הוא `!== null` מדויק (null⇒false; undefined⇒true, כי undefined!==null).
//   ל-Dart אין undefined — null הוא הערך-הנוֹל היחיד, והוא מייצג את null המאותחל
//   של המקור. לכן `!= null` פה נאמן-לתחום-הישיג במלואו: null⇒false, כל-אובייקט⇒true.
//   דוגמת-החוזה הרביעית (undefined⇒true) בלתי-ניתנת-לביטוי ב-Dart (אין undefined;
//   ארגומנט-dynamic חסר הופך ל-null) — והחוזה עצמו מסמן שהיא "לא קורה" (הקופסה
//   מזריקה null-או-אירוע). אין locale/פורמט/getMonth/truthiness/מוטביליות.

/// Returns whether the PWA install prompt is available — i.e. whether a
/// `beforeinstallprompt` event was captured (the injected slot is not null).
/// Verbatim behaviour of the JS source `installAvailable` (`deferredInstall !== null`);
/// Dart has no `undefined`, so `!= null` faithfully covers the reachable domain
/// (null ⇒ false, any object ⇒ true).
bool installAvailable(Object? deferredInstall) {
  return deferredInstall != null;
}
