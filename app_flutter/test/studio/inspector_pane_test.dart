// Pins the Studio inspector (#studio · Pillar 1 · step 19): no selection ⇒ a
// placeholder; an unknown id ⇒ fail-closed; editing the text writes the DRAFT (via
// applyOps, not live); reset clears the override. Uses the real registry + a fake
// sink — no auth/prefs.
import 'package:buildsmart/screens/studio/panes/inspector_pane.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/studio_nav.dart';
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

Widget _app(ProviderContainer c) => UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: InspectorPane()),
        ),
      ),
    );

const _kpi = 'manager.cockpit.kpi.stores';

void main() {
  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [configSinkProvider.overrideWithValue(_FakeSink())],
    );
    addTearDown(c.dispose);
    return c;
  }

  testWidgets('no selection ⇒ placeholder', (tester) async {
    await tester.pumpWidget(_app(make()));
    expect(find.textContaining('בחר רכיב'), findsOneWidget);
  });

  testWidgets('an unknown id ⇒ fail-closed message', (tester) async {
    final c = make();
    c.read(studioSelectedIdProvider.notifier).state = 'no.such.id';
    await tester.pumpWidget(_app(c));
    expect(find.textContaining('אינו ברישום'), findsOneWidget);
  });

  testWidgets('editing the text writes the draft (global)', (tester) async {
    final c = make();
    c.read(studioSelectedIdProvider.notifier).state = _kpi;
    await tester.pumpWidget(_app(c));

    expect(find.text(_kpi), findsOneWidget); // the id subtitle (unique)
    await tester.enterText(find.byType(TextField).first, 'חנויות חדשות');
    await tester.pump();

    expect(c.read(configStoreProvider).draft.global[_kpi]?.text, 'חנויות חדשות');
  });

  testWidgets('reset clears the draft override', (tester) async {
    final c = make();
    c.read(studioSelectedIdProvider.notifier).state = _kpi;
    await tester.pumpWidget(_app(c));

    await tester.enterText(find.byType(TextField).first, 'X');
    await tester.pump();
    expect(c.read(configStoreProvider).draft.global[_kpi], isNotNull);

    await tester.tap(find.text('אפס רכיב לברירת-המחדל'));
    await tester.pump();
    expect(c.read(configStoreProvider).draft.global[_kpi], isNull);
  });
}
