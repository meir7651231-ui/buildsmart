// חוט · tel-href — טלפון שמור לקישור-חיוג tel:. חוזה: tel-href.contract.md
// הומר מ-new/atoms/tel-href.mjs (מקור-האמת). זהה-ביט ל-JS (חוק-4).

/// טלפון שמור (פורמט מקומי מעוצב) ⇒ קישור-חיוג `tel:`; קצר מ-6 ספרות ⇒ null.
dynamic telHref(dynamic phone) {
  // ‏JS: (phone || '') — truthiness מפורש (RULES-DIGEST חוק-7)
  final String p = ((_falsy(phone) ? '' : phone) as String);
  final cleaned = p.replaceAll(RegExp(r'[^\d+]'), '');
  final digits = cleaned.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 6) return null; // קצר מדי = לא מספר-חיוג תקין
  return 'tel:' + cleaned;
}

bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN));
