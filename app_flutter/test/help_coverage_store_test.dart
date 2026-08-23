// #31 wave-3 — "מצב היכרות" coverage for the STORE/supplier board
// (store_dashboard). Gated by boardAuth only (no docs/vehicle gate), so a
// seeded store session renders the board. Pins: (1) the 💡 toggle exists so a
// supplier can ENTER help mode, (2) the AppBar bell is HelpTarget-wrapped, and
// (3) a bottom-nav tab pops a bubble out of itself in help mode.
import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder helpTargetWithTitle(String title) =>
      find.byWidgetPredicate((w) => w is HelpTarget && w.title == title);

  Future<void> pumpStore(WidgetTester t) async {
    // #65 gate: seed a logged-in store session so the board renders.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"store","username":"shop","displayName":"חנות","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(390, 820));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      const ProviderScope(child: MaterialApp(home: StoreDashboardScreen())),
    );
    await t.pump();
    // Let the lazy boardAuthProvider _load() resolve, then rebuild gate→board.
    await t.pump(const Duration(milliseconds: 120));
  }

  testWidgets('store board exposes a 💡 toggle + covered chrome (#31)', (
    t,
  ) async {
    await pumpStore(t);
    expect(find.byType(HelpToggleButton), findsOneWidget);
    // AppBar bell.
    expect(helpTargetWithTitle('התראות'), findsOneWidget);
    // A bottom-nav tab (now a HelpTarget).
    expect(helpTargetWithTitle('מלאי'), findsOneWidget);
  });

  testWidgets('help mode: a store tab pops a bubble out of it (#31)', (
    t,
  ) async {
    await pumpStore(t);
    await t.tap(find.byType(HelpToggleButton));
    await t.pump();
    await t.tap(helpTargetWithTitle('מלאי'));
    for (var i = 0; i < 5; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    expect(find.textContaining('ניהול מלאי החנות'), findsOneWidget);
  });
}
