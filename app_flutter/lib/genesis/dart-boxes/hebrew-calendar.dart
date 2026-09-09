import '../dart-data-maor/heb-month-he-sockets.dart' as skb_hmh;
import '../dart-data-maor/gematria-sockets.dart' as td_gematria;
// 📦 קופסת-חיבורים · לוח עברי (Dart) — מחווטת 4 אטומי-Dart. מקבילה ל-new/boxes/hebrew-calendar.mjs.
// חוזה משותף: new/boxes/hebrew-calendar.contract.md. מקור-האמת: maor/src/lib/hebrew.ts.
// זהו ההוכחה ש-מאור(JS) ובנייה-חכמה(Dart) מתחברות לאותה קופסה: אותם קלטים ⇒ אותו פלט.
//
// דבק-החיווט `_noon` = כלל-הצהריים — הכרעת-הקופסה (ידע-קופסה, חוק-5/6), לא אטום.
// המקור: `const noon = (iso) => new Date(String(iso).slice(0,10) + 'T12:00:00')`.
// פער-הייצוג "תאריך-שבור": ה-JS מייצג תאריך לא-תקין כ-Invalid Date (isNaN);
// ל-Dart אין DateTime לא-תקין — התאום מייצג "שבור" כ-null, בדיוק כפי שהאטומים
// (hebParts/hebMonthHe) מקבלים DateTime? ומחזירים חלקים-בטוחים/'' על null.
import '../dart-maor/gematria.dart' as g;
import '../dart-maor/heb-parts.dart' as hp;
import '../dart-maor/heb-month-he.dart' as hm;
import '../dart-maor/adar-norm.dart' as an;

// ── דבק-החיווט: כלל-הצהריים (ידע-קופסה) ──────────────────────────────────────
// String(iso).slice(0,10) + 'T12:00:00' ⇒ תאריך בצהרי-המקום. קלט-שבור ⇒ null.
DateTime? _noon(String iso) {
  final s = iso.length > 10 ? iso.substring(0, 10) : iso;
  return DateTime.tryParse('${s}T12:00:00');
}

/// רכיבי-התאריך-העברי של [iso] דרך כלל-הצהריים. שבור/ריק ⇒ {day:0,month:'',year:0}.
Map<String, Object> parts(String iso) => hp.hebParts(_noon(iso));

/// תאריך-עברי מלא בעברית: "‹יום גימטרי› ‹חודש› ‹שנה גימטרית פרטית›".
/// קלט ריק/null ⇒ '' (מקביל ל-`!iso`); קלט שבור ⇒ '' (מקביל ל-isNaN).
String fullDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final d = _noon(iso);
  if (d == null) return '';
  final p = hp.hebParts(d);
  final day = p['day'] as int;
  final year = p['year'] as int;
  return '${g.gem(day, td_gematria.gematria_U, td_gematria.gematria_T, td_gematria.gematria_H, td_gematria.gematria_T2)} ${hm.hebMonthHe(d, skb_hmh.hebMonthHe_monthNames)} ${g.gem(year % 1000, td_gematria.gematria_U, td_gematria.gematria_T, td_gematria.gematria_H, td_gematria.gematria_T2)}';
}

/// מפתח-חזרה-שנתית: "‹חודש-מנורמל-אדר› ‹יום›". חודש ריק (קלט שבור) ⇒ ''.
String annualKey(String iso) {
  final p = parts(iso);
  final month = p['month'] as String;
  return month.isNotEmpty ? '${an.adarNorm(month)} ${p['day']}' : '';
}
