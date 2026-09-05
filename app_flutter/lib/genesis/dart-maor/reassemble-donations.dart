// חוט · reassemble-donations — הרכבת תומך חזרה ממסמכי-תרומה בענן (מסלול-B, טהור).
// חוזה: reassemble-donations.contract.md
// המרה מ-JS (new/atoms/reassemble-donations.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חולץ כלשונו מ-maor/src/lib/donationPartition.ts:66-102, כולל המיון הפרטי
// byDateThenRid (חלק מהיחידה — דטרמיניזם חוצה-מכשירים). אפס import פנימי.
//   • הסינון supporterId===base.id → == (השוואת-מחרוזת, כמו === ב-JS על מחרוזות).
//   • המיון: date עולה ואז rid עולה, השוואת-מחרוזות (JS `<` = UTF-16 code-units,
//     כמו String.compareTo של Dart).
//   • ⚠️ כלל-המרה 1 (מיון-יציב): sort של Dart לא-יציב ל-≥32; JS יציב. byDateThenRid
//     מחזיר 0 רק כשגם date וגם rid זהים ⇒ שובר-שוויון = אינדקס-מקורי (שימור-סדר-JS).
//   • התרומה עוברת בזהות-הפניה (x['donation'] = אותה הפניה, כמו .map ב-JS).
//   • {...base, 'donations': ...} משמר את שדות-הבסיס ומחליף donations (spread כמו JS).

Map<String, dynamic> reassembleDonations(
  Map<String, dynamic> base,
  List<dynamic> docs,
) {
  final baseId = base['id'];

  // filter(x => x.supporterId === base.id).map(x => x.donation) — שימור-סדר.
  final filtered = <dynamic>[];
  for (final raw in docs) {
    final x = raw as Map;
    if (x['supporterId'] == baseId) filtered.add(x['donation']);
  }

  // decorate-sort-undecorate: אינדקס-מקורי כשובר-שוויון ⇒ יציבות זהה ל-JS.
  final order = <int>[for (var i = 0; i < filtered.length; i++) i];
  order.sort((ia, ib) {
    final a = filtered[ia] as Map;
    final b = filtered[ib] as Map;
    final ad = a['date'], bd = b['date'];
    if (ad != bd) return (ad as String).compareTo(bd as String);
    final ar = a['rid'], br = b['rid'];
    if (ar != br) return (ar as String).compareTo(br as String);
    return ia.compareTo(ib); // date+rid זהים ⇒ שמירת-סדר-מקורי
  });

  final donations = [for (final i in order) filtered[i]];
  return {...base, 'donations': donations};
}
