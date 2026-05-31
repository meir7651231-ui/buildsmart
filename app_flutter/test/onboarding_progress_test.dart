// Onboarding progress — a persisted Set<String> of hint ids the user has
// already seen. Mirrors the feature_flags persistence pattern: must survive a
// refresh/restart via SharedPreferences.
import 'package:buildsmart/state/onboarding_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default empty — hasSeen false, seenAll false on non-empty input',
      () async {
    SharedPreferences.setMockInitialValues({});
    final n = OnboardingProgressNotifier();
    await _settle(); // initial _load
    expect(n.state, isEmpty);
    expect(n.hasSeen('x'), isFalse);
    expect(n.seenAll(['x']), isFalse);
  });

  test('markSeen adds; hasSeen true; idempotent (no state churn)', () async {
    SharedPreferences.setMockInitialValues({});
    final n = OnboardingProgressNotifier();
    await _settle();

    n.markSeen('hint-a');
    expect(n.hasSeen('hint-a'), isTrue);
    expect(n.state, {'hint-a'});

    // idempotent — re-marking an already-seen hint must not churn state
    final before = n.state;
    n.markSeen('hint-a');
    final after = n.state;
    expect(identical(before, after), isTrue,
        reason: 'markSeen on an already-seen hint must not churn state');
  });

  test('seenAll true iff every member has been seen', () async {
    SharedPreferences.setMockInitialValues({});
    final n = OnboardingProgressNotifier();
    await _settle();

    n.markSeen('a');
    n.markSeen('b');

    expect(n.seenAll(['a']), isTrue);
    expect(n.seenAll(['a', 'b']), isTrue);
    expect(n.seenAll(['a', 'b', 'c']), isFalse,
        reason: 'one missing member must flip seenAll to false');
  });

  test('reset clears all seen hints; hasSeen back to false', () async {
    SharedPreferences.setMockInitialValues({});
    final n = OnboardingProgressNotifier();
    await _settle();

    n.markSeen('a');
    n.markSeen('b');
    expect(n.hasSeen('a'), isTrue);

    n.reset();
    expect(n.state, isEmpty);
    expect(n.hasSeen('a'), isFalse);
    expect(n.hasSeen('b'), isFalse);
  });

  test('persists across a fresh notifier (simulated app restart)', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = OnboardingProgressNotifier();
    await _settle();

    n1.markSeen('intro');
    n1.markSeen('bom-button');
    await _settle(); // let _persist flush

    // A fresh notifier (simulating an app restart) reloads from prefs.
    final n2 = OnboardingProgressNotifier();
    await _settle();
    expect(n2.hasSeen('intro'), isTrue,
        reason: 'onboarding progress must survive a refresh/restart');
    expect(n2.hasSeen('bom-button'), isTrue);
    expect(n2.state, {'intro', 'bom-button'});
  });
}
