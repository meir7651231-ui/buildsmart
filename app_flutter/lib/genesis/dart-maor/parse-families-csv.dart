// ⚛️ אטום-Dart (דרגת-חוזה) · parseFamiliesCsv — תכנון ייבוא-משפחות 13 עמודות.
// מוצא: maor/src/lib/familiesImport.ts:60-114 (חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/parse-families-csv.mjs · החוזה: new/atoms/parse-families-csv.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). שלושת השכנים
//        (clean / normName / digits) = שקעי-פרמטר (חוק-1 — קריאות-השכן הוזרקו).
//
// תפקיד: פענוח קובץ-משפחות 13 עמודות ל-{news, upds} — טהור, לא נוגע ב-store.
//        שורה-1=כותרת (מדולגת) · ניקויים כבלגאסי (יריד-חנוכה, #NAME?, עיר, סטטוס…).
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES + חוק-4):
//  • `!name` / `!digits(x)` (truthiness של JS על מחרוזת) ⇒ שקע `_falsy` (כלל 7) —
//    '' ⇒ falsy. `name || ''` / `r[12] || ''` / `clean(r[10]) || 'חסידי'` ⇒ `_falsy ? …`
//    ולא `??` (המנוע פספס: `??` תופס null בלבד, JS `||` תופס גם '').
//  • `/יריד חנוכה/.test(name)` ⇒ `RegExp(...).hasMatch(name)` (Dart אין `.test`).
//  • `name.replace(/…/g, '')` הוא **גלובלי** ⇒ `replaceAll` (המנוע כתב replaceFirst — סטייה).
//  • `name.replace('#NAME?', '')` (מחרוזת) = החלפת-מופע-ראשון בלבד ⇒ `replaceFirst` (מחרוזת=ליטרל).
//  • `noteRaw.match(/…/)` ⇒ `RegExp(...).firstMatch(noteRaw)`; `[1]` ⇒ `group(1)`;
//    `(… || [])[1] || ''` ⇒ `?.group(1) ?? ''` (אין match ⇒ '').
//  • `.filter(Boolean)` ⇒ `.where((s) => !_falsy(s))` (מסיר מחרוזות ריקות).
//  • `existing.find(…)` (מחזיר undefined אם אין) ⇒ לולאה עם `null` (Dart `firstWhere` **זורק**;
//    המנוע כתב firstWhere — סטייה שהייתה מפילה על אי-התאמה). `if (ex)` ⇒ `if (ex != null)`.
//  • גישת-שדה `f.name`/`obj.phone`/`ex.id` ⇒ גישת-Map `f['name']`/`obj['phone']`/`ex['id']`
//    (existing/obj הם Map, לא אובייקטים עם getters).
//  • אין locale/פורמט/getMonth/מודולו/תאריך-מגלגל מעורבים — שאר כללי-ההמרה לא חלים כאן.

/// Plan a 13-column families-import CSV into {news, upds} (verbatim of the JS
/// source new/atoms/parse-families-csv.mjs). Row 0 = header (skipped). The three
/// neighbours clean/normName/digits are injected as sockets (Law 1).
Map<String, List> parseFamiliesCsv(
  List rows,
  List existing,
  String Function(dynamic) clean,
  String Function(dynamic) normName,
  String Function(dynamic) digits,
 {required String Function(String) term}) {
  final List news = [];
  final List upds = [];
  for (final r in rows.sublist(1)) {
    var name = clean(r[0]);
    if (_falsy(name) || name.contains(term('shm-prty-shm-mshpchh'))) continue;
    var isFair = false;
    if (RegExp(term('yryd-chnvkh')).hasMatch(name)) {
      isFair = true;
      name = clean(name.replaceAll(RegExp(term('yryd-chnvkh-tshp')), ''));
    }
    name = clean(name.replaceFirst('#NAME?', ''));
    if (_falsy(name)) continue;
    var city = clean(r[6]);
    if (city == term('rgyl')) city = '';
    if (city == term('bytr') || city == term('bytr-alyt')) city = term('bytr-aylyt');
    final noteRaw = _falsy(r[12]) ? '' : r[12].toString();
    final stc = clean(
        RegExp(term('sttvs')).firstMatch(noteRaw)?.group(1) ?? '');
    final r9 = _falsy(r[9]) ? '' : r[9].toString();
    final community = clean(r[10]);
    final Map<String, dynamic> obj = {
      'name': name,
      'father': '',
      'mother': clean(r[3]),
      'fatherId': clean(r[1]),
      'motherId': clean(r[4]),
      'phone': clean(r[2]) == '-' ? '' : clean(r[2]),
      'phone2': clean(r[5]) == '-' ? '' : clean(r[5]),
      'email': '',
      'address': clean([r[7], r[8]].map(clean).where((s) => !_falsy(s)).join(' ')),
      'city': city,
      'status': stc.contains(term('la-payl')) ? 'inactive' : 'active',
      'maritalStatus': (stc.contains(term('almn')) || r9.contains(term('t10')))
          ? term('almnh')
          : stc.contains(term('grvsh'))
              ? term('grvshym')
              : term('nshvaym'),
      'language': term('abryt'),
      'community': _falsy(community) ? term('chsydy') : community,
      'notes': isFair ? term('hshttph-byryd-chnvkh-tshpv') : '',
    };
    dynamic ex;
    for (final f in existing) {
      if (normName(f['name']) == normName(name) &&
          (_falsy(digits(obj['phone'])) ||
              _falsy(digits(f['phone'])) ||
              digits(f['phone']) == digits(obj['phone']))) {
        ex = f;
        break;
      }
    }
    if (ex != null) {
      upds.add({'id': ex['id'], 'obj': obj});
    } else {
      news.add(obj);
    }
  }
  return {'news': news, 'upds': upds};
}

/// JS falsiness for the values that flow here (String/null): '' / null / 0 /
/// false / NaN ⇒ falsy. Mirrors JS `!x` and `x || y` exactly (Law 4).
bool _falsy(Object? v) =>
    v == null ||
    v == false ||
    v == '' ||
    v == 0 ||
    (v is num && v.isNaN);
