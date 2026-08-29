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
/// new/atoms/dup-fields.mjs (`DUP_FIELDS`). Order and labels are source-sacred.
final List<DupField> dupFields = <DupField>[
  (key: 'name', label: 'שם משפחה', get: (f) => (f['name'] ?? '') as String),
  (key: 'mother', label: 'שם האם', get: (f) => (f['mother'] ?? '') as String),
  (key: 'father', label: 'שם האב', get: (f) => (f['father'] ?? '') as String),
  (key: 'phone', label: 'טלפון', get: (f) => (f['phone'] ?? '') as String),
  (key: 'phone2', label: 'טלפון 2', get: (f) => (f['phone2'] ?? '') as String),
  (key: 'email', label: 'אימייל', get: (f) => (f['email'] ?? '') as String),
  (key: 'city', label: 'עיר', get: (f) => (f['city'] ?? '') as String),
  (key: 'address', label: 'כתובת', get: (f) => (f['address'] ?? '') as String),
  (key: 'motherId', label: 'ת"ז אם', get: (f) => (f['motherId'] ?? '') as String),
  (key: 'fatherId', label: 'ת"ז אב', get: (f) => (f['fatherId'] ?? '') as String),
  (key: 'community', label: 'קהילה', get: (f) => (f['community'] ?? '') as String),
  (key: 'language', label: 'שפה', get: (f) => (f['language'] ?? '') as String),
  (key: 'maritalStatus', label: 'מצב משפחתי', get: (f) => (f['maritalStatus'] ?? '') as String),
  (key: 'status', label: 'סטטוס', get: (f) => (f['status'] ?? '') as String),
  (key: 'kidsHome', label: 'ילדים בבית', get: (f) => f['kidsHome'] == null ? '' : f['kidsHome'].toString()),
  (key: 'kidsMarried', label: 'ילדים נשואים', get: (f) => f['kidsMarried'] == null ? '' : f['kidsMarried'].toString()),
  (key: 'createdAt', label: 'נרשמה', get: (f) => (f['createdAt'] ?? '') as String),
  (key: 'notes', label: 'הערות', get: (f) => (f['notes'] ?? '') as String),
];
