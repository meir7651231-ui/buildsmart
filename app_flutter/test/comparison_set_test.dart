// Roadmap step 76-adjacent — product comparison set (persisted).
import 'package:buildsmart/state/comparison_set.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('default empty', () {
    SharedPreferences.setMockInitialValues({});
    final n = ComparisonSetNotifier();
    expect(n.state, isEmpty);
    expect(n.contains('x'), isFalse);
  });

  test('add then contains; adding the same key is idempotent', () {
    SharedPreferences.setMockInitialValues({});
    final n = ComparisonSetNotifier();
    expect(n.add('a'), isTrue);
    expect(n.contains('a'), isTrue);
    final before = n.state;
    expect(n.add('a'), isTrue);
    expect(identical(before, n.state), isTrue, reason: 'no state churn');
  });

  test('add stops at maxItems', () {
    SharedPreferences.setMockInitialValues({});
    final n = ComparisonSetNotifier(maxItems: 2);
    expect(n.add('a'), isTrue);
    expect(n.add('b'), isTrue);
    expect(n.add('c'), isFalse);
    expect(n.state.length, 2);
  });

  test('remove drops the key', () {
    SharedPreferences.setMockInitialValues({});
    final n = ComparisonSetNotifier();
    n.add('a');
    n.remove('a');
    expect(n.contains('a'), isFalse);
  });

  test('toggle flips presence; toggle at cap doesn\'t add new', () {
    SharedPreferences.setMockInitialValues({});
    final n = ComparisonSetNotifier(maxItems: 2);
    n.toggle('a');
    expect(n.contains('a'), isTrue);
    n.toggle('a');
    expect(n.contains('a'), isFalse);
    n.add('b');
    n.add('c');
    n.toggle('d'); // at cap, can't add
    expect(n.contains('d'), isFalse);
  });

  test('persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = ComparisonSetNotifier();
    n1.add('x');
    n1.add('y');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = ComparisonSetNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.state, {'x', 'y'});
  });
}
