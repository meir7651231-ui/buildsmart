// keyboard_tool_actions — the single keyboard→app seam ([runKeyboardTool]).
//
// We assert the STATE-PROVIDER tools actually mutate the providers they target:
//   • departments → mainTabProvider == 1 (DepartmentsScreen in HomeShell).
//   • finder      → catalogSectionProvider == 'מאתר' AND mainTabProvider == 0
//                   (the section only shows on the catalog tab).
//   • intro       → helpModeProvider == true (discovery mode ON).
//
// Navigator-push tools (connect/camera) are NOT asserted on behaviour here: they
// push real screens (InstallStudioScreen / the mobile_scanner plugin) whose
// build needs the full app — out of scope for this hermetic seam test (their
// push code is verified by reading and mirrors smart_home_screen.dart). We DO
// assert a TODO tool (voice) shows its "בקרוב" SnackBar.
//
// runKeyboardTool is invoked from a real button TAP — exactly how the keyboard's
// onTool fires it (post-build, from a gesture) — never during build (a build-time
// provider mutation would throw "setState() called during build"). The inner
// Builder context sits below the Scaffold/Navigator so ScaffoldMessenger.of and
// Navigator.of resolve; the ProviderContainer is held so state can be read after.

import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogSectionProvider;
import 'package:buildsmart/screens/keyboard_tool_actions.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/help_mode.dart' show helpModeProvider;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbTool;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Pumps a minimal tree with a button that, WHEN TAPPED, runs [body] with a
  /// `(ref, context)` captured below a real Scaffold/Navigator. Returns the
  /// [ProviderContainer] so providers can be read after. Invoking from the tap
  /// (not during build) mirrors how the keyboard's onTool fires runKeyboardTool.
  Future<ProviderContainer> pumpAndRun(
    WidgetTester tester,
    void Function(WidgetRef ref, BuildContext context) body,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (_, ref, __) => Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => body(ref, context),
                    child: const Text('run'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    return container;
  }

  testWidgets('departments → mainTab index 1 (DepartmentsScreen)',
      (tester) async {
    final container = await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.departments),
    );
    expect(container.read(mainTabProvider), 1);
  });

  testWidgets('finder → catalog section מאתר on the catalog tab (0)',
      (tester) async {
    final container = await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.finder),
    );
    expect(container.read(catalogSectionProvider), 'מאתר');
    expect(container.read(mainTabProvider), 0);
  });

  testWidgets('search → same finder section מאתר', (tester) async {
    final container = await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.search),
    );
    expect(container.read(catalogSectionProvider), 'מאתר');
  });

  testWidgets('smartTree → catalog section עץ חכם', (tester) async {
    final container = await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.smartTree),
    );
    expect(container.read(catalogSectionProvider), 'עץ חכם');
  });

  testWidgets('favorites → catalog section מועדפים', (tester) async {
    final container = await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.favorites),
    );
    expect(container.read(catalogSectionProvider), 'מועדפים');
  });

  testWidgets('intro → help mode ON', (tester) async {
    final container = await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.intro),
    );
    expect(container.read(helpModeProvider), isTrue);
  });

  testWidgets('a TODO tool (voice) shows the "בקרוב" SnackBar', (tester) async {
    await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.voice),
    );
    await tester.pump(); // let the SnackBar enter
    expect(find.textContaining('בקרוב'), findsOneWidget);
  });

  // STEP B: תפריט is no longer a single destination in the seam — it became a
  // BRANCH in the morph keyboard ([keyboard_tool_tree.dart]) whose children are
  // the AI hub + settings (the old `_openAppMenu` sheet is removed). The morph
  // keyboard drills the branch directly and never calls runKeyboardTool(menu);
  // the legacy seam path for KbTool.menu now surfaces "בקרוב" instead of a
  // half/guessed nav. The branch itself is asserted in keyboard_tool_tree_test.
  testWidgets('menu → "בקרוב" SnackBar (no longer a sheet)', (tester) async {
    await pumpAndRun(
      tester,
      (ref, context) => runKeyboardTool(ref, context, KbTool.menu),
    );
    await tester.pump(); // let the SnackBar enter
    expect(find.textContaining('בקרוב'), findsOneWidget);
    // The removed sheet's items must NOT appear.
    expect(find.text('הגדרות'), findsNothing);
  });
}
