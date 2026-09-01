// ⚛️ אטום-Dart (דרגת-חוזה) · ayinDailyRows — שורות הדוח-היומי של מעקב-הטיפול.
// מוצא: maor/src/lib/ayin.ts:249-295 (קריאות-השכן שוקעו) · המקור: new/atoms/ayin-daily-rows.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: רק תומכים ש"נגעו" היום (lastTouch===todayIso או log?.some(date===today)); שורת-כותרת ראשונה.
//        'כמות היום' = סכום log-היום (+eyes||0), ובהיעדרו eyesTotal(a), ו-0 ⇒ ''. שורת-שמות
//        'שם ·כמות ✓' מחוברים ב-' · '. הערה = answers.note מחוברות ב-' | ' או הערת-התיק. nextTalk ⇒ DD/MM/YYYY.
// שקעים (חוק-1): unitLabel(cfg)→String · itemLabel(cfg)→String · emptyAyin()→Map (תיק-ריק עם כל המערכים) ·
//        eyesTotal(a)→num (סכום +eyes||0 על names) · stageLabel(cfg, stage)→String.
// קלט: cfg · supporters · todayIso · חמשת השקעים. פלט: List<List<Object?>> (כותרת + שורה פר-תומך-שנגע).
//
// הערת-המרה (מקור→Dart) — היכן המנוע היה מפספס:
//   • `sp.ayin.log?.some(...)` (optional chaining) ⇒ בדיקת-null מפורשת לפני any (log חסר = false).
//   • merge `{...emptyAyin(), ...sp.ayin}` ⇒ spread של שני Map (מפתחות-ayin גוברים).
//   • `+l.eyes || 0` (Number coercion + NaN→0) שוחזר ב-`_plusEyes`: '3'→3 · ''→0 · חסר→0.
//   • truthiness של JS (`sp.ayin` · `phone||''` · `eyesTotal(a)||''` · `join||note||''` · `n.done`) ⇒ `_jsTruthy`.
//   • `' ·' + n.eyes` (מספר⇒מחרוזת JS) ⇒ `_jsNumStr` (int בלי נקודה עשרונית).
//   • fmtD מקומי (עוזר-פנימי, לא import) ⇒ `_fmtD`. אין locale/getMonth/מוטביליות זרה.

/// שורות הדוח-היומי של מעקב-הטיפול. שורת-כותרת + שורה פר-תומך-שנגע-היום. התנהגות זהה-ביט למקור-ה-JS.
List<List<Object?>> ayinDailyRows(
  Object? cfg,
  List<dynamic> supporters,
  String todayIso,
  String Function(Object? cfg) unitLabel,
  String Function(Object? cfg) itemLabel,
  Map<dynamic, dynamic> Function() emptyAyin,
  num Function(Map<dynamic, dynamic> a) eyesTotal,
  String Function(Object? cfg, Object? stage) stageLabel,
 {required String Function(String) term}) {
  final unit = unitLabel(cfg);
  final item = itemLabel(cfg);
  final rows = <List<Object?>>[
    [term('shm'), term('tlpvn'), '$unit${term('xi_hyvm')}', term('shlb'), item, term('mty-ldbr-shvb'), term('harh')],
  ];

  // touched = supporters.filter(sp => sp.ayin && (ayin.lastTouch===today || ayin.log?.some(l=>l.date===today)))
  final touched = <Map>[];
  for (final spDyn in supporters) {
    final sp = spDyn as Map;
    final ayin = sp['ayin'];
    if (!_jsTruthy(ayin)) continue;
    final ay = ayin as Map;
    final log = ay['log'];
    final logMatch = log is List &&
        log.any((l) => (l as Map)['date'] == todayIso);
    if (ay['lastTouch'] == todayIso || logMatch) touched.add(sp);
  }

  for (final sp in touched) {
    // 🐛 נחיל-עמוק (13.8): ayin חלקי (מלגאסי/ענן, חסר log/names/answers) הפיל את
    // הדוח ואת מסך-התורמים. מיזוג עם emptyAyin מבטיח את כל המערכים.
    final a = <dynamic, dynamic>{...emptyAyin(), ...(sp['ayin'] as Map)};

    final log = (a['log'] as List);
    final logToday =
        log.where((l) => (l as Map)['date'] == todayIso).toList();

    Object? eyesToday;
    if (logToday.isNotEmpty) {
      num t = 0;
      for (final l in logToday) {
        t += _plusEyes((l as Map)['eyes']);
      }
      eyesToday = t;
    } else {
      final et = eyesTotal(a);
      eyesToday = _jsTruthy(et) ? et : '';
    }

    final names = (a['names'] as List);
    final namesLine = names.map((nDyn) {
      final n = nDyn as Map;
      final eyes = n['eyes'];
      final eyesPart =
          (eyes != '' && eyes != null) ? ' ·' + _jsNumStr(eyes) : '';
      final donePart = _jsTruthy(n['done']) ? ' ✓' : '';
      return _jsStr(n['name']) + eyesPart + donePart;
    }).join(' · ');

    final answers = (a['answers'] as List);
    final answersJoined =
        answers.map((x) => _jsStr((x as Map)['note'])).join(' | ');
    final noteLine = _jsTruthy(answersJoined)
        ? answersJoined
        : (_jsTruthy(a['note']) ? _jsStr(a['note']) : '');

    final nextTalk = a['nextTalk'];

    rows.add([
      sp['name'],
      _jsTruthy(sp['phone']) ? sp['phone'] : '',
      eyesToday,
      stageLabel(cfg, a['stage']),
      namesLine,
      _jsTruthy(nextTalk) ? _fmtD(nextTalk as String) : '',
      noteLine,
    ]);
  }

  return rows;
}

/// תצוגת תאריך DD/MM/YYYY מ-ISO (מקומי לדוח — מקביל ל-fmtD במקור).
String _fmtD(String iso) {
  if (iso.isEmpty) return '';
  final parts = iso.split('-');
  final y = parts[0];
  final m = parts.length > 1 ? parts[1] : '';
  final d = parts.length > 2 ? parts[2] : '';
  return '$d/$m/$y';
}

/// מקביל-ביט ל-`+v || 0` של JS: מחרוזת⇒מספר (''/לא-מספרי⇒0) · num⇒עצמו (NaN⇒0) · bool⇒1/0 · null/אחר⇒0.
num _plusEyes(Object? v) {
  if (v is num) return v.isNaN ? 0 : v;
  if (v is String) {
    final p = num.tryParse(v.trim());
    return p ?? 0;
  }
  if (v is bool) return v ? 1 : 0;
  return 0;
}

/// מקביל-ביט ל-truthiness של JS: null/''/0/-0/false/NaN = כוזב, השאר = אמת.
bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// המרת-ערך-למחרוזת כקונקטנציה של JS (`'' + v`): null⇒'' · num⇒ללא-נקודה-עשרונית-מיותרת · השאר⇒toString.
String _jsStr(Object? v) {
  if (v == null) return '';
  if (v is num) return _jsNumStr(v);
  return v.toString();
}

/// מספר⇒מחרוזת בסגנון JS: שלם (int או double שלם) בלי '.0'.
String _jsNumStr(Object? v) {
  if (v is int) return v.toString();
  if (v is double) {
    if (v.isFinite && v == v.truncateToDouble()) {
      return v.toInt().toString();
    }
    return v.toString();
  }
  return v.toString();
}
