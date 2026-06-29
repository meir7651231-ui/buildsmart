// Pins find-&-replace (#studio · Pillar 1 · step 25): a query previews each hit by
// labelHe; "החלף בנבחרים" rewrites the DRAFT only (published untouched) as a SINGLE
// undo unit; kImmutable elements are read-only (excluded from the batch). Fake sink.
import 'package:buildsmart/screens/studio/panes/find_replace_pane.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/element_registry.dart';
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

const _openOrders = 'manager.cockpit.kpi.openOrders';

void main() {
  ProviderContainer make({List<Override> extra = const []}) {
    final c = ProviderContainer(
      overrides: [
        configSinkProvider.overrideWithValue(_FakeSink()),
        ...extra,
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> mount(WidgetTester tester, ProviderContainer c) =>
      tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: FindReplacePane()),
            ),
          ),
        ),
      );

  testWidgets('preview shows a hit by labelHe; replace hits the DRAFT only', (
    tester,
  ) async {
    final c = make();
    c.read(configStoreProvider.notifier).applyOps(
      const [SetText(_openOrders, 'הזמנות פתוחות')],
    );
    await mount(tester, c);

    await tester.enterText(find.byType(TextField).first, 'פתוחות');
    await tester.enterText(find.byType(TextField).at(1), 'סגורות');
    await tester.pump();

    // The hit is previewed by the element's labelHe (not its content).
    expect(find.text('KPI — הזמנות פתוחות'), findsOneWidget);

    await tester.tap(find.text('החלף בנבחרים (1)'));
    await tester.pump();

    final doc = c.read(configStoreProvider);
    expect(doc.draft.global[_openOrders]?.text, 'הזמנות סגורות'); // draft rewritten
    expect(doc.published.global[_openOrders], isNull); // published untouched

    await tester.pump(const Duration(seconds: 5)); // drain the confirm SnackBar timer
    await tester.pumpAndSettle();
  });

  testWidgets('replace is a single undo unit', (tester) async {
    final c = make();
    final n = c.read(configStoreProvider.notifier)
      ..applyOps(const [SetText(_openOrders, 'הזמנות פתוחות')]);
    await mount(tester, c);

    await tester.enterText(find.byType(TextField).first, 'פתוחות');
    await tester.enterText(find.byType(TextField).at(1), 'סגורות');
    await tester.pump();
    await tester.tap(find.text('החלף בנבחרים (1)'));
    await tester.pump();
    expect(c.read(configStoreProvider).draft.global[_openOrders]?.text, 'הזמנות סגורות');

    n.undo(); // ONE frame restores the whole batch
    expect(c.read(configStoreProvider).draft.global[_openOrders]?.text, 'הזמנות פתוחות');

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('kImmutable hit is read-only (excluded from replace)', (
    tester,
  ) async {
    final c = make(
      extra: [
        elementRegistryProvider.overrideWithValue(const [
          ElementDescriptor(
            id: 'x',
            screen: 's',
            area: 'a',
            labelHe: 'רכיב נעול',
            kind: ElementKind.text,
            editableProps: {EditAxis.text},
            kImmutable: true,
          ),
        ]),
      ],
    );
    c.read(configStoreProvider.notifier).applyOps(
      const [SetText('x', 'טקסט נעול')],
    );
    await mount(tester, c);

    await tester.enterText(find.byType(TextField).first, 'נעול');
    await tester.pump();

    expect(find.text('רכיב נעול'), findsOneWidget); // shown…
    expect(find.text('רכיב קריטי — קריאה בלבד'), findsOneWidget); // …but locked
    expect(find.text('החלף בנבחרים (0)'), findsOneWidget); // 0 selectable ⇒ disabled
  });
}
