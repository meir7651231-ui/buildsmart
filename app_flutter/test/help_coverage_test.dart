// #31 — "מצב היכרות" (interactive help) coverage for the contractor board's
// PRIMARY chrome (wave 1 = home_shell). Pins two things the full-coverage
// roll-out must never silently lose:
//   1. the app-bar primary actions are wrapped in [HelpTarget] (logo→role
//      switch, the ⋮ menu) and the #30 camera target survives, and
//   2. in help mode a bottom-nav tap *explains* the destination (showHelpInfo)
//      instead of navigating — the tabs live outside the freeze overlay.
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/state/help_mode.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(const <String, Object>{}));

  Finder helpTargetWithTitle(String title) =>
      find.byWidgetPredicate((w) => w is HelpTarget && w.title == title);

  Future<void> pumpShell(WidgetTester t, {bool helpMode = false}) async {
    await t.binding.setSurfaceSize(const Size(390, 760));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [if (helpMode) helpModeProvider.overrideWith((ref) => true)],
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: HomeShell(),
          ),
        ),
      ),
    );
    // Bounded settle (the shell animates) — pumpAndSettle would hang.
    for (var i = 0; i < 5; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('home app-bar primary chrome is HelpTarget-covered (#31)', (
    t,
  ) async {
    await pumpShell(t);
    // Logo → opens the role/board switcher.
    expect(helpTargetWithTitle('החלפת לוח / זהות'), findsOneWidget);
    // ⋮ menu — catalog variant on the default בית tab.
    expect(helpTargetWithTitle('תפריט הקטלוג'), findsOneWidget);
    // The #30 camera target must still be there (no regression).
    expect(helpTargetWithTitle('מצלמה / סורק'), findsOneWidget);
  });

  testWidgets(
    'help mode: a bottom-nav tab is a HelpTarget + pops a bubble out of it (#31)',
    (t) async {
      await pumpShell(t, helpMode: true);
      // Each tab is now wrapped in a HelpTarget (so help mode rings it), not a
      // bare BottomNavigationBarItem.
      final tab = find.byWidgetPredicate(
        (w) => w is HelpTarget && w.title == 'עדכונים',
      );
      expect(tab, findsOneWidget);
      // Tapping it pops the anchored explanation bubble out of the tab itself
      // (the old build showed a detached centred "הבנתי" card instead).
      await t.tap(tab);
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(milliseconds: 120));
      }
      expect(find.textContaining('ההתראות והשיחות'), findsOneWidget);
    },
  );
}
