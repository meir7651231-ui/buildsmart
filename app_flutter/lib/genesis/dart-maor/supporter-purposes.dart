// ⚛️ אטום-Dart (דרגת-חוזה) · supporterPurposes — קבוצת-הייעודים שעל תורם (distinct, בלי ריקים).
// מוצא: maor/src/components/supporters/lib.ts:36-45 · המקור: new/atoms/supporter-purposes.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). אין שכנים — אפס שקעים (כמו במקור).
//
// תפקיד: איחוד ייחודי של הייעוד-פר-תורם (forWho) והייעוד-פר-תרומה (donations[].purpose),
//        עם trim ובלי ריקים. הסדר: forWho ראשון (אם קיים), אחר-כך סדר-התרומות (סדר-הכנסת Set).
// קלט:  sup — מפה עם 'forWho'?: String ו-'donations'?: List של מפות עם 'purpose'?: String.
// פלט:  List<String> — ייעודים ייחודיים לא-ריקים.
//
// הערות-המרה (מקור→Dart):
//  • `new Set()` → `<String>{}` (LinkedHashSet) — שומר סדר-הכנסה, כמו Set של JS;
//    `[...set]` → `set.toList()` (אותו סדר-הכנסה, אין מיון).
//  • `sup.forWho ?? ''` / `d.purpose ?? ''` → גישת-מפה `sup['forWho'] ?? ''` —
//    מפתח-חסר במפה מחזיר null בדיוק כמו property-חסר ב-JS (undefined ?? '' ⇒ '').
//  • `.trim()` → `_jsTrim` (כלל-16): trim של ES = WhiteSpace∪LineTerminator בלבד —
//    U+0085 (NEL) ו-U+180E אינם נגזמים ב-JS אך כן ב-Dart.trim ⇒ עוזר נאמן-ES.
//  • `if (fw)` / `if (p)` — truthiness של מחרוזת ב-JS = לא-ריקה (כלל-7) ⇒ `.isNotEmpty`.
//  • `sup.donations ?? []` → `(sup['donations'] ?? const []) as Iterable` — לולאה זהה.
//  • מוטביליות: הכול final; אין var מוקצה-מחדש. אין תאריכים/locale/מספרים — הכללים 1-6,9-15,17-18 לא נוגעים.

/// Distinct, non-empty purpose set on a supporter — union of the per-supporter
/// forWho and each donation's purpose, trimmed, insertion-ordered (forWho first).
/// Verbatim port of new/atoms/supporter-purposes.mjs (`supporterPurposes`).
List<String> supporterPurposes(Map sup) {
  final set = <String>{};
  final fw = _jsTrim((sup['forWho'] ?? '') as String);
  if (fw.isNotEmpty) set.add(fw);
  for (final d in (sup['donations'] ?? const []) as Iterable) {
    final p = _jsTrim(((d as Map)['purpose'] ?? '') as String);
    if (p.isNotEmpty) set.add(p);
  }
  return set.toList();
}

/// ECMAScript WhiteSpace∪LineTerminator trim — WITHOUT U+0085/U+180E (כלל-16).
const String _esWs =
    '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF';

String _jsTrim(String s) {
  int i = 0, j = s.length;
  while (i < j && _esWs.contains(s[i])) i++;
  while (j > i && _esWs.contains(s[j - 1])) j--;
  return s.substring(i, j);
}
