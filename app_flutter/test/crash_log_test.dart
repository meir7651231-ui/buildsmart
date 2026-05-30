// Roadmap step 90 — in-app crash/error log (in-memory only).
import 'package:buildsmart/state/crash_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default empty + countBy() == 0', () {
    final n = CrashLogNotifier();
    expect(n.state, isEmpty);
    expect(n.countBy(), 0);
  });

  test('record adds to the front (newest first)', () {
    final n = CrashLogNotifier();
    n.record('first');
    n.record('second');
    expect(n.state.first.message, 'second');
    expect(n.state.last.message, 'first');
  });

  test('maxEntries trims oldest (FIFO from the back)', () {
    final n = CrashLogNotifier(maxEntries: 3);
    n.record('a');
    n.record('b');
    n.record('c');
    n.record('d');
    n.record('e');
    expect(n.state.length, 3);
    expect(n.state.map((e) => e.message).toList(), ['e', 'd', 'c']);
  });

  test('clear empties the log', () {
    final n = CrashLogNotifier();
    n.record('x');
    n.record('y');
    n.clear();
    expect(n.state, isEmpty);
  });

  test('countBy filters by context substring; null matches all', () {
    final n = CrashLogNotifier();
    n.record('e1', context: 'BOM dialog');
    n.record('e2', context: 'cart add');
    n.record('e3', context: 'BOM render');
    expect(n.countBy(), 3);
    expect(n.countBy(contextFilter: 'BOM'), 2);
    expect(n.countBy(contextFilter: 'cart'), 1);
  });
}
