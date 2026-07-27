// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · קרנל תעודת-משלוח — PURE, בונה שורות-הדפסה
// (label/value) מ-Order לרכבת printable_docs, לצד קרנל-החשבונית.
//
// תעודת-משלוח היא **סחורה, לא כסף** — בכוונה אין כאן סכומים/מע"מ (זה תפקיד
// invoice.dart). כל שורת-פריט מציגה שם + כמות בלבד, כדי שהמקבל יסמן מה הגיע.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/orders_engine.dart' show Order;

/// תאריך קצר DD/MM/YYYY (טהור, בלי תלות-חבילה).
String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

/// שורות-ההדפסה לתעודת-משלוח מ-[order]: פרטי-הזמנה + יעד + פריטים (שם×כמות,
/// ללא מחיר). buildPrintableHtml מדלג על value ריק, כך שדות-רשות נעדרים נקי.
List<({String label, String value})> buildDeliveryNoteRows(Order order) {
  final rows = <({String label, String value})>[
    (label: 'מספר הזמנה', value: order.id),
    (label: 'לקוח', value: order.who),
  ];
  if (order.site.isNotEmpty) {
    rows.add((label: 'אתר', value: order.site));
  }
  if (order.shipTo.isNotEmpty) {
    rows.add((label: 'כתובת אספקה', value: order.shipTo));
  }
  if (order.createdAt != null) {
    rows.add((label: 'תאריך', value: _fmtDate(order.createdAt!)));
  }
  for (final l in order.lines) {
    final head = l.emoji.isEmpty ? l.name : '${l.emoji} ${l.name}';
    rows.add((label: head, value: '${l.qty} יח\''));
  }
  if (order.notes.isNotEmpty) {
    rows.add((label: 'הערות', value: order.notes));
  }
  return rows;
}

/// כותרת-המסמך לתעודת-משלוח של הזמנה.
String deliveryNoteTitle(Order order) => 'תעודת משלוח — ${order.id}';
