/// חוט · waitlist-for — רשימת-ההמתנה של חוג (status 'wait', FIFO לפי enrolledAt).
/// חוזה: waitlist-for.contract.md · מקור-האמת: new/atoms/waitlist-for.mjs
/// מוצא: maor/src/components/courses/lib.ts:369-373 — טהור, אפס שקעים.
/// חוק-1: sort של JS יציב ⇒ decorate-sort-undecorate (אינדקס שובר-שוויון).
/// חוק-7: ‏e.enrolledAt || '' — כל ערך כוזב (null/חסר/'') ⇒ ''.

bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    v == '' ||
    (v is num && (v == 0 || v.isNaN));

dynamic waitlistFor(dynamic enrollments, dynamic courseId) {
  // filter — עותק חדש, הקלט אינו משתנה (כמו ב-JS).
  final filtered = <dynamic>[];
  for (final e in (enrollments as List)) {
    if (e['courseId'] == courseId && e['status'] == 'wait') {
      filtered.add(e);
    }
  }
  // sort יציב: decorate (ערך, אינדקס-מקורי) ⇒ sort ⇒ undecorate.
  final decorated = <List<dynamic>>[
    for (var i = 0; i < filtered.length; i++) [filtered[i], i],
  ];
  decorated.sort((a, b) {
    final sa = _falsy(a[0]['enrolledAt']) ? '' : a[0]['enrolledAt'] as String;
    final sb = _falsy(b[0]['enrolledAt']) ? '' : b[0]['enrolledAt'] as String;
    final c = sa.compareTo(sb);
    if (c != 0) return c;
    return (a[1] as int) - (b[1] as int); // שובר-שוויון = סדר-הסינון
  });
  return [for (final d in decorated) d[0]];
}
