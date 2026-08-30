/// חוט · suggestions — מנוע מקדים-הצורך (SHOP8): חג מתקרב · גיל בית-ספר ·
/// תינוק · כרטיסייה נגמרת. המרה נאמנה מ-new/atoms/suggestions.mjs
/// (חוק-4: המקור קדוש). השכנים termOf/moduleOn/upcomingHoliday/ageAt מוזרקים
/// כשקעים במפת-sockets — כמו הדה-סטרקטור בחתימת ה-JS (חוק-1: אפס import פנימי).
/// ‏db/config = מבנים דינמיים (Map/List); ‏undefined מיוצג בהיעדר-מפתח (חוק-2).

const int _pow2_53 = 9007199254740992; // 2^53 — גבול השלם-הבטוח של JS

/// truthiness של JS (חוק-7): null/false/0/NaN/'' ⇒ falsy; כל אובייקט ⇒ truthy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// ‏String(num) של JS — shortest-round-trip (חוק-12). מאומת מול js-compat jsStr:
/// שלם-בטוח ⇒ בלי ".0"; טווח [2^53,1e21) ⇒ עשרוני-מלא **בלי ".0"** דרך
/// toStringAsFixed(0) (התיקון להסגר — Dart פורס שם ".0" עשרוני, לא מדעי,
/// והרג'קס-הישן שחיפש 'e+' פספס והחזיר את ה".0" בטעות); ‏≥1e21 ⇒ מעריכי;
/// שבר ⇒ ה-toString הקצר של Dart; ‏-0 ⇒ '0'.
String _jsNum(num v) {
  if (v is int) return v.toString();
  final d = v as double;
  if (d.isNaN) return 'NaN';
  if (d == double.infinity) return 'Infinity';
  if (d == double.negativeInfinity) return '-Infinity';
  if (d == 0) return '0'; // כולל -0.0 — JS String(-0) === '0'
  final neg = d < 0;
  final ad = neg ? -d : d;
  String body;
  if (ad == ad.truncateToDouble() && ad < 1e21) {
    // שלם-ערך בטווח [1, 1e21): עשרוני-מלא, בלי ".0".
    if (ad < _pow2_53) {
      body = ad.toInt().toString();
    } else {
      body = ad.toStringAsFixed(0); // אין ".0" — התיקון להסגר
    }
  } else {
    // שבר או ≥1e21 — ה-toString של Dart כבר shortest-round-trip (זהה-ל-V8).
    body = ad.toString();
  }
  return neg ? '-' + body : body;
}

/// ToString של תבנית-מחרוזת JS (`${v}`).
String _jsStr(dynamic v) {
  if (v == null) return 'null';
  if (v is String) return v;
  if (v is num) return _jsNum(v);
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

/// גישת-מאפיין לתבנית: מפתח-חסר = undefined ⇒ 'undefined' (חוק-2 — containsKey!).
String _strAt(dynamic obj, String key) {
  if (obj is Map && obj.containsKey(key)) return _jsStr(obj[key]);
  return 'undefined';
}

/// ‏trim בקבוצת-הרווחים של ECMAScript בלבד (חוק-16) — בלי U+0085/U+180E.
/// מאומת מול js-compat jsTrim (codeUnit-set, לא literal-פריך).
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

/// ‏ToNumber של JS על ערך-מאפיין (חוק-15): null ⇒ 0 · bool ⇒ 0/1 ·
/// מחרוזת-גזומה-ריקה ⇒ 0 · לא-מספר ⇒ NaN (num.tryParse, לא parse-זורק — חוק-10).
num _jsToNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final t = _jsTrim(v);
    if (t.isEmpty) return 0;
    if (t == 'Infinity' || t == '+Infinity') return double.infinity;
    if (t == '-Infinity') return double.negativeInfinity;
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan;
}

/// ‏obj.key מספרי לחיסור: מפתח-חסר = undefined ⇒ NaN (חוק-2), אחרת ToNumber.
num _numAt(dynamic obj, String key) {
  if (obj is Map) return obj.containsKey(key) ? _jsToNum(obj[key]) : double.nan;
  return double.nan;
}

/// ‏Array.prototype.find: האיבר הראשון שמקיים, אחרת null (undefined של JS).
dynamic _find(dynamic list, bool Function(dynamic) pred) {
  if (list is List) {
    for (final x in list) {
      if (pred(x)) return x;
    }
  }
  return null;
}

