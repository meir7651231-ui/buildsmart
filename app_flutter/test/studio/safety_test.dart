// Pins the critical-id safety net (#studio · Pillar 1 · step 26): the kImmutable
// seeds form the critical set (criticalIdsProvider — single source, no drift); the
// publish-validator strips a hide/reroute of a critical id BEFORE it goes live (the
// legal part still publishes; published stays clean); criticalViolations reports
// them; and the model layer neutralizes a critical hide even if it reached published.
// Gate/role/sink overridden — no SharedPreferences / auth touched.
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart' show CfgAction;
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:buildsmart/state/studio/element_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSink implements ConfigSink {
  @override
  Future<void> save(ConfigDoc doc) async {}
  @override
  Future<ConfigDoc?> load() async => null;
  @override
  Stream<ConfigDoc>? watch() => null;
}

const _critical = 'nav.bottombar';

void main() {
  final owner = kOwnerEmails.first;

  ProviderContainer make({bool editing = false}) {
    final c = ProviderContainer(
      overrides: [
        configSinkProvider.overrideWithValue(_FakeSink()),
        roleProvider.overrideWithValue(null),
        studioActiveProvider.overrideWithValue(editing),
        studioOwnerEmailProvider.overrideWithValue(editing ? owner : null),
        studioInManagerContextProvider.overrideWithValue(editing),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('criticalIdsProvider = every kImmutable registry id (step-26 seeds)', () {
    final ids = make().read(criticalIdsProvider);
    expect(
      ids,
      containsAll(<String>{
        'auth.login.cta',
        'auth.logout',
        'nav.bottombar',
        'manager.entry',
        'studio.exit',
      }),
    );
    // The editable pilot ids are NOT critical.
    expect(ids.contains('cart.cta'), isFalse);
    expect(ids.contains('manager.cockpit.kpi.openOrders'), isFalse);
  });

  test('publish strips a critical hide but keeps the legal edits', () {
    final c = make();
    final n = c.read(configStoreProvider.notifier);
    final critical = c.read(criticalIdsProvider);
    n.applyOps(const [
      SetText('cart.cta', 'קנה עכשיו'),
      SetHidden(_critical, true),
    ]);
    expect(n.criticalViolations(critical), {_critical}); // validator detects it

    final ok = n.publish(nowMs: 1, criticalIds: critical);
    expect(ok, isTrue);
    final pub = c.read(configStoreProvider).published;
    expect(pub.global['cart.cta']?.text, 'קנה עכשיו'); // legal edit went live
    expect(pub.global[_critical]?.hidden, isNull); // illegal hide rejected
  });

  test('publish returns false when the draft is ONLY an illegal critical edit', () {
    final c = make();
    final n = c.read(configStoreProvider.notifier)
      ..applyOps(const [SetHidden(_critical, true)]);
    final ok = n.publish(nowMs: 1, criticalIds: c.read(criticalIdsProvider));
    expect(ok, isFalse);
    expect(c.read(configStoreProvider).published.isEmpty, isTrue); // nothing published
  });

  test('resolve neutralizes a critical hide that reached published', () {
    final c = make();
    // Publish WITHOUT the validator so the hide slips into published…
    c.read(configStoreProvider.notifier)
      ..applyOps(const [SetHidden(_critical, true)])
      ..publish(nowMs: 1);
    expect(c.read(configStoreProvider).published.global[_critical]?.hidden, isTrue);
    // …yet the model layer still resolves it visible (defence-in-depth).
    expect(c.read(resolvedNodeProvider(_critical)).hidden, isNull);
  });

  // ── step 27: write-validator + behavior whitelist + 3rd reset scope ──────────

  test('write-validator: text over the length cap is dropped', () {
    final c = make();
    final n = c.read(configStoreProvider.notifier)
      ..applyOps([SetText('cart.cta', 'א' * (kCfgMaxTextLen + 1))]);
    expect(c.read(configStoreProvider).draft.global['cart.cta'], isNull); // refused
    n.applyOps(const [SetText('cart.cta', 'קנה')]); // a legal-length edit is kept
    expect(c.read(configStoreProvider).draft.global['cart.cta']?.text, 'קנה');
  });

  test('write-validator: a bidi-control (LTR-injection) is refused', () {
    final c = make();
    // U+202E (RLO) via fromCharCode — a raw control char in the literal would itself
    // trip the analyzer (text_direction_code_point_in_literal).
    final injected = 'שלום${String.fromCharCode(0x202E)}evil';
    c.read(configStoreProvider.notifier).applyOps([SetText('cart.cta', injected)]);
    expect(c.read(configStoreProvider).draft.global['cart.cta'], isNull);
  });

  test('behavior whitelist: an unauthorized action kind is dropped', () {
    final c = make();
    final n = c.read(configStoreProvider.notifier)
      ..applyOps(const [SetAction('cart.cta', CfgAction(kind: 'launchUrl'))]);
    expect(c.read(configStoreProvider).draft.global['cart.cta'], isNull); // refused
    n.applyOps(const [SetAction('cart.cta', CfgAction(kind: 'noop'))]); // whitelisted
    expect(c.read(configStoreProvider).draft.global['cart.cta']?.action?.kind, 'noop');
  });

  test('cfgActionRegistry whitelists exactly noop + navigate (v1)', () {
    expect(make().read(cfgActionRegistryProvider), {'noop', 'navigate'});
  });

  test('resetAll wipes everything but stays recoverable via history', () {
    final c = make();
    final n = c.read(configStoreProvider.notifier)
      ..applyOps(const [SetText('cart.cta', 'מקורי')])
      ..publish(nowMs: 1);
    expect(c.read(configStoreProvider).published.global['cart.cta']?.text, 'מקורי');

    expect(n.resetAll(nowMs: 2), isTrue);
    expect(c.read(configStoreProvider).published.isEmpty, isTrue); // wiped

    n.rollback(1, nowMs: 3); // the pre-reset version
    expect(
      c.read(configStoreProvider).published.global['cart.cta']?.text,
      'מקורי', // recovered — reset was non-destructive
    );
  });
}
