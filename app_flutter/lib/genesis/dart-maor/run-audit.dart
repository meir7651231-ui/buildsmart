/// חוט · run-audit — מנוע בדיקת-תקינות-הנתונים (8 קטגוריות ממצאים).
/// המרה נאמנה מ-new/atoms/run-audit.mjs (חוק-4: המקור קדוש); חוזה: run-audit.contract.md.
/// השכנים termOf · normName · validIsraeliId · phoneIssue · ageOf · supporterAggregates
/// מוזרקים כאובייקט-שקעים deps (חוק-1 — אפס import של אטום אחר).
/// טיוטת-ה-AST שימשה נקודת-פתיחה בלבד; תיקונים מעבר לה:
///  · נתונים = Map/List (גישת-מפתח, לא property-access); deps = Map של פונקציות.
///  · truthiness של JS ⇒ עוזר _truthy (כלל-7); ‏`!x`/`if(x)` על כל ערך.
///  · שרשור-מחרוזות עם מספרים ⇒ _jsStr — ‏int בלי נקודה, ‏double שלם בלי ‎.0,
///    ‏null⇒'undefined' (property-access חסר ב-JS) — כמו String(x) של JS.
///  · ‏for-in על אובייקט-JS ⇒ _jsKeys: מפתחות-אינדקס-מערך קנוניים (בלי אפס-מוביל,
///    ‏0..2^32-2) ממוינים מספרית תחילה, השאר בסדר-הכנסה — סדר-ECMAScript המלא
///    (משפיע על סדר-הממצאים כשמפתחות-ת"ז מספריים — g3).
///  · ‏[...new Set(a)] על אובייקטים ⇒ דדופ-משמר-סדר (זהות-אובייקט, _dedupe).
///  · ‏Array.prototype.join ⇒ _jsJoin (‏null/undefined⇒'' — דין-join של JS).
///  · ‏a.map(f=>f.id).sort().join() ⇒ מיון-מחרוזות (compareTo ≡ קוד-UTF-16 של JS)
///    ומפריד ',' (ברירת-המחדל של join).
///  · חיסור/השוואה מספריים על ערכי-JS ⇒ _jsToNum (‏null⇒0 · מחרוזת⇒tryParse⇒NaN,
///    כלל-10 — ‏num.parse של Dart זורק).

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// digits — קבוע-עזר מקומי של קובץ-המקור, מוטבע כלשונו: (x||'').replace(/\D/g,'').
String _digits(dynamic x) =>
    _truthy(x) ? x.toString().replaceAll(RegExp(r'\D'), '') : '';

