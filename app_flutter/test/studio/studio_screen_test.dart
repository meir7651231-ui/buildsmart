// Pins the Studio shell + top-bar (#studio · Pillar 1 · steps 16–17): RTL chrome +
// white AppBar; the kStudioFlag-guarded route (null when inactive — no deep-link in);
// and the top-bar's publish gate (disabled on an empty draft, enabled once a draft
// exists, with a live change-count badge). The gate + sink are overridden, so no
// auth/prefs are touched. The screen stays unreachable until step 20.
import 'package:buildsmart/screens/studio/studio_screen.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:buildsmart/theme/tokens.dart';
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
  ProviderContainer store() {
    final c = ProviderContainer(
      overrides: [
        configSinkProvider.overrideWithValue(_FakeSink()),
        studioActiveProvider.overrideWithValue(false),
        studioOwnerEmailProvider.overrideWithValue(null),
        studioInManagerContextProvider.overrideWithValue(false),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  testWidgets('builds in RTL with a white AppBar', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: store(),
        child: const MaterialApp(home: StudioScreen()),
      ),
    );

    expect(find.byType(StudioScreen), findsOneWidget);
    final dir = tester.widget<Directionality>(
      find
          .descendant(
            of: find.byType(StudioScreen),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(dir.textDirection, TextDirection.rtl);
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      BsTokens.cardLight,
    );
  });

  testWidgets('route() is kStudioFlag-guarded (null when inactive)', (
    tester,
  ) async {
    Route<void>? offRoute;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [studioActiveProvider.overrideWithValue(false)],
        child: MaterialApp(
          home: Consumer(
            builder: (_, ref, __) {
              offRoute = StudioScreen.route(ref);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(offRoute, isNull);

    Route<void>? onRoute;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [studioActiveProvider.overrideWithValue(true)],
        child: MaterialApp(
          home: Consumer(
            builder: (_, ref, __) {
              onRoute = StudioScreen.route(ref);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(onRoute, isNotNull);
  });

  testWidgets('top-bar: publish disabled on empty draft, enabled with a draft', (
    tester,
  ) async {
    final c = store();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: StudioScreen()),
      ),
    );

    final publish = find.widgetWithText(ElevatedButton, 'פרסם לכולם');
    expect(tester.widget<ElevatedButton>(publish).onPressed, isNull); // empty
    expect(find.text('אין שינויים'), findsOneWidget);

    c.read(configStoreProvider.notifier).applyOps([const SetText('x', 'y')]);
    await tester.pump();

    expect(tester.widget<ElevatedButton>(publish).onPressed, isNotNull); // draft
    expect(find.text('טיוטה · 1 שינויים'), findsOneWidget);
  });
}
