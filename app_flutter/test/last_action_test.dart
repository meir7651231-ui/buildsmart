// In-memory "last actions" log — supports a future undo affordance.
import 'package:buildsmart/state/last_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LastActionNotifier', () {
    test('default state is empty and latest is null', () {
      final notifier = LastActionNotifier();
      expect(notifier.state, isEmpty);
      expect(notifier.latest, isNull);
    });

    test('record adds entries to the front (newest first)', () {
      final notifier = LastActionNotifier();
      notifier.record(kind: 'brand-pick', label: 'Picked Acme');
      notifier.record(kind: 'add-to-project', label: 'Added Widget');

      expect(notifier.state.length, 2);
      expect(notifier.state.first.kind, 'add-to-project');
      expect(notifier.state.first.label, 'Added Widget');
      expect(notifier.state.last.kind, 'brand-pick');
    });

    test('latest reflects the newest recorded action', () {
      final notifier = LastActionNotifier();
      notifier.record(kind: 'brand-pick', label: 'First');
      notifier.record(kind: 'brand-pick', label: 'Second');
      notifier.record(kind: 'add-to-project', label: 'Third');

      final latest = notifier.latest;
      expect(latest, isNotNull);
      expect(latest!.kind, 'add-to-project');
      expect(latest.label, 'Third');
    });

    test('maxEntries trims older entries beyond the cap', () {
      final notifier = LastActionNotifier(maxEntries: 3);
      notifier.record(kind: 'k', label: 'a');
      notifier.record(kind: 'k', label: 'b');
      notifier.record(kind: 'k', label: 'c');
      notifier.record(kind: 'k', label: 'd');
      notifier.record(kind: 'k', label: 'e');

      expect(notifier.state.length, 3);
      // Newest first: e, d, c — a and b are dropped.
      expect(notifier.state[0].label, 'e');
      expect(notifier.state[1].label, 'd');
      expect(notifier.state[2].label, 'c');
    });

    test('countByKind returns exact-match count', () {
      final notifier = LastActionNotifier();
      notifier.record(kind: 'brand-pick', label: 'x');
      notifier.record(kind: 'add-to-project', label: 'y');
      notifier.record(kind: 'brand-pick', label: 'z');
      notifier.record(kind: 'brand-pick', label: 'w');

      expect(notifier.countByKind('brand-pick'), 3);
      expect(notifier.countByKind('add-to-project'), 1);
      expect(notifier.countByKind('missing'), 0);
    });

    test('clear empties the log', () {
      final notifier = LastActionNotifier();
      notifier.record(kind: 'brand-pick', label: 'x');
      notifier.record(kind: 'add-to-project', label: 'y');
      expect(notifier.state, isNotEmpty);

      notifier.clear();
      expect(notifier.state, isEmpty);
      expect(notifier.latest, isNull);
    });
  });
}
