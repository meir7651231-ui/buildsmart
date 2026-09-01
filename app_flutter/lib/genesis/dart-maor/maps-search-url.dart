// חוט · maps-search-url — קישור-חיפוש Google Maps לכתובת. חוזה: maps-search-url.contract.md
// המרה מ-JS (new/atoms/maps-search-url.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). Uri.encodeComponent ≡ encodeURIComponent של JS
// (משמר A-Za-z0-9-_.!~*'() ; רווח⇒%20 ; פסיק⇒%2C ; עברית⇒UTF-8 percent).

// עוזר-פנימי cleanStop (שוקע פנימה, אינו אטום נפרד):
// '|' ליטרלי = מפריד-העצירות של Google (אין escaping ב-api=1) ⇒ מוחלף ברווח.
// המקור JS משתמש ב-regex גלובלי /\|/g ⇒ replaceAll (כל המופעים), לא replaceFirst.
String _cleanStop(String s) {
  return s.replaceAll('|', ' ').trim();
}

String? mapsSearchUrl(String address, [String city = '']) {
  // filter(Boolean) של JS = השמטת מחרוזות ריקות ⇒ where(isNotEmpty).
  final q = [address, city].map(_cleanStop).where((s) => s.isNotEmpty).join(', ');
  if (q.isEmpty) return null; // !q של JS על מחרוזת = ריקה.
  return 'https://www.google.com/maps/search/?api=1&query=' + Uri.encodeComponent(q);
}
