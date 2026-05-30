// Roadmap step 48-adjacent — persisted quote drafts.
import 'package:buildsmart/state/draft_quote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('default empty + byLabel null', () {
    SharedPreferences.setMockInitialValues({});
    final n = DraftQuoteNotifier();
    expect(n.state, isEmpty);
    expect(n.byLabel('x'), isNull);
  });

  test('save adds a draft; byLabel returns it', () {
    SharedPreferences.setMockInitialValues({});
    final n = DraftQuoteNotifier();
    n.save(label: 'kitchen', text: 'one liner');
    final d = n.byLabel('kitchen');
    expect(d, isNotNull);
    expect(d!.text, 'one liner');
  });

  test('save with existing label replaces text (no duplicate)', () {
    SharedPreferences.setMockInitialValues({});
    final n = DraftQuoteNotifier();
    n.save(label: 'q', text: 'v1');
    n.save(label: 'q', text: 'v2');
    expect(n.state.length, 1);
    expect(n.byLabel('q')!.text, 'v2');
  });

  test('remove(id) drops it', () {
    SharedPreferences.setMockInitialValues({});
    final n = DraftQuoteNotifier();
    final d = n.save(label: 'x', text: 't');
    n.remove(d.id);
    expect(n.state, isEmpty);
  });

  test('maxEntries trims oldest, keeping newest', () {
    SharedPreferences.setMockInitialValues({});
    final n = DraftQuoteNotifier(maxEntries: 2);
    n.save(label: 'a', text: '1');
    n.save(label: 'b', text: '2');
    n.save(label: 'c', text: '3');
    expect(n.state.length, 2);
    expect(n.state.map((d) => d.label).toList(), ['b', 'c']);
  });

  test('persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = DraftQuoteNotifier();
    n1.save(label: 'kitchen', text: 'hello');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = DraftQuoteNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.byLabel('kitchen')?.text, 'hello');
  });
}
