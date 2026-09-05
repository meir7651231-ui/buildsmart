// ⚛️ אטום-Dart (דרגת-חוזה) · dupFields — 18 שדות-מיזוג כפולי-משפחות (key·label·get).
// מוצא: maor/src/lib/dedup.ts:189-208 (תוויות verbatim מהלגאסי 1643-1653) ·
//        המקור: new/atoms/dup-fields.mjs. חוזה: new/atoms/dup-fields.contract.md.
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// הערות-המרה (מקור→Dart):
//  • כל שדה-JS `{key,label,get}` → רשומת-Dart בשם (`DupField` = record מוקלד).
//    הגישה `.key/.label/.get` נשמרת זהה לצרכן.
//  • `f.name || ''` → `(f['name'] ?? '')`. בתחום-המחרוזות שדות אלו מכילים String|null
//    בלבד ⇒ `||` (falsy) ו-`??` (null) מניבים פלט זהה: '' חסר/ריק. (אין 0/false כערך.)
//  • ‏kidsHome/kidsMarried: המקור `f.x == null ? '' : String(f.x)` — `==`-loose של JS
//    תופס גם undefined (מפתח-חסר) וגם null. ‏Dart `f['x'] == null` על Map תופס בדיוק
//    את שניהם (מפתח-חסר ⇒ null) ⇒ סמנטיקה זהה (כלל-המרה 2: כאן ה-JS כבר loose, לא ===).
//    `String(3)`→'3', `String(0)`→'0'; ‏Dart `3.toString()`→'3', `0.toString()`→'0' ⇒ זהה.
//    אפס אינו-ריק נשמר: kidsHome:0 ⇒ '0'.
//  • מוטביליות: הרשימה `final`; ה-get-ים טהורים ללא צד-לוואי. אין locale/פורמט/getMonth.

/// A family record, addressed by string field-keys (dynamic values: String|int|null).
typedef Family = Map<String, dynamic>;

/// One duplicate-merge field descriptor: stable [key], Hebrew [label], and a pure
/// [get] extractor that renders the family's value for that field as a String.
typedef DupField = ({String key, String label, String Function(Family) get});

/// The 18 family duplicate-merge fields (key · label · get), verbatim port of
/// new/atoms/dup-fields.mjs (`makeDUP_FIELDS(T)`). מפתחות+תוויות = שקע-T (הכרעה 16);
/// הסדר קדוש-מקור.
List<DupField> makeDupFields(Map<String, String> T) => <DupField>[
  (key: T['k1']!, label: T['k2']!, get: (f) => (f['name'] ?? '') as String),
  (key: T['k3']!, label: T['k4']!, get: (f) => (f['mother'] ?? '') as String),
  (key: T['k5']!, label: T['k6']!, get: (f) => (f['father'] ?? '') as String),
  (key: T['k7']!, label: T['k8']!, get: (f) => (f['phone'] ?? '') as String),
  (key: T['k9']!, label: T['k10']!, get: (f) => (f['phone2'] ?? '') as String),
  (key: T['k11']!, label: T['k12']!, get: (f) => (f['email'] ?? '') as String),
  (key: T['k13']!, label: T['k14']!, get: (f) => (f['city'] ?? '') as String),
  (key: T['k15']!, label: T['k16']!, get: (f) => (f['address'] ?? '') as String),
  (key: T['k17']!, label: T['k18']!, get: (f) => (f['motherId'] ?? '') as String),
  (key: T['k19']!, label: T['k20']!, get: (f) => (f['fatherId'] ?? '') as String),
  (key: T['k21']!, label: T['k22']!, get: (f) => (f['community'] ?? '') as String),
  (key: T['k23']!, label: T['k24']!, get: (f) => (f['language'] ?? '') as String),
  (key: T['k25']!, label: T['k26']!, get: (f) => (f['maritalStatus'] ?? '') as String),
  (key: T['k27']!, label: T['k28']!, get: (f) => (f['status'] ?? '') as String),
  (key: T['k29']!, label: T['k30']!, get: (f) => f['kidsHome'] == null ? '' : f['kidsHome'].toString()),
  (key: T['k31']!, label: T['k32']!, get: (f) => f['kidsMarried'] == null ? '' : f['kidsMarried'].toString()),
  (key: T['k33']!, label: T['k34']!, get: (f) => (f['createdAt'] ?? '') as String),
  (key: T['k35']!, label: T['k36']!, get: (f) => (f['notes'] ?? '') as String),
];
