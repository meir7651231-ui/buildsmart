// ⚛️ אטום-Dart (דרגת-חוזה) · ayinAllRows — דוח כל-השמות בכרטיסי מעקב-הטיפול.
// מוצא: maor/src/lib/ayin.ts:296-334 (קריאות-השכן שוקעו) · המקור: new/atoms/ayin-all-rows.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: שורה פר-שם בכל תיקי-ה-ayin; שורת-כותרת ראשונה. בלי-ayin מדולג · שם-רווחים מדולג ·
//        eyes ריק/null ⇒ '' (0 נשמר) · done ⇒ 'טופל ✓' אחרת 'ממתין'.
// שקעים (חוק-1): unitLabel(cfg)→String · emptyAyin()→Map (תיק-ריק עם כל המערכים) ·
//        stageLabel(cfg, stage)→String.
// קלט: cfg · supporters · שלושת השקעים. פלט: List<List<Object?>> (כותרת + שורה פר-שם).
//
// הערת-המרה (מקור→Dart):
//   • תא מעורב String/int (eyes=3/0 מול טקסט) ⇒ List<List<Object?>>.
//   • truthiness של JS (`!sp.ayin` · `phone||''` · `note||''` · `n.done ? …`) שוחזר ב-`_jsTruthy`
//     (undefined/null/''/0/false/NaN = כוזב) — מקביל-ביט ל-JS.
//   • `n.eyes !== '' && n.eyes != null` ⇒ שדה-חסר (null ב-Dart) וגם '' מפולים ל-'' ; 0 נשמר.
//   • merge `{...emptyAyin(), ...sp.ayin}` ⇒ spread של שני Map ב-Dart (מפתחות-ayin גוברים).
//   • אין locale/פורמט/getMonth/מוטביליות זרה.

/// דוח כל-השמות בתיקי-ה-ayin. שורת-כותרת + שורה פר-שם לא-ריק. התנהגות זהה-ביט למקור-ה-JS.
List<List<Object?>> ayinAllRows(
  Object? cfg,
  List<dynamic> supporters,
  String Function(Object? cfg) unitLabel,
  Map<dynamic, dynamic> Function() emptyAyin,
  String Function(Object? cfg, Object? stage) stageLabel,
 {required String Function(String) term}) {
  final unit = unitLabel(cfg);
  final rows = <List<Object?>>[
    [term('tvrmt'), term('tlpvn'), term('shm'), unit, term('harh'), term('sttvs'), term('shlb')],
  ];
  for (final sp in supporters) {
    final spm = sp as Map;
    if (!_jsTruthy(spm['ayin'])) continue;
    final a = <dynamic, dynamic>{...emptyAyin(), ...(spm['ayin'] as Map)};
    final names = (a['names'] as List);
    for (final nDyn in names) {
      final n = nDyn as Map;
      final nameVal = n['name'];
      if (nameVal == null || (nameVal as String).trim().isEmpty) continue;
      final eyes = n['eyes'];
      rows.add([
        spm['name'],
        _jsTruthy(spm['phone']) ? spm['phone'] : '',
        n['name'],
        (eyes != '' && eyes != null) ? eyes : '',
        _jsTruthy(n['note']) ? n['note'] : '',
        _jsTruthy(n['done']) ? term('tvpl') : term('mmtyn'),
        stageLabel(cfg, a['stage']),
      ]);
    }
  }
  return rows;
}

/// מקביל-ביט ל-truthiness של JS: undefined/null/''/0/-0/false/NaN = כוזב, השאר = אמת.
bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}
