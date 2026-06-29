// Pins the Cfg* wrapper zero-cost contract (#studio · Pillar 1 · steps 9–11).
//  • Step 9 — EditHandle.maybe: OUTSIDE edit-mode returns the child verbatim (zero
//    added widgets ⇒ the zero-regression root); INSIDE edit-mode tags the subtree
//    with a StudioEditTarget (overlay hit-test, step 13) + draws the brand outline.
//  • Step 10 — CfgText: empty doc ⇒ the Hebrew literal VERBATIM (same style); a
//    published override applies text / emoji / a token style.
// The gate inputs (+ a fake sink for the store) are overridden — no auth/prefs.
//
// (Step 11 EXTENDS this with CfgVisible / CfgList / CfgBox / CfgAction.)
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/edit_handle.dart';
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

class _Host extends ConsumerWidget {
  const _Host();
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      EditHandle.maybe(ref, 'cart.cta', child: const Text('הזמן'));
}

ProviderContainer _gateContainer({required bool editing}) {
  final c = ProviderContainer(
    overrides: [
      studioActiveProvider.overrideWithValue(editing),
      studioOwnerEmailProvider
          .overrideWithValue(editing ? kOwnerEmails.first : null),
      studioInManagerContextProvider.overrideWithValue(editing),
    ],
  );
  if (editing) c.read(editModeProvider.notifier).enterEdit();
  return c;
}

Widget _wrap(ProviderContainer c, Widget child) => UncontrolledProviderScope(
      container: c,
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    );

void main() {
  group('EditHandle — edit affordance', () {
    testWidgets('OFF edit-mode: returns the child verbatim', (tester) async {
      final c = _gateContainer(editing: false);
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c, const _Host()));

      expect(find.text('הזמן'), findsOneWidget);
      expect(find.byType(MetaData), findsNothing); // no affordance wrapper
    });

    testWidgets('ON edit-mode: tags StudioEditTarget(id) + draws the outline', (
      tester,
    ) async {
      final c = _gateContainer(editing: true);
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c, const _Host()));

      expect(find.text('הזמן'), findsOneWidget);
      final meta = tester.widget<MetaData>(find.byType(MetaData));
      expect(meta.metaData, isA<StudioEditTarget>());
      expect((meta.metaData as StudioEditTarget).id, 'cart.cta');
      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });

  group('CfgText — content wrapper', () {
    ProviderContainer storeContainer() {
      final c = ProviderContainer(
        overrides: [
          configSinkProvider.overrideWithValue(_FakeSink()),
          roleProvider.overrideWithValue(null), // contractor
          studioActiveProvider.overrideWithValue(false),
          studioOwnerEmailProvider.overrideWithValue(null),
          studioInManagerContextProvider.overrideWithValue(false),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    Widget pumpCfg(ProviderContainer c) => UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: CfgText('cart.cta', 'הזמן'),
            ),
          ),
        );

    testWidgets('empty doc ⇒ the fallback verbatim (identity style + RTL)', (
      tester,
    ) async {
      final c = storeContainer();
      await tester.pumpWidget(pumpCfg(c));

      expect(find.text('הזמן'), findsOneWidget);
      final t = tester.widget<Text>(find.text('הזמן'));
      expect(t.style, isNull); // no override + no call-site ⇒ inherits (== raw Text)
      expect(t.textDirection, isNull); // inherits the ambient RTL
    });

    testWidgets('published text override replaces the fallback', (tester) async {
      final c = storeContainer();
      c.read(configStoreProvider.notifier)
        ..applyOps([const SetText('cart.cta', 'שלם עכשיו')])
        ..publish(nowMs: 1);
      await tester.pumpWidget(pumpCfg(c));

      expect(find.text('שלם עכשיו'), findsOneWidget);
      expect(find.text('הזמן'), findsNothing);
    });

    testWidgets('published emoji override is prepended', (tester) async {
      final c = storeContainer();
      c.read(configStoreProvider.notifier)
        ..applyOps([const SetEmoji('cart.cta', '🛒')])
        ..publish(nowMs: 1);
      await tester.pumpWidget(pumpCfg(c));

      expect(find.text('🛒 הזמן'), findsOneWidget);
    });

    testWidgets('published style override applies the token color', (
      tester,
    ) async {
      final c = storeContainer();
      c.read(configStoreProvider.notifier)
        ..applyOps([const SetStyle('cart.cta', CfgStyle(colorToken: 'brand'))])
        ..publish(nowMs: 1);
      await tester.pumpWidget(pumpCfg(c));

      final t = tester.widget<Text>(find.text('הזמן'));
      expect(t.style?.color, BsTokens.brand);
    });
  });
}
