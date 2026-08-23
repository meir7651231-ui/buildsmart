// FREEZES the Pillar-1 → Pillars-2-5 seams (#studio · step 30 · §13). These are the
// stable interface the later pillars build on. This is a COMPILE-GUARD: each seam is
// bound to an explicit function/provider type, so ANY signature drift stops this test
// compiling (and the build). Paired with the "FROZEN" markers in the code.
//
//   1. ConfigSink                 — persistence/sync swap point (Pillar-5)
//   2. applyOps + undo/redo       — the op seam (Pillar-4 produces ops; editDraft is
//                                    a PRIVATE primitive, never a seam — R1-A3)
//   3. publish                    — promote-to-live boundary
//   4. elementRegistryProvider    — Pillar-2 appends via domainElementsProvider;
//      + criticalIdsProvider        the 6-field ElementDescriptor froze at step 12.5
//   5. cfgActionRegistryProvider  — behavior whitelist (Pillar-4)
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_merge.dart' show mergeNodeSlices;
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
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

void main() {
  test('the 5 frozen Pillar seams keep their signatures (compile-guard)', () {
    final c = ProviderContainer(
      overrides: [configSinkProvider.overrideWithValue(_FakeSink())],
    );
    addTearDown(c.dispose);
    final store = c.read(configStoreProvider.notifier);

    // SEAM 1 — ConfigSink.
    final ConfigSink sink = _FakeSink();
    final Future<void> Function(ConfigDoc) save = sink.save;
    final Future<ConfigDoc?> Function() load = sink.load;

    // SEAM 2 — applyOps + undo/redo.
    final int Function(List<ConfigOp>, {String? persona, Set<String> criticalIds})
        applyOps = store.applyOps;
    final void Function() undo = store.undo;
    final void Function() redo = store.redo;

    // SEAM 3 — publish.
    final bool Function({
      String note,
      String byEmail,
      int nowMs,
      Set<String> criticalIds,
    })
    publish = store.publish;

    // SEAM 4 — element registry (+ critical set).
    final List<ElementDescriptor> registry = c.read(elementRegistryProvider);
    final Set<String> critical = c.read(criticalIdsProvider);

    // SEAM 5 — action whitelist.
    final Set<String> actions = c.read(cfgActionRegistryProvider);

    // Reference every binding so a drift can't hide behind an unused local.
    expect(
      <Function>[save, load, applyOps, undo, redo, publish],
      everyElement(isNotNull),
    );
    expect(sink, isA<ConfigSink>());
    expect(registry, isA<List<ElementDescriptor>>());
    expect(critical, isA<Set<String>>());
    expect(actions, isA<Set<String>>());
  });

  test('scales to 10K registry ids (perf smoke — resolve is O(1) per id)', () {
    // domainElementsProvider is the Pillar-2 append seam; 10K rows must not break
    // the registry or per-id resolve (resolvedNodeProvider is autoDispose.family).
    final domain = List.generate(
      10000,
      (i) => ElementDescriptor(
        id: 'perf.$i',
        screen: 'perf',
        area: 'a',
        labelHe: 'ל$i',
        kind: ElementKind.text,
      ),
    );
    final c = ProviderContainer(
      overrides: [
        configSinkProvider.overrideWithValue(_FakeSink()),
        domainElementsProvider.overrideWithValue(domain),
      ],
    );
    addTearDown(c.dispose);

    expect(c.read(elementRegistryProvider).length, greaterThanOrEqualTo(10000));
    expect(c.read(descriptorProvider('perf.5000'))?.id, 'perf.5000');
    // Per-id resolve is a pure O(1) fold of THIS id's slices (no scan): an empty doc
    // ⇒ identity (the zero-regression root). resolvedNodeProvider wraps this with the
    // viewer's persona/draft slices (its `.select` isolation is pinned by R2-#1).
    expect(mergeNodeSlices('perf.9999'), CfgNode.identity);
  });
}
