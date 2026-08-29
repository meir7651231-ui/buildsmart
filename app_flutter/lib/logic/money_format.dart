// ─────────────────────────────────────────────────────────────────────────────
// money_format — the SINGLE SOURCE for ₪ thousands-grouping.
//
// Before this, the grouping algorithm was copy-pasted into 4 private helpers
// (store `_price`, manager `_grouped`, budget `_thousands`, finance `_group`)
// while the catalog product cards, smart-home recommendations and contractor
// sheets rendered ₪ amounts RAW ("₪4200"). Same product → "₪4200" browsing,
// "₪4,200" in the cart. This primitive is the one true grouper; every ₪ display
// routes through it so the displayed number is identical on every screen.
//
// Pure (no locale dependency — mirrors the legacy `Number.toLocaleString()` the
// app shipped with). [groupThousands] groups the ABSOLUTE value; the sign and
// the ₪/currency symbol are the caller's responsibility, so the same primitive
// serves "₪3,150", "-₪3,150" and "$3,150" alike.
// ─────────────────────────────────────────────────────────────────────────────

/// Thousands-grouped absolute integer — e.g. 3150 → "3,150", 900 → "900",
/// -3150 → "3,150" (caller prepends the sign). Locale-independent.
String groupThousands(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Convenience: a signed ₪ amount with grouping — "₪3,150" / "-₪3,150".
/// The sign sits BEFORE the ₪ (never "₪-3,150"). [prefix] (e.g. "~") leads.
String formatNis(int n, {String prefix = ''}) =>
    '$prefix${n < 0 ? '-' : ''}₪${groupThousands(n)}';