List runAudit(dynamic db,
    [dynamic todayIso = '', dynamic extra = true, dynamic config, Map? deps]) {
  final termOf = deps!['termOf'];
  final normName = deps['normName'];
  final validIsraeliId = deps['validIsraeliId'];
  final phoneIssue = deps['phoneIssue'];
  final ageOf = deps['ageOf'];
  final supporterAggregates = deps['supporterAggregates'];
  final issues = [];
  dynamic T(dynamic k, dynamic fb) =>
      _truthy(config) ? termOf(config, k, fb) : fb;
  void add(dynamic cat, dynamic title, dynamic famId) =>
      issues.add({'cat': cat, 'title': title, 'famId': famId});
  // הגנה מפני נתונים מיובאים פגומים — כלי הבדיקה לעולם לא קורס על מה שהוא בודק
  List members(dynamic f) =>
      (f['members'] is List) ? f['members'] as List : [];
  List families() =>
      (db['families'] is List) ? db['families'] as List : [];
  // ——— כפילויות משפחה: שם+אם · טלפון משותף · ת"ז משותפת ———
  final g1 = <dynamic, dynamic>{};
  final g2 = <dynamic, dynamic>{};
  final g3 = <dynamic, dynamic>{};
  for (final f in families()) {
    final k1 = _jsStr(normName(f['name'])) +
        '|' +
        _jsStr(normName(_truthy(f['mother']) ? f['mother'] : ''));
    ((g1[k1] ??= []) as List).add(f);
    for (final p in [f['phone'], f['phone2']]) {
      final d = _digits(p);
      if (d.length >= 7) ((g2[d] ??= []) as List).add(f);
    }
    for (final idn in [f['fatherId'], f['motherId']]) {
      final d = _digits(idn);
      if (d.length >= 5) ((g3[d] ??= []) as List).add(f);
    }
  }
  for (final k in _jsKeys(g1)) {
    final a = g1[k] as List;
    if (a.length > 1 && !(k as String).endsWith('|')) {
      add(
          'כפילות',
          'שם + שם האם זהים: "' +
              _jsStr(a[0]['name']) +
              '" — ' +
              _jsStr(a.length) +
              ' רשומות',
          a[0]['id']);
    }
  }
  final seenPair = <String>{};
  for (final k in _jsKeys(g2)) {
    final a = _dedupe(g2[k] as List);
    if (a.length > 1) {
      final ids = a.map((f) => _jsStr(f['id'])).toList()..sort();
      final key = ids.join(',');
      if (!seenPair.contains(key)) {
        seenPair.add(key);
        add(
            'כפילות',
            'טלפון ' +
                _jsStr(k) +
                ' משותף ל-' +
                _jsStr(a.length) +
                ' ' +
                _jsStr(T('nav.families', 'משפחות')) +
                ': ' +
                _jsJoin(a.map((f) => f['name']).take(3), ', '),
            a[0]['id']);
      }
    }
  }
  for (final k in _jsKeys(g3)) {
    final a = _dedupe(g3[k] as List);
    if (a.length > 1) {
      add(
          'כפילות',
          'ת"ז ' +
              _jsStr(k) +
              ' מופיעה ב-' +
              _jsStr(a.length) +
              ' ' +
              _jsStr(T('nav.families', 'משפחות')) +
              ': ' +
              _jsJoin(a.map((f) => f['name']).take(2), ', '),
          a[0]['id']);
    }
  }
  // ——— בדיקות פר-משפחה ———
  for (final f in families()) {
    for (final pair in [
      [f['fatherId'], 'אב'],
      [f['motherId'], 'אם'],
    ]) {
      final idn = pair[0];
      final who = pair[1];
      final d = _digits(idn);
      if (d.isNotEmpty && !_truthy(validIsraeliId(d))) {
        add(
            'ת"ז',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': ת"ז ' +
                _jsStr(who) +
                ' לא עוברת ספרת ביקורת (' +
                _jsStr(idn) +
                ')',
            f['id']);
      }
    }
    for (final p in [f['phone'], f['phone2']]) {
      final pi = phoneIssue(p);
      if (_truthy(pi)) {
        add(
            'טלפון',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': ' +
                _jsStr(pi),
            f['id']);
      }
    }
    if (_truthy(f['email']) && !_emailRe.hasMatch(f['email'].toString())) {
      add(
          'אימייל',
          _jsStr(T('entity.familyOf', 'משפחת')) +
              ' ' +
              _jsStr(f['name']) +
              ': אימייל לא תקין (' +
              _jsStr(f['email']) +
              ')',
          f['id']);
    }
    if (f['status'] != 'inactive') {
      if (!_truthy(f['city'])) {
        add(
            'כתובת',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': חסרה עיר',
            f['id']);
      } else if (!_truthy(f['address'])) {
        add(
            'כתובת',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': יש עיר אבל חסרה כתובת',
            f['id']);
      }
    }
    final single = f['maritalStatus'] == 'אלמן/ה' ||
        f['maritalStatus'] == 'גרושים' ||
        f['maritalStatus'] == 'פרודים';
    if (single && _truthy(f['father']) && _truthy(f['mother'])) {
      add(
          'לוגיקה',
          _jsStr(T('entity.familyOf', 'משפחת')) +
              ' ' +
              _jsStr(f['name']) +
              ': מסומנת "' +
              _jsStr(f['maritalStatus']) +
              '" — אמורה להיות בלי בן/בת זוג, אבל רשומים שניים (' +
              _jsStr(f['father']) +
              ' + ' +
              _jsStr(f['mother']) +
              ')',
          f['id']);
    } else if (single &&
        _digits(f['fatherId']).isNotEmpty &&
        _digits(f['motherId']).isNotEmpty) {
      add(
          'לוגיקה',
          _jsStr(T('entity.familyOf', 'משפחת')) +
              ' ' +
              _jsStr(f['name']) +
              ': מסומנת "' +
              _jsStr(f['maritalStatus']) +
              '" אבל רשומות שתי תעודות זהות של בני זוג',
          f['id']);
    }
    if (f['maritalStatus'] == 'נשואים' &&
        f['status'] == 'active' &&
        !_truthy(f['father']) &&
        !_truthy(f['mother'])) {
      add(
          'לוגיקה',
          _jsStr(T('entity.familyOf', 'משפחת')) +
              ' ' +
              _jsStr(f['name']) +
              ': מסומנת נשואים אבל לא רשום אף בן זוג',
          f['id']);
    }
    if (_digits(f['phone']).isEmpty &&
        _digits(f['phone2']).isEmpty &&
        !_truthy(f['email'])) {
      add(
          'קשר',
          _jsStr(T('entity.familyOf', 'משפחת')) +
              ' ' +
              _jsStr(f['name']) +
              ': אין שום פרט קשר (טלפון או אימייל)',
          f['id']);
    }
    final seenKid = <String>{};
    for (final m in members(f)) {
      if (_truthy(m['isParent'])) {
        if (_truthy(m['idNum']) && !_truthy(validIsraeliId(m['idNum']))) {
          add(
              'ת"ז',
              _jsStr(T('entity.familyOf', 'משפחת')) +
                  ' ' +
                  _jsStr(f['name']) +
                  ': ת"ז של ' +
                  _jsStr(m['first']) +
                  ' (הורה) לא תקינה',
              f['id']);
        }
        continue;
      }
      if (!_truthy(m['birth'])) {
        add(
            'ילדים',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': ל' +
                _jsStr(m['first']) +
                ' אין תאריך לידה',
            f['id']);
      } else {
        final a = ageOf(m['birth']);
        if (a != null && (_jsNum(a) < 0 || _jsNum(a) > 25)) {
          add(
              'ילדים',
              _jsStr(T('entity.familyOf', 'משפחת')) +
                  ' ' +
                  _jsStr(f['name']) +
                  ': גיל חריג ל' +
                  _jsStr(m['first']) +
                  ' (' +
                  _jsStr(a) +
                  ')',
              f['id']);
        }
      }
      if (_truthy(m['idNum']) && !_truthy(validIsraeliId(m['idNum']))) {
        add(
            'ת"ז',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': ת"ז של ' +
                _jsStr(m['first']) +
                ' לא תקינה',
            f['id']);
      }
      final mp = phoneIssue(m['phone']);
      if (_truthy(mp)) {
        add(
            'טלפון',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': טלפון של ' +
                _jsStr(m['first']) +
                ' — ' +
                _jsStr(mp),
            f['id']);
      }
      final kk =
          _jsStr(m['first']) + '|' + _jsStr(_truthy(m['birth']) ? m['birth'] : '');
      if (seenKid.contains(kk)) {
        add(
            'כפילות',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(f['name']) +
                ': הילד/ה ' +
                _jsStr(m['first']) +
                ' מופיע/ה פעמיים',
            f['id']);
      }
      seenKid.add(kk);
    }
  }
  // ——— לוגיקה: תשלום-יתר בשיבוצים ———
  // אינדקס חבר→משפחה במעבר יחיד, במקום find מקונן לכל שיבוץ.
  final famByMember = <dynamic, dynamic>{};
  for (final f in families()) {
    for (final m in members(f)) {
      famByMember[m['id']] = f;
    }
  }
  for (final e
      in (db['enrollments'] is List) ? db['enrollments'] as List : []) {
    final pays = _truthy(e['payments']) ? e['payments'] as List : [];
    dynamic paid = 0; // reduce((a,x)=>a+x.amount, 0) — `+` פולימורפי: מחרוזת⇒שרשור
    for (final x in pays) {
      paid = _jsPlus(paid, _prop(x, 'amount')); // מפתח-חסר⇒undefined⇒NaN; מחרוזת⇒שרשור
    }
    if (_truthy(e['totalDue']) && _jsGt(paid, e['totalDue'])) {
      final fam = famByMember[e['memberId']];
      if (fam != null) {
        add(
            'לוגיקה',
            _jsStr(T('entity.familyOf', 'משפחת')) +
                ' ' +
                _jsStr(fam['name']) +
                ': שולם ₪' +
                _jsConcat(paid) + // `+ paid` פולימורפי: מחרוזת נשמרת ('012')
                ' — יותר מסה"כ העסקה (₪' +
                _concatProp(e, 'totalDue') +
                '). בדקו החזר או עדכנו את הסכום',
            fam['id']);
      }
    }
  }
  // ——— תומכים: ת"ז לא תקינה · טלפון · כפילות שם · אי-התאמת מצבור/פירוט ———
  final supByName = <dynamic, dynamic>{};
  final supporters =
      (db['supporters'] is List) ? db['supporters'] as List : [];
  for (final sp in supporters) {
    if (_truthy(sp['idNum']) &&
        _digits(sp['idNum']).isNotEmpty &&
        !_truthy(validIsraeliId(sp['idNum']))) {
      issues.add({
        'cat': 'ת"ז',
        'title': 'תומכ/ת ' +
            _jsStr(sp['name']) +
            ': ת"ז לא תקינה (' +
            _jsStr(sp['idNum']) +
            ')',
        'spId': sp['id'],
      });
    }
    final pi = phoneIssue(sp['phone']);
    if (_truthy(pi)) {
      issues.add({
        'cat': 'טלפון',
        'title': 'תומכ/ת ' + _jsStr(sp['name']) + ': ' + _jsStr(pi),
        'spId': sp['id'],
      });
    }
    if (_truthy(sp['email']) && !_emailRe.hasMatch(sp['email'].toString())) {
      issues.add({
        'cat': 'אימייל',
        'title': 'תומכ/ת ' +
            _jsStr(sp['name']) +
            ': אימייל לא תקין (' +
            _jsStr(sp['email']) +
            ')',
        'spId': sp['id'],
      });
    }
    // עקביות מצבור מול פירוט התרומות — #14 (הכרעת בעלים): המצבור נגזר מ-donations+hist.
    final agg = supporterAggregates(sp) as Map;
    bool off(dynamic a, dynamic b) =>
        (_orZeroNum(a) - _orZeroNum(b)).abs() > 0.5;
    if (off(sp['ils'], agg['ils']) ||
        off(sp['usd'], agg['usd']) ||
        _or(sp['count'], 0) != agg['count']) {
      issues.add({
        'cat': 'לוגיקה',
        'title': 'תומכ/ת ' +
            _jsStr(sp['name']) +
            ': הסכום המצטבר הרשום (₪' +
            _jsStr(_or(sp['ils'], 0)) +
            (_truthy(sp['usd']) ? ' + \$' + _jsStr(sp['usd']) : '') +
            ' · ' +
            _jsStr(_or(sp['count'], 0)) +
            ' ' +
            _jsStr(T('entity.donations', 'תרומות')) +
            ') לא תואם את פירוט ה' +
            _jsStr(T('entity.donations', 'תרומות')) +
            ' (₪' +
            _jsStr(agg['ils']) +
            (_truthy(agg['usd']) ? ' + \$' + _jsStr(agg['usd']) : '') +
            ' · ' +
            _jsStr(agg['count']) +
            ' ' +
            _jsStr(T('entity.donations', 'תרומות')) +
            ')',
        'spId': sp['id'],
      });
    }
    // ——— ביקורת מורחבת (P2 פער 22) ———
    if (_truthy(extra) &&
        _truthy(todayIso) &&
        _truthy(sp['nextDate']) &&
        _jsLt(sp['nextDate'], todayIso)) {
      issues.add({
        'cat': 'קשר',
        'title': 'עבר יעד הקשר של "' +
            _jsStr(sp['name']) +
            '" (' +
            _jsStr(sp['nextDate']) +
            ')',
        'spId': sp['id'],
      });
    }
    if (_truthy(extra)) {
      for (final d
          in (sp['donations'] is List) ? sp['donations'] as List : []) {
        if (!(_jsNum(d['amount']) > 0)) {
          issues.add({
            'cat': 'לוגיקה',
            'title': _jsStr(T('entity.donation', 'תרומה')) +
                ' בסכום ' +
                _concatProp(d, 'amount') + // null-מפורש⇒'null' · מפתח-חסר⇒'undefined'
                ' אצל "' +
                _jsStr(sp['name']) +
                '" (' +
                _jsStr(d['rid']) +
                ')',
            'spId': sp['id'],
          });
        }
      }
    }
    final nk = normName(sp['name']);
    if (_truthy(nk)) ((supByName[nk] ??= []) as List).add(sp['id']);
  }
  for (final k in _jsKeys(supByName)) {
    final ids = supByName[k] as List;
    if (ids.length > 1) {
      dynamic sp;
      for (final x in supporters) {
        if (x['id'] == ids[0]) {
          sp = x;
          break;
        }
      }
      if (sp != null) {
        issues.add({
          'cat': 'כפילות',
          'title': 'תומכ/ת בשם "' +
              _jsStr(sp['name']) +
              '" מופיע/ה ' +
              _jsStr(ids.length) +
              ' פעמים',
          'spId': sp['id'],
        });
      }
    }
  }
  return issues;
}

