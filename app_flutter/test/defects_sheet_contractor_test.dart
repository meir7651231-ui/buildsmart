// The contractor is the MAIN APP: it never holds a BoardSession. The defects
// sheet (ניהול אתר → 🔧 רשימת ליקויים) used to decide "contractor" with
// `session?.role == BoardRole.manager`, so a plain contractor (null session)
// got the WORKER variant: the wrong sub-title, an always-empty list, and a
// "דווח ליקוי" button whose save silently did nothing.
//
// These widget tests pump the real sheet and pin who gets which variant:
//   · no board session (contractor) → OPEN-defect variant, employer list, save works
//   · a store/courier session lingering in the main app → same employer variant
//   · a worker board session → REPORT variant (unchanged)
import 'package:buildsmart/screens/defects_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _contractorSub = 'פתח ליקוי ועקוב אחרי הליקויים הפתוחים.';
const _workerSub = 'דווח על ליקוי שמצאת — הוא יישלח לקבלן לאישור.';

Widget _host({ThemeData? theme}) => ProviderScope(
      child: MaterialApp(
        theme: theme,
        builder: (ctx, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showDefectsSheet(ctx),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

/// Pumps the host on a tall surface (so the sheet's save button is on screen),
/// lets the tasks engine finish its lazy load, and seeds one employer-scoped
/// defect. Returns the live container.
Future<ProviderContainer> _boot(
  WidgetTester t, {
  ThemeData? theme,
  Size size = const Size(480, 1400),
}) async {
  SharedPreferences.setMockInitialValues({});
  await t.binding.setSurfaceSize(size);
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(_host(theme: theme));
  final c = ProviderScope.containerOf(t.element(find.text('open')));
  c.read(tasksProvider.notifier);
  c.read(boardAuthProvider);
  await t.pumpAndSettle();
  c.read(tasksProvider.notifier).createTask(
        name: 'סדק בקיר',
        kind: 'defect',
        location: 'אמבטיה',
        employerId: kDemoContractorId,
      );
  return c;
}

Future<void> _open(WidgetTester t) async {
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
      'contractor (no board session) gets the OPEN-defect variant with the '
      'employer list, and saving really opens a defect', (t) async {
    final c = await _boot(t);
    expect(c.read(boardAuthProvider), isNull,
        reason: 'precondition: the main-app contractor has no board session');

    await _open(t);

    expect(find.byKey(const ValueKey('defect-open')), findsOneWidget);
    expect(find.byKey(const ValueKey('defect-report')), findsNothing);
    expect(find.text(_contractorSub), findsOneWidget);
    expect(find.text(_workerSub), findsNothing);
    expect(find.text('סדק בקיר'), findsOneWidget,
        reason: 'the employer-scoped defect must be listed');

    await t.enterText(find.byKey(const ValueKey('defect-name')), 'נזילה');
    await t.ensureVisible(find.byKey(const ValueKey('defect-open')));
    await t.tap(find.byKey(const ValueKey('defect-open')));
    await t.pumpAndSettle();

    final saved = c.read(defectsProvider).where((d) => d.name == 'נזילה');
    expect(saved, hasLength(1), reason: 'save must not be a silent no-op');
    expect(saved.single.status, 'pending');
    expect(saved.single.employerId, kDemoContractorId);
    expect(find.byKey(const ValueKey('defect-open')), findsNothing,
        reason: 'the sheet closes after a successful save');

    // Let the confirmation toast run out so no timer is left pending.
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
  });

  for (final role in [BoardRole.store, BoardRole.courier, BoardRole.manager]) {
    testWidgets(
        'a ${role.name} session left over in the main app still gets the '
        'employer variant (never the worker report form)', (t) async {
      final c = await _boot(t);
      c.read(boardAuthProvider.notifier).enterDemo(role);
      await t.pumpAndSettle();
      expect(c.read(boardAuthProvider)?.role, role);

      await _open(t);

      expect(find.byKey(const ValueKey('defect-open')), findsOneWidget);
      expect(find.byKey(const ValueKey('defect-report')), findsNothing);
      expect(find.text(_contractorSub), findsOneWidget);
    });
  }

  testWidgets(
      'saving with an empty name shows an inline error, keeps the sheet open, '
      'and the error clears on typing', (t) async {
    final c = await _boot(t);
    final before = c.read(defectsProvider).length;
    await _open(t);

    await t.ensureVisible(find.byKey(const ValueKey('defect-open')));
    await t.tap(find.byKey(const ValueKey('defect-open')));
    await t.pumpAndSettle();

    expect(find.text('יש לכתוב מה הליקוי'), findsOneWidget);
    expect(find.byKey(const ValueKey('defect-open')), findsOneWidget,
        reason: 'the sheet stays open');
    expect(c.read(defectsProvider).length, before, reason: 'nothing was saved');
    final nameField =
        t.widget<TextField>(find.byKey(const ValueKey('defect-name')));
    expect(nameField.focusNode?.hasFocus, isTrue,
        reason: 'focus moves to the field that needs fixing');

    await t.enterText(find.byKey(const ValueKey('defect-name')), 'נ');
    await t.pump();
    expect(find.text('יש לכתוב מה הליקוי'), findsNothing);
  });

  testWidgets('dark theme: the sheet text is readable on the dark surface',
      (t) async {
    await _boot(t, theme: AppTheme.dark());
    await _open(t);

    final surface = AppTheme.dark().colorScheme.surface;
    double contrast(Color fg) {
      final a = fg.computeLuminance(), b = surface.computeLuminance();
      final hi = a > b ? a : b, lo = a > b ? b : a;
      return (hi + 0.05) / (lo + 0.05);
    }

    Color colorOf(String text) {
      final ctx = t.element(find.text(text));
      final w = ctx.widget as Text;
      return (w.style?.color ?? DefaultTextStyle.of(ctx).style.color)!;
    }

    for (final text in [
      '🔧 ליקויים',
      _contractorSub,
      'רשימת ליקויים',
      'סדק בקיר',
      '🔧 אמבטיה',
      '➕ פתח ליקוי',
      'חומרה',
    ]) {
      expect(contrast(colorOf(text)), greaterThanOrEqualTo(4.5),
          reason: '"$text" must be legible in dark mode');
    }
  });

  testWidgets(
      'high-contrast: the save label and the selected severity chip use the '
      'on-accent ink, not white on orange', (t) async {
    final theme = AppTheme.light(highContrast: true);
    await _boot(t, theme: theme);
    await _open(t);
    await t.ensureVisible(find.text('חמור'));
    await t.tap(find.text('חמור'));
    await t.pumpAndSettle();

    double onBrand(Color fg) {
      final a = fg.computeLuminance(), b = BsTokens.brand.computeLuminance();
      final hi = a > b ? a : b, lo = a > b ? b : a;
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final text in ['פתח ליקוי', 'חמור']) {
      final w = t.widget<Text>(find.text(text));
      expect(onBrand(w.style!.color!), greaterThanOrEqualTo(4.5),
          reason: '"$text" on the brand fill');
    }
  });

  testWidgets('a short status does not take half the row from the defect name',
      (t) async {
    await _boot(t, size: const Size(360, 800));
    await _open(t);
    final row = t.getSize(find.text('סדק בקיר'));
    expect(row.width, greaterThan(360 * .5),
        reason: 'the name keeps the room the status does not need');
  });

  testWidgets('the sheet is lifted above the on-screen keyboard', (t) async {
    await _boot(t, size: const Size(360, 640));
    await _open(t);
    final sheet = find.byType(DraggableScrollableSheet);
    final bottomBefore = t.getRect(sheet).bottom;

    // FakeViewPadding is in physical pixels: a 300-logical-px keyboard.
    const keyboard = 300.0;
    t.view.viewInsets =
        FakeViewPadding(bottom: keyboard * t.view.devicePixelRatio);
    addTearDown(t.view.resetViewInsets);
    await t.pumpAndSettle();

    expect(t.getRect(sheet).bottom, closeTo(bottomBefore - keyboard, 1),
        reason: 'the keyboard inset must be consumed, not drawn over');
  });

  testWidgets('a worker board session keeps the REPORT variant', (t) async {
    final c = await _boot(t);
    c.read(boardAuthProvider.notifier).enterDemo(BoardRole.worker);
    await t.pumpAndSettle();
    expect(c.read(boardAuthProvider)?.role, BoardRole.worker);

    await _open(t);

    expect(find.byKey(const ValueKey('defect-report')), findsOneWidget);
    expect(find.byKey(const ValueKey('defect-open')), findsNothing);
    expect(find.text(_workerSub), findsOneWidget);
  });
}
