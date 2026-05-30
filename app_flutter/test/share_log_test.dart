// Share action log — persisted history of quote-copy / deep-link /
// project-quote share events.
import 'package:buildsmart/state/share_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('default empty + countByKind("x") == 0', () {
    SharedPreferences.setMockInitialValues({});
    final n = ShareLogNotifier();
    expect(n.state, isEmpty);
    expect(n.countByKind('x'), 0);
    expect(n.countByKind('quote'), 0);
  });

  test('record adds to the front (newest first)', () {
    SharedPreferences.setMockInitialValues({});
    final n = ShareLogNotifier();
    n.record(kind: 'quote', label: 'first');
    n.record(kind: 'deep-link', label: 'second');
    expect(n.state.length, 2);
    expect(n.state.first.kind, 'deep-link');
    expect(n.state.first.label, 'second');
    expect(n.state.last.kind, 'quote');
  });

  test('maxEntries trims oldest (newest preserved)', () {
    SharedPreferences.setMockInitialValues({});
    final n = ShareLogNotifier(maxEntries: 3);
    n.record(kind: 'quote', label: 'a');
    n.record(kind: 'quote', label: 'b');
    n.record(kind: 'quote', label: 'c');
    n.record(kind: 'quote', label: 'd');
    n.record(kind: 'quote', label: 'e');
    expect(n.state.length, 3);
    expect(n.state.map((e) => e.label).toList(), ['e', 'd', 'c']);
  });

  test('clear empties the log + countByKind == 0', () {
    SharedPreferences.setMockInitialValues({});
    final n = ShareLogNotifier();
    n.record(kind: 'quote', label: 'x');
    n.record(kind: 'project-quote', label: 'y');
    expect(n.state, isNotEmpty);
    n.clear();
    expect(n.state, isEmpty);
    expect(n.countByKind('quote'), 0);
    expect(n.countByKind('project-quote'), 0);
  });

  test('persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = ShareLogNotifier();
    n1.record(kind: 'quote', label: 'ברז למטבח · AQUATEC');
    n1.record(kind: 'deep-link', label: 'project/42');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    final n2 = ShareLogNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(n2.state.length, 2);
    expect(n2.state.first.kind, 'deep-link');
    expect(n2.state.first.label, 'project/42');
    expect(n2.state.last.kind, 'quote');
    expect(n2.countByKind('quote'), 1);
    expect(n2.countByKind('deep-link'), 1);
  });
}
