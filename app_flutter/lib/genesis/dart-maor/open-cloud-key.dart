// ⚛️ אטום-Dart (דרגת-חוזה) · openCloudKey — חילוץ DEK-ענן מ-envelope: האצלה שקופה.
// מוצא: maor/src/lib/cloudCrypto.ts:72-77 · המקור: new/atoms/open-cloud-key.mjs —
//        `export function openCloudKey(env, secret, via, openDek) { return openDek(env, secret, via); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מעביר את (env, secret, via) כלשונם לפותח-המעטפות (השקע openDek) ומחזיר את
//        הערך-המוחזר כמו-שהוא — אותה רפרנס / אותה Future, כולל null על סוד שגוי.
//        האטום לא מוסיף שום התנהגות; קיומו מקבע את חוזה-הענן בנפרד מחוזה-המכשיר.
// שקע (חוק-1 — קריאה-לשכן הוזרקה כפרמטר): openDek(env, secret, via) — פותח-המעטפות.
// קלט: env, secret, via ('pass'|'rec'), והשקע openDek. פלט: בדיוק פלט-openDek.
//
// הערת-המרה (מקור→Dart): המקור עיוור-לתוכן ומחזיר מה ש-openDek החזיר — ערך-סנכרוני
//   (זקיף) או Promise (כולל Promise.resolve(null)). כדי לשמר זהות לכל טיפוס-החזרה,
//   טיפוס-ההחזרה של השקע ושל הפונקציה = dynamic (מקביל להיעדר-טיפוס של JS): ערך-סנכרוני
//   מוחזר כמו-שהוא, Future מוחזרת בלי await (בדיוק כמו JS שמחזיר את ה-Promise, לא ממתין
//   לה). הארגומנטים עוברים ברפרנס — זהות נשמרת (=== של JS ⇒ identical ב-Dart).
//   אין locale/פורמט/getMonth/truthiness/מוטביליות שהמנוע יכול היה לפספס — האצלה טהורה.

/// Extracts the cloud DEK from a key-envelope by transparent delegation: passes
/// (env, secret, via) verbatim to the [openDek] socket and returns its result
/// as-is — the same reference / the same Future, including null on a wrong
/// secret. Verbatim behaviour of the JS source `openCloudKey`.
dynamic openCloudKey(
  Object? env,
  Object? secret,
  Object? via,
  dynamic Function(Object? env, Object? secret, Object? via) openDek,
) {
  return openDek(env, secret, via);
}
