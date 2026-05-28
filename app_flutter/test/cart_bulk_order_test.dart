import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Orders 20 distinct catalog products at 20 different quantities (1..20) and
/// reports exactly what the cart produces, end-to-end through the real cart
/// math (subtotal · VAT · delivery · total · order record).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  String price(int n) => n < 1000
      ? '₪$n'
      : '₪${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';

  test('order 20 different products · varying quantities · real catalog data',
      () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cart = c.read(smartCartProvider.notifier);

    // 20 distinct catalog products.
    final picks = <LipskeyCatalogProduct>[];
    final seen = <String>{};
    for (final p in kLipskeyCatalog) {
      if (seen.add(p.sku)) picks.add(p);
      if (picks.length == 20) break;
    }
    expect(picks.length, 20, reason: 'need 20 distinct catalog products');

    // Add each at quantity 1..20, exactly as the product card does
    // (brandPrice 0 — catalog items are "מחיר לפי ספק").
    for (var i = 0; i < picks.length; i++) {
      final p = picks[i];
      cart.add(SmartCartLine(
        productKey: 'lip:${p.sku}',
        productName: p.nameHe,
        productEmoji: p.typeEmoji,
        brandName: p.brand,
        brandPrice: 0,
        productQty: i + 1,
      accessories: const []));
    }

    final lines = c.read(smartCartProvider);
    final subtotal = lines.fold<int>(0, (s, l) => s + l.total);
    final count = cartItemCount(const {}, lines); // distinct lines (by design)
    final totalUnits = lines.fold<int>(0, (s, l) => s + l.productQty);
    final deliveryFee = deliveryFeeFor(CartDelivery.standard);
    final vat = cartVat(subtotal, vatInclusive: false);
    final total = cartTotal(subtotal, deliveryFee, vatInclusive: false);
    final orderNo = 12345;

    // ignore_for_file: avoid_print
    print('\n══════════ הזמנה · 20 מוצרי קטלוג · כמויות 1..20 ══════════');
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      print('${(i + 1).toString().padLeft(2)}. ${l.productEmoji} '
          '${l.productName}  ×${l.productQty}  = ${price(l.total)}');
    }
    print('──────────────────────────────────────────────────────────');
    print('שורות שונות:        ${lines.length}');
    print('"פריטים" (badge):   $count   ← סופר שורות, לא יחידות');
    print('סך יחידות בפועל:    $totalUnits');
    print('סכום ביניים:        ${price(subtotal)}');
    print('מע"מ 18%:           ${price(vat)}');
    print('משלוח:              ${price(deliveryFee)}');
    print('סה"כ לתשלום:        ${price(total)}');
    print('הזמנה שנוצרת:       BS-$orderNo · $count פריטים · ${price(total)} · בהכנה 🔧');
    print('════════════════════════════════════════════════════════════\n');

    expect(lines.length, 20);
    expect(count, 20); // cartItemCount = distinct lines (documented behaviour)
    expect(totalUnits, 210); // 1+2+…+20 — the real unit count
    expect(subtotal, 0, reason: 'catalog items carry no price (מחיר לפי ספק)');
    expect(total, deliveryFee, reason: 'only the delivery fee is chargeable');
  });

  test('same 20 lines but priced — proves the money math scales', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cart = c.read(smartCartProvider.notifier);

    var expected = 0;
    for (var i = 0; i < 20; i++) {
      final qty = i + 1; // 1..20
      final unit = (i + 1) * 10; // ₪10,20,…,200
      expected += unit * qty;
      cart.add(SmartCartLine(
        productKey: 'p$i',
        productName: 'מוצר $i',
        productEmoji: '📦',
        brandName: 'ספק',
        brandPrice: unit,
        productQty: qty,
        accessories: const []));
    }

    final lines = c.read(smartCartProvider);
    final subtotal = lines.fold<int>(0, (s, l) => s + l.total);
    final deliveryFee = deliveryFeeFor(CartDelivery.express); // 4 שעות = ₪120
    final vat = cartVat(subtotal, vatInclusive: false);
    final total = cartTotal(subtotal, deliveryFee, vatInclusive: false);

    print('\n══════════ הזמנה · 20 מוצרים מתומחרים · כמויות 1..20 ══════════');
    print('סכום ביניים:   ${price(subtotal)}  (צפוי ${price(expected)})');
    print('מע"מ 18%:      ${price(vat)}');
    print('משלוח (4 שעות):${price(deliveryFee)}');
    print('סה"כ לתשלום:   ${price(total)}');
    print('═══════════════════════════════════════════════════════════════\n');

    expect(subtotal, expected);
    expect(total, subtotal + vat + deliveryFee);
  });
}
