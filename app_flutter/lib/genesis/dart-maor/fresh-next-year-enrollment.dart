/// חוט · fresh-next-year-enrollment — טיוטת-שיבוץ לשנה הבאה (איפוס-היסטוריה).
/// המרה נאמנה מ-new/atoms/fresh-next-year-enrollment.mjs (חוק-4: המקור קדוש).
/// שדות-תמחור אופציונליים מועברים רק אם המפתח קיים במקור (JS: `!== undefined`
/// ⇒ Dart: containsKey — כלל-המרה 2: null≠undefined). אפס-import, אפס-מוטציית-מקור.
Map<String, Object?> freshNextYearEnrollment(
  Map<String, Object?> src,
  String targetCourseId,
  String newId,
  String todayIso, [
  Object? groupOverride,
]) {
  final out = <String, Object?>{
    'id': newId,
    'memberId': src['memberId'],
    'courseId': targetCourseId,
    'plan': src['plan'],
    'purchased': 0,
    'used': 0,
    // groupOverride: מנהל-העבודה בחר קבוצה ברישום. null ⇒ אותה קבוצה של אשתקד.
    'group': groupOverride ?? src['group'],
    'absences': <Object?>[],
    'payments': <Object?>[],
    'totalDue': src['totalDue'],
    'dueDate': '',
    'status': 'active',
    'note': '',
    'enrolledAt': todayIso,
  };
  // תמחור משוקלל — נשמר כדי שהמחיר יעבור לשנה הבאה כמו שהיה.
  if (src.containsKey('freq')) out['freq'] = src['freq'];
  if (src.containsKey('freqUnit')) out['freqUnit'] = src['freqUnit'];
  if (src.containsKey('term')) out['term'] = src['term'];
  if (src.containsKey('termMonths')) out['termMonths'] = src['termMonths'];
  if (src.containsKey('tier')) out['tier'] = src['tier'];
  return out;
}
