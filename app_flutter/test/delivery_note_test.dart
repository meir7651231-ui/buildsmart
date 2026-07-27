// GIANT Phase-2 wave-4 (documents) — the pure delivery-note kernel. A delivery
// note is GOODS, not money: line items show name × quantity and there are NO
// amounts / VAT / totals (that is the invoice kernel's job).

import 'package:buildsmart/logic/delivery_note.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rows: meta + ship-to + date + line items as name × qty (no price)', () {
    final o = Order(
      id: 'BS-1042',
      who: 'דנה כהן',
      site: 'אתר צפון',
      items: 2,
      sum: 1180,
      stage: 'new',
      shipTo: 'רחוב הבניין 5, חיפה',
      createdAt: DateTime(2026, 3, 15),
      lines: const [
        OrderLineItem(name: 'מלט', emoji: '🧱', qty: 3, price: 600),
        OrderLineItem(name: 'חול', emoji: '', qty: 1, price: 400),
      ],
    );
    final rows = buildDeliveryNoteRows(o);
    expect(rows.any((r) => r.label == 'מספר הזמנה' && r.value == 'BS-1042'),
        isTrue);
    expect(rows.any((r) => r.label == 'לקוח' && r.value == 'דנה כהן'), isTrue);
    expect(rows.any((r) => r.label == 'כתובת אספקה'), isTrue);
    expect(rows.any((r) => r.label == 'תאריך' && r.value == '15/3/2026'), isTrue);
    // line items carry quantity, never a price
    final cement = rows.firstWhere((r) => r.label.contains('מלט'));
    expect(cement.value, '3 יח\'');
    expect(rows.any((r) => r.label.contains('חול')), isTrue,
        reason: 'emoji-less line still names the item');
  });

  test('NO money anywhere — no ₪, no total/VAT rows', () {
    const o = Order(
      id: 'x',
      who: 'y',
      site: '',
      items: 1,
      sum: 5000,
      stage: 'new',
      lines: [OrderLineItem(name: 'בלוק', emoji: '', qty: 10, price: 999)],
    );
    final rows = buildDeliveryNoteRows(o);
    expect(rows.every((r) => !r.value.contains('₪')), isTrue);
    expect(rows.any((r) => r.label.contains('מע"מ') || r.label.contains('סה"כ')),
        isFalse);
    expect(rows.any((r) => r.value.contains('999')), isFalse,
        reason: 'the line price is never printed on a delivery note');
  });

  test('optional rows (site/ship-to/date/notes) omitted when empty/null', () {
    const o =
        Order(id: 'x', who: 'y', site: '', items: 1, sum: 100, stage: 'new');
    final rows = buildDeliveryNoteRows(o);
    for (final label in ['אתר', 'כתובת אספקה', 'תאריך', 'הערות']) {
      expect(rows.any((r) => r.label == label), isFalse, reason: label);
    }
  });

  test('deliveryNoteTitle', () {
    const o =
        Order(id: 'BS-9', who: 'a', site: '', items: 1, sum: 1, stage: 'new');
    expect(deliveryNoteTitle(o), 'תעודת משלוח — BS-9');
  });
}
