// Real-fleet fix guard (9×9, 2026-06-09): the canonical lens-audit (async-race)
// confirmed 3 med StateNotifiers with the same load-race as #24 — the lazy
// provider's async _load() resolves AFTER a synchronous user mutation and
// clobbers it with the stale persisted value. Each got a _userTouched guard
// (mirrors UserProfileNotifier). These tests reproduce the race per notifier:
// seed OLD prefs, construct + mutate synchronously, let _load() resolve, assert
// the fresh user write SURVIVED.
//
// DETERMINISM (gate-quality, 2026-07-27): each test awaits the notifier's
// `ready` future (the @visibleForTesting hook that completes when the
// constructor's _load settles) instead of a fixed Future.delayed. The fixed
// delay was load-sensitive and made this file flaky under the full-suite
// concurrency (it was the known-failing baseline) — awaiting the real _load is
// exact, so the guard is verified every run.
import 'package:buildsmart/state/card_acc_state.dart';
import 'package:buildsmart/state/card_filter_state.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('card_filter_state — late _load does not clobber setType', () async {
    SharedPreferences.setMockInitialValues(
        {'bs.card-filter-state.v1': '{"P0":{"type":"ישן","size":null}}'});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final n = c.read(cardFilterStateProvider.notifier);
    n.setType('P1', 'חדש');
    await n.ready; // deterministic: wait for the late _load to actually settle

    expect(c.read(cardFilterStateProvider)['P1']?.type, 'חדש',
        reason: 'fresh setType must survive the late prefs load');
  });

  test('card_acc_state — late _load does not clobber setSelected', () async {
    SharedPreferences.setMockInitialValues(
        {'bs.card-acc-state.v1': '{"P0":{"a1":{"s":true,"q":5}}}'});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final n = c.read(cardAccStateProvider.notifier);
    n.setSelected('P1', 'a2', true);
    await n.ready;

    expect(c.read(cardAccStateProvider)['P1']?['a2']?.selected, true,
        reason: 'fresh setSelected must survive the late prefs load');
  });

  test('product_favorites — late _load does not clobber toggle', () async {
    SharedPreferences.setMockInitialValues(
        {'bs.product-favorites.v1': <String>['OLD_SKU']});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final n = c.read(productFavoritesProvider.notifier);
    n.toggle('NEW_SKU');
    await n.ready;

    expect(c.read(productFavoritesProvider).contains('NEW_SKU'), true,
        reason: 'fresh toggle must survive the late prefs load');
  });
}
