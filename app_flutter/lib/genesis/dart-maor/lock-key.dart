// ⚛️ אטום-Dart (דרגת-חוזה) · lockKey — מפתח-הנעילה הממורחב-שמות.
// מוצא: המקור new/atoms/lock-key.mjs —
//   `const LOCK_BASE = 'maor_lock'; export function lockKey(nsLsKey){ return nsLsKey(LOCK_BASE); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מחזיר את מפתח-הנעילה (localStorage) דרך שקע-ההרחבה nsLsKey — הבסיס
//        הקבוע 'maor_lock' תמיד מועבר לשקע כמו-שהוא; השקע-של-הזהות מחזיר אותו,
//        ושקע-הפלטפורמה מוסיף slug. בחירת-ה-namespace = חיווט-קופסה/הצבה (חוק-6).
// שקע (חוק-1/חוק-6): nsLsKey — פונקציית String→String שהוזרקה (הבסיס מוחזר/ממורחב).
// קלט: השקע nsLsKey. פלט: nsLsKey('maor_lock') — בדיוק כמו במקור.
//
// הערת-המרה (מקור→Dart): אין locale/פורמט/getMonth/truthiness/מוטביליות/מודולו/תאריך —
// חוט טהור של קריאת-שקע. הבסיס final (const במקור). החתימה מוטיפסת String Function(String)
// המקבילה לשקע-ה-JS; אין import.

/// The base localStorage key for the lock, before namespace-expansion.
const String lockBase = 'maor_lock';

/// Returns the (namespace-expanded) lock key by passing the constant base
/// 'maor_lock' through the injected [nsLsKey] socket. Verbatim behaviour of
/// the JS source `lockKey` — the socket receives exactly 'maor_lock'.
String lockKey(String Function(String) nsLsKey) {
  return nsLsKey(lockBase);
}
