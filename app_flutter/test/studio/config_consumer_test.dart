// Pins the config CONSUMER seam (#studio · Pillar 1 · read-back) — the layer the
// Studio was MISSING: `resolvedCfgProvider` + `ConfigDoc.resolved(id)` read the
// published⊕draft overlay so a Studio edit finally becomes VISIBLE in the live app.
//   • default (empty doc) ⇒ identity (empty text/hidden) — the zero-regression root;
//   • a SetText draft overlays the label (draft wins);
//   • a SetHidden draft flips visibility (owner can hide the element);
//   • ConfigDoc.resolved: draft overlays published; an untouched id stays identity.
// Isolated via a fake sink (no SharedPreferences / Firebase).
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
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

void main() {
  // The wired pilot element (the cart/checkout button — element_registry.dart).
  const cartCta = 'cart.cta';

  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [configSinkProvider.overrideWithValue(_FakeSink())],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('default ⇒ identity (empty text) — the zero-regression contract', () {
    final c = make();
    final cfg = c.read(resolvedCfgProvider(cartCta));
    expect(cfg, CfgNode.identity);
    expect(cfg.text, isNull);
    expect(cfg.hidden, isNull);
    expect(cfg.emoji, isNull);
  });

  test('a SetText draft overlays the resolved node (draft wins)', () {
    final c = make();
    c
        .read(configStoreProvider.notifier)
        .applyOps([const SetText(cartCta, 'שלח הזמנה')]);
    expect(c.read(resolvedCfgProvider(cartCta)).text, 'שלח הזמנה');
  });

  test('a SetHidden draft hides the element (hidden overlay works)', () {
    final c = make();
    c
        .read(configStoreProvider.notifier)
        .applyOps([const SetHidden(cartCta, true)]);
    expect(c.read(resolvedCfgProvider(cartCta)).hidden, isTrue);
  });

  test('ConfigDoc.resolved: draft overlays published; identity when untouched', () {
    final c = make();
    final notifier = c.read(configStoreProvider.notifier);
    // Publish a base text into `published`, then stage a `draft` on top.
    notifier
      ..applyOps([const SetText(cartCta, 'published')])
      ..publish(nowMs: 1);
    expect(c.read(configStoreProvider).resolved(cartCta).text, 'published',
        reason: 'published value is read back when there is no draft');
    notifier.applyOps([const SetText(cartCta, 'draft')]);
    expect(c.read(configStoreProvider).resolved(cartCta).text, 'draft',
        reason: 'draft overlays published (draft wins per-axis)');
    // An id neither layer touches resolves to the identity node (verbatim fallback).
    expect(c.read(configStoreProvider).resolved('untouched.id'), CfgNode.identity);
  });
}
