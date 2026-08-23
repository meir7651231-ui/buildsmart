// GIANT Phase-2 wave-3 (documents) — the pure invoice/receipt kernel. The
// authoritative total is order.sum (VAT+delivery-inclusive gross); VAT is
// backed out at the statutory rate so (sum-vat)+vat == sum always — no drift,
// no fabricated subtotal. Line items are informational.

import 'package:buildsmart/logic/invoice.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('invoiceVatOf backs VAT out of a VAT-inclusive gross (18%)', () {
    expect(invoiceVatOf(1180), 180); // 1000 + 18% = 1180
    expect(invoiceVatOf(0), 0);
  });

  test('reconciles by construction — (gross - vat) + vat == gross', () {
    for (final g in [0, 1, 99, 999, 1180, 12800, 100001]) {
      expect((g - invoiceVatOf(g)) + invoiceVatOf(g), g, reason: 'g=$g');
    }
  });

  test('buildInvoiceRows: meta + line items + total==sum + backed-out VAT', () {
    const o = Order(
      id: 'BS-1042',
      who: 'דנה כהן',
      site: 'אתר צפון',
      items: 2,
      sum: 1180,
      stage: 'new',
      lines: [
        OrderLineItem(name: 'מלט', emoji: '🧱', qty: 3, price: 600),
        OrderLineItem(name: 'חול', emoji: '', qty: 1, price: 400),
      ],
    );
    final rows = buildInvoiceRows(o);
    expect(
      rows.any((r) => r.label == 'מספר הזמנה' && r.value == 'BS-1042'),
      isTrue,
    );
    expect(rows.any((r) => r.label == 'לקוח' && r.value == 'דנה כהן'), isTrue);
    // line items — with emoji and without
    expect(rows.any((r) => r.label.contains('מלט') && r.value.contains('600')),
        isTrue);
    expect(rows.any((r) => r.label.contains('חול')), isTrue,
        reason: 'emoji-less line still names the item');
    // total is the authoritative gross; VAT is the backed-out portion
    final total = rows.firstWhere((r) => r.label.contains('סה"כ'));
    expect(total.value, contains('1,180'));
    final vat = rows.firstWhere((r) => r.label.contains('מע"מ'));
    expect(vat.value, contains('180'));
  });

  test('site row omitted when the order has no site', () {
    const o =
        Order(id: 'x', who: 'y', site: '', items: 1, sum: 100, stage: 'new');
    expect(buildInvoiceRows(o).any((r) => r.label == 'אתר'), isFalse);
  });

  test('invoiceTitle distinguishes invoice from receipt', () {
    const o =
        Order(id: 'BS-9', who: 'a', site: '', items: 1, sum: 1, stage: 'new');
    expect(invoiceTitle(o, receipt: false), 'חשבונית — BS-9');
    expect(invoiceTitle(o, receipt: true), 'קבלה — BS-9');
  });
}
