// ⚛️ אטום-Dart (דרגת-חוזה) · detectRecurringHok — זיהוי הוראות-קבע מתבנית-ה-hist
// ומילוי משבצת-ההו"ק. מוצא: maor/src/lib/nedarimSync.ts:236-278 ·
// המקור: new/atoms/detect-recurring-hok.mjs · חוזה: detect-recurring-hok.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1, הוזרקו כפרמטרים במקום קריאות-שכן):
//   clearingProviders : ספקי-סליקה מוכרים · modeStr : שכיח-מחרוזת ·
//   modeOf : שכיח-מספר · monthsAgo : מרחק-חודשים בין שני ISO.
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  · אובייקטי-JS (sp, h, hok) ⇒ Map<String, Object?>; גישת-שדה .clearer ⇒ ['clearer'].
//  · truthiness של JS (`sp.hok && !sp.hok.kevaId`, `h.clearer || ''`, `... || 'auto'`)
//    ⇒ שקע `_truthy` מפורש (null/false/''/0 = שקרי) — כלל-7.
//  · `.slice(a,b)` של JS (סלחן לטווח) ⇒ `_slice` שמחקה את סמנטיקת-slice ולא זורק — כלל-5.
//  · `Number(x) || 1` ⇒ `_numOr1` (NaN/0 ⇒ 1).
//  · `dates.sort()` — מיון-מחרוזות לקסיקוגרפי; לוקחים רק ראשון/אחרון ⇒ יציבות לא-רלוונטית (כלל-1).
//  · אי-מוטביליות: החזרת-אותה-רפרנס (הו"ק ידני / אין-תבנית) ⇒ מוסיפים את `sp` עצמו;
//    זיהוי ⇒ מפה-חדשה `{...sp, 'hok': ...}` (זהות-אובייקט שונה, כמו spread ב-JS).

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0;
  return true;
}

// מחקה String.prototype.slice(start, end) של JS: קליפינג-טווח, לעולם לא זורק.
String _slice(String s, int start, int end) {
  final len = s.length;
  var st = start < 0 ? (len + start < 0 ? 0 : len + start) : (start > len ? len : start);
  var en = end < 0 ? (len + end < 0 ? 0 : len + end) : (end > len ? len : end);
  if (en < st) return '';
  return s.substring(st, en);
}

// מחקה `Number(x) || 1` של JS: פרסור-כושל (NaN) או 0 ⇒ 1.
num _numOr1(String s) {
  final v = num.tryParse(s);
  if (v == null || v == 0) return 1;
  return v;
}

/// Detects recurring standing-orders (הו"ק) from a supporter's clearing history.
/// Verbatim behaviour of the JS source `detectRecurringHok`. Returns
/// `{'supporters': List<Map>, 'detected': int}`. Untouched supporters keep the
/// exact same Map reference; detected ones get a fresh `{...sp, 'hok': ...}` map.
Map<String, Object?> detectRecurringHok(List<Map<String, Object?>> supporters,
  String todayIso,
  int minMonths,
  List<String> clearingProviders,
  String Function(List<String>) modeStr,
  num Function(List<num>) modeOf,
  int Function(String, String) monthsAgo, Map<String, dynamic> T) {
  var detected = 0;
  final out = <Map<String, Object?>>[];

  for (final sp in supporters) {
    final hok = sp['hok'];
    if (hok != null && !_truthy((hok as Map)['kevaId'])) {
      out.add(sp); // הו"ק ידני — לא נוגעים
      continue;
    }
    // 🐛 נחיל-סולה C7: המנוע היה עיוור לסולה — 552 חיובים דולריים חוזרים לא מילאו הו"ק.
    final hist = (sp['hist'] as List?) ?? const [];
    final nd = <Map<String, Object?>>[];
    for (final h in hist.cast<Map<String, Object?>>()) {
      final clearer = (h['clearer'] as String?) ?? '';
      final aOk = ((h['a'] as num?) ?? 0) > 0;
      if (clearingProviders.contains(clearer) && aOk && _truthy(h['d'])) nd.add(h);
    }
    if (nd.isEmpty) {
      out.add(sp);
      continue;
    }
    // חיוב עם kevaId ⇒ הו"ק ודאי (גם חיוב-בודד). אחרת ⇒ תבנית: חיובי-נדרים
    // ב-≥minMonths חודשים שונים (סכום עשוי להשתנות בין שנים ⇒ לא דורשים סכום-זהה).
    Map<String, Object?>? kevaCharge;
    for (final h in nd) {
      if (_truthy(h['kevaId'])) {
        kevaCharge = h;
        break;
      }
    }
    final distinctMonths = <String>{};
    for (final h in nd) {
      distinctMonths.add(_slice(h['d'] as String, 0, 7));
    }
    if (kevaCharge == null && distinctMonths.length < minMonths) {
      out.add(sp);
      continue;
    }
    detected++;
    // סכום/מטבע ההו"ק = השכיח; day = היום השכיח (מוגבל 1..28).
    final parts = modeStr([
      for (final h in nd) '${h['a']}|${_truthy(h['c']) ? h['c'] : '₪'}',
    ]).split('|');
    final cur = parts.length > 1 && parts[1] == '\$' ? '\$' : '₪';
    final dates = [for (final h in nd) h['d'] as String]..sort();
    final md = modeOf([for (final h in nd) _numOr1(_slice(h['d'] as String, 8, 10))]);
    final day = md < 1 ? 1 : (md > 28 ? 28 : md);
    final clearer0 = _truthy(nd[0]['clearer']) ? nd[0]['clearer'] : (T['k3'] as String);
    final note = kevaCharge != null
        ? '${(T['k2'] as String)}$clearer0 · ${kevaCharge['kevaId']}'
        : '${(T['k2'] as String)}$clearer0${(T['k4'] as String)}${distinctMonths.length}${(T['k5'] as String)}';
    out.add({
      ...sp,
      'hok': <String, Object?>{
        'amount': num.parse(parts[0]),
        'cur': cur,
        'day': day,
        'method': 'card',
        'note': note,
        'active': monthsAgo(dates[dates.length - 1], todayIso) <= 2,
        'startedAt': dates[0],
        'kevaId': _truthy(kevaCharge?['kevaId']) ? kevaCharge!['kevaId'] : 'auto',
      },
    });
  }

  return {'supporters': out, 'detected': detected};
}
