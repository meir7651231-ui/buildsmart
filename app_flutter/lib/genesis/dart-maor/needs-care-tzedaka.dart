// ⚛️ אטום-Dart (דרגת-חוזה) · needsCare — רשימת-הטיפול של מודול-הקופות (צדקה).
// מוצא: maor/src/components/tzedaka/lib.ts:101-141 · המקור: new/atoms/needs-care-tzedaka.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). חמשת השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        termOf · staleBoxes · lastCollectionIso · coordinatorBoxes · isoOf.
//
// תפקיד: מקבץ ארבעה סוגי-התרעה על מודול-הקופות, בסדר-המקור בדיוק:
//        (1) 'stale'         — קופות שלא רוקנו מזמן (מהשקע staleBoxes).
//        (2) 'lost'          — קופות בסטטוס 'lost'.
//        (3) 'inactiveCoord' — רכז לא-פעיל שעדיין מחזיק קופות-בבתים (status 'home').
//        (4) 'campaignEnding'— מבצע פעיל שמסתיים בתוך 14 יום מהיום.
// קלט:  db={tzBoxes[], tzCoordinators[], tzCampaigns[]} · todayIso · config? · sockets.
//        פלט: List<Map> ‏{kind,id,label,hint}.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע פספס/סילף):
//  • `var undefined = sockets` (זבל-AST) — נמחק; השקעים נשלפים מ-sockets המפה.
//  • `config ? ...` truthiness (כלל-7): config=undefined⇒'קופה'. Dart: `config != null`
//    (בבדיקה config הוא null או Map — Map תמיד אמת, מכסה גם {} הריק שהוא truthy ב-JS).
//  • שרשור-מספר: JS ‏'קופה ' + b.num ממיר אוטומטית; Dart דורש `.toString()`.
//  • `last ? ...` / `b.since || '—'` truthiness (כלל-7): מחרוזת-ריקה = falsy ⇒ שקע `_truthy`
//    (לא `??` — `??` תופס רק null ויחמיץ '' שהמקור מטפל בו).
//  • `!x.active` ⇒ `_falsy(x['active'])`; `if (holding)` ⇒ `holding > 0` (0 = falsy ב-JS).
//  • תאריך-מגלגל (setDate): `soon.setDate(getDate()+14)` הוא הוספת-יום-קלנדרית עם גלישת-חודש.
//    Dart DateTime לא-מוטבל + `.add(Duration)` היה חשוף ל-DST ⇒ בונים DateTime מפורש
//    ‏(year, month, day+14, ...) — הבנאי מנרמל גלישה בדיוק כמו setDate, בלי שעון-קיץ.
//  • השוואת-מחרוזות ISO ‏(`>=`/`<=`) ⇒ `compareTo` (לקסיקוגרפי, זהה ל-JS על מחרוזות).

/// The care-list of the tzedaka (charity-box) module: stale/lost boxes, inactive
/// coordinators still holding boxes, and campaigns ending within 14 days — in source
/// order. Verbatim port of new/atoms/needs-care-tzedaka.mjs (`needsCare`); the five
/// neighbours (termOf, staleBoxes, lastCollectionIso, coordinatorBoxes, isoOf) are
/// injected as sockets (Law 1/3).
List<Map<String, dynamic>> needsCare(
  Map<String, dynamic> db,
  String todayIso,
  Map<String, dynamic>? config,
  Map<String, dynamic> sockets,
 {required String Function(String) term}) {
  final termOf = sockets['termOf'];
  final staleBoxes = sockets['staleBoxes'];
  final lastCollectionIso = sockets['lastCollectionIso'];
  final coordinatorBoxes = sockets['coordinatorBoxes'];
  final isoOf = sockets['isoOf'];

  final boxTerm =
      config != null ? termOf(config, 'entity.tzBox', term('kvph')) : term('kvph');
  final out = <Map<String, dynamic>>[];

  for (final b in (staleBoxes(db['tzBoxes'], todayIso) as Iterable)) {
    final last = lastCollectionIso(b);
    out.add({
      'kind': 'stale',
      'id': b['id'],
      'label': boxTerm + ' ' + b['num'].toString() + term('la-rvknh-mzmn'),
      'hint': _truthy(last)
          ? term('rykvn-achrvn') + (last as String)
          : term('mavlm-la-rvknh-maz') +
              (_truthy(b['since']) ? b['since'].toString() : '—') +
              ')',
    });
  }

  for (final b in (db['tzBoxes'] as List).where((x) => x['status'] == 'lost')) {
    out.add({
      'kind': 'lost',
      'id': b['id'],
      'label': boxTerm + ' ' + b['num'].toString() + term('msvmnt-kabvdh'),
      'hint': term('lbrr-av-lhvtsya-mshymvsh'),
    });
  }

  for (final c in (db['tzCoordinators'] as List).where((x) => _falsy(x['active']))) {
    final holding = (coordinatorBoxes(db['tzBoxes'], c['id']) as Iterable)
        .where((b) => b['status'] == 'home')
        .length;
    if (holding > 0) {
      out.add({
        'kind': 'inactiveCoord',
        'id': c['id'],
        'label': c['name'] +
            term('aynv-payl-ak-adyyn-am') +
            holding.toString() +
            term('kvpvt-bbtym'),
        'hint': term('lhabyr-lrkz-achr-av-lhchzyr-lmshrd'),
      });
    }
  }

  final soonBase = DateTime.parse(todayIso + 'T12:00:00');
  final soon = DateTime(soonBase.year, soonBase.month, soonBase.day + 14,
      soonBase.hour, soonBase.minute, soonBase.second);
  final soonIso = isoOf(soon);
  for (final p in (db['tzCampaigns'] as List).where((x) =>
      _truthy(x['active']) &&
      _truthy(x['end']) &&
      (x['end'] as String).compareTo(todayIso) >= 0 &&
      (x['end'] as String).compareTo(((soonIso) as String)) <= 0)) {
    out.add({
      'kind': 'campaignEnding',
      'id': p['id'],
      'label': term('hmbtsa') + (p['name'] as String) + term('mstyym-b') + (p['end'] as String),
      'hint': term('lskm-vlsgvr'),
    });
  }

  return out;
}

/// JS truthiness: null/undefined, false, 0, and '' are falsy; everything else truthy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.isNotEmpty;
  return true;
}

bool _falsy(dynamic v) => !_truthy(v);
