// Roadmap step 91 — in-app analytics event log (in-memory only).
import 'package:buildsmart/state/analytics_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default empty + countByName(x) == 0', () {
    final n = AnalyticsLogNotifier();
    expect(n.state, isEmpty);
    expect(n.countByName('x'), 0);
  });

  test('record adds to the front (newest first)', () {
    final n = AnalyticsLogNotifier();
    n.record('a');
    n.record('b');
    expect(n.state.first.name, 'b');
    expect(n.state.last.name, 'a');
  });

  test('maxEntries trims oldest (newest 3 preserved)', () {
    final n = AnalyticsLogNotifier(maxEntries: 3);
    n.record('a');
    n.record('b');
    n.record('c');
    n.record('d');
    n.record('e');
    expect(n.state.length, 3);
    expect(n.state.map((e) => e.name).toList(), ['e', 'd', 'c']);
  });

  test('clear empties the log', () {
    final n = AnalyticsLogNotifier();
    n.record('x');
    n.record('y');
    n.clear();
    expect(n.state, isEmpty);
  });

  test('countByName matches exact name only', () {
    final n = AnalyticsLogNotifier();
    n.record('click_bom');
    n.record('click_bom');
    n.record('click_quote');
    expect(n.countByName('click_bom'), 2);
    expect(n.countByName('click_quote'), 1);
    expect(n.countByName('click'), 0);
  });

  test('recent(name:) filters; recent(limit:) caps', () {
    final n = AnalyticsLogNotifier();
    for (var i = 0; i < 10; i++) {
      n.record('view');
    }
    n.record('other');
    final r = n.recent(name: 'view', limit: 3);
    expect(r.length, 3);
    expect(r.every((e) => e.name == 'view'), isTrue);
  });
}
