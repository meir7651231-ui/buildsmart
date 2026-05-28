import 'dart:math';

import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 50 "hard" randomised-but-deterministic cart/order scenarios plus mutation
/// edge cases. Each scenario builds a cart with many lines, extreme
/// quantities, accessories, ₪0 items, random VAT mode and delivery method,
/// then checks the cart math against an independent hand computation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const qtyChoices = [1, 2, 3, 7, 13, 50, 250, 999, 5000];
  const unitChoices = [0, 0, 5, 18, 99, 450, 1299, 8800];

  test('50 hard order scenarios · math + invariants hold', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cart = c.read(smartCartProvider.notifier);
    final rng = Random(50);

    var biggest = 0;
    var biggestDesc = '';
    var maxLines = 0;
    var maxUnits = 0;

    for (var s = 1; s <= 50; s++) {
      cart.clear();

      final nLines = 1 + rng.nextInt(30); // 1..30 distinct lines
      var expSubtotal = 0;
      var expUnits = 0;

      for (var i = 0; i < nLines; i++) {
        final qty = qtyChoices[rng.nextInt(qtyChoices.length)];
        final unit = unitChoices[rng.nextInt(unitChoices.length)];
        final accs = <SmartCartAcc>[];
        for (var a = 0; a < rng.nextInt(3); a++) {
          final ap = 5 + rng.nextInt(120);
          final aq = 1 + rng.nextInt(4);
          accs.add(SmartCartAcc(name: 'acc$a', emoji: '🔩', price: ap, qty: aq));
          expSubtotal += ap * aq;
        }
        expSubtotal += unit * qty;
        expUnits += qty;
        cart.add(SmartCartLine(
          productKey: 's${s}_$i',
          productName: 'מוצר $i',
          productEmoji: '📦',
          brandName: 'ספק',
          brandPrice: unit,
          productQty: qty,
          accessories: accs,
        ));
      }

      // Random fixed-item quantities too (the other half of cartItemCount).
      final fixed = <String, int>{};
      for (var f = 0; f < rng.nextInt(4); f++) {
        fixed['f$f'] = rng.nextInt(40); // may be 0 → ignored
      }
      expUnits += fixed.values.where((q) => q > 0).fold<int>(0, (x, q) => x + q);

      final lines = c.read(smartCartProvider);
      final subtotal = lines.fold<int>(0, (x, l) => x + l.total);
      final units = cartItemCount(fixed, lines);
      final vatInclusive = rng.nextBool();
      final delivery = CartDelivery.values[rng.nextInt(3)];
      final fee = deliveryFeeFor(delivery);
      final vat = cartVat(subtotal, vatInclusive: vatInclusive);
      final total = cartTotal(subtotal, fee, vatInclusive: vatInclusive);

      expect(lines.length, nLines, reason: 'scenario $s · line count');
      expect(subtotal, expSubtotal, reason: 'scenario $s · subtotal');
      expect(units, expUnits, reason: 'scenario $s · unit count');
      expect(vat >= 0, isTrue, reason: 'scenario $s · vat negative');
      expect(total >= subtotal, isTrue, reason: 'scenario $s · total < subtotal');
      if (vatInclusive) {
        expect(total, subtotal + fee, reason: 'scenario $s · inclusive total');
      } else {
        expect(total, subtotal + vat + fee,
            reason: 'scenario $s · exclusive total');
      }

      if (total > biggest) {
        biggest = total;
        biggestDesc =
            'תרחיש $s · $nLines שורות · $units יח׳ · סה"כ ₪$total';
      }
      maxLines = max(maxLines, nLines);
      maxUnits = max(maxUnits, units);
    }

    // ignore_for_file: avoid_print
    print('\n══════════ 50 תרחישי לחץ קשים — עברו ══════════');
    print('מקס׳ שורות בתרחיש:  $maxLines');
    print('מקס׳ יחידות בתרחיש: $maxUnits');
    print('ההזמנה הגדולה ביותר: $biggestDesc');
    print('═══════════════════════════════════════════════\n');
  });

  test('hard mutation edge cases on the cart', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cart = c.read(smartCartProvider.notifier);

    SmartCartLine line(String k, int qty, {int price = 100}) => SmartCartLine(
          productKey: k,
          productName: k,
          productEmoji: '📦',
          brandName: 'b',
          brandPrice: price,
          productQty: qty,
          accessories: const [],
        );

    // 1 · setLineQty to 0 removes the line.
    cart.add(line('a', 3));
    cart.add(line('b', 2));
    cart.setLineQty(0, 0);
    expect(c.read(smartCartProvider).length, 1);
    expect(c.read(smartCartProvider).first.productKey, 'b');

    // 2 · setLineQty negative also removes.
    cart.setLineQty(0, -5);
    expect(c.read(smartCartProvider), isEmpty);

    // 3 · setLineQty out of range is a no-op (no crash).
    cart.setLineQty(7, 4);
    expect(c.read(smartCartProvider), isEmpty);

    // 4 · setLineQty raises a huge quantity correctly.
    cart.add(line('c', 1, price: 7));
    cart.setLineQty(0, 100000);
    expect(c.read(smartCartProvider).first.productQty, 100000);
    expect(c.read(smartCartProvider).first.total, 700000);

    // 5 · setQtyForKey collapses duplicates of the same product key.
    cart.clear();
    cart.add(line('dup', 2));
    cart.add(line('dup', 5));
    expect(c.read(smartCartProvider).length, 2);
    cart.setQtyForKey(line('dup', 9));
    final dups = c.read(smartCartProvider).where((l) => l.productKey == 'dup');
    expect(dups.length, 1, reason: 'duplicates collapsed to one line');
    expect(dups.first.productQty, 9);

    // 6 · clear empties everything.
    cart.add(line('x', 4));
    cart.clear();
    expect(c.read(smartCartProvider), isEmpty);
    expect(cartItemCount(const {}, c.read(smartCartProvider)), 0);

    print('hard mutation edge cases — passed');
  });
}
