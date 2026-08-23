import 'package:buildsmart/screens/store_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the W1 saved-cart ₪-truncation (store_screen, 2026-06-08):
/// `_loadItem` reconstructed a saved line as `brandPrice = total ~/ qty`, which
/// shaved up to (qty-1) ₪ off any line whose total wasn't divisible by qty
/// (₪340 @ qty 3 → 339; ₪1000 @ qty 7 → 994). [savedLineReconstruct] now
/// preserves the total exactly.
void main() {
  void preservesTotal(int total, int qty) {
    final r = savedLineReconstruct(total, qty);
    expect(r.brandPrice * r.qty, total, reason: 'total=$total qty=$qty');
  }

  test('divisible: keeps the per-unit price and qty', () {
    final r = savedLineReconstruct(360, 3);
    expect(r.brandPrice, 120);
    expect(r.qty, 3);
  });

  test('non-divisible: preserves total exactly (the bug case)', () {
    preservesTotal(340, 3); // was 339
    preservesTotal(1000, 7); // was 994
  });

  test('preserves total across a sweep', () {
    for (var total = 0; total <= 500; total += 7) {
      for (var qty = 1; qty <= 6; qty++) {
        preservesTotal(total, qty);
      }
    }
  });

  test('qty <= 0 is guarded to 1', () {
    final r = savedLineReconstruct(50, 0);
    expect(r.brandPrice, 50);
    expect(r.qty, 1);
  });
}
