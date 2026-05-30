// Roadmap step 62 foundation — recent in-card searches.
// Tests the pure list transform (trim + move-to-front + dedupe + cap) and the
// persisted notifier round-trip backed by SharedPreferences.
import 'package:buildsmart/state/recent_searches.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RecentSearchesNotifier (default empty + record + clear)', () {
    test('default state is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final n = RecentSearchesNotifier();
      // _load is async; before it resolves the initial state is const [].
      expect(n.state, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n.state, isEmpty);
    });

    test('record adds to front; multiple records keep order newest-first',
        () async {
      SharedPreferences.setMockInitialValues({});
      final n = RecentSearchesNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      n
        ..add('alpha')
        ..add('beta')
        ..add('gamma');
      expect(n.state, ['gamma', 'beta', 'alpha']);
    });

    test('whitespace-only or empty query is ignored', () async {
      SharedPreferences.setMockInitialValues({});
      final n = RecentSearchesNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      n
        ..add('')
        ..add('   ')
        ..add('\t\n ');
      expect(n.state, isEmpty);
      n
        ..add('real')
        ..add('   '); // still ignored
      expect(n.state, ['real']);
    });

    test('re-recording an existing query moves it to the front (no duplicate)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final n = RecentSearchesNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      n
        ..add('a')
        ..add('b')
        ..add('c')
        ..add('a'); // promote 'a' to the front
      expect(n.state, ['a', 'c', 'b']);
      expect(n.state.toSet().length, n.state.length); // no duplicates
    });

    test('cap-N trims oldest when exceeded (max:3, record 5)', () {
      // Use the pure transform with a custom cap so the invariant is testable
      // without touching the notifier's hardcoded default.
      var list = <String>[];
      for (final q in ['one', 'two', 'three', 'four', 'five']) {
        list = addRecentSearch(list, q, max: 3);
      }
      expect(list.length, 3);
      // Newest 3 of the 5, ordered newest-first.
      expect(list, ['five', 'four', 'three']);
    });

    test('persists across a fresh notifier', () async {
      SharedPreferences.setMockInitialValues({});
      final n1 = RecentSearchesNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      n1
        ..add('persisted-1')
        ..add('persisted-2');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(n1.state, ['persisted-2', 'persisted-1']);

      final n2 = RecentSearchesNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(n2.state, ['persisted-2', 'persisted-1']);
    });
  });
}
