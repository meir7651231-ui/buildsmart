// ⚛️ אטום-Dart (דרגת-חוזה) · hokRecordedThisMonth — האם חיוב-החודש של הוראת-הקבע נרשם.
// מוצא: maor · new/atoms/hok-recorded-this-month.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
//        המקור: maor/src/components/supporters/lib.ts:708-725. הקבוע-השכן HOK_CAT (קטגוריית-
//        התרומה של הו"ק) מוזרק כשקע hokCat (חוק-1/3 — אפס import פנימי, קריאה-לשכן ⇒ פרמטר-שקע).
//
// תיקוני-פורט מול טיוטת-המנוע (התנהגות משומרת ביט-אחר-ביט):
//   • sublist⇒substring — המנוע פלט `todayIso.sublist(0,7)` (API של List); ‏ISO הוא String
//                 ⇒ `todayIso.substring(0,7)` ("YYYY-MM"). כלל-פורט: slice⇒substring על מחרוזת.
//   • גישת-שדות — המנוע פלט `sp.hok`/`d.date`/`h.clearer` על `dynamic`; ב-Dart על אובייקט-JS
//                 (Map) זו גישת-מפתח ⇒ `sp['hok']`/`d['date']`/`h['clearer']`.
//   • truthiness — JS `!sp.hok`: hok falsy = null/חסר (או false). ⇒ שקע `_falsy` מפורש
//                 (כלל-פורט 7), נאמן ל-`||`/`!` של JS.
//   • `d.cur || '₪'` / `h.c || '₪'` — ברירת-מחדל-falsy של JS (null/חסר/'' ⇒ '₪').
//                 ⇒ `_or(v,'₪')` דרך אותו `_falsy`, לא `?? ` (ש-'' היה עובר בטעות).
//   • `d.date.startsWith` / `h.d || ''` — במקור d.date נגיש-ישירות; ‏hist דרך `h.d || ''`.
//                 שיקוף: date חסר ⇒ '' (startsWith(month) ⇒ false), כמו הנפילה-הרכה של המקור.
//
// קלט:  sp — תומך ({hok?:{amount,cur}, donations:[{date,cat,amount,cur?}], hist?:[{d,clearer?,a?,c?}]})
//        todayIso — "YYYY-MM-DD" של היום · hokCat — קטגוריית-הו"ק (שקע; במאור 'הו"ק').
// פלט:  bool — האם חיוב-החודש של ההו"ק כבר נרשם (בתרומות או ב-hist).

bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || v == '' || (v is num && v.isNaN);

dynamic _or(dynamic v, dynamic fallback) => _falsy(v) ? fallback : v;

/// האם חיוב-ההו"ק של החודש-הנוכחי כבר נרשם — התאמה בתרומות (קטגוריה או סכום+מטבע)
/// או ב-hist (נדרים/סולה בלי דרישת-סכום, או סכום-מדויק+מטבע ברשומת-לגאסי).
bool hokRecordedThisMonth(Map sp, String todayIso, String hokCat) {
  if (_falsy(sp['hok'])) return false;
  final month = todayIso.substring(0, 7);
  final hok = sp['hok'] as Map;
  final donations = (sp['donations'] as List?) ?? const [];
  final inDonations = donations.any((d) {
    final date = (d['date'] ?? '') as String;
    return date.startsWith(month) &&
        (d['cat'] == hokCat ||
            (d['amount'] == hok['amount'] && _or(d['cur'], '₪') == hok['cur']));
  });
  if (inDonations) return true;
  final hist = (sp['hist'] as List?) ?? const [];
  return hist.any((h) {
    final hd = (h['d'] ?? '') as String;
    return hd.startsWith(month) &&
        (h['clearer'] == 'נדרים' ||
            h['clearer'] == 'סולה' ||
            (h['a'] == hok['amount'] && _or(h['c'], '₪') == hok['cur']));
  });
}
