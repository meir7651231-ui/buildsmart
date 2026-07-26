// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · קרנל חשבונית/קבלה — PURE, בונה את שורות-ההדפסה
// (label/value) + פירוק-המע"מ מ-Order, לרכיבה על רכבת printable_docs הקיימת.
//
// מוקש-אמת (מפת-המסמכים): `order.sum` הוא **ברוטו כולל-מע"מ** (מה שחויב), בעוד
// `OrderLineItem.price` הוא סכום-שורה לפני-מע"מ. פרסר נאיבי (Σprice×1.18) יסטה
// מ-order.sum. לכן: order.sum הוא הסה"כ הסמכותי, המע"מ מחולץ-לאחור מהברוטו
// (כמו cartVat(vatInclusive:true)) — (ברוטו−מע"מ)+מע"מ ≡ ברוטו, מתשלב תמיד,
// בלי סכום-ביניים מפוברק. שורות-הפריטים מוצגות כמידע.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/money_format.dart' show formatNis;
import 'package:buildsmart/state/catalog_settings.dart' show kVatRate;
import 'package:buildsmart/state/orders_engine.dart' show Order;

/// חלק-המע"מ הטמון בסכום-ברוטו כולל-מע"מ — מחולץ-לאחור בשיעור החוקי (מראה את
/// cartVat(vatInclusive:true)). לפי-הבנייה (ברוטו−מע"מ)+מע"מ ≡ ברוטו, כך
/// שחשבונית שנבנית על זה תמיד מתשלבת ל-order.sum — אפס-סטייה.
int invoiceVatOf(int grossTotal) =>
    grossTotal - (grossTotal / (1 + kVatRate)).round();

/// שורות-ההדפסה לחשבונית/קבלה מ-[order]. פריטי-השורה מידעיים; הסה"כ הסמכותי
/// הוא order.sum (מה שחויב) עם מע"מ כחלק המחולץ-לאחור.
List<({String label, String value})> buildInvoiceRows(Order order) {
  final rows = <({String label, String value})>[
    (label: 'מספר הזמנה', value: order.id),
    (label: 'לקוח', value: order.who),
  ];
  if (order.site.isNotEmpty) {
    rows.add((label: 'אתר', value: order.site));
  }
  for (final l in order.lines) {
    final head = l.emoji.isEmpty ? l.name : '${l.emoji} ${l.name}';
    rows.add((label: '$head × ${l.qty}', value: formatNis(l.price)));
  }
  rows.add((label: 'סה"כ לתשלום (כולל מע"מ)', value: formatNis(order.sum)));
  rows.add((
    label: 'מזה מע"מ ${(kVatRate * 100).round()}%',
    value: formatNis(invoiceVatOf(order.sum)),
  ));
  return rows;
}

/// כותרת-המסמך לחשבונית (receipt=false) או קבלה (receipt=true) של הזמנה.
String invoiceTitle(Order order, {required bool receipt}) =>
    '${receipt ? 'קבלה' : 'חשבונית'} — ${order.id}';
