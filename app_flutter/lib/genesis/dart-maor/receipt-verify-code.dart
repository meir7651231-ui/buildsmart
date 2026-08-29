/// חוט · receipt-verify-code — קוד-אימות FNV-1a לקבלה (XXX-XXX).
/// חוזה: receipt-verify-code.contract.md
/// הומר מ-new/atoms/receipt-verify-code.mjs (חולץ מ-maor/src/lib/receipt.ts).
/// התנהגות זהה-לחלוטין למקור-ה-JS (חוק-4).
String receiptVerifyCode(String rid, num amount, String? currency, String date) {
  // JS: (currency || '₪') — מחרוזת ריקה/null נופלת ל-'₪' (truthiness, כלל-המרה 7).
  final cur = (currency == null || currency.isEmpty) ? '₪' : currency;
  // JS: date.slice(0, 10) — סלחן לאורך קצר.
  final d = date.length <= 10 ? date : date.substring(0, 10);
  final s = '$rid|$amount|$cur|$d';

  // FNV-1a על 32 ביט ללא-סימן.
  var h = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    // JS: Math.imul(h, 0x01000193) >>> 0  ≡  (h * m) mod 2^32.
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }

  // JS: h.toString(36).toUpperCase().padStart(7,'0').slice(-6)
  var code = h.toRadixString(36).toUpperCase();
  while (code.length < 7) {
    code = '0$code';
  }
  code = code.substring(code.length - 6); // slice(-6)
  return '${code.substring(0, 3)}-${code.substring(3)}';
}
