// Pins resolvedNodeProvider (#studio · Pillar 1 · step 7): per-id resolution via
// `.select` slices. Empty doc ⇒ identity (the zero-regression root); published
// global applies to all; a published persona override wins for THAT roleKey only;
// the draft is visible ONLY while previewing; and the R2-#1 keystone — editing
// id-A must NOT notify resolvedNodeProvider(id-B). Fully isolated: the gate +
// role + sink are overridden, so no SharedPreferences / Firebase is touched.
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
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
  final owner = kOwnerEmails.first;

  // A container with the viewer pinned to [role]. When [editing], the Studio gate
  // is opened (owner+manager+active) and edit-mode entered ⇒ previewDraft is true.
  // Overriding the gate providers keeps featureFlags/auth out of the test.
  ProviderContainer make({String? role, bool editing = false}) {
    final c = ProviderContainer(
      overrides: [
        configSinkProvider.overrideWithValue(_FakeSink()),
        roleProvider.overrideWithValue(role),
        studioActiveProvider.overrideWithValue(editing),
        studioOwnerEmailProvider.overrideWithValue(editing ? owner : null),
        studioInManagerContextProvider.overrideWithValue(editing),
      ],
    );
    addTearDown(c.dispose);
    if (editing) c.read(editModeProvider.notifier).enterEdit();
    return c;
  }

  test('empty doc ⇒ identity (the zero-regression root)', () {
    final c = make();
    expect(c.read(resolvedNodeProvider('any.id')), CfgNode.identity);
  });

  test('published.global applies to every persona', () {
    final c = make(role: 'store');
    c.read(configStoreProvider.notifier)
      ..applyOps([const SetText('cta', 'X')])
      ..publish(nowMs: 1);
    expect(c.read(resolvedNodeProvider('cta')).text, 'X');
  });

  group('published.persona is picked by the viewer roleKey', () {
    test('the matching persona sees its override (beats global)', () {
      final c = make(role: 'manager');
      c.read(configStoreProvider.notifier)
        ..applyOps([const SetText('cta', 'global')])
        ..applyOps([const SetText('cta', 'mgr')], persona: 'manager')
        ..publish(nowMs: 1);
      expect(c.read(resolvedNodeProvider('cta')).text, 'mgr');
    });

    test('a different persona falls back to global (no leak across roles)', () {
      final c = make(role: 'store');
      c.read(configStoreProvider.notifier)
        ..applyOps([const SetText('cta', 'global')])
        ..applyOps([const SetText('cta', 'mgr')], persona: 'manager')
        ..publish(nowMs: 1);
      expect(c.read(resolvedNodeProvider('cta')).text, 'global');
    });
  });

  group('draft is visible ONLY while previewing', () {
    test('not editing ⇒ unpublished draft is invisible', () {
      final c = make(role: 'manager');
      c.read(configStoreProvider.notifier).applyOps([const SetText('cta', 'wip')]);
      expect(c.read(resolvedNodeProvider('cta')).text, isNull);
    });

    test('editing (previewDraft) ⇒ the owner sees the draft live', () {
      final c = make(role: 'manager', editing: true);
      c.read(configStoreProvider.notifier).applyOps([const SetText('cta', 'wip')]);
      expect(c.read(resolvedNodeProvider('cta')).text, 'wip');
    });
  });

  test('R2-#1: editing id-A does NOT notify resolvedNodeProvider(id-B)',
      () async {
    final c = make(role: 'manager');
    var aHits = 0;
    var bHits = 0;
    c
      ..listen(resolvedNodeProvider('a'), (_, __) => aHits++)
      ..listen(resolvedNodeProvider('b'), (_, __) => bHits++);

    c.read(configStoreProvider.notifier)
      ..applyOps([const SetText('a', 'A2')])
      ..publish(nowMs: 1);
    await Future<void>.delayed(Duration.zero); // flush scheduled notifications

    expect(bHits, 0, reason: 'a change in id-A must never rebuild id-B');
    expect(aHits, greaterThan(0), reason: 'id-A did change (positive control)');
  });
}
