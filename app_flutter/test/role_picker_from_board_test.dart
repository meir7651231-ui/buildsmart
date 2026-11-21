// Regression: opening "מי אתה?" from INSIDE a role board used to (a) do
// nothing on "קבלן" — only the picker closed, the board stayed — and (b) stack
// the next board on top of the old one. Opened from an ORDINARY main-app
// screen (e.g. ProfileScreen with an unsaved form) only the picker may close.
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _managerSession =
    '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}';

void main() {
  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  // Root page with two entries: open the picker directly, or push an
  // ordinary (non-board) screen that opens the picker itself.
  Widget app() => ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(
            builder: (rootCtx) => Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => showRolePicker(rootCtx),
                    child: const Text('root picker'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(rootCtx).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) => Scaffold(
                          body: Center(
                            child: ElevatedButton(
                              onPressed: () => showRolePicker(ctx),
                              child: const Text('profile picker'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('open profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> pumpApp(WidgetTester t) async {
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(app());
    await settle(t);
  }

  /// Root → picker → מנהל המערכת: a real board pushed by the picker.
  Future<void> openManagerBoard(WidgetTester t) async {
    await t.tap(find.text('root picker'));
    await settle(t);
    await t.tap(find.text('מנהל המערכת'));
    await settle(t);
    expect(find.byType(ManagerDashboardScreen), findsOneWidget);
  }

  /// Open the picker from INSIDE the manager board.
  Future<void> openPickerFromBoard(WidgetTester t) async {
    final boardCtx = t.element(find.byType(ManagerDashboardScreen));
    // ignore: unawaited_futures
    showRolePicker(boardCtx);
    await settle(t);
    expect(find.text('מי אתה?'), findsOneWidget);
  }

  testWidgets('"קבלן" from inside a board returns to the main app',
      (t) async {
    SharedPreferences.setMockInitialValues({'bs.board-auth.v1': _managerSession});
    await pumpApp(t);
    await openManagerBoard(t);
    await openPickerFromBoard(t);

    await t.tap(find.text('קבלן'));
    await settle(t);

    expect(find.text('מי אתה?'), findsNothing);
    expect(find.byType(ManagerDashboardScreen, skipOffstage: false),
        findsNothing,
        reason: 'the board the picker was opened from must close');
    expect(find.text('root picker'), findsOneWidget);
  });

  testWidgets('another role from inside a board replaces it (no stacking)',
      (t) async {
    SharedPreferences.setMockInitialValues({'bs.board-auth.v1': _managerSession});
    await pumpApp(t);
    await openManagerBoard(t);
    await openPickerFromBoard(t);

    // The board shows the session name too — tap the picker's row (on top).
    await t.tap(find.text('מנהל המערכת').last);
    await settle(t);

    expect(find.byType(ManagerDashboardScreen, skipOffstage: false),
        findsOneWidget,
        reason: 'the old board must not stay underneath the new one');
    // Back from the new board lands on the main app, not the old board.
    Navigator.of(t.element(find.byType(ManagerDashboardScreen))).pop();
    await settle(t);
    expect(find.byType(ManagerDashboardScreen, skipOffstage: false),
        findsNothing);
    expect(find.text('root picker'), findsOneWidget);
  });

  testWidgets('"קבלן" from an ordinary screen closes ONLY the picker',
      (t) async {
    SharedPreferences.setMockInitialValues({});
    await pumpApp(t);
    await t.tap(find.text('open profile'));
    await settle(t);
    await t.tap(find.text('profile picker'));
    await settle(t);
    expect(find.text('מי אתה?'), findsOneWidget);

    await t.tap(find.text('קבלן'));
    await settle(t);

    expect(find.text('מי אתה?'), findsNothing);
    expect(find.text('profile picker'), findsOneWidget,
        reason: 'a non-board screen (e.g. an unsaved profile form) must stay');
  });
}
