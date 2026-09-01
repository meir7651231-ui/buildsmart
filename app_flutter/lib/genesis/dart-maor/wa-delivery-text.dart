// ⚛️ אטום-Dart (דרגת-חוזה) · waDeliveryText — נוסח הודעת-מסירה (חלוקה) לוואטסאפ.
// מוצא: maor/src/lib/wa.ts:52-54 · המקור: new/atoms/wa-delivery-text.mjs · חוזה: wa-delivery-text.contract.md.
// טוהר: פונקציה top-level עצמאית, אפס import של אטום אחר (חוק-1) — השכנים
//        renderTemplate (מנוע-התבניות, lib/templates.ts) ו-orgOf (שם-ארגון-עם-נפילה,
//        wa.ts:47-49) מוזרקים כשקעי-פרמטר. חוק-4 — זהה-ביט למקור-ה-JS.
//
// תפקיד: מרכיב את משתני-התבנית — name = 'משפחת ' + famName מקוצץ-רווחים
//        (famName ריק ⇒ 'משפחת' לבדו) · org = orgOf(orgName) — ומרנדר את
//        תבנית 'wa.delivery' דרך שקע-renderTemplate.
// קלט:  orgName · famName · cfg (אופציונלי — {templates?}) · שני השקעים.
// פלט:  מחרוזת-ההודעה.
//
// הערות-המרה (מקור→Dart):
//  • `.trim()` של JS = קבוצת-ES בלבד (חוק-16): U+0085/U+180E אינם נגזמים —
//    בניגוד ל-String.trim של Dart. לכן עוזר _esTrim מפורש על קבוצת-ES,
//    בנוי מנקודות-קוד מספריות (בלי תווי-רווח גולמיים בקובץ).
//  • `{ name: ..., org: ... }` → Map מילולי בסדר-הכנסה זהה (name ואז org) —
//    משמר את סדר-מפתחות-JS (חוק-14, מפתחות-מחרוזת = סדר-הכנסה).
//  • famName מוחזק כמחרוזת (כמו במקור — שרשור '+' עם מחרוזת); cfg נשאר dynamic
//    ועובר כפי-שהוא לשקע — האטום לא נוגע בו.

/// ES trim set (ECMA-262 WhiteSpace + LineTerminator) — חוק-16:
/// TAB LF VT FF CR SP NBSP OGHAM 2000–200A LS PS NNBSP MMSP IDSP ZWNBSP.
/// U+0085 (NEL) ו-U+180E נשארים בכוונה (Dart.trim היה גוזם אותם).
const Set<int> _esWsCodes = {
  0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x0020, 0x00A0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000,
  0xFEFF,
};

String _esTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _esWsCodes.contains(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _esWsCodes.contains(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

/// Verbatim port of new/atoms/wa-delivery-text.mjs (`waDeliveryText`).
/// renderTemplate(cfg, key, vars) ⇒ String · orgOf(orgName) ⇒ String — injected sockets.
dynamic waDeliveryText(dynamic orgName, dynamic famName, dynamic cfg,
    dynamic renderTemplate, dynamic orgOf) {
  return renderTemplate(cfg, 'wa.delivery', {
    'name': _esTrim('משפחת ' + (famName as String)),
    'org': orgOf(orgName),
  });
}
