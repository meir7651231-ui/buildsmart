/// חוט · supporter-aggregates — צבירת-קבלות של תורם ממערך donations בלבד:
/// {count, ils, usd, first, last}. hist אינו נכלל כאן (מתווסף בתצוגה פעם אחת).
/// חוזה: supporter-aggregates.contract.md · הומר זהה-ביט מ-new/atoms/supporter-aggregates.mjs.

/// truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false = כוזב.
bool _truthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v is String) return v.isNotEmpty;
  if (v is num) return !(v == 0 || v.isNaN);
  return true; // אובייקטים/מערכים/true = אמת
}

/// Number.isFinite של JS: מספר-סופי בלבד (מחרוזת/NaN/Infinity/חסר ⇒ false).
bool _isFiniteNum(dynamic v) => v is num && v.isFinite;

dynamic supporterAggregates(dynamic sp) {
  final donsRaw = (sp is Map) ? sp['donations'] : null;
  final List dons = (donsRaw is List) ? donsRaw : [];
  double ils = 0; // אריתמטיקת-JS = float64 (חוק 17)
  double usd = 0;
  final List dates = [];
  for (final d in dons) {
    final dynamic amount = (d is Map) ? d['amount'] : null;
    final num amt = ((_isFiniteNum(amount) ? amount : 0) as num);
    final dynamic cur = (d is Map) ? d['cur'] : null;
    if (cur == '\$') {
      usd += amt.toDouble();
    } else {
      ils += amt.toDouble(); // ריק/₪/מיובא = שקל (עקבי עם addDonation והבית)
    }
    final dynamic date = (d is Map) ? d['date'] : null;
    if (_truthy(date)) dates.add(date);
  }
  // מיון-ברירת-מחדל של JS = השוואת-מחרוזות (UTF-16 code units) — זהה ל-compareTo של Dart.
  dates.sort((a, b) => a.toString().compareTo(b.toString()));
  // count/ils/usd = קבלות בלבד; hist מתווסף בתצוגה (supporters/lib) פעם אחת.
  // dates[0] על מערך ריק ב-JS = undefined ⇒ '' דרך ?? — כאן גידור-ריקנות מפורש.
  return {
    'count': dons.length,
    'ils': ils,
    'usd': usd,
    'first': dates.isEmpty ? '' : dates.first,
    'last': dates.isEmpty ? '' : dates.last,
  };
}
