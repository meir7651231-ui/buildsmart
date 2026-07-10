// Pins the Cfg* wrapper zero-cost contract (#studio · Pillar 1 · steps 9–11). For
// every wrapper: NO override ⇒ the child renders verbatim (the zero-regression
// root); an owner override changes exactly one axis. The gate inputs (+ a fake sink
// for the store) are overridden, so no auth/prefs are touched.
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_action.dart';
import 'package:buildsmart/widgets/studio/cfg_box.dart';
import 'package:buildsmart/widgets/studio/cfg_list.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
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

// Gate-only container (EditHandle tests — no store needed).
ProviderContainer _gate({required bool editing}) {
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

// Store-backed container (Cfg* wrappers). [editing] opens the gate + edit-mode.
ProviderContainer _store({bool editing = false}) {
  final c = ProviderContainer(
    overrides: [
      configSinkProvider.overrideWithValue(_FakeSink()),
      roleProvider.overrideWithValue(null), // contractor
      studioActiveProvider.overrideWithValue(editing),
      studioOwnerEmailProvider
          .overrideWithValue(editing ? kOwnerEmails.first : null),
      studioInManagerContextProvider.overrideWithValue(editing),
    ],
  );
  addTearDown(c.dispose);
  if (editing) c.read(editModeProvider.notifier).enterEdit();
  return c;
}

Widget _rtl(ProviderContainer c, Widget child) => UncontrolledProviderScope(
      container: c,
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    );

ConfigStore _notifier(ProviderContainer c) =>
    c.read(configStoreProvider.notifier);

void main() {
  group('EditHandle — edit affordance', () {
    testWidgets('OFF edit-mode: returns the child verbatim', (tester) async {
      final c = _gate(editing: false);
      addTearDown(c.dispose);
      await tester.pumpWidget(_rtl(c, const _Host()));

      expect(find.text('הזמן'), findsOneWidget);
      expect(find.byType(MetaData), findsNothing);
    });

    testWidgets('ON edit-mode: tags StudioEditTarget(id) + draws the outline', (
      tester,
    ) async {
      final c = _gate(editing: true);
      addTearDown(c.dispose);
      await tester.pumpWidget(_rtl(c, const _Host()));

      final meta = tester.widget<MetaData>(find.byType(MetaData));
      expect(meta.metaData, isA<StudioEditTarget>());
      expect((meta.metaData as StudioEditTarget).id, 'cart.cta');
      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });

  group('EditHandle — WYSIWYG in-place edit (עריכה בחי)', () {
    testWidgets('tap a live text → editor → applies SetText to the draft',
        (tester) async {
      final c = _store(editing: true);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: Center(child: CfgText('cart.cta', 'הזמן'))),
            ),
          ),
        ),
      );

      // A tap on the live text opens the inline editor (NOT any app action).
      await tester.tap(find.text('הזמן'));
      await tester.pumpAndSettle();
      expect(find.text('עריכת טקסט'), findsOneWidget);

      // Edit + save ⇒ the draft carries the new text (live preview).
      await tester.enterText(find.byType(TextField), 'שלם עכשיו');
      await tester.tap(find.text('שמור'));
      await tester.pumpAndSettle();
      expect(
        c.read(configStoreProvider).draft.global['cart.cta']?.text,
        'שלם עכשיו',
      );
    });

    testWidgets('cancel leaves the draft untouched', (tester) async {
      final c = _store(editing: true);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: Center(child: CfgText('cart.cta', 'הזמן'))),
            ),
          ),
        ),
      );
      await tester.tap(find.text('הזמן'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'לא נשמר');
      await tester.tap(find.text('ביטול'));
      await tester.pumpAndSettle();
      expect(c.read(configStoreProvider).draft.isEmpty, isTrue);
    });
  });

  group('CfgText — content wrapper', () {
    testWidgets('empty doc ⇒ the fallback verbatim (identity style + RTL)', (
      tester,
    ) async {
      final c = _store();
      await tester.pumpWidget(_rtl(c, const CfgText('cart.cta', 'הזמן')));

      final t = tester.widget<Text>(find.text('הזמן'));
      expect(t.style, isNull); // no override + no call-site ⇒ inherits (== raw Text)
      expect(t.textDirection, isNull); // inherits the ambient RTL
    });

    testWidgets('published text override replaces the fallback', (tester) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetText('cart.cta', 'שלם עכשיו')])
        ..publish(nowMs: 1);
      await tester.pumpWidget(_rtl(c, const CfgText('cart.cta', 'הזמן')));

      expect(find.text('שלם עכשיו'), findsOneWidget);
      expect(find.text('הזמן'), findsNothing);
    });

    testWidgets('published emoji override is prepended', (tester) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetEmoji('cart.cta', '🛒')])
        ..publish(nowMs: 1);
      await tester.pumpWidget(_rtl(c, const CfgText('cart.cta', 'הזמן')));

      expect(find.text('🛒 הזמן'), findsOneWidget);
    });

    testWidgets('published style override applies the token color', (
      tester,
    ) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetStyle('cart.cta', CfgStyle(colorToken: 'brand'))])
        ..publish(nowMs: 1);
      await tester.pumpWidget(_rtl(c, const CfgText('cart.cta', 'הזמן')));

      expect(tester.widget<Text>(find.text('הזמן')).style?.color, BsTokens.brand);
    });
  });

  group('CfgVisible — show/hide', () {
    testWidgets('no override ⇒ child shown (zero-regression)', (tester) async {
      final c = _store();
      await tester.pumpWidget(
        _rtl(c, const CfgVisible('sec.promo', child: Text('מבצע'))),
      );
      expect(find.text('מבצע'), findsOneWidget);
    });

    testWidgets('hidden + not editing ⇒ removed', (tester) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetHidden('sec.promo', true)])
        ..publish(nowMs: 1);
      await tester.pumpWidget(
        _rtl(c, const CfgVisible('sec.promo', child: Text('מבצע'))),
      );
      expect(find.text('מבצע'), findsNothing);
    });

    testWidgets('critical ⇒ shown even when hidden is published', (tester) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetHidden('sec.promo', true)])
        ..publish(nowMs: 1);
      await tester.pumpWidget(
        _rtl(
          c,
          const CfgVisible('sec.promo', critical: true, child: Text('מבצע')),
        ),
      );
      expect(find.text('מבצע'), findsOneWidget);
    });

    testWidgets('hidden + editing ⇒ ghost + "מוסתר" badge (restorable)', (
      tester,
    ) async {
      final c = _store(editing: true);
      _notifier(c)
        ..applyOps([const SetHidden('sec.promo', true)])
        ..publish(nowMs: 1);
      await tester.pumpWidget(
        _rtl(c, const CfgVisible('sec.promo', child: Text('מבצע'))),
      );
      expect(find.text('מבצע'), findsOneWidget); // ghosted, still present
      expect(find.text('מוסתר'), findsOneWidget); // badge
      expect(find.byType(Opacity), findsWidgets);
    });
  });

  group('CfgBox — container restyle', () {
    testWidgets('no override ⇒ child verbatim (no ColoredBox added)', (
      tester,
    ) async {
      final c = _store();
      await tester.pumpWidget(
        _rtl(c, const CfgBox('card.x', child: Text('תוכן'))),
      );
      expect(find.text('תוכן'), findsOneWidget);
      expect(find.byType(ColoredBox), findsNothing);
    });

    testWidgets('bgToken override ⇒ a brand ColoredBox', (tester) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetStyle('card.x', CfgStyle(bgToken: 'brand'))])
        ..publish(nowMs: 1);
      await tester.pumpWidget(
        _rtl(c, const CfgBox('card.x', child: Text('תוכן'))),
      );
      final brandBoxes = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .where((b) => b.color == BsTokens.brand);
      expect(brandBoxes, isNotEmpty);
    });
  });

  group('CfgList — order', () {
    const items = [
      CfgListItem('a', Text('A')),
      CfgListItem('b', Text('B')),
      CfgListItem('cc', Text('C')),
    ];

    Widget list() => CfgList(
          items: items,
          builder: (_, kids) => Column(children: kids),
        );

    testWidgets('no order override ⇒ declaration order', (tester) async {
      final c = _store();
      await tester.pumpWidget(_rtl(c, list()));
      final ay = tester.getTopLeft(find.text('A')).dy;
      final by = tester.getTopLeft(find.text('B')).dy;
      final cy = tester.getTopLeft(find.text('C')).dy;
      expect(ay < by && by < cy, isTrue);
    });

    testWidgets('order overrides re-sort the items (stable)', (tester) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetOrder('a', 2), const SetOrder('cc', 0)])
        ..publish(nowMs: 1);
      await tester.pumpWidget(_rtl(c, list()));
      // cc(0) < b(1=index) < a(2)
      final ay = tester.getTopLeft(find.text('A')).dy;
      final by = tester.getTopLeft(find.text('B')).dy;
      final cy = tester.getTopLeft(find.text('C')).dy;
      expect(cy < by && by < ay, isTrue);
    });
  });

  group('CfgAction — behavior seam (v1 fallthrough)', () {
    testWidgets('no override ⇒ returns the fallback unchanged', (tester) async {
      final c = _store();
      void original() {}
      VoidCallback? resolved;
      await tester.pumpWidget(
        _rtl(
          c,
          Consumer(
            builder: (_, ref, __) {
              resolved = cfgAction(ref, 'btn.x', original);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(identical(resolved, original), isTrue);
    });

    testWidgets('a published action override still falls through (v1)', (
      tester,
    ) async {
      final c = _store();
      _notifier(c)
        ..applyOps([const SetAction('btn.x', CfgAction(kind: 'navigate'))])
        ..publish(nowMs: 1);
      void original() {}
      VoidCallback? resolved;
      await tester.pumpWidget(
        _rtl(
          c,
          Consumer(
            builder: (_, ref, __) {
              resolved = cfgAction(ref, 'btn.x', original);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(identical(resolved, original), isTrue); // original wins until Pillar-4
    });
  });
}
