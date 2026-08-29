// Pins the version-history pane (#studio · Pillar 1 · step 21): empty ⇒ placeholder;
// a published version shows (note); "שחזר" → confirm → forward-only rollback (the
// snapshot is re-published as a NEW version, history grows). Fake sink, no auth.
import 'package:buildsmart/screens/studio/panes/history_pane.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_store.dart';
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
          child: Scaffold(body: HistoryPane()),
        ),
      ),
    );

void main() {
  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [configSinkProvider.overrideWithValue(_FakeSink())],
    );
    addTearDown(c.dispose);
    return c;
  }

  testWidgets('empty history ⇒ placeholder', (tester) async {
    await tester.pumpWidget(_app(make()));
    expect(find.textContaining('עדיין לא פורסמו'), findsOneWidget);
  });

  testWidgets('a published version shows its note', (tester) async {
    final c = make();
    c.read(configStoreProvider.notifier)
      ..applyOps([const SetText('a', 'x')])
      ..publish(note: 'שינוי ראשון', nowMs: 1);
    await tester.pumpWidget(_app(c));
    expect(find.text('שינוי ראשון'), findsOneWidget);
  });

  testWidgets('restore re-publishes the old snapshot forward', (tester) async {
    final c = make();
    final n = c.read(configStoreProvider.notifier)
      ..applyOps([const SetText('a', 'one')])
      ..publish(nowMs: 10)
      ..applyOps([const SetText('a', 'two')])
      ..publish(nowMs: 20);
    expect(n.state.published.global['a']?.text, 'two');

    await tester.pumpWidget(_app(c));
    // The oldest version ('one') is last in the newest-first list.
    await tester.tap(find.text('שחזר').last);
    await tester.pumpAndSettle();
    // Confirm in the dialog (its "שחזר" button is now on top).
    await tester.tap(find.text('שחזר').last);
    await tester.pumpAndSettle();

    expect(n.state.published.global['a']?.text, 'one'); // restored
    expect(n.state.history.length, 3); // forward-only: history grew
  });
}
