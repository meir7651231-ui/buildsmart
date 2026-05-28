import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/test_harness/types.dart';

/// Cart & checkout math — mirrors test/gaps_test, test/cart_bulk_order_test and
/// test/cart_stress_test so the in-app "רגרסיה מלאה" button exercises the cart
/// too. Pure-function checks only (no SmartCartNotifier instance) so running
/// the panel never touches the persisted live cart. Reported under
/// [TestCategory.cart].
List<TestResult> testCart() {
  TestCheck eq(String name, Object got, Object exp) => TestCheck(
        name: name,
        pass: got == exp,
        expected: '$exp',
        got: '$got',
      );

  const line = SmartCartLine(
    productKey: 'lip:demo',
    productName: 'מוצר בדיקה',
    productEmoji: '📦',
    brandName: 'ספק',
    brandPrice: 100,
    productQty: 3,
    accessories: [SmartCartAcc(name: 'אום', emoji: '🔩', price: 20, qty: 2)],
  );
  final round = SmartCartLine.fromJson(line.toJson());

  return [
    TestResult(
      id: 'cart:units',
      category: TestCategory.cart,
      area: 'סל',
      label: '🛒 ספירת יחידות (לא שורות)',
      checks: [
        // 3 fixed units (b:0 ignored) + 3 line units = 6.
        eq('כמויות קבועות + שורה', cartItemCount(const {'a': 3, 'b': 0}, [line]), 6),
        eq('סל ריק = 0', cartItemCount(const {}, const []), 0),
      ],
    ),
    TestResult(
      id: 'cart:line-total',
      category: TestCategory.cart,
      area: 'סל',
      label: '🛒 סכום שורה כולל אביזרים',
      checks: [
        eq('100×3 + 20×2', line.total, 340),
      ],
    ),
    TestResult(
      id: 'cart:money',
      category: TestCategory.cart,
      area: 'סל',
      label: '🛒 מע"מ · משלוח · סה"כ',
      checks: [
        eq('מע"מ 18% על 1000 (לא כלול)', cartVat(1000, vatInclusive: false), 180),
        eq('משלוח אקספרס', deliveryFeeFor(CartDelivery.express), 120),
        eq('משלוח רגיל', deliveryFeeFor(CartDelivery.standard), 45),
        eq('איסוף עצמי', deliveryFeeFor(CartDelivery.pickup), 0),
        eq('סה"כ לא-כלול (1000+180+45)',
            cartTotal(1000, 45, vatInclusive: false), 1225),
        eq('סה"כ כלול (1000+45)',
            cartTotal(1000, 45, vatInclusive: true), 1045),
      ],
    ),
    TestResult(
      id: 'cart:persistence',
      category: TestCategory.cart,
      area: 'סל',
      label: '🛒 שמירה/טעינה (JSON round-trip)',
      checks: [
        eq('productKey', round.productKey, line.productKey),
        eq('productQty', round.productQty, line.productQty),
        eq('total נשמר', round.total, line.total),
        eq('אביזר נשמר', round.accessories.first.name, 'אום'),
      ],
    ),
  ];
}
