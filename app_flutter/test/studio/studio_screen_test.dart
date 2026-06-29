// Pins the Studio shell (#studio · Pillar 1 · step 16): RTL chrome, a white AppBar,
// and the kStudioFlag-guarded route (null when the Studio is inactive — no deep-link
// in off-gate). The screen is unreachable until step 20 wires the manager entry.
import 'package:buildsmart/screens/studio/studio_screen.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds in RTL with a white AppBar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: StudioScreen())),
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
}