/// שקע-truthiness שמחקה את JS: null / false / '' / 0 / NaN = falsy, השאר truthy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// ‏String(x) של JS לשרשור: מספרים בלי ‎.0 מיותר, ‏null⇒'undefined'
/// (property-access חסר ב-JS = undefined; ‏null-מפורש נדיר בנתוני-המקור).
String _jsStr(dynamic v) {
  if (v == null) return 'undefined';
  if (v is num) return _jsNumStr(v);
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

String _jsNumStr(num v) {
  if (v is int) return v.toString();
  final d = v as double;
  if (d.isNaN) return 'NaN';
  if (d.isInfinite) return d > 0 ? 'Infinity' : '-Infinity';
  if (d == d.truncateToDouble() && d.abs() < 1e21) {
    return d.truncate().toString();
  }
  return d.toString();
}

/// ⚙️ תיקון-הסגר (26.8, גל-שחרור-תאריכים): הקוארציה-המספרית של בדיקת-הסכום
/// השתמשה ב-num.tryParse שאינו מכיר בינארי/אוקטלי (‏0b/0o) — ‏JS ‏Number('0b101')=5
/// מול ‏Dart null⇒NaN, ‏ממצא-שווא. הוחלף ל-שקע jsStrToNum/jsNum המאומת מהספרייה
/// (machtzev/emit/js-compat-reference.dart) — מוטבע כלשונו עם קידומת _ (חוק-1: אטום
/// לא-מייבא). ‏jsNum מטפל גם ב-null⇒NaN (‏Number(undefined) — מפתח-חסר בנתונים).
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

/// ‏ToNumber של JS על מחרוזת (כלל-10/18): דקדוק-ES קפדני + הקסה/אוקטלי/בינארי.
double _jsStrToNum(String raw) {
  final s = _jsTrim(raw);
  if (s.isEmpty) return 0.0;
  if (s == 'Infinity' || s == '+Infinity') return double.infinity;
  if (s == '-Infinity') return double.negativeInfinity;
  if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(s)) {
    return _fromRadix(s.substring(2), 16);
  }
  if (RegExp(r'^0[oO][0-7]+$').hasMatch(s)) return _fromRadix(s.substring(2), 8);
  if (RegExp(r'^0[bB][01]+$').hasMatch(s)) return _fromRadix(s.substring(2), 2);
  if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) {
    return double.nan;
  }
  return double.tryParse(s) ?? double.nan;
}

