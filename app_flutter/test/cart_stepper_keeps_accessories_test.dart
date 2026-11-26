// Regression guard — the grid/list quick-add stepper (SmartCartNotifier
// .setQtyForKey) must NOT silently delete the priced accessories the product
// sheet already put on the same product key.
//
// Before: lipskey_product_sheet adds a 'lip:<sku>' line carrying e.g. teflon
// tape ₪4 + gasket ₪8. Back on the grid, "+" rebuilt the line with
// `accessories: const []` and setQtyForKey replaced every line of that key →
// qty 2, accessories gone, subtotal down ₪12, no warning.
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tape = SmartCartAcc(name: 'טפלון', emoji: '🧻', price: 4, qty: 1);
const _gasket = SmartCartAcc(name: 'אטם', emoji: '⭕', price: 8, qty: 1);

SmartCartLine _line(
  int qty, {
  String key = 'lip:123',
  int price = 10,
  List<SmartCartAcc> accs = const [],
  Map<String, String> sel = const {},
}) =>
    SmartCartLine(
      productKey: key,
      productName: 'ברך 90°',
      productEmoji: '🔧',
      brandName: 'ליפסקי',
      brandPrice: price,
      productQty: qty,
      accessories: accs,
      selection: sel,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer c;
  late SmartCartNotifier cart;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    c = ProviderContainer();
    cart = c.read(smartCartProvider.notifier);
  });
  tearDown(() => c.dispose());

  List<SmartCartLine> lines() => c.read(smartCartProvider);

  test('stepper "+" keeps the sheet-added accessories and their price', () {
    cart.add(_line(1, accs: const [_tape, _gasket]));
    expect(lines().single.total, 10 + 4 + 8);

    cart.setQtyForKey(_line(2)); // grid card "+" (no accessories)

    final l = lines().single;
    expect(l.productQty, 2);
    expect(l.accessories.map((a) => a.name), ['טפלון', 'אטם'],
        reason: 'the accessories must survive the stepper');
    expect(l.total, 2 * 10 + 4 + 8,
        reason: 'the subtotal must not silently drop ₪12');
  });

  test('two sheet adds of the same product collapse with summed accessories',
      () {
    cart.add(_line(1, accs: const [_tape]));
    cart.add(_line(1, accs: const [_tape, _gasket]));

    cart.setQtyForKey(_line(3));

    final l = lines().single;
    expect(l.productQty, 3);
    final byName = {for (final a in l.accessories) a.name: a.qty};
    expect(byName, {'טפלון': 2, 'אטם': 1});
    expect(l.total, 3 * 10 + 2 * 4 + 8);
  });

  test('stepper keeps the saved configuration (selection)', () {
    cart.add(_line(1, sel: const {'קוטר': '32'}));
    cart.setQtyForKey(_line(2));
    expect(lines().single.selection, {'קוטר': '32'});
  });

  test('stepper to 0 removes the product (and its accessories)', () {
    cart.add(_line(1, accs: const [_tape]));
    cart.add(_line(1, key: 'lip:999'));
    cart.setQtyForKey(_line(0));
    expect(lines().map((l) => l.productKey), ['lip:999']);
  });

  test('other products are untouched; a plain key still collapses as before',
      () {
    cart.add(_line(1, key: 'lip:999', accs: const [_gasket]));
    cart.setQtyForKey(_line(1));
    cart.setQtyForKey(_line(4));
    expect(lines().length, 2);
    expect(lines().firstWhere((l) => l.productKey == 'lip:999').accessories,
        hasLength(1));
    final mine = lines().firstWhere((l) => l.productKey == 'lip:123');
    expect(mine.productQty, 4);
    expect(mine.accessories, isEmpty);
    expect(cart.qtyForKey('lip:123'), 4);
  });
}
