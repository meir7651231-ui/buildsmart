// חוט · pay-link — בניית קישור-תשלום: amount/name על ה-URL של הארגון.
// המרה מ-JS (new/atoms/pay-link.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חוזה: pay-link.contract.md · שקע safeHttpsUrl מוזרק כפרמטר (חוק-1). אפס-import (dart-core בלבד).
//
// כללי-המרה שהוחלו (machtzev/emit/DART-PORTING-RULES.md):
//  · פורמט-מספר (#6-דומה): JS `String(round(x*100)/100)` מדפיס שלם בלי '.0'; Dart double.toString לא.
//    ⇒ הרכבה מ-אגורות (cents) — שלם/עשירית/מאית — מחקה בדיוק את String של JS.
//  · קידוד: JS encodeURIComponent ⇒ Uri.encodeComponent (רווח⇒%20); JS URLSearchParams ⇒
//    Uri.encodeQueryComponent (רווח⇒'+'); שניהם UTF-8 hex-גדול, זהה לענף המקביל ב-JS.
//  · new URL(base) ממופה ל-Uri.parse(base) — סוגריים {}⇒%7B זהה (אומת); base כבר מנורמל ע"י safeHttpsUrl,
//    לכן הרכבת-המחרוזת מצרפת פרמטרים ל-base הגולמי (שקילות ל-searchParams.set על query-פשוט).
String? payLink(String payUrl, num amount,
    [String name = '', String? Function(String)? safeHttpsUrl]) {
  final base = safeHttpsUrl!(payUrl);
  if (base == null || base.isEmpty) return null;
  final amt = _amt(amount);
  if (base.contains('%7Bamount%7D') || base.contains('{amount}')) {
    // תבנית-מותאמת — החלפה בתוך ה-URL (גם בצורה המקודדת %7B…%7D).
    // סכום 0 ⇒ שדה-ריק (קישור-תרומה-כללי), עקבי עם מצב-הפרמטרים.
    return base
        .replaceAll(RegExp(r'%7Bamount%7D|\{amount\}'),
            amt == '0' ? '' : Uri.encodeComponent(amt))
        .replaceAll(RegExp(r'%7Bname%7D|\{name\}'), Uri.encodeComponent(name));
  }
  final u = Uri.parse(base);
  final pathAndSearch = u.path + (u.hasQuery ? '?' + u.query : '');
  // נדרים-פלוס: עמוד-הסליקה קורא Amount/ClientName (PascalCase), לא amount/name.
  if (RegExp(r'(^|\.)matara\.pro$', caseSensitive: false).hasMatch(u.host) &&
      RegExp('nedarimplus', caseSensitive: false).hasMatch(pathAndSearch)) {
    final params = <List<String>>[];
    if (amt != '0') params.add(['Amount', amt]);
    if (name.trim().isNotEmpty) params.add(['ClientName', name.trim()]);
    return _appendParams(base, params);
  }
  final params = <List<String>>[];
  if (amt != '0') params.add(['amount', amt]);
  if (name.trim().isNotEmpty) params.add(['name', name.trim()]);
  return _appendParams(base, params);
}

// String(Math.max(0, Math.round(amount*100)/100)) — מחקה את פלט-JS למחרוזת (בלי '.0' לשלם).
String _amt(num amount) {
  var cents = (amount * 100).round();
  if (cents < 0) cents = 0;
  final whole = cents ~/ 100;
  final frac = cents % 100;
  if (frac == 0) return '$whole';
  if (frac % 10 == 0) return '$whole.${frac ~/ 10}';
  return '$whole.${frac < 10 ? '0' : ''}$frac';
}

// שקילות ל-u.searchParams.set(...)+u.toString() על query פשוט: צירוף פרמטרים (form-encoded) ל-URL.
String _appendParams(String base, List<List<String>> params) {
  var main = base;
  var frag = '';
  final h = main.indexOf('#');
  if (h >= 0) {
    frag = main.substring(h);
    main = main.substring(0, h);
  }
  if (params.isEmpty) return main + frag;
  final enc =
      params.map((p) => p[0] + '=' + Uri.encodeQueryComponent(p[1])).join('&');
  final sep = main.contains('?') ? '&' : '?';
  return main + sep + enc + frag;
}
