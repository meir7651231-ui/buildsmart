import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show searchQueryProvider, smartTreeCatProvider;
import 'package:buildsmart/screens/store_screen.dart' show cartQtysProvider;
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Behavior tests — composite flows that touch multiple providers.
/// Pattern: save → mutate → assert → restore.
List<TestResult> testBehavior(WidgetRef ref) {
  return [
    _runOne(
      id: 'behavior:cart-qty',
      label: 'cartQty — set → read → remove',
      run: () {
        final checks = <TestCheck>[];
        final before = Map<String, int>.from(ref.read(cartQtysProvider));
        const testId = '__rt_probe__';
        // Set
        final updated = Map<String, int>.from(ref.read(cartQtysProvider))
          ..[testId] = 7;
        ref.read(cartQtysProvider.notifier).state = updated;
        checks.add(TestCheck(
          name: 'qty נשמר לאחר set',
          pass: ref.read(cartQtysProvider)[testId] == 7,
          expected: '7',
          got: '${ref.read(cartQtysProvider)[testId]}',
        ));
        // Remove
        final cleared = Map<String, int>.from(ref.read(cartQtysProvider))
          ..remove(testId);
        ref.read(cartQtysProvider.notifier).state = cleared;
        checks.add(TestCheck(
          name: 'remove מסיר את ה-key',
          pass: !ref.read(cartQtysProvider).containsKey(testId),
        ));
        // Restore
        ref.read(cartQtysProvider.notifier).state = before;
        checks.add(TestCheck(
          name: 'שחזור למצב המקורי',
          pass: ref.read(cartQtysProvider).length == before.length,
        ));
        return checks;
      },
    ),
    _runOne(
      id: 'behavior:smart-cart',
      label: 'smartCart — add → remove → clear',
      run: () {
        final checks = <TestCheck>[];
        final before = List<SmartCartLine>.from(ref.read(smartCartProvider));
        final notifier = ref.read(smartCartProvider.notifier)..clear();
        checks.add(TestCheck(
          name: 'clear מאפס לרשימה ריקה',
          pass: ref.read(smartCartProvider).isEmpty,
          got: '${ref.read(smartCartProvider).length}',
        ));
        const line = SmartCartLine(
          productKey: '__rt__',
          productName: 'בדיקה',
          productEmoji: '🧪',
          brandName: 'מותג בדיקה',
          brandPrice: 100,
          productQty: 2,
          accessories: [
            SmartCartAcc(name: 'אטם', emoji: '⚫', price: 5, qty: 3),
          ],
        );
        notifier.add(line);
        checks.add(TestCheck(
          name: 'add מוסיף שורה אחת',
          pass: ref.read(smartCartProvider).length == 1,
          got: '${ref.read(smartCartProvider).length}',
        ));
        final added = ref.read(smartCartProvider).first;
        checks.add(TestCheck(
          name: 'total מחושב נכון (100×2 + 5×3 = 215)',
          pass: added.total == 215,
          expected: '215',
          got: '${added.total}',
        ));
        notifier.add(line);
        notifier.remove(0);
        checks.add(TestCheck(
          name: 'remove(0) משאיר שורה אחת',
          pass: ref.read(smartCartProvider).length == 1,
          got: '${ref.read(smartCartProvider).length}',
        ));
        notifier.clear();
        // Restore
        for (final l in before) {
          notifier.add(l);
        }
        checks.add(TestCheck(
          name: 'שחזור מספר השורות',
          pass: ref.read(smartCartProvider).length == before.length,
          expected: '${before.length}',
          got: '${ref.read(smartCartProvider).length}',
        ));
        return checks;
      },
    ),
    _runOne(
      id: 'behavior:search-query',
      label: 'searchQuery — set / clear',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(searchQueryProvider);
        ref.read(searchQueryProvider.notifier).state = 'ברז';
        checks.add(TestCheck(
          name: 'set שומר את הערך',
          pass: ref.read(searchQueryProvider) == 'ברז',
          expected: 'ברז',
          got: ref.read(searchQueryProvider),
        ));
        ref.read(searchQueryProvider.notifier).state = '';
        checks.add(TestCheck(
          name: 'clear (set "") מנקה',
          pass: ref.read(searchQueryProvider).isEmpty,
        ));
        ref.read(searchQueryProvider.notifier).state = before;
        return checks;
      },
    ),
    _runOne(
      id: 'behavior:smart-tree-drill',
      label: 'smartTree — בחירת קטגוריה ושחזור',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(smartTreeCatProvider);
        if (kSmartTreeCats.isEmpty) {
          checks.add(const TestCheck(
            name: 'יש לפחות קטגוריה אחת לבדוק',
            pass: false,
            detail: 'kSmartTreeCats ריק',
          ));
          return checks;
        }
        final first = kSmartTreeCats.first;
        ref.read(smartTreeCatProvider.notifier).state = first;
        checks.add(TestCheck(
          name: 'drill לקטגוריה "$first"',
          pass: ref.read(smartTreeCatProvider) == first,
          expected: first,
          got: ref.read(smartTreeCatProvider) ?? 'null',
        ));
        final products = smartProductsForCat(first);
        checks.add(TestCheck(
          name: 'יש מוצרים לקטגוריה "$first"',
          pass: products.isNotEmpty,
          got: '${products.length}',
        ));
        ref.read(smartTreeCatProvider.notifier).state = null;
        checks.add(TestCheck(
          name: 'pop ל-null מחזיר לרשימת קטגוריות',
          pass: ref.read(smartTreeCatProvider) == null,
        ));
        ref.read(smartTreeCatProvider.notifier).state = before;
        return checks;
      },
    ),
  ];
}

TestResult _runOne({
  required String id,
  required String label,
  required List<TestCheck> Function() run,
}) {
  var checks = <TestCheck>[];
  var crashed = false;
  try {
    checks = run();
  } on Object catch (e) {
    crashed = true;
    checks.add(TestCheck(
      name: 'הבדיקה רצה בלי לקרוס',
      pass: false,
      detail: '$e',
    ));
  }
  if (!crashed) {
    checks.add(const TestCheck(name: 'הבדיקה רצה בלי לקרוס', pass: true));
  }
  return TestResult(
    id: id,
    category: TestCategory.behavior,
    label: label,
    area: 'התנהגות',
    checks: checks,
  );
}
