// Feature flags (ROADMAP step 10) — a persisted Set<String> of enabled flag
// names. Mirrors the hidden_catalog_sections persistence pattern: must survive
// a refresh/restart via SharedPreferences.
import 'package:buildsmart/state/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default empty — fresh notifier with no prefs is empty', () async {
    SharedPreferences.setMockInitialValues({});
    final n = FeatureFlagsNotifier();
    await _settle(); // initial _load
    expect(n.state, isEmpty);
    expect(n.isOn('anything'), isFalse);
  });

  test('word-finder NOT force-enabled without the build define (safe default)',
      () async {
    // The buildsmart-il.com demo build passes --dart-define=ENABLE_WORD_FINDER
    // to turn 'kWordFinder' on; EVERY other build (app, Android, tests) must
    // leave it OFF. Tests run with no define, so the forced set is empty.
    SharedPreferences.setMockInitialValues({});
    final n = FeatureFlagsNotifier();
    await _settle();
    expect(n.isOn('kWordFinder'), isFalse,
        reason: 'kWordFinder must stay OFF unless the demo build define is set');
  });

  test('enable adds; isOn → true', () async {
    SharedPreferences.setMockInitialValues({});
    final n = FeatureFlagsNotifier();
    await _settle();

    n.enable('foo');
    expect(n.isOn('foo'), isTrue);
    expect(n.state, {'foo'});

    // idempotent — enabling an already-on flag does not duplicate or churn
    final before = n.state;
    n.enable('foo');
    expect(identical(n.state, before), isTrue,
        reason: 'enable on an already-enabled flag must not churn state');
  });

  test('disable removes — enable then disable → isOn false', () async {
    SharedPreferences.setMockInitialValues({});
    final n = FeatureFlagsNotifier();
    await _settle();

    n.enable('foo');
    expect(n.isOn('foo'), isTrue);

    n.disable('foo');
    expect(n.isOn('foo'), isFalse);
    expect(n.state, isEmpty);

    // idempotent — disabling an absent flag does not churn
    final before = n.state;
    n.disable('foo');
    expect(identical(n.state, before), isTrue,
        reason: 'disable on an absent flag must not churn state');
  });

  test('toggle flips — twice → on → off', () async {
    SharedPreferences.setMockInitialValues({});
    final n = FeatureFlagsNotifier();
    await _settle();

    n.toggle('foo');
    expect(n.isOn('foo'), isTrue);
    n.toggle('foo');
    expect(n.isOn('foo'), isFalse);
  });

  test('persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = FeatureFlagsNotifier();
    await _settle();

    n1.enable('new-card');
    n1.enable('beta-bom');
    await _settle(); // let _persist flush

    // A fresh notifier (simulating an app restart) reloads from prefs.
    final n2 = FeatureFlagsNotifier();
    await _settle();
    expect(n2.isOn('new-card'), isTrue,
        reason: 'feature flags must survive a refresh/restart');
    expect(n2.isOn('beta-bom'), isTrue);
    expect(n2.state, {'new-card', 'beta-bom'});
  });
}
