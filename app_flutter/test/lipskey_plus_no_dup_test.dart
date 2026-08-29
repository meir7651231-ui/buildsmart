import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression guard for the W1 lipskey '+' duplicate-line bug (2026-06-08):
/// the list-card '+' (`_ProductRow._addToCart`) appended via `add`, so when a
/// ListView recycle reset the row's `_open` while the product was already in
/// the cart, a second tap created a DUPLICATE line. The fix routes the '+'
/// through `setQtyForKey`, which is idempotent on `productKey`. These tests pin
/// that contract — the property the screen now relies on.
SmartCartLine _line(String key, int qty) => SmartCartLine(
      productKey: key,
      productName: 'x',
      productEmoji: '🔧',
      brandName: 'b',
      brandPrice: 10,
      productQty: qty,
      accessories: const [],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer c;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    c = ProviderContainer();
  });
  tearDown(() => c.dispose());

  test('setQtyForKey twice on one key keeps a single line (recycle re-tap)', () {
    final cart = c.read(smartCartProvider.notifier);
    cart.setQtyForKey(_line('lip:1', 1));
    cart.setQtyForKey(_line('lip:1', 1));
    final lines =
        c.read(smartCartProvider).where((l) => l.productKey == 'lip:1');
    expect(lines.length, 1);
    expect(cart.qtyForKey('lip:1'), 1);
  });

  test('setQtyForKey replaces qty in place, never stacks', () {
    final cart = c.read(smartCartProvider.notifier);
    cart.setQtyForKey(_line('lip:3', 1));
    cart.setQtyForKey(_line('lip:3', 5));
    final lines =
        c.read(smartCartProvider).where((l) => l.productKey == 'lip:3').toList();
    expect(lines.length, 1);
    expect(lines.single.productQty, 5);
  });
}
