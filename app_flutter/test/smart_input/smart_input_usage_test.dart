// Smart-input usage store (Phase-1) — persisted recent picks + frequency tally
// feeding the ranker. Mirrors the feature_flags_test style: ensureInitialized,
// setMockInitialValues, and a short settle for the async _load/_persist.
import 'package:buildsmart/state/smart_input_usage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default empty — fresh notifier with no prefs', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final n = SmartInputUsageNotifier();
    await _settle(); // initial _load
    expect(n.state.recent, isEmpty);
    expect(n.state.frequencies, isEmpty);
  });

  test('record() prepends to recent (most-recent-first) and counts frequency',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final n = SmartInputUsageNotifier();
    await _settle();

    n.record('alpha');
    n.record('beta');
    expect(n.state.recent, ['beta', 'alpha'],
        reason: 'newest pick is at the front');
    expect(n.state.frequencies, {'alpha': 1, 'beta': 1});
  });

  test('record() de-duplicates recent and bumps frequency on a repeat',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final n = SmartInputUsageNotifier();
    await _settle();

    n.record('alpha');
    n.record('beta');
    n.record('alpha'); // repeat — moves to front, no duplicate entry

    expect(n.state.recent, ['alpha', 'beta'],
        reason: 'a repeat moves to front and is de-duplicated');
    expect(n.state.frequencies['alpha'], 2,
        reason: 'repeat increments the frequency');
    expect(n.state.frequencies['beta'], 1);
  });

  test('record() ignores blank/whitespace input', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final n = SmartInputUsageNotifier();
    await _settle();

    n.record('   ');
    n.record('');
    expect(n.state.recent, isEmpty);
    expect(n.state.frequencies, isEmpty);
  });

  test('recent length is capped at kMaxSmartInputRecent (newest kept)',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final n = SmartInputUsageNotifier();
    await _settle();

    for (var i = 0; i < kMaxSmartInputRecent + 5; i++) {
      n.record('item$i');
    }
    expect(n.state.recent.length, kMaxSmartInputRecent);
    expect(n.state.recent.first, 'item${kMaxSmartInputRecent + 4}',
        reason: 'the most-recent pick is at the front');
    expect(n.state.recent, isNot(contains('item0')),
        reason: 'oldest picks fall off the end');
    // Frequency tally is NOT capped — every distinct text is still counted.
    expect(n.state.frequencies.length, kMaxSmartInputRecent + 5);
  });

  test('persists recent + frequencies across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final n1 = SmartInputUsageNotifier();
    await _settle();

    n1.record('saw');
    n1.record('drill');
    n1.record('saw'); // saw freq → 2
    await _settle(); // let _persist flush

    final n2 = SmartInputUsageNotifier(); // simulate restart
    await _settle();
    expect(n2.state.recent, ['saw', 'drill'],
        reason: 'recent survives a refresh/restart');
    expect(n2.state.frequencies, {'saw': 2, 'drill': 1},
        reason: 'frequency tally survives a refresh/restart');
  });
}
