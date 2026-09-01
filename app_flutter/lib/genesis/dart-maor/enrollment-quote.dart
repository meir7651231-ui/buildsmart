// ⚛️ אטום-Dart (דרגת-חוזה) · enrollmentQuote
// מוצא: maor · new/atoms/enrollment-quote.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
//        המקור: maor/src/components/courses/lib.ts:298-303 (תמחור-משוקלל מתוך שדות-שיבוץ שמורים).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). השכן weightedQuote מוזרק כשקע
//        (חוק-1/3 — חוט לא מייבא שכן; קריאה-לשכן ⇒ פרמטר-שקע).
//
// תיקוני-פורט מול טיוטת-המנוע (dart-from-maor/enrollment-quote.dart.draft; התנהגות משומרת ביט-אחר-ביט):
//   • גישת-שדות — המנוע פלט `c.perLesson`/`e.freq`/… (גישת-property על dynamic). ב-Dart על
//                 אובייקט-JS (Map) זו גישת-מפתח ⇒ `c['perLesson']`/`e['freq']`/… . קלט מוקשח ל-Map.
//   • truthiness — המנוע פלט `_falsy(...)` (לא-מוגדר). JS `!x` נכון לכל שדה: perLesson (bool),
//                 freq (number — 0 falsy), freqUnit/term (string — '' falsy). ⇒ שקע `_falsy`
//                 שמחקה נאמנה את falsy-של-JS (null/false/0/''/NaN) (כלל-פורט 7).
//   • tier '||' — המנוע פלט `e.tier ?? ''`; JS-המקור הוא `e.tier || ''`. ‏`??` תופס null בלבד,
//                 בעוד `||` תופס גם '' / false / 0. ⇒ `_falsy(e['tier']) ? '' : e['tier']`
//                 (tier חסר/ריק/falsy ⇒ '' = מחיר-מלא, כלשון-המקור).
//   • months     — `e['termMonths']` חסר ⇒ null ב-Dart = undefined ב-JS (המפתח 'months' קיים
//                 עם null; הזהב מוודא `== null`, המקבילה ל-`=== undefined`).
//
// קלט:  c ({perLesson?}) · e ({freq?, freqUnit?, term?, termMonths?, tier?}) ·
//        weightedQuote — שקע חובה: (c, {freq, unit, term, months?, tier}) ⇒ {lessons, perLesson, total}.
// פלט:  תוצאת-השקע (Map) או null — שער-כניסה+נירמול, בלי חישוב עצמי.

/// תמחור-משוקלל מתוך שדות-שיבוץ: null אם החוג אינו פר-שיעור או חסר freq/freqUnit/term;
/// אחרת מאציל ל-weightedQuote עם נירמול-הארגומנטים (tier חסר/ריק ⇒ '').
dynamic enrollmentQuote(
  Map c,
  Map e,
  dynamic Function(Map, Map) weightedQuote,
) {
  if (_falsy(c['perLesson']) ||
      _falsy(e['freq']) ||
      _falsy(e['freqUnit']) ||
      _falsy(e['term'])) {
    return null;
  }
  return weightedQuote(c, {
    'freq': e['freq'],
    'unit': e['freqUnit'],
    'term': e['term'],
    'months': e['termMonths'],
    'tier': _falsy(e['tier']) ? '' : e['tier'],
  });
}

/// מחקה את falsy-של-JS (`!v`): null/undefined · false · 0 · '' · NaN.
bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || v == '' || (v is double && v.isNaN);
