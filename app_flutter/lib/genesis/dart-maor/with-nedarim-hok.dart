// ⚛️ אטום-Dart (דרגת-חוזה) · withNedarimHok — מילוי משבצת-ההו"ק מחיוב-נדרים
// חוזר (kevaId); ידני לא נדרס. חיוב עם kevaId ⇒ תומך חדש עם hok מלא
// (סכום/מטבע/יום, method='card', active=true, startedAt=המוקדם-מבין).
// לא-נוגע (sp כלשונו): amount≤0 · בלי kevaId · הו"ק ידני קיים (hok בלי kevaId).
// מוצא: maor/src/lib/nedarimSync.ts:172-192 · המקור: new/atoms/with-nedarim-hok.mjs
// חוזה: new/atoms/with-nedarim-hok.contract.md · טוהר: top-level, אפס import.
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1, שכני-הקובץ הוזרקו כפרמטרים):
//   curOf(charge)      ⇒ '₪'|'$' — מטבע מנורמל מהעסקה.
//   hokDayFromDate(iso) ⇒ 1–28  — יום-החיוב מתאריך-העסקה.
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  · `!(charge.amount > 0)` — amount חסר/null/NaN ⇒ ההשוואה כוזבת ⇒ sp כלשונו;
//    ב-Dart: is num && >0 (NaN>0 כוזב גם ב-JS).
//  · `(charge.kevaId || '')` — falsy-של-JS (חסר/null/'') ⇒ ''; ‏trim לפי קבוצת-ES
//    בלבד (כלל-16: U+0085/U+180E אינם נגזמים — בניגוד ל-Dart.trim).
//  · `sp.hok && !sp.hok.kevaId` — אובייקט תמיד-אמת ב-JS; ‏kevaId כוזב
//    (חסר/null/''/0/NaN/false) ⇒ הו"ק ידני ⇒ לא דורסים (כלל-7 — _falsy מפורש).
//  · `.slice(0, 10)` ⇒ substring מגודר-אורך (כלל-5).
//  · `prevStart < cd` — השוואת-מחרוזות לפי יחידות-UTF-16: compareTo של Dart זהה.
//  · `{...sp, hok:{…}}` — עותק שומר-סדר-הכנסה; מפתח hok קיים שומר את מקומו
//    (סמנטיקת-spread של JS ≡ Map.of + הצבה); סדר מפתחות-hok = סדר-המקור.

/// ‏falsy-של-JS לערך-מפתח (undefined≡null כאן — שני הצדדים חסרי-ערך).
bool _falsy(Object? v) =>
    v == null ||
    v == false ||
    v == '' ||
    (v is num && (v == 0 || v.isNaN));

/// האם יחידת-קוד שייכת לקבוצת-הרווחים של ES (כלל-16 — בלי U+0085/U+180E).
bool _isEsWs(int c) =>
    (c >= 0x09 && c <= 0x0D) || // TAB LF VT FF CR
    c == 0x20 ||
    c == 0xA0 ||
    c == 0x1680 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x2028 ||
    c == 0x2029 ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000 ||
    c == 0xFEFF;

/// ‏trim לפי קבוצת-הרווחים של ES בלבד (כלל-16).
String _trimEs(String s) {
  var a = 0, b = s.length;
  while (a < b && _isEsWs(s.codeUnitAt(a))) a++;
  while (b > a && _isEsWs(s.codeUnitAt(b - 1))) b--;
  return s.substring(a, b);
}

/// ‏`v || ''` על מועמד-מחרוזת: מחרוזת לא-ריקה ⇒ עצמה; אחרת ''.
String _strOr(Object? v) => v is String && v.isNotEmpty ? v : '';

/// Fill the supporter's standing-order (hok) slot from a recurring Nedarim
/// charge (kevaId). Returns a new supporter map with a fully-populated hok, or
/// the very same `sp` reference when untouched (amount≤0, no kevaId, or an
/// existing manual hok). Pure — `sp` is never mutated. Verbatim JS behaviour.
Map<String, Object?> withNedarimHok(
  Map<String, Object?> sp,
  Map<String, Object?> charge,
  String Function(Map<String, Object?>) curOf,
  num Function(String) hokDayFromDate,
) {
  final amt = charge['amount'];
  if (!(amt is num && amt > 0)) return sp; // זיכוי/ביטול (Amount≤0) לא ממלא/מעדכן הו"ק
  final keva = _trimEs(_strOr(charge['kevaId']));
  if (keva.isEmpty) return sp;
  final hok = sp['hok'];
  if (hok is Map && _falsy(hok['kevaId'])) return sp; // הו"ק ידני — לא דורסים
  var cdSrc = _strOr(charge['d']);
  if (cdSrc.isEmpty) cdSrc = _strOr(charge['at']);
  final cd = cdSrc.length > 10 ? cdSrc.substring(0, 10) : cdSrc;
  final prevStart = hok is Map ? _strOr(hok['startedAt']) : '';
  final out = Map<String, Object?>.of(sp);
  out['hok'] = <String, Object?>{
    'amount': amt,
    'cur': curOf(charge),
    'day': hokDayFromDate(cd),
    'method': 'card',
    'note': 'הו״ק נדרים · $keva',
    'active': true,
    'startedAt': prevStart.isNotEmpty && prevStart.compareTo(cd) < 0
        ? prevStart
        : (cd.isNotEmpty ? cd : prevStart),
    'kevaId': keva,
  };
  return out;
}
