// ⚛️ אטום-Dart (דרגת-חוזה) · supDupFields — 9 שדות-מיזוג כפולי-תורמים (key·label·get).
// מוצא: maor/src/lib/dedup.ts:404-416 · המקור: new/atoms/sup-dup-fields.mjs.
// חוזה: new/atoms/sup-dup-fields.contract.md (אטום-קבוע · צילום-ערך).
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// הערות-המרה (מקור→Dart):
//  • כל שדה-JS `{key,label,get}` → רשומת-Dart בשם (`SupDupField` = record מוקלד).
//    הגישה `.key/.label/.get` נשמרת זהה לצרכן.
//  • `s.name || ''` = ‏`||`-falsy של JS (חוק-7): לא רק null/מפתח-חסר אלא גם
//    '' · 0 · ‎-0 · NaN · false ⇒ ''. ערך-truthy מוחזר **כמות-שהוא** (JS לא ממחרז!).
//    ⇒ עוזר מקומי `_orEmpty` (dynamic→dynamic) במקום `??` — נאמן גם מחוץ
//    לתחום-המחרוזות. מפתח-חסר ב-Map ⇒ null ⇒ '' (זהה ל-undefined||'' ב-JS).
//  • מוטביליות: הרשימה `final`; ה-get-ים טהורים ללא צד-לוואי. אין locale/פורמט/getMonth.

/// A supporter record, addressed by string field-keys (dynamic values).
typedef Supporter = Map<String, dynamic>;

/// One supporter duplicate-merge field descriptor: stable [key], Hebrew [label],
/// and a pure [get] extractor mirroring JS `s.x || ''` exactly.
typedef SupDupField = ({String key, String label, dynamic Function(Supporter) get});

/// JS `v || ''`: falsy (null/undefined, '', 0, -0, NaN, false) ⇒ ''; otherwise v itself.
dynamic _orEmpty(dynamic v) {
  if (v == null || v == false || v == '') return '';
  if (v is num && (v == 0 || v.isNaN)) return '';
  return v;
}

/// The 9 supporter duplicate-merge fields (key · label · get), verbatim port of
/// new/atoms/sup-dup-fields.mjs (`SUP_DUP_FIELDS`). Order and labels are source-sacred.
final List<SupDupField> supDupFields = <SupDupField>[
  (key: 'name', label: 'שם', get: (s) => _orEmpty(s['name'])),
  (key: 'phone', label: 'טלפון', get: (s) => _orEmpty(s['phone'])),
  (key: 'email', label: 'אימייל', get: (s) => _orEmpty(s['email'])),
  (key: 'idNum', label: 'ת"ז', get: (s) => _orEmpty(s['idNum'])),
  (key: 'city', label: 'עיר', get: (s) => _orEmpty(s['city'])),
  (key: 'address', label: 'כתובת', get: (s) => _orEmpty(s['address'])),
  (key: 'cat', label: 'קטגוריה', get: (s) => _orEmpty(s['cat'])),
  (key: 'forWho', label: 'ייעוד', get: (s) => _orEmpty(s['forWho'])),
  (key: 'notes', label: 'הערות', get: (s) => _orEmpty(s['notes'])),
];
