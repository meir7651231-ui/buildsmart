import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chat_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/screens/suppliers_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 20 robustness checks — render every major screen under stress (large text,
/// narrow / tiny widths) and exercise the shell's tab/section/dial states,
/// asserting no overflow or render error anywhere.
void main() {
  ProviderContainer shellContainer(WidgetTester t) =>
      ProviderScope.containerOf(t.element(find.byType(HomeShell)));

  /// Pump [screen] under [size] + [textScale], scroll it, return the first
  /// render error (or null). [wrapScaffold] for body-only tab widgets.
  Future<String?> renderError(
    WidgetTester t,
    Widget screen, {
    double textScale = 1.15,
    Size size = const Size(340, 680),
    bool wrapScaffold = false,
  }) async {
    await t.binding.setSurfaceSize(size);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => MediaQuery(
              data: MediaQuery.of(ctx)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: wrapScaffold ? Scaffold(body: screen) : screen,
              ),
            ),
          ),
        ),
      ),
    );
    // Bounded settle (some screens animate forever, so pumpAndSettle hangs).
    for (var i = 0; i < 5; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    Object? err = t.takeException();
    final scroll = find.byType(Scrollable);
    if (scroll.evaluate().isNotEmpty) {
      for (var i = 0; i < 6 && err == null; i++) {
        await t.drag(scroll.first, const Offset(0, -320));
        await t.pump();
        err = t.takeException();
      }
    }
    return err?.toString().split('\n').first;
  }

  // ── 1–4 · the four tab screens at large text + narrow ──────────────────
  testWidgets('1 · catalog renders (large text, narrow)', (t) async {
    expect(await renderError(t, const CatalogScreen(), wrapScaffold: true),
        isNull);
  });
  testWidgets('2 · chats renders (large text, narrow)', (t) async {
    expect(
        await renderError(t, const ChatsScreen(), wrapScaffold: true), isNull);
  });
  testWidgets('3 · notifications renders (large text, narrow)', (t) async {
    expect(await renderError(t, const NotificationsScreen(), wrapScaffold: true),
        isNull);
  });
  testWidgets('4 · store renders (large text, narrow)', (t) async {
    expect(
        await renderError(t, const StoreScreen(), wrapScaffold: true), isNull);
  });

  // ── 5–8 · the four settings screens at large text + narrow ─────────────
  testWidgets('5 · catalog settings renders', (t) async {
    expect(await renderError(t, const CatalogSettingsScreen()), isNull);
  });
  testWidgets('6 · chat settings renders', (t) async {
    expect(await renderError(t, const ChatSettingsScreen()), isNull);
  });
  testWidgets('7 · notif settings renders', (t) async {
    expect(await renderError(t, const NotifSettingsScreen()), isNull);
  });
  testWidgets('8 · store settings renders', (t) async {
    expect(await renderError(t, const StoreSettingsScreen()), isNull);
  });

  // ── 9–11 · secondary / tool screens ────────────────────────────────────
  testWidgets('9 · suppliers screen renders', (t) async {
    expect(await renderError(t, const SuppliersScreen()), isNull);
  });
  testWidgets('10 · install studio renders', (t) async {
    expect(await renderError(t, const InstallStudioScreen()), isNull);
  });
  testWidgets('11 · regression panel renders', (t) async {
    expect(await renderError(t, const RegressionPanelScreen()), isNull);
  });

  // ── 12–13 · tiny width (300px) ─────────────────────────────────────────
  testWidgets('12 · catalog renders at tiny width 300', (t) async {
    expect(
        await renderError(t, const CatalogScreen(),
            wrapScaffold: true, size: const Size(300, 640)),
        isNull);
  });
  testWidgets('13 · store renders at tiny width 300', (t) async {
    expect(
        await renderError(t, const StoreScreen(),
            wrapScaffold: true, size: const Size(300, 640)),
        isNull);
  });

  // ── 14–15 · extra-large text (1.3) ─────────────────────────────────────
  testWidgets('14 · notifications at extra-large text 1.3', (t) async {
    expect(
        await renderError(t, const NotificationsScreen(),
            wrapScaffold: true, textScale: 1.3),
        isNull);
  });
  testWidgets('15 · store settings at extra-large text 1.3', (t) async {
    expect(await renderError(t, const StoreSettingsScreen(), textScale: 1.3),
        isNull);
  });

  // ── 16–20 · the real shell: tab / section / dial states ────────────────
  testWidgets('16 · shell renders every bottom-nav tab', (t) async {
    await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
    await t.pumpAndSettle();
    final c = shellContainer(t);
    for (var tab = 0; tab < 4; tab++) {
      c.read(mainTabProvider.notifier).state = tab;
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: 'tab $tab threw');
    }
  });

  testWidgets('17 · store renders every section', (t) async {
    await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
    await t.pumpAndSettle();
    final c = shellContainer(t);
    c.read(mainTabProvider.notifier).state = 3;
    await t.pumpAndSettle();
    for (final s in StoreSection.values) {
      c.read(storeSectionProvider.notifier).state = s;
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: 'store section $s threw');
    }
  });

  testWidgets('18 · catalog renders every section', (t) async {
    await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
    await t.pumpAndSettle();
    final c = shellContainer(t);
    for (final s in const [
      'הכל',
      'קטגוריות',
      'חיפושים אחרונים',
      'תאימות',
      'מועדפים',
      'עץ חכם',
    ]) {
      c.read(catalogSectionProvider.notifier).state = s;
      // 'תאימות' embeds the install studio, which animates forever — bounded
      // pump instead of pumpAndSettle.
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(milliseconds: 120));
      }
      expect(t.takeException(), isNull, reason: 'catalog section "$s" threw');
    }
  });

  testWidgets('19 · catalog search panel renders live results', (t) async {
    await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
    await t.pumpAndSettle();
    final c = shellContainer(t);
    c.read(searchPanelOpenProvider.notifier).state = true;
    c.read(searchQueryProvider.notifier).state = 'מחסום';
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('20 · BS dial opens with 5 personas', (t) async {
    await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
    await t.pumpAndSettle();
    shellContainer(t).read(openDialProvider.notifier).state = OpenDial.bs;
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    for (final p in const ['קבלן', 'מנהל המערכת', 'חנות ספק', 'שליח', 'עובד']) {
      expect(find.text(p), findsWidgets, reason: 'persona $p missing');
    }
  });
}