/// המנוע: 4 כללים ⇒ רשימת-הצעות {key,emoji,title,detail,famId?,courseId?,act}.
/// ‏sockets = {termOf, moduleOn, upcomingHoliday, ageAt} — שקעי-השכנים המוזרקים.
List<dynamic> suggestions(dynamic db,
  dynamic todayIso,
  dynamic config,
  Map<String, dynamic> sockets, Map<String, dynamic> T2) {
  final dynamic termOf = sockets['termOf'];
  final dynamic moduleOn = sockets['moduleOn'];
  final dynamic upcomingHoliday = sockets['upcomingHoliday'];
  final dynamic ageAt = sockets['ageAt'];

  // JS: const T = (k, fb) => (config ? termOf(config, k, fb) : fb)
  dynamic t(dynamic k, dynamic fb) => _truthy(config) ? termOf(config, k, fb) : fb;
  // גידור-מודולים: בלי config (בדיקות ישנות) הכול פעיל, כמו חוזה-הדגלים.
  bool modOn(dynamic m) => !_truthy(config) || _truthy(moduleOn(config, m));

  final out = <dynamic>[];
  final activeFams = <dynamic>[];
  for (final f in (db['families'] as List)) {
    if ((f as Map)['status'] == 'active') activeFams.add(f);
  }

  // A — חג מתקרב (מודול חנות בלבד — היעד הוא מתנת-חג בחנות)
  final hol = upcomingHoliday(todayIso, 30);
  if (modOn('shop') && _truthy(hol) && activeFams.length > 0) {
    // מפתח 'sug:' פטור מגיזום-30-הימים — השנה העברית במפתח ⇒ החג הבא עולה מחדש.
    out.add(<String, dynamic>{
      'key': 'sug:holiday:${_strAt(hol, 'name')}:${_strAt(hol, 'hebYear')}',
      'emoji': '🎁',
      'title': '${T2['k8']!}${_strAt(hol, 'name')}${T2['k9']!}${_strAt(hol, 'inDays')}${T2['k10']!}',
      'detail':
          '${_jsNum(activeFams.length)} ${_jsStr(t('nav.families', 'משפחות'))}${T2['k13']!}',
      'act': 'shop',
    });
  }

  // B/C — לפי גיל הילדים
  for (final f in activeFams) {
    for (final m in ((f as Map)['members'] as List)) {
      if (_truthy((m as Map)['isParent'])) continue;
      final age = ageAt(m['birth'], todayIso);
      if (age == 6 || age == 5) {
        // הגיל במפתח — ביטול בגיל 5 לא מסתיר את ההצעה המחודשת בגיל 6.
        out.add(<String, dynamic>{
          'key': 'sug:school:${_strAt(m, 'id')}:${_jsStr(age)}',
          'emoji': '🎒',
          'title': '${T2['k15']!}${_strAt(m, 'first')} (${_strAt(f, 'name')})',
          'detail': '${T2['k16']!}${_jsStr(age)}${T2['k17']!}',
          'famId': f['id'],
          'act': 'families',
        });
      } else if (age == 0) {
        out.add(<String, dynamic>{
          'key': 'sug:baby:${_strAt(m, 'id')}',
          'emoji': '👶',
          'title':
              '${T2['k19']!}${_jsStr(t('entity.familyOf', 'משפחת'))} ${_strAt(f, 'name')}',
          'detail':
              '${_strAt(m, 'first')}${T2['k22']!}${_jsStr(t('entity.family', 'משפחה'))}',
          'famId': f['id'],
          'act': 'families',
        });
      }
    }
  }

  // D — כרטיסייה נגמרת (מודול חוגים בלבד — הנתון והיעד שניהם בחוגים)
  for (final e
      in (modOn('courses') ? (db['enrollments'] as List) : const <dynamic>[])) {
    if ((e as Map)['plan'] != 'punch' || e['status'] != 'active') continue;
    final rem = _numAt(e, 'purchased') - _numAt(e, 'used');
    // NaN: שתי ההשוואות false — כמו ב-JS ההצעה נוצרת עם 'נותרו NaN ניקובים'.
    if (rem > 2 || rem < 0) continue;
    final course = _find(db['courses'], (c) => (c as Map)['id'] == e['courseId']);
    final fam = _find(
      db['families'],
      (f) => ((f as Map)['members'] as List)
          .any((m) => (m as Map)['id'] == e['memberId']),
    );
    final member = fam == null
        ? null
        : _find(fam['members'], (m) => (m as Map)['id'] == e['memberId']);
    // purchased = סמן-דור-מילוי דטרמיניסטי במפתח — חידוש מציף מחדש.
    out.add(<String, dynamic>{
      'key': 'sug:renew:${_strAt(e, 'id')}:${_strAt(e, 'purchased')}',
      'emoji': '🎫',
      'title':
          '${T2['k26']!}${_jsStr((member is Map ? member['first'] : null) ?? '—')} · ${_jsStr((course is Map ? course['name'] : null) ?? '—')}',
      'detail': rem <= 0 ? T2['k6']! : '${T2['k27']!}${_jsStr(rem)}${T2['k28']!}',
      'famId': fam == null ? null : fam['id'],
      'courseId': e['courseId'],
      'act': 'courses',
    });
  }
  return out;
}
