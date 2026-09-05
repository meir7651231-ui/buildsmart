/// חוט · total-label — תווית סה"כ ₪/$ לתצוגה. חוזה: total-label.contract.md
/// הומר מ-new/atoms/total-label.mjs (מקור: maor supporters/lib.ts:235-241).
/// supIls/supUsd = שקעי-צבירה מוזרקים (sp)⇒מספר.

/// truthiness של JS (חוק 7): null/false/0/-0/NaN/'' כוזבים.
bool _truthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v is num) return !(v == 0 || v.isNaN);
  if (v is String) return v.isNotEmpty;
  return true;
}

/// קיבוץ-אלפים בפסיקים על מחרוזת-ספרות.
String _groupThousands(String digits) {
  final sb = StringBuffer();
  final len = digits.length;
  for (var idx = 0; idx < len; idx++) {
    if (idx > 0 && (len - idx) % 3 == 0) sb.write(',');
    sb.write(digits[idx]);
  }
  return sb.toString();
}

/// מחקה את Number.prototype.toLocaleString('he-IL') (חוק 6):
/// ספרות מערביות, פסיק-אלפים, נקודה-עשרונית, עד 3 ספרות-שבר (half-expand),
/// מינוס עם LRM (‎) כמו CLDR-עברית, אינסוף='∞'.
String _toLocaleStringHeIL(dynamic v) {
  final n = (v as num).toDouble();
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n > 0 ? '∞' : '‎-∞';
  final neg = n < 0;
  final a = n.abs();
  // עיגול ל-3 ספרות-שבר (ברירת-המחדל של Intl.NumberFormat)
  final scaled = (a * 1000).roundToDouble();
  final intPart = (scaled / 1000).floorToDouble();
  final fracPart = (scaled - intPart * 1000).round();
  // חלק שלם ללא ".0" של Dart (חוק 12 — טווח שלמים)
  var intStr = intPart.toStringAsFixed(0);
  var out = _groupThousands(intStr);
  if (fracPart != 0) {
    var f = fracPart.toString().padLeft(3, '0');
    while (f.endsWith('0')) {
      f = f.substring(0, f.length - 1);
    }
    out = '$out.$f';
  }
  return neg ? '‎-$out' : out;
}

/// "₪1,200 + $300" · מטבע יחיד כשהשני אפס · "—" כשאין כלום.
dynamic totalLabel(dynamic sp, dynamic supIls, dynamic supUsd) {
  final i = supIls(sp);
  final u = supUsd(sp);
  final ils = _truthy(i) ? '₪${_toLocaleStringHeIL(i)}' : '';
  final usd = _truthy(u) ? '\$${_toLocaleStringHeIL(u)}' : '';
  if (ils.isNotEmpty && usd.isNotEmpty) return '$ils + $usd';
  if (ils.isNotEmpty) return ils;
  if (usd.isNotEmpty) return usd;
  return '—';
}
