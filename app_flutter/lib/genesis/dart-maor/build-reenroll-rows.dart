// ⚛️ אטום-Dart (דרגת-חוזה) · buildReenrollRows — שורות מסך רישום-לשנה-הבאה.
// מוצא: maor/src/components/courses/reenroll-lib.ts:134-183 · המקור: new/atoms/build-reenroll-rows.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מסנן enrollments לפי courseId/decision/includeRenewed/q (חיפוש רב-מילתי
//        על שם-פרטי + שם-משפחה + שם-חוג), בונה שורה פר-רישום, ממיין לפי memberName
//        (localeCompare 'he'). ארבעת השכנים (isRenewed · renewOf · enrollSummary ·
//        findMember) הם שקעים (חוק-1).
// קלט: db{enrollments,courses} · filter? {courseId?,decision?,includeRenewed?,q?} ·
//        4 שקעים. פלט: List של שורות-Map {e,member,memberName,familyName,course,
//        courseName,summary,decision,renewed}.
//
// הערות-המרה (מקור→Dart) — מה שהמנוע פספס:
//  · המנוע השמיט את הפרמטר-הרביעי (destructuring של השקעים) והפך אותו ל-`dynamic undefined`;
//    כאן הוא ארבעה פרמטרים-בשם מטופסים.
//  · אובייקטי-JS ⇒ Map<String,Object?>; גישת-שדה .x ⇒ ['x']; member?.first ⇒ member?['first'].
//  · truthiness של JS (`filter.courseId` / `filter.decision` / `if (q)`) ⇒ _truthy מפורש
//    (מחרוזת-ריקה = false); `filter.includeRenewed !== false` ⇒ `!= false` (חסר ⇒ true).
//  · findMember מחזיר {member, family} כ-Map; family הוא מחרוזת (שם-המשפחה).
//  · `q.split(/\s+/).filter(Boolean)` ⇒ split(RegExp(r'\s+')).where(isNotEmpty).
//  · localeCompare(...,'he') ⇒ compareTo (אותיות-עברית U+05D0.. שומרות סדר-code-unit);
//    מיון-יציב דרך שובר-שוויון על אינדקס (Array.sort יציב ב-ES2019+; List.sort אינו-יציב).

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// Builds the rows for the "re-enroll for next year" screen. Verbatim behaviour
/// of the JS source `buildReenrollRows`. `isRenewed`/`renewOf`/`enrollSummary`/
/// `findMember` are injected sockets.
List<Map<String, Object?>> buildReenrollRows(
  Map<String, Object?> db,
  Map<String, Object?>? filter, {
  required bool Function(Map<String, Object?> e) isRenewed,
  required String Function(Map<String, Object?> e) renewOf,
  required Object? Function(Map<String, Object?> e) enrollSummary,
  required Map<String, Object?> Function(Map<String, Object?> db, Object? id) findMember,
}) {
  final f = filter ?? <String, Object?>{};
  final includeRenewed = f['includeRenewed'] != false;
  final q = ((f['q'] ?? '') as String).trim();
  final rows = <Map<String, Object?>>[];
  final enrollments = (db['enrollments'] as List).cast<Map<String, Object?>>();
  final courses = (db['courses'] as List).cast<Map<String, Object?>>();
  for (final e in enrollments) {
    final courseId = f['courseId'];
    if (_truthy(courseId) && e['courseId'] != courseId) continue;
    final renewed = isRenewed(e);
    if (!includeRenewed && renewed) continue;
    Map<String, Object?>? course;
    for (final c in courses) {
      if (c['id'] == e['courseId']) {
        course = c;
        break;
      }
    }
    final fm = findMember(db, e['memberId']);
    final member = fm['member'] as Map<String, Object?>?;
    final family = (fm['family'] ?? '') as String;
    final memberName = (member?['first'] ?? '') as String;
    final courseName = (course?['name'] ?? '') as String;
    final decision = renewOf(e);
    final fDecision = f['decision'];
    if (_truthy(fDecision)) {
      if (fDecision == 'undecided') {
        if (decision != '') continue;
      } else if (decision != fDecision) {
        continue;
      }
    }
    if (q.isNotEmpty) {
      final hay = '$memberName $family $courseName';
      // כל מילה חייבת להימצא (חיפוש רב-מילתי) — כמו smartFilter במודולים האחרים.
      final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (!words.every((w) => hay.contains(w))) continue;
    }
    rows.add({
      'e': e,
      'member': member,
      'memberName': memberName,
      'familyName': family,
      'course': course,
      'courseName': courseName,
      'summary': enrollSummary(e),
      'decision': decision,
      'renewed': renewed,
    });
  }
  // מיון-יציב לפי memberName: שובר-שוויון על אינדקס-כניסה כמו sort יציב ב-JS.
  final indexed = <MapEntry<int, Map<String, Object?>>>[];
  for (var i = 0; i < rows.length; i++) {
    indexed.add(MapEntry(i, rows[i]));
  }
  indexed.sort((x, y) {
    final c = (x.value['memberName'] as String).compareTo(y.value['memberName'] as String);
    return c != 0 ? c : x.key.compareTo(y.key);
  });
  return indexed.map((en) => en.value).toList();
}
