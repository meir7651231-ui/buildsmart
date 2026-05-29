// Roadmap step 66 — recently-viewed history. Tests the pure list transform
// (move-to-front + dedupe + cap) and the persisted notifier round-trip.
import 'package:buildsmart/state/recently_viewed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('recentlyViewedNext (pure)', () {
    test('new sku goes to the front', () {
      expect(recentlyViewedNext(['a', 'b'], 'c'), ['c', 'a', 'b']);
    });

    test('re-viewing moves the sku to the front without duplicating', () {
      expect(recentlyViewedNext(['a', 'b', 'c'], 'c'), ['c', 'a', 'b']);
      final r = recentlyViewedNext(['a', 'b', 'c'], 'c');
      expect(r.toSet().length, r.length);
    });

    test('caps the list length', () {
      final long = List.generate(25, (i) => 's$i');
      final r = recentlyViewedNext(long, 'new', cap: 20);
      expect(r.length, 20);
      expect(r.first, 'new');
    });

    test('empty sku is a no-op', () {
      expect(recentlyViewedNext(['a'], ''), ['a']);
    });
  });

  group('RecentlyViewedNotifier (persisted)', () {
    test('touch persists and reloads across a fresh notifier', () async {
      SharedPreferences.setMockInitialValues({});
      final n1 = RecentlyViewedNotifier();
      n1.touch('SKU-1');
      n1.touch('SKU-2');
      // allow async _persist to run
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n1.state, ['SKU-2', 'SKU-1']);

      final n2 = RecentlyViewedNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n2.state, ['SKU-2', 'SKU-1']);
    });

    test('clear empties the history', () async {
      SharedPreferences.setMockInitialValues({});
      final n = RecentlyViewedNotifier();
      n.touch('X');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      n.clear();
      expect(n.state, isEmpty);
    });
  });
}
