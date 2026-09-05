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
/// new/atoms/sup-dup-fields.mjs (`makeSUP_DUP_FIELDS(T)`). מפתחות+תוויות = שקע-T
/// (הכרעה 16); הסדר קדוש-מקור.
List<SupDupField> makeSupDupFields(Map<String, String> T) => <SupDupField>[
  (key: T['k1']!, label: T['k2']!, get: (s) => _orEmpty(s['name'])),
  (key: T['k3']!, label: T['k4']!, get: (s) => _orEmpty(s['phone'])),
  (key: T['k5']!, label: T['k6']!, get: (s) => _orEmpty(s['email'])),
  (key: T['k7']!, label: T['k8']!, get: (s) => _orEmpty(s['idNum'])),
  (key: T['k9']!, label: T['k10']!, get: (s) => _orEmpty(s['city'])),
  (key: T['k11']!, label: T['k12']!, get: (s) => _orEmpty(s['address'])),
  (key: T['k13']!, label: T['k14']!, get: (s) => _orEmpty(s['cat'])),
  (key: T['k15']!, label: T['k16']!, get: (s) => _orEmpty(s['forWho'])),
  (key: T['k17']!, label: T['k18']!, get: (s) => _orEmpty(s['notes'])),
];
