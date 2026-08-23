// Pillar-2 Step 43 — pins the active-trade resolution BEFORE any UI consumes
// it: default 'plumbing'; the reserved-plumbing guard (plan addition-B: you
// can never unpublish your way into an empty catalog); the switcher hidden at
// count==1; and the unpublish-fallback (the RESOLVED id snaps back to
// 'plumbing' — the raw selection is deliberately NOT pinned). Zero visual
// change — no widget imports. Fake prefs + ProviderContainer over the step-34
// store, with the async-_load settle trick from trades_store_test.dart.
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

/// A fresh container over EMPTY mock prefs. Instantiates the trades store and
/// lets its async `_load` settle (empty prefs ⇒ it keeps the empty doc), so a
/// test mutation can never race the load — same trick as
/// trades_store_test.dart.
Future<ProviderContainer> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final c = ProviderContainer();
  addTearDown(c.dispose);
  c.read(tradesStoreProvider); // instantiate ⇒ kicks off the async _load
  await _settle();
  return c;
}

/// Minimal real ctor — id / nameHe / emoji / color / personaId are required;
/// `published` is opt-in (defaults to false).
const _electric = Trade(
  id: 'electric',
  nameHe: 'חשמל',
  emoji: '⚡',
  color: 0xFF112233,
  personaId: 'p.elec',
  published: true,
);

/// The same trade flipped back to a draft — `published` omitted ⇒ false (an
/// explicit `published: false` would trip avoid_redundant_argument_values).
const _electricDraft = Trade(
  id: 'electric',
  nameHe: 'חשמל',
  emoji: '⚡',
  color: 0xFF112233,
  personaId: 'p.elec',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default is plumbing (empty store)', () async {
    final c = await _fresh();
    expect(c.read(activeTradeProvider), 'plumbing');
    expect(c.read(resolvedActiveTradeIdProvider), 'plumbing');
    // addition-A: the reserved plumbing id has no authored Trade ⇒ null obj.
    expect(c.read(activeTradeObjProvider), isNull);
  });

  test('plumbing is always published (reserved)', () async {
    final c = await _fresh();
    final ids = c.read(publishedTradeIdsProvider);
    expect(ids, contains('plumbing'));
    expect(ids, hasLength(1));
  });

  test('switcher hidden at count==1, visible at 2', () async {
    final c = await _fresh();
    expect(
      c.read(tradeSwitcherVisibleProvider),
      isFalse,
      reason: 'plumbing alone (count==1) must not show the switcher',
    );

    c.read(tradesStoreProvider.notifier).upsertTrade(_electric);
    expect(c.read(publishedTradeIdsProvider), {'plumbing', 'electric'});
    expect(c.read(tradeSwitcherVisibleProvider), isTrue);
  });

  test('set + resolve: a published trade becomes active', () async {
    final c = await _fresh();
    c.read(tradesStoreProvider.notifier).upsertTrade(_electric);
    // publishing alone must not switch — the selection is explicit.
    expect(c.read(resolvedActiveTradeIdProvider), 'plumbing');

    c.read(activeTradeProvider.notifier).set('electric');
    expect(c.read(resolvedActiveTradeIdProvider), 'electric');
    expect(c.read(activeTradeObjProvider)?.id, 'electric');
  });

  test('fallback: unpublishing the active trade resolves back to plumbing',
      () async {
    final c = await _fresh();
    c.read(tradesStoreProvider.notifier).upsertTrade(_electric);
    expect(c.read(publishedTradeIdsProvider), contains('electric'));
    c.read(activeTradeProvider.notifier).set('electric');
    expect(c.read(resolvedActiveTradeIdProvider), 'electric');

    // the same id flips back to draft (removeTrade exercises the same path).
    c.read(tradesStoreProvider.notifier).upsertTrade(_electricDraft);
    expect(
      c.read(resolvedActiveTradeIdProvider),
      'plumbing',
      reason: 'only the RESOLVED id is pinned — the raw selection may '
          'legitimately stay on the unpublished id',
    );
  });

  test('setting an unknown/unpublished id resolves to plumbing', () async {
    final c = await _fresh();
    c.read(activeTradeProvider.notifier).set('gardening');
    expect(c.read(resolvedActiveTradeIdProvider), 'plumbing');
  });
}
