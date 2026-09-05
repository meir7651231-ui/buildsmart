// ⚛️ אטום-Dart (דרגת-חוזה) · pendingMakeups — חיסורים-זכאים-להשלמה (makeup טרו),
//    אופציונלית מסונן פר-חוג. חוזה: new/atoms/pending-makeups.contract.md.
// מוצא: maor/src/components/courses/lib.ts:354-367 · המקור: new/atoms/pending-makeups.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  • כלל-7 truthiness: JS `if (courseId && …)` ⇒ מחרוזת-לא-ריקה בלבד ⇒
//    `courseId != null && courseId != ''`; `!a.makeup` ⇒ `_falsy(makeup)`.
//  • המנוע תרגם `||` בקומפרטור ל-`??` — שגוי (null-coalesce ≠ or-לוגי על int).
//    ‏JS `(a-b) || cmp` = "אם ההפרש 0, השתמש ב-cmp"; שוחזר במפורש.
//  • כלל-1 מיון-יציב: `List.sort` של Dart לא-יציב ל-≥32; JS יציב ⇒
//    decorate-sort-undecorate עם אינדקס-מקורי כשובר-שוויון.
//  • הנתונים = Map (לא property-access); makeupDate חסר ⇒ null ≡ undefined של JS.

bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || (v is double && v.isNaN);
  if (v is String) return v.isEmpty;
  return false;
}

/// Absences eligible for makeup (makeup truthy), optionally filtered by [courseId].
/// Non-scheduled (no makeupDate) come first, then by date. Verbatim behaviour of
/// the JS source `pendingMakeups`.
List<Map<String, Object?>> pendingMakeups(List<dynamic> enrollments,
    [String? courseId]) {
  final out = <Map<String, Object?>>[];
  for (final e in enrollments) {
    final en = e as Map;
    final status = en['status'];
    if (status == 'ended' || status == 'wait') continue;
    if (courseId != null && courseId != '' && en['courseId'] != courseId) {
      continue;
    }
    for (final a in (en['absences'] as List)) {
      final ab = a as Map;
      if (_falsy(ab['makeup'])) continue;
      out.add({
        'enrollmentId': en['id'],
        'memberId': en['memberId'],
        'courseId': en['courseId'],
        'date': ab['date'],
        'reason': ab['reason'],
        'makeupDate': ab['makeupDate'],
      });
    }
  }

  // מיון-יציב (JS Array.sort יציב): עיטוף באינדקס-מקורי כשובר-שוויון.
  final indexed = <MapEntry<int, Map<String, Object?>>>[];
  for (var i = 0; i < out.length; i++) {
    indexed.add(MapEntry(i, out[i]));
  }
  indexed.sort((xa, ya) {
    final x = xa.value, y = ya.value;
    final xm = _falsy(x['makeupDate']) ? 0 : 1;
    final ym = _falsy(y['makeupDate']) ? 0 : 1;
    var d = xm - ym;
    if (d == 0) {
      d = (x['date'] as String).compareTo(y['date'] as String);
    }
    if (d != 0) return d;
    return xa.key - ya.key; // שובר-שוויון: יציבות כמו JS
  });
  return [for (final p in indexed) p.value];
}
