// חוט · next-closure — הסגירה ההלכתית הבאה (שבת/יו״ט, חלון 10 ימים) לווידג'ט-הבית.
// מוצא: maor/src/components/telephony/lib.ts:186-198 · המקור: new/atoms/next-closure.mjs.
// המרה נאמנה מ-JS — התנהגות זהה-לחלוטין למקור (חוק-4: המקור קדוש).
// השכנים hebrewClosedWindows (מנוע-הזמנים) ו-CITIES (מילון-ערים) מוזרקים כשקעים
// (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
//
// הערות-המרה (מקור→Dart · תיקוני-מנוע):
//   • `!tel`: tel = config.telephony הוא מפה-או-undefined; מפה=truthy, חסר=falsy ⇒ `== null`.
//   • `tel.city || 'default'`: JS `||` נופל על falsy (null/''); ⇒ בדיקת null-או-ריק מפורשת.
//   • `const w = wins[0]; if (!w)`: ב-JS wins[0] על ריק = undefined ⇒ null. ב-Dart
//     `wins[0]` על ריק **זורק RangeError** ⇒ שער `wins.isEmpty` לפני-האינדוקס (המנוע פספס).
//   • `.he`/`.jerusalem`: המנוע פלט גישת-שדה-נקודה על מפות (Dart לא-חוקי) ⇒ `['he']`/`['jerusalem']`.
//   • תנאי cityHe: `tel.city && CITIES[tel.city]` = שתיהן truthy ⇒ `!= null && != ''`.
//   • אין locale/פורמט/getMonth/מודולו-שלילי מעורבים — אין שקע-שפה להוסיף.
Map<String, dynamic>? nextClosure(
  Map<String, dynamic> config,
  String todayIso,
  List Function(String fromIso, int windowDays, Map<String, dynamic> tenant,
          Map<String, dynamic> opt)
      hebrewClosedWindows,
  Map<String, dynamic> CITIES,
) {
  final tel = config['telephony'];
  if (tel == null) return null;
  final cityRaw = tel['city'];
  final city = (cityRaw == null || cityRaw == '') ? 'default' : cityRaw;
  final Map<String, dynamic> tenant = {'city': city, 'timezone': 'Asia/Jerusalem'};
  final wins = hebrewClosedWindows(todayIso, 10, tenant, <String, dynamic>{});
  if (wins.isEmpty) return null;
  final w = wins[0];
  final tc = tel['city'];
  final cityHe = (tc != null && tc != '' && CITIES[tc] != null)
      ? CITIES[tc]['he']
      : CITIES['jerusalem']['he'];
  return {
    'reason': w['reason'],
    'kind': w['kind'],
    'startIso': w['startIso'],
    'candle': w['startTime'],
    'endIso': w['endIso'],
    'tzeis': w['endTime'],
    'cityHe': cityHe,
  };
}
