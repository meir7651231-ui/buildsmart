// Swarm-review CRITICAL fix: the line basket (cardPicksProvider) must be identity-scoped
// when the unified finder is on — a uid switch on a shared fleet tablet must WIPE employee
// A's picks so employee B never inherits them. Mirrors recentlyViewedProvider's scoping.
//
// The flag is persisted (not enable()-d) so FeatureFlagsNotifier._load() keeps it ON across
// awaits; a listener keeps cardPicksProvider active (the line UI ref.watch-es it in
// production); awaits let Riverpod apply the uid-scoped rebuild.

import 'package:buildsmart/features/card_keyboard/card_keyboard_flag.dart'
    show kCardKeyboardFlag;
import 'package:buildsmart/features/card_keyboard/card_picks.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _testUid = StateProvider<String?>((ref) => 'A');

Future<ProviderContainer> _scopedContainer() async {
  final c = ProviderContainer(
    overrides: [
      currentUidProvider.overrideWith((ref) => ref.watch(_testUid)),
    ],
  );
  addTearDown(c.dispose);
  c.listen(cardPicksProvider, (_, __) {}); // the line UI watches it in production
  await Future<void>.delayed(Duration.zero); // settle FeatureFlagsNotifier._load()
  expect(c.read(featureFlagsProvider).contains(kCardKeyboardFlag), isTrue,
      reason: 'flag must be ON for the scoping branch to engage');
  return c;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({
        'bs.feature-flags.v1': [kCardKeyboardFlag],
      }));

  test('flag-ON: switching identity RESETS the line basket (no A->B bleed)',
      () async {
    final c = await _scopedContainer();
    c.read(cardPicksProvider.notifier)
      ..addPick(const CardPick(sku: 'X', label: 'x'))
      ..addPick(const CardPick(sku: 'Y', label: 'y'));
    expect(c.read(cardPicksProvider), hasLength(2));

    c.read(_testUid.notifier).state = 'B'; // employee B logs in
    await Future<void>.delayed(Duration.zero); // let the uid-scoped rebuild apply
    expect(c.read(cardPicksProvider), isEmpty,
        reason: 'employee B must not inherit employee A line picks');
  });

  test('flag-ON: a microtask WITHOUT a uid change keeps the basket (control)',
      () async {
    final c = await _scopedContainer();
    c.read(cardPicksProvider.notifier)
        .addPick(const CardPick(sku: 'X', label: 'x'));
    await Future<void>.delayed(Duration.zero); // an await alone must NOT clear it
    expect(c.read(cardPicksProvider), hasLength(1),
        reason: 'only a uid change resets — not the passage of a microtask');
  });
}
