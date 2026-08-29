// ⚛️ אטום-Dart (דרגת-חוזה) · normalizeTelephony — חיטוי תצורת-הטלפוניה
//    (allowlist מלא + ברירות-מחדל). מוצא: maor/src/lib/config.ts:169-211 ·
//    המקור: new/atoms/normalize-telephony.mjs · חוזה: normalize-telephony.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core RegExp).
//    השכנים telStr/telExt הוזרקו כשקעי-פונקציה (חוק-1 — אפס import פנימי);
//    הקבועים TEL_KINDS/TEL_HHMM_RE שוכנו כאן. חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//    המנוע-האוטומטי נכשל לגמרי על אטום זה (dart-from-maor: "engine-failed") ⇒ פורט ידנית.
//
// deps (שקעים):
//  · telStr: String Function(dynamic, int) — מחטא-מחרוזת עם תקרת-אורך (ריק=falsy).
//  · telExt: String Function(dynamic, String) — מחטא-שלוחה (ספרות, ≤8) עם ברירת-מחדל.
//
// הערות-המרה (DART-PORTING-RULES):
//  · כלל 2 (null≠undefined): המקור מחזיר `undefined` לזבל ⇒ Dart מחזיר `null`.
//    `!raw || typeof!=='object' || isArray` ⇒ `raw is! Map` (null/List/פרימיטיב אינם Map).
//  · כלל 5 (substring שלילי/גלישה): `.slice(0,24)` של JS לא-זורק כש-len<24 ⇒ שקע _sliceMax.
//  · כלל 7 (truthiness): `telStr(...) || fallback` — '' של telStr הוא falsy ⇒ `isNotEmpty ? s : fb`.
//    `o.kosher === true` / `t.enabled === true` ⇒ השוואה-מפורשת `== true` (רק bool-true עובר).
//  · `Array.isArray` ⇒ `is List`; `typeof==='object' && !isArray` ⇒ `is Map`.
//  · `Number.isInteger(d)` ⇒ `d is int` (קלטי-הזהב שלמים; double אינו int, כמו שאינו integer).
//  · מיון officeDays: `.sort((a,b)=>a-b)` על ints-ייחודיים = מיון-מספרי מלא ⇒ `..sort()`
//    דטרמיניסטי, אין תלות-ביציבות (כלל 1 לא רלוונטי — כל האיברים ייחודיים).
//  · אין locale/getMonth/תאריך/מודולו מעורבים.

const List<String> _telKinds = ['sim', 'virtual', 'whatsapp'];
final RegExp _telHhmmRe = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
final RegExp _e164Strip = RegExp(r'[^\d+()\-\s]');
final RegExp _nonAz = RegExp(r'[^a-z]');

/// slice(0,n) בטוח — JS `str.slice(0,n)` לא-זורק גם כש-len<n; Dart substring כן (כלל 5).
String _sliceMax(String s, int n) => s.length <= n ? s : s.substring(0, n);

/// חיטוי תצורת-הטלפוניה — allowlist מלא + ברירות-מחדל. פורט ביט-זהה מ-config.ts:169-211.
/// זבל (לא-אובייקט) ⇒ null (המקביל ל-undefined של המקור).
Map<String, dynamic>? normalizeTelephony(
  dynamic raw,
  String Function(dynamic, int) telStr,
  String Function(dynamic, String) telExt,
) {
  if (raw is! Map) return null;
  final t = raw;

  final numsRaw = t['numbers'] is List ? (t['numbers'] as List).take(64).toList() : <dynamic>[];
  final numbers = <Map<String, dynamic>>[];
  for (var i = 0; i < numsRaw.length; i++) {
    final n = numsRaw[i];
    if (n is! Map) continue;
    final o = n;
    final kind = _telKinds.contains(o['kind']) ? o['kind'] : 'sim';
    final e164 = o['e164'] is String
        ? _sliceMax((o['e164'] as String).replaceAll(_e164Strip, '').trim(), 24)
        : '';
    final ids = telStr(o['id'], 32);
    final id = ids.isNotEmpty ? ids : 'n${i + 1}';
    final labelS = telStr(o['label'], 60);
    final num = <String, dynamic>{
      'id': id,
      'e164': e164,
      'label': labelS.isNotEmpty ? labelS : id,
      'kind': kind,
    };
    if (o['kosher'] == true) num['kosher'] = true;
    numbers.add(num);
  }

  final daysRaw = t['officeDays'] is List ? (t['officeDays'] as List) : <dynamic>[0, 1, 2, 3, 4];
  final officeDays = daysRaw.where((d) => d is int && d >= 0 && d <= 6).cast<int>().toSet().toList()
    ..sort();

  bool boolf(dynamic v, bool def) => v is bool ? v : def;
  String hhmm(dynamic v, String def) => (v is String && _telHhmmRe.hasMatch(v)) ? v : def;

  // עיר — [a-z] בלבד, 2–20 תווים; אורך פסול ⇒ '' (מושמט, לא נגזם).
  final cityRaw = t['city'] is String ? (t['city'] as String).toLowerCase().replaceAll(_nonAz, '') : '';

  final out = <String, dynamic>{};
  // מתג-המקטע — opt-in: נשמר רק כשהוא bool-true בדיוק (חסר/false ⇒ מושמט).
  if (t['enabled'] == true) out['enabled'] = true;
  out['numbers'] = numbers;
  out['officeDays'] = officeDays;
  out['officeStart'] = hhmm(t['officeStart'], '09:00');
  out['officeEnd'] = hhmm(t['officeEnd'], '17:00');
  out['officeExt'] = telExt(t['officeExt'], '101');
  out['managerExt'] = telExt(t['managerExt'], '201');
  out['vmBox'] = telExt(t['vmBox'], '100');
  out['city'] = (cityRaw.length >= 2 && cityRaw.length <= 20) ? cityRaw : '';
  out['kosherMode'] = boolf(t['kosherMode'], false);
  out['hebrewCalendar'] = boolf(t['hebrewCalendar'], true);
  out['zmanim'] = boolf(t['zmanim'], false);
  out['shabbat'] = boolf(t['shabbat'], true);
  out['fasts'] = boolf(t['fasts'], false);
  out['voicemail'] = boolf(t['voicemail'], true);
  return out;
}
