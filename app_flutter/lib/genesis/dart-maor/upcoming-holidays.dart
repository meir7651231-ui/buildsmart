/// חוט · upcoming-holidays — החגים בטווח הימים הקרוב (חג רב-ימי ⇒ יומו הראשון).
/// המרה נאמנה מ-new/atoms/upcoming-holidays.mjs (חוק-4: המקור קדוש).
/// שקעים (חוק-1): holidayOf(DateTime)→שם-חג או null/'' · isoOf(DateTime)→'YYYY-MM-DD' מקומי.
/// כללי-המרה: עיגון T12:00:00 (צהריים מקומי) · Date(y,m,d+i) מגלגל חודש/שנה
/// דרך DateTime(y,m,d+i) (JS month 0-based בקונסטרוקטור ≡ Dart month 1-based) ·
/// truthiness (‏name && ⇒ null/'' כוזבים) · days עבר לאופציונלי-זנב (Dart אוסר
/// אופציונלי לפני חובה; ברירת-המחדל 45 נשמרה).
List<Map<String, dynamic>> upcomingHolidays(
  String fromIso,
  dynamic Function(DateTime) holidayOf,
  String Function(DateTime) isoOf, [
  int days = 45,
]) {
  final out = <Map<String, dynamic>>[];
  final seen = <dynamic>{};
  final start = DateTime.parse('${fromIso}T12:00:00');
  for (var i = 0; i <= days; i++) {
    final d = DateTime(start.year, start.month, start.day + i);
    final name = holidayOf(d);
    // JS: if (name && !seen.has(name)) — truthiness: null/'' כוזבים
    if (name != null && name != '' && !seen.contains(name)) {
      seen.add(name);
      out.add({'iso': isoOf(d), 'name': name});
    }
  }
  return out;
}
