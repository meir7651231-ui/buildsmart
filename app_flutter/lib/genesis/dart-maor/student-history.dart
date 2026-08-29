// ⚛️ אטום-Dart (דרגת-חוזה) · studentHistory — היסטוריית-ההשתתפויות של תלמיד/ה, מהחדש לישן.
// מוצא: maor/src/components/courses/reenroll-lib.ts:279-305 · המקור: new/atoms/student-history.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: כל השיבוצים של memberId, שורה פר-שיבוץ עם נתוני-החוג (חוג חסר ⇒ '—' ותאריכים
//        ריקים), yearLabel (course.year גובר, אחרת שקע על start), סימוני-חידוש
//        (fromRenewal = מישהו מצביע עליו ב-renewedToId · renewedForward = לו-עצמו יש),
//        ומיון מהחדש לישן (start יורד, שובר-שוויון enrolledAt יורד).
//        השכנים academicYearLabel ו-enrollSummary הם שקעים (חוק-1).
//
// הערות-המרה (מקור→Dart) — מה שטיוטת-ה-AST פספסה:
//  · `find(...) ?? null` ⇒ לולאת-חיפוש שמחזירה null (firstWhere של Dart זורק על אין-התאמה).
//  · truthiness של JS (חוק-7): `.filter(Boolean)` על renewedToId · `e.group || ''` ·
//    `course?.year || ...` · `start ? ...` · `!!e.renewedToId` — כולם דרך _truthy מפורש
//    ('' / 0 / NaN / false / null ⇒ שקר); `||` של JS מחזיר את האופרנד עצמו, לא בוליאני.
//  · `course?.start ?? ''` — ‏?? של JS תופס גם undefined וגם null; גישת-Map בדארט מחזירה
//    null לשניהם (מפתח-חסר ≡ null-מפורש) ⇒ `?? ''` נאמן כאן (אין הבחנת-containsKey נצפית).
//  · localeCompare() על מחרוזות-ISO (ספרות ומקפים, אותו פורמט) ≡ סדר-code-unit ⇒ compareTo.
//  · Array.sort של JS יציב (ES2019+); List.sort של Dart לא ⇒ decorate-sort-undecorate
//    עם אינדקס-כניסה כשובר-שוויון אחרון (חוק-1 של כללי-ההמרה).
//  · Set.has של JS (SameValueZero) ⇒ Set.contains של Dart — זהה על מזהי-מחרוזת.

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// כל ההשתתפויות של תלמיד/ה לאורך הזמן — התנהגות verbatim של המקור-ה-JS.
/// `academicYearLabel` ו-`enrollSummary` הם שקעים מוזרקים (חוק-1).
List<Map<String, Object?>> studentHistory(
  Map<String, Object?> db,
  Object? memberId,
  Object? Function(Object? startIso) academicYearLabel,
  Object? Function(Map<String, Object?> e) enrollSummary,
) {
  final enrollments = (db['enrollments'] as List).cast<Map<String, Object?>>();
  final courses = (db['courses'] as List).cast<Map<String, Object?>>();
  // מזהי-שיבוצים שמישהו התחדש אליהם (יעד-רישום) — לזיהוי fromRenewal.
  // ‏.filter(Boolean) של JS ⇒ רק ערכי-renewedToId אמת-יים נכנסים לסט.
  final renewTargetIds = <Object?>{};
  for (final e in enrollments) {
    final t = e['renewedToId'];
    if (_truthy(t)) renewTargetIds.add(t);
  }
  final out = <Map<String, Object?>>[];
  for (final e in enrollments) {
    if (e['memberId'] != memberId) continue;
    Map<String, Object?>? course;
    for (final c in courses) {
      if (c['id'] == e['courseId']) {
        course = c;
        break;
      }
    }
    final start = course == null ? '' : (course['start'] ?? '');
    final group = e['group'];
    final year = course?['year'];
    out.add({
      'enrollment': e,
      'courseId': e['courseId'],
      'courseName': course == null ? '—' : (course['name'] ?? '—'),
      'group': _truthy(group) ? group : '', // ‏e.group || '' — האופרנד עצמו כשאמת
      'yearLabel': _truthy(year)
          ? year // ‏course?.year || … — ‏year האמת-י מוחזר כמות-שהוא
          : (_truthy(start) ? academicYearLabel(start) : ''),
      'start': start,
      'end': course == null ? '' : (course['end'] ?? ''),
      'summary': enrollSummary(e),
      'fromRenewal': renewTargetIds.contains(e['id']),
      'renewedForward': _truthy(e['renewedToId']), // ‏!!e.renewedToId
    });
  }
  // מהחדש לישן — start יורד, ואז enrolledAt יורד; אינדקס-כניסה = יציבות-JS (חוק-1).
  String _s(Object? v) => _truthy(v) ? v as String : ''; // ‏(x || '')
  final indexed = <MapEntry<int, Map<String, Object?>>>[];
  for (var i = 0; i < out.length; i++) {
    indexed.add(MapEntry(i, out[i]));
  }
  indexed.sort((x, y) {
    final a = x.value;
    final b = y.value;
    var c = _s(b['start']).compareTo(_s(a['start']));
    if (c == 0) {
      c = _s((b['enrollment'] as Map)['enrolledAt'])
          .compareTo(_s((a['enrollment'] as Map)['enrolledAt']));
    }
    return c != 0 ? c : x.key.compareTo(y.key);
  });
  return indexed.map((en) => en.value).toList();
}
