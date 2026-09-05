/// חוט · wa-href — בורר-סכמה לפי הקונפיג: appScheme ⇒ whatsapp:// (קריאה-ישירה);
/// אחרת wa.me (ביט-זהה להיום). מחזיר גם דגל-אפליקציה כדי שהצרכן ידע לא לפתוח
/// target=_blank (סכמת-אפליקציה ⇒ אין טאב חדש). בלי מספר תקין ⇒ null.
/// חוזה: wa-href.contract.md · שקעים: waAppLink · waLink
/// מוצא: maor/src/lib/wa.ts · waHref (main 24-25.8; חוק-4 verbatim).
/// הומר מ-JS: new/atoms/wa-href.mjs — התנהגות זהה (truthiness של JS דרך _jsTruthy).

// עוזר-תאימות (כלל 7 · DART-PORTING-RULES): truthiness של JS, מוזרק-inline (אפס-import).
bool _jsTruthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

dynamic waHref(dynamic phone, dynamic text, dynamic appScheme,
    dynamic Function(dynamic, dynamic) waAppLink,
    dynamic Function(dynamic, dynamic) waLink) {
  final href =
      _jsTruthy(appScheme) ? waAppLink(phone, text) : waLink(phone, text);
  return _jsTruthy(href) ? {'href': href, 'app': appScheme} : null;
}
