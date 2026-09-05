/// חוט · expiring-intakes — קליטות מתכלות שפגו/עומדות-לפוג (SHOP10).
/// המרה נאמנה מ-new/atoms/expiring-intakes.mjs (חוק-4: המקור קדוש).
/// שקע: isoOf(DateTime)→'YYYY-MM-DD' מקומי. SHOP_EXPIRY_WARN_DAYS=7 שוכן כברירת-מחדל.
/// כללי-המרה: truthiness (‏!expiry ⇒ null/ריק) · setDate-מגלגל דרך DateTime · מיון-יציב.
List<Map<String, dynamic>> expiringIntakes(
  Map<String, dynamic> db,
  String todayIso,
  String Function(DateTime) isoOf, [
  int windowDays = 7,
]) {
  // JS: new Date(todayIso+'T12:00:00'); horizon.setDate(getDate()+windowDays)
  // הבנייה מ-DateTime(y,m,d+windowDays) מגלגלת חודשים בדיוק כמו setDate.
  final base = DateTime.parse('${todayIso}T12:00:00');
  final horizon = DateTime(base.year, base.month, base.day + windowDays, 12);
  final horizonIso = isoOf(horizon);

  final intakes = (db['shopIntakes'] as List).cast<Map<String, dynamic>>();
  final items = (db['shopItems'] as List).cast<Map<String, dynamic>>();

  final out = <Map<String, dynamic>>[];
  for (final it in intakes) {
    final expiry = it['expiry'] as String?;
    // JS: if (!it.expiry || it.expiry > horizonIso) continue;  (‏!expiry = null/ריק)
    if (expiry == null || expiry.isEmpty || expiry.compareTo(horizonIso) > 0) {
      continue;
    }
    String itemName = '—';
    for (final s in items) {
      if (s['id'] == it['itemId']) {
        itemName = (s['name'] as String?) ?? '—';
        break;
      }
    }
    out.add({
      'intake': it,
      'itemName': itemName,
      'expired': expiry.compareTo(todayIso) < 0,
    });
  }

  // מיון-יציב (כלל-המרה 1): decorate-sort-undecorate עם אינדקס-מקורי כשובר-שוויון.
  // localeCompare על תאריכי-ISO ≡ השוואת-קוד; expiry תמיד קיים אחרי הסינון.
  final idx = [for (var i = 0; i < out.length; i++) i];
  idx.sort((x, y) {
    final ex = (out[x]['intake']['expiry'] as String?) ?? '';
    final ey = (out[y]['intake']['expiry'] as String?) ?? '';
    final c = ex.compareTo(ey);
    return c != 0 ? c : x.compareTo(y);
  });
  return [for (final i in idx) out[i]];
}
