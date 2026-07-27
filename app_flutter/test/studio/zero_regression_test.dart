// Pins the Studio #84 governance gate (#studio · Pillar 1 · step 8): edit-mode
// flips ON only for owner + manager-context + active, and is INERT for every
// other persona (contractor=roleKeyOf(null), store, courier, worker, stranger)
// — the zero-regression / no-leak contract. The three gate inputs are overridden
// directly, so no fake AuthGateway is needed. Also pins the #84 reset: edit-mode
// drops the instant the manager-context drops (logout / role switch).
//
// (Step 15 will EXTEND this file with the Cfg* wrapper zero-regression cases.)
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:buildsmart/widgets/studio/studio_overlay.dart';
import 'package:flutter/material.dart';
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
  final owner = kOwnerEmails.first; // the real allowlisted owner email

  // Defaults: active=true, email=null (no owner), manager=false (other persona).
  ProviderContainer make({
    bool active = true,
    String? email,
    bool manager = false,
  }) {
    final c = ProviderContainer(
      overrides: [
        studioActiveProvider.overrideWithValue(active),
        studioOwnerEmailProvider.overrideWithValue(email),
        studioInManagerContextProvider.overrideWithValue(manager),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('edit-mode gate — flips ON only for owner + manager + active', () {
    test('owner + manager + active CAN enter edit (preview turns on)', () {
      final c = make(email: owner, manager: true);
      c.read(editModeProvider.notifier).enterEdit();
      expect(c.read(editModeProvider).isEditing, isTrue);
      expect(c.read(editModeProvider).previewDraft, isTrue); // owner sees WIP
    });

    test('non-owner (no email) CANNOT enter — even WITH manager + active', () {
      final c = make(manager: true);
      c.read(editModeProvider.notifier).enterEdit();
      expect(c.read(editModeProvider).isEditing, isFalse);
    });

    test('a stranger email CANNOT enter — even WITH manager + active', () {
      final c = make(email: 'stranger@example.com', manager: true);
      c.read(editModeProvider.notifier).enterEdit();
      expect(c.read(editModeProvider).isEditing, isFalse);
    });

    test('owner but NOT a manager context CANNOT enter (#84 — other personas)',
        () {
      final c = make(email: owner);
      c.read(editModeProvider.notifier).enterEdit();
      expect(c.read(editModeProvider).isEditing, isFalse);
    });

    test('owner + manager but Studio NOT active (flag off) CANNOT enter', () {
      final c = make(email: owner, manager: true, active: false);
      c.read(editModeProvider.notifier).enterEdit();
      expect(c.read(editModeProvider).isEditing, isFalse);
    });

    test('canEdit mirrors the gate', () {
      expect(
        make(email: owner, manager: true).read(editModeProvider.notifier).canEdit,
        isTrue,
      );
      expect(
        make(manager: true).read(editModeProvider.notifier).canEdit,
        isFalse,
      );
    });

    test('toggleEdit never leaks for a non-owner', () {
      final c = make(manager: true);
      c.read(editModeProvider.notifier).toggleEdit();
      expect(c.read(editModeProvider).isEditing, isFalse);
    });
  });

  group('#84 reset — edit-mode dies when the gate stops qualifying', () {
    test('revalidate() drops edit-mode once the manager context is gone', () {
      final mgr = StateProvider<bool>((_) => true);
      final c = ProviderContainer(
        overrides: [
          studioActiveProvider.overrideWithValue(true),
          studioOwnerEmailProvider.overrideWithValue(owner),
          studioInManagerContextProvider.overrideWith((ref) => ref.watch(mgr)),
        ],
      );
      addTearDown(c.dispose);

      c.read(editModeProvider.notifier).enterEdit();
      expect(c.read(editModeProvider).isEditing, isTrue);

      c.read(mgr.notifier).state = false; // owner leaves manager / logs out
      c.read(editModeProvider.notifier).revalidate(); // deterministic
      expect(c.read(editModeProvider).isEditing, isFalse);
    });

    test('the listener auto-resets edit-mode on a context change', () async {
      final mgr = StateProvider<bool>((_) => true);
      final c = ProviderContainer(
        overrides: [
          studioActiveProvider.overrideWithValue(true),
          studioOwnerEmailProvider.overrideWithValue(owner),
          studioInManagerContextProvider.overrideWith((ref) => ref.watch(mgr)),
        ],
      );
      addTearDown(c.dispose);

      c.read(editModeProvider.notifier).enterEdit();
      expect(c.read(editModeProvider).isEditing, isTrue);

      c.read(mgr.notifier).state = false;
      c.read(studioInManagerContextProvider); // force recompute
      await Future<void>.delayed(Duration.zero); // flush ref.listen
      expect(c.read(editModeProvider).isEditing, isFalse);
    });
  });

  group('selection + audit', () {
    test('select is a no-op outside edit-mode', () {
      final c = make();
      c.read(editModeProvider.notifier).select('cart.cta');
      expect(c.read(editModeProvider).selectedId, isNull);
    });

    test('select then exit clears selection + editing', () {
      final c = make(email: owner, manager: true);
      final n = c.read(editModeProvider.notifier)
        ..enterEdit()
        ..select('cart.cta');
      expect(c.read(editModeProvider).selectedId, 'cart.cta');
      n.exitEdit();
      expect(c.read(editModeProvider).isEditing, isFalse);
      expect(c.read(editModeProvider).selectedId, isNull);
    });

    test('audit log records enter + exit with the owner email (#84 trail)', () {
      final c = make(email: owner, manager: true);
      final n = c.read(editModeProvider.notifier)
        ..enterEdit()
        ..exitEdit();
      expect(n.auditLog.map((e) => e.action), ['enter', 'exit']);
      expect(n.auditLog.first.email, owner);
    });
  });

  group('StudioOverlay — inert off-gate + navigate⇄edit chrome (#13 · slice-0)', () {
    testWidgets('off-gate ⇒ SizedBox.shrink, no chrome (answer-equivalent)', (
      tester,
    ) async {
      final c = ProviderContainer(
        overrides: [
          studioActiveProvider.overrideWithValue(false),
          studioOwnerEmailProvider.overrideWithValue(null),
          studioInManagerContextProvider.overrideWithValue(false),
        ],
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: StudioOverlay(),
          ),
        ),
      );
      expect(find.byType(StudioOverlay), findsOneWidget);
      // No chrome at all off-gate — not even the navigate/edit toggle.
      expect(find.text('נווט'), findsNothing);
      expect(find.text('ערוך'), findsNothing);
    });

    testWidgets('on-gate ⇒ the persistent נווט⇄ערוך chrome (default נווט)', (
      tester,
    ) async {
      final c = ProviderContainer(
        overrides: [
          studioActiveProvider.overrideWithValue(true),
          studioOwnerEmailProvider.overrideWithValue(owner),
          studioInManagerContextProvider.overrideWithValue(true),
        ],
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Stack(children: [StudioOverlay()]),
          ),
        ),
      );
      // The toggle is present even when NOT editing (persistent chrome), so the
      // owner is never stranded in edit-mode with no visible way back to navigate.
      expect(find.text('נווט'), findsOneWidget);
      expect(find.text('ערוך'), findsOneWidget);
      expect(c.read(editModeProvider).isEditing, isFalse); // default = navigate
    });

    testWidgets('the נווט⇄ערוך toggle flips edit-mode (the un-trap fix)', (
      tester,
    ) async {
      final c = ProviderContainer(
        overrides: [
          studioActiveProvider.overrideWithValue(true),
          studioOwnerEmailProvider.overrideWithValue(owner),
          studioInManagerContextProvider.overrideWithValue(true),
        ],
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Stack(children: [StudioOverlay()]),
          ),
        ),
      );
      expect(c.read(editModeProvider).isEditing, isFalse);
      await tester.tap(find.text('ערוך'));
      await tester.pump();
      expect(c.read(editModeProvider).isEditing, isTrue); // armed edit
      await tester.tap(find.text('נווט'));
      await tester.pump();
      expect(c.read(editModeProvider).isEditing, isFalse); // back to navigate
    });
  });

  // The canonical Pillar-1 zero-regression proof: with an empty doc + Studio off,
  // resolvedNodeProvider == CfgNode.identity for EVERY persona (incl. the canonical
  // contractor=roleKeyOf(null)) ⇒ every wrapper renders its verbatim fallback. A
  // parametrized loop so a future persona is covered automatically.
  group('empty doc ⇒ identity for every persona (#15)', () {
    for (final role in const <String?>[
      null,
      'contractor',
      'store',
      'courier',
      'worker',
      'manager',
    ]) {
      test('roleKey ${role ?? "null(=contractor)"}: resolved == identity', () {
        final c = ProviderContainer(
          overrides: [
            configSinkProvider.overrideWithValue(_FakeSink()),
            roleProvider.overrideWithValue(role),
            studioActiveProvider.overrideWithValue(false),
            studioOwnerEmailProvider.overrideWithValue(null),
            studioInManagerContextProvider.overrideWithValue(false),
          ],
        );
        addTearDown(c.dispose);
        expect(c.read(resolvedNodeProvider('any.id')), CfgNode.identity);
      });
    }
  });
}
