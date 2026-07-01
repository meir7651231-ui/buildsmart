// live_mirror_screen_tools_test — END-TO-END proof of the KB_GLOBAL "live-mirror".
//
// The tools a screen registers on the screen-tools stack (what `KbScreen` does on
// mount, keyboard_screen_tools.dart) are EXACTLY what the floating keyboard's grid
// renders, and they follow the route stack (LIFO — deeper screen wins, popping
// reveals the parent). This is the pipeline floating_card_keyboard `_onGrid` runs
// under `kKbGlobal`:
//     tiles = kbTilesFor(currentScreenTools(stack))   // top-of-stack screen wins
// so this test exercises that same projection with the REAL per-screen tool
// factories (kbAiHubNodes / kbStockNodes) and asserts the rendered labels.
//
// (The `kKbGlobal` flag only SELECTS this path vs the tab-tools fallback; it does
// not change the projection, which is what this test locks down. The flag-gated
// registration itself is covered by keyboard_screen_tools_test.dart.)

import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> labelsOf(List<KbToolNode>? tools) =>
      (tools ?? const <KbToolNode>[]).map((n) => n.label).toList();

  // Render the pure keyboard showing the TOP-of-stack screen's tools — the exact
  // projection the floating keyboard grid uses under kKbGlobal.
  Future<void> pumpGridForStack(
    WidgetTester tester,
    List<KbScreenToolsEntry> stack,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BsKeyboard(
            onKey: (_) {},
            onBackspace: () {},
            onEnter: () {},
            onSend: () {},
            onToggleSymbols: () {},
            onLanguage: () {},
            tiles: kbTilesFor(
              currentScreenTools(stack) ?? const <KbToolNode>[],
            ),
            onTile: (_) {},
          ),
        ),
      ),
    );
  }

  group('live-mirror — the keyboard grid mirrors the CURRENT screen', () {
    test('the stack follows a LIFO push/pop of adopting screens', () {
      final n = KeyboardScreenToolsNotifier();
      final aiHub = Object();
      final stock = Object();

      // No screen adopted yet → the keyboard would fall back to the tab tools.
      expect(labelsOf(currentScreenTools(n.state)), isEmpty);

      // Land on the AI hub → its own tools are on top.
      n.push(KbScreenToolsEntry(aiHub, kbAiHubNodes()));
      expect(labelsOf(currentScreenTools(n.state)), ['מאתר', 'עץ חכם']);

      // Navigate DEEPER to stock → the front-most screen wins.
      n.push(KbScreenToolsEntry(stock, kbStockNodes()));
      expect(labelsOf(currentScreenTools(n.state)), ['בקשות חומר', 'הגדרות חנות']);

      // Go BACK (pop stock) → the parent AI hub is revealed again.
      n.removeToken(stock);
      expect(labelsOf(currentScreenTools(n.state)), ['מאתר', 'עץ חכם']);
    });

    testWidgets('the AI-hub tools RENDER in the keyboard — not the home tools',
        (tester) async {
      final n = KeyboardScreenToolsNotifier()
        ..push(KbScreenToolsEntry(Object(), kbAiHubNodes()));
      await pumpGridForStack(tester, n.state);

      expect(find.text('מאתר'), findsOneWidget); // AI-hub tool shows
      expect(find.text('עץ חכם'), findsOneWidget); // AI-hub tool shows
      expect(find.text('מחלקות'), findsNothing); // a HOME-only tool — absent
      expect(find.text('בקשות חומר'), findsNothing); // a STOCK-only tool — absent
    });

    testWidgets('moving to another screen SWITCHES the rendered tools',
        (tester) async {
      final n = KeyboardScreenToolsNotifier()
        ..push(KbScreenToolsEntry(Object(), kbAiHubNodes()));
      await pumpGridForStack(tester, n.state);
      expect(find.text('מאתר'), findsOneWidget); // on the AI hub

      // Navigate to the stock screen (push its tools on top).
      n.push(KbScreenToolsEntry(Object(), kbStockNodes()));
      await pumpGridForStack(tester, n.state);
      expect(find.text('בקשות חומר'), findsOneWidget); // stock tool now shows
      expect(find.text('מאתר'), findsNothing); // AI-hub tool no longer shows
    });

    testWidgets('each newly-wired screen renders ITS distinctive tool',
        (tester) async {
      Future<void> expectRenders(List<KbToolNode> tools, String label) async {
        final n = KeyboardScreenToolsNotifier()
          ..push(KbScreenToolsEntry(Object(), tools));
        await pumpGridForStack(tester, n.state);
        expect(find.text(label), findsOneWidget);
      }

      await expectRenders(kbAiFinderNodes(), 'מאתר'); // AiFinderScreen
      await expectRenders(kbWorkerProfileNodes(), 'נוכחות'); // WorkerProfile
      await expectRenders(kbManagerDashboardNodes(), 'קו-פיילוט'); // ManagerDash
      await expectRenders(kbWorkerSettingsNodes(), 'תנאי שימוש');
      await expectRenders(kbManagerProfileNodes(), 'מעבר בין מסכים');
      await expectRenders(kbCourierDashboardNodes(), 'פרופיל');
      await expectRenders(kbCourierProfileNodes(), 'תעודות נהג');
      await expectRenders(kbCourierSettingsNodes(), 'מדיניות פרטיות');
      await expectRenders(kbStoreDashboardNodes(), 'אזור אישי');
      await expectRenders(kbStoreProfileNodes(), 'תעודות עסק');
      await expectRenders(kbProjectsNodes(), 'תקציב');
      await expectRenders(kbSuppliersNodes(), 'ליפסקי ברקן');
      await expectRenders(kbProfileNodes(), 'החלפת תפקיד');
      await expectRenders(kbWorkerAppNodes(), 'ליקויים');
    });
  });
}
