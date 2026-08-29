/// חוט · plan-demo-cleanup — תכנון ניקוי נתוני-דמו שהתערבבו בנתונים האמיתיים.
/// המרה נאמנה מ-new/atoms/plan-demo-cleanup.mjs (חוק-4: המקור קדוש) — התנהגות זהה-לחלוטין.
/// המנוע לא ייצר טיוטה (dart-from-maor ריק) ⇒ הומר ידנית. תיקונים מעבר ל-AST:
///  · SEP = '' (בייט SOH מהמקור, לא מחרוזת-ריקה).
///  · `{...db}` ⇒ Map.from — עותק-רדוד, כך שישות-ללא-דמו נשמרת כאותה הפניה (identical).
///  · `String(x ?? '')` ⇒ שקע `_jsStrOrEmpty` (null/undefined⇒'', מספר-שלם בלי נקודה כמו JS).
///  · truthiness `if(id)` / `|| '(ללא שם)'` ⇒ בדיקת-מחרוזת-ריקה מפורשת (כלל-7).
///  · Set/List טהורים; db לא-מוטבל (keep/drop רשימות-חדשות).
Map<String, dynamic> planDemoCleanup(Map db, Map demoDb, {required Map<String, dynamic> fpFields}) {
  final cleaned = Map<String, dynamic>.from(db);
  final removed = <String, dynamic>{};
  // ids של ישויות-אב שהוסרו — לצורך מפל
  final removedIds = <String, Set<String>>{};
  final removedMemberIds = <String>{};

  for (final ent in fpFields.keys) {
    final cur = db[ent];
    final demo = demoDb[ent];
    if (cur is! List || demo is! List || demo.isEmpty) continue;
    final fields = fpFields[ent]!;
    final demoFps = <String>{for (final r in demo) _fingerprint(r, fields)};
    final keep = <dynamic>[];
    final drop = <dynamic>[];
    final ids = <String>{};
    for (final r in cur) {
      if (demoFps.contains(_fingerprint(r, fields))) {
        drop.add(r);
        final id = _jsStrOrEmpty(r is Map ? r['id'] : null);
        if (id.isNotEmpty) ids.add(id);
        // חברי-משפחה שהוסרה — לצורך מפל-שיבוצים (memberId)
        if (ent == 'families' && r is Map && r['members'] is List) {
          for (final m in (r['members'] as List)) {
            final mid = _jsStrOrEmpty(m is Map ? m['id'] : null);
            if (mid.isNotEmpty) removedMemberIds.add(mid);
          }
        }
      } else {
        keep.add(r);
      }
    }
    if (drop.isNotEmpty) {
      cleaned[ent] = keep;
      removedIds[ent] = ids;
      removed[ent] = <String, dynamic>{
        'count': drop.length,
        'names': [for (final r in _take(drop, 8)) _nameOf(r)],
      };
    }
  }

  // ── מפל: רשומות-תלויות שמצביעות על ישות-דמו שהוסרה ──
  bool has(String ent, dynamic id) {
    final s = removedIds[ent];
    return s != null && s.contains(_jsStrOrEmpty(id));
  }

  void cascade(String ent, bool Function(Map r) pred) {
    final cur = db[ent];
    if (cur is! List) return;
    final keep = <dynamic>[];
    final drop = <dynamic>[];
    for (final r in cur) {
      (pred(r as Map) ? drop : keep).add(r);
    }
    if (drop.isNotEmpty) {
      cleaned[ent] = keep;
      final prevEntry = removed[ent] as Map?;
      final prev = (prevEntry?['count'] as int?) ?? 0;
      final existing = (prevEntry?['names'] as List?) ?? const [];
      final names = _take(<dynamic>[
        ...existing,
        for (final r in _take(drop, 8)) _nameOf(r),
      ], 8);
      removed[ent] = <String, dynamic>{
        'count': prev + drop.length,
        'names': names,
      };
    }
  }

  // שיבוצים: חבר-דמו או חוג-דמו
  cascade('enrollments',
      (r) => removedMemberIds.contains(_jsStrOrEmpty(r['memberId'])) || has('courses', r['courseId']));
  // מסירות: יום/מתנדב/שיוך/משפחה של דמו
  cascade(
      'deliveries',
      (r) =>
          has('distributionDays', r['dayId']) ||
          has('volunteers', r['volunteerId']) ||
          has('shopAssignments', r['assignmentId']) ||
          has('families', r['familyId']));
  // שיוכי-חנות: מוצר-דמו או משפחת-דמו
  cascade('shopAssignments', (r) => has('shopProducts', r['productId']) || has('families', r['famId']));
  // קופות-צדקה: רכז-דמו או משפחת-דמו
  cascade('tzBoxes', (r) => has('tzCoordinators', r['coordinatorId']) || has('families', r['famId']));

  var total = 0;
  for (final k in removed.keys) {
    total += (removed[k] as Map)['count'] as int;
  }
  return {'cleaned': cleaned, 'total': total, 'removed': removed};
}

/// שדות-זיהוי יציבים פר-ישות (בלי id/תאריכים/מערכים-מקוננים/מונים).
/// Map של Dart שומר על סדר-הכנסה ⇒ ROOT_ENTITIES = fpFields.keys (זהה ל-Object.keys).

/// מפריד-השדות במקור: בייט SOH (0x01), לא מחרוזת-ריקה.
const String _sep = '';

String _fingerprint(dynamic rec, List<String> fields) {
  return fields.map((f) => _jsStrOrEmpty(rec is Map ? rec[f] : null)).join(_sep);
}

String _nameOf(dynamic rec) {
  final m = rec is Map ? rec : const {};
  // JS: rec?.name ?? rec?.title ?? rec?.id ?? '' — ?? תופס רק null/undefined.
  final picked = m['name'] ?? m['title'] ?? m['id'] ?? '';
  final s = _jsStr(picked).trim();
  return s.isEmpty ? '(ללא שם)' : s;
}

/// שקע-`String(x ?? '')`: null/undefined ⇒ '', אחרת String(x).
String _jsStrOrEmpty(dynamic v) => v == null ? '' : _jsStr(v);

/// שקע-`String(x)` של JS: מספר-שלם בלי נקודה-עשרונית (String(100)==='100'),
/// bool⇒'true'/'false', מחרוזת כמותשהיא. מיישר להתנהגות-המקור.
String _jsStr(dynamic v) {
  if (v is String) return v;
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) {
    if (v is int) return v.toString();
    final d = v as double;
    if (d.isNaN) return 'NaN';
    if (d.isInfinite) return d.isNegative ? '-Infinity' : 'Infinity';
    if (d == d.roundToDouble()) return d.toInt().toString();
    return d.toString();
  }
  return v.toString();
}

/// שקע-`Array.slice(0, n)`: n הראשונים (או פחות אם קצר).
List<dynamic> _take(List<dynamic> list, int n) =>
    list.sublist(0, list.length < n ? list.length : n);
