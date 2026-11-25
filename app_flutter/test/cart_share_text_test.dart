// cartShareText — the cart summary handed to the share sheet must carry the
// SAME «סה״כ» the on-screen summary charges (delivery, and VAT on a
// VAT-exclusive store, included) and group thousands like every other ₪.

import 'package:buildsmart/screens/store_screen.dart' show cartShareText;
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_test/flutter_test.dart';

SmartCartLine _line(String name, String emoji, int price, int qty) =>
    SmartCartLine(
      productKey: name,
      productName: name,
      productEmoji: emoji,
      brandName: 'מותג',
      brandPrice: price,
      productQty: qty,
      accessories: const [],
    );

void main() {
  test('VAT-inclusive + standard delivery → total = lines + ₪45', () {
    final t = cartShareText(
      [_line('מלט', '🧱', 30, 2)],
      deliveryFee: 45,
      vatInclusive: true,
    );
    expect(t, contains('🧱 מלט × 2 = ₪60'));
    expect(t, contains('משלוח: ₪45'));
    expect(t, contains('סה״כ: ₪105'));
    expect(t, isNot(contains('מע"מ'))); // embedded in the prices
  });

  test('pickup → משלוח: חינם, total = lines', () {
    final t = cartShareText(
      [_line('מלט', '🧱', 30, 2)],
      deliveryFee: 0,
      vatInclusive: true,
    );
    expect(t, contains('משלוח: חינם'));
    expect(t, contains('סה״כ: ₪60'));
  });

  test('VAT-exclusive → VAT line + VAT added to the total', () {
    final t = cartShareText(
      [_line('ברז', '🚰', 100, 1)],
      deliveryFee: 120,
      vatInclusive: false,
    );
    expect(t, contains('מע"מ 18%: ₪18'));
    expect(t, contains('סה״כ: ₪238')); // 100 + 18 + 120
  });

  test('thousands are grouped on lines and total', () {
    final t = cartShareText(
      [_line('צינור', '🔧', 1350, 4)],
      deliveryFee: 45,
      vatInclusive: true,
    );
    expect(t, contains('= ₪5,400'));
    expect(t, contains('סה״כ: ₪5,445'));
  });
}
