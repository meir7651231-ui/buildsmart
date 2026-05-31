// Roadmap step 83 — offline cache primitive.
import 'package:buildsmart/state/offline_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('get returns null when missing', () {
    SharedPreferences.setMockInitialValues({});
    final n = OfflineCacheNotifier();
    expect(n.get('missing'), isNull);
  });

  test('put then get returns the value', () {
    SharedPreferences.setMockInitialValues({});
    final n = OfflineCacheNotifier();
    n.put('k', 'v');
    expect(n.get('k'), 'v');
  });

  test('expired entry is invisible to get', () {
    SharedPreferences.setMockInitialValues({});
    final n = OfflineCacheNotifier();
    n.put('k', 'v', ttl: const Duration(seconds: 10));
    final later = DateTime.now().add(const Duration(hours: 1));
    expect(n.get('k', now: later), isNull);
  });

  test('sweep drops expired and returns the count', () {
    SharedPreferences.setMockInitialValues({});
    final n = OfflineCacheNotifier();
    n.put('a', '1', ttl: const Duration(seconds: 1));
    n.put('b', '2', ttl: const Duration(days: 1));
    final later = DateTime.now().add(const Duration(minutes: 5));
    final dropped = n.sweep(now: later);
    expect(dropped, 1);
    expect(n.get('a', now: later), isNull);
    expect(n.get('b', now: later), '2');
  });

  test('clearAll empties the cache', () {
    SharedPreferences.setMockInitialValues({});
    final n = OfflineCacheNotifier();
    n.put('k', 'v');
    n.clearAll();
    expect(n.get('k'), isNull);
    expect(n.state, isEmpty);
  });

  test('persists across a fresh notifier (within TTL)', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = OfflineCacheNotifier();
    n1.put('keep', 'survives');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = OfflineCacheNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.get('keep'), 'survives');
  });
}