double _fromRadix(String digits, int radix) {
  try {
    return BigInt.parse(digits, radix: radix).toDouble();
  } catch (_) {
    return double.nan;
  }
}

/// ‏ToNumber כללי (כל טיפוס) במרחב-double של JS (כלל-10/17): ‏null≡undefined⇒NaN.
double _jsNum(dynamic v) {
  if (v == null) return double.nan;
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStrToNum(v);
  return double.nan;
}

/// סנטינל ל-undefined של JS (מפתח-חסר) — נבדל מ-null-מפורש (חוק-2). זהות-יחידה.
const Object _undef = _Undef();

class _Undef {
  const _Undef();
}

/// ‏a['k'] של JS: קיים ⇒ הערך (null-מפורש נשמר); חסר ⇒ סנטינל-undefined.
dynamic _prop(dynamic m, dynamic k) =>
    (m is Map && m.containsKey(k)) ? m[k] : _undef;

/// ‏String(x) לשרשור-אופרטור `+` של JS: **null-מפורש ⇒ 'null'** (בשונה מ-_jsStr
/// שנותן 'undefined' למפתח-חסר); סנטינל-undefined ⇒ 'undefined'; מספר ⇒ בלי ‎.0.
String _jsConcat(dynamic v) {
  if (identical(v, _undef)) return 'undefined';
  if (v == null) return 'null';
  if (v is num) return _jsNumStr(v);
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

/// ‏שרשור-property של JS: ‏'…' + obj.key — מפתח-חסר⇒'undefined', null⇒'null'.
String _concatProp(dynamic m, dynamic k) => _jsConcat(_prop(m, k));

/// ToNumber בהקשר `+`/`>` שמבחין null↔undefined (חוק-2): **null-מפורש⇒0**
/// (‏Number(null)=0 · ‏0+null=0), **סנטינל-undefined⇒NaN** (‏Number(undefined)).
/// (_jsNum הכללי נותן null⇒NaN לשימושים אחרים; כאן ההבחנה קריטית ל-reduce.)
double _numAdd(dynamic v) {
  if (identical(v, _undef)) return double.nan;
  if (v == null) return 0.0;
  return _jsNum(v);
}

/// אופרטור `+` של JS (פולימורפי): מחרוזת באחד הצדדים ⇒ שרשור-מחרוזות
/// (‏0 + '100' ⇒ '0100'); אחרת חיבור-מספרי float64 (‏undefined⇒NaN · null⇒0).
/// (הערכים כאן פרימיטיביים כבר ⇒ ToPrimitive = זהות.)
dynamic _jsPlus(dynamic a, dynamic b) {
  if (a is String || b is String) return _jsConcat(a) + _jsConcat(b);
  return _numAdd(a) + _numAdd(b);
}

/// אופרטור `>` של JS (השוואה-יחסית): שני-מחרוזות ⇒ קוד-UTF-16 (compareTo);
/// אחרת ToNumber שני-הצדדים (‏'012'⇒12 · '00b101'⇒NaN⇒false · null⇒0). NaN⇒false.
bool _jsGt(dynamic a, dynamic b) {
  if (a is String && b is String) return a.compareTo(b) > 0;
  return _numAdd(a) > _numAdd(b);
}

/// ‏(a||0) של JS ואז שימוש מספרי.
num _orZeroNum(dynamic v) => _truthy(v) ? _jsNum(v) : 0;

/// ‏(a||b) של JS — הערך עצמו, בלי המרה.
dynamic _or(dynamic a, dynamic b) => _truthy(a) ? a : b;

/// ‏a < b של JS: שתי מחרוזות ⇒ השוואת קוד-UTF-16 (compareTo זהה); אחרת מספרית.
bool _jsLt(dynamic a, dynamic b) {
  if (a is String && b is String) return a.compareTo(b) < 0;
  return _jsNum(a) < _jsNum(b);
}

/// סדר-מפתחות של for-in על אובייקט-JS (ECMAScript): מפתחות-אינדקס-מערך
/// קנוניים (ספרות בלבד, בלי אפס-מוביל, ‏0..2^32-2) ממוינים מספרית תחילה,
/// אחריהם שאר המפתחות בסדר-הכנסה. משפיע כשמפתחות הם ספרות-ת"ז/טלפון.
Iterable<dynamic> _jsKeys(Map m) {
  final idx = <String>[];
  final rest = <dynamic>[];
  for (final k in m.keys) {
    if (k is String && _isArrayIndex(k)) {
      idx.add(k);
    } else {
      rest.add(k);
    }
  }
  idx.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  return [...idx, ...rest];
}

bool _isArrayIndex(String s) {
  final n = int.tryParse(s);
  return n != null && n >= 0 && n <= 4294967294 && n.toString() == s;
}

/// ‏[...new Set(a)] של JS על אובייקטים — דדופ משמר-סדר (זהות-אובייקט:
/// ‏Map של Dart לא דורס ==, כמו SameValueZero על reference).
List _dedupe(List a) {
  final seen = <dynamic>{};
  final out = [];
  for (final x in a) {
    if (seen.add(x)) out.add(x);
  }
  return out;
}

/// ‏Array.prototype.join של JS: ‏null/undefined ⇒ מחרוזת ריקה.
String _jsJoin(Iterable xs, String sep) =>
    xs.map((v) => v == null ? '' : _jsStr(v)).join(sep);
