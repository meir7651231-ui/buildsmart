// ⚛️ אטום-Dart (דרגת-חוזה) · forecastFromScan — חיזוי-מתנה-הבאה (סכום/מועד/ביטחון).
// מוצא: maor-system/src/components/supporters/intel.ts:131 (forecastFromScan)+MS_DAY:13 · המקור: new/atoms/intel-forecast-from-scan.mjs.
// טוהר: פונקציית top-level עצמאית, import שפה-בלבד (dart:math). חוק-4 — זהה-ביט למקור-JS.
//        השכן dayDiff הוזרק כשקע-פרמטר (חוק-1/חוק-3).
//
// ⚠️ נקודות-עדינות (אומתו מול Node ב-TZ=UTC):
//  • `Date.parse(last+'T12:00:00')` = צהריים-**מקומי** ⇒ DateTime.parse(...).millisecondsSinceEpoch (מקומי).
//  • `new Date(dueMs).toISOString().slice(0,10)` = תאריך ב-**UTC**. הוטבע inline:
//    DateTime.fromMillisecondsSinceEpoch(ms, isUtc:true) ⇒ מרכיבי-UTC ⇒ 'YYYY-MM-DD'.
//    דין-ה-UTC קריטי; דטרמיניסטי רק כשהשעון ב-UTC (כפי שנלכד ה-Golden).
//  • `new Date(float)` = TimeClip⇒ToInteger (חיתוך-לעבר-אפס) ⇒ dueMs.toInt() (חיתוך זהה).
//  • `Math.round` ⇒ _jsRound (floor(x+0.5)); confidence-שלילי אפשרי אך נבלע ב-max(15,…).
//  • הפלט Map בסדר: amount → dueIso → confidence · count==0/last-ריק ⇒ null (Map?).
import 'dart:math' as math;

int _jsRound(num x) => (x + 0.5).floor();

/// Next-gift forecast {amount, dueIso, confidence} — or null. Verbatim port of
/// intel-forecast-from-scan.mjs (`forecastFromScan`). `dayDiff` injected as a socket (Law 1/3).
Map<String, dynamic>? forecastFromScan(
    Map<String, dynamic> scan, String todayIso, num Function(String, String) dayDiff) {
  const msDay = 86400000;
  final last = scan['last'];
  if (scan['count'] == 0 || last == null || last == '') return null;
  final num ils = scan['ils'] as num;
  final int count = scan['count'] as int;
  final int avg = _jsRound(ils / count);
  final first = scan['first'];
  final num span = (first != null && first != '' && first != last)
      ? dayDiff(first as String, last as String)
      : 0;
  final num cadence = (count >= 2 && span > 0) ? span / (count - 1) : 365;
  final ls = last as String;
  final lastMs = DateTime.parse('${ls.length < 10 ? ls : ls.substring(0, 10)}T12:00:00')
      .millisecondsSinceEpoch;
  final num dueMs = lastMs + cadence * msDay;
  final due = DateTime.fromMillisecondsSinceEpoch(dueMs.toInt(), isUtc: true);
  final dueIso = '${due.year.toString().padLeft(4, '0')}-'
      '${due.month.toString().padLeft(2, '0')}-'
      '${due.day.toString().padLeft(2, '0')}';
  final num daysSince = dayDiff(ls, todayIso);
  final num overdue = cadence > 0 ? math.max(0.0, daysSince / cadence - 1) : 0;
  final int confidence =
      math.max(15, math.min(92, _jsRound(30 + count * 7 - overdue * 25)));
  return {'amount': avg, 'dueIso': dueIso, 'confidence': confidence};
}
