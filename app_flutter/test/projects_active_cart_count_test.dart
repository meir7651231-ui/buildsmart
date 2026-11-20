// Nightly 2026-11-20 — the ACTIVE project's card reads its cart count from the
// live shared cart. `LiveProject.cart` is only a snapshot written when
// switching AWAY from a project, so the active card used to read
// "🛒 0 פריטים בעגלה" while the cart held items.
import 'package:buildsmart/screens/projects_screen.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

SmartCartLine _line(String key) => SmartCartLine(
  productKey: key,
  productName: 'מוצר $key',
  productEmoji: '🔧',
  brandName: 'b',
  brandPrice: 10,
  productQty: 1,
  accessories: const [],
);

void main() {
  group('projectCartLines (pure)', () {
    final stale = LiveProject(
      id: 'PRJ-1',
      name: 'x',
      addr: '',
      manager: '',
      cart: [_line('a')], // stashed snapshot (stale for the active project)
      treeCount: 0,
    );
    test('active project → live cart count', () {
      expect(projectCartLines(stale, activeId: 'PRJ-1', liveCartLines: 5), 5);
    });
    test('inactive project → its stashed snapshot', () {
      expect(projectCartLines(stale, activeId: 'PRJ-2', liveCartLines: 5), 1);
    });
  });

  testWidgets('active project card shows the live cart count', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(500, 1600));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final state = c.read(projectsProvider);
    expect(state.projects, isNotEmpty, reason: 'local demo seed');
    final cart = c.read(smartCartProvider.notifier);
    for (final k in ['a', 'b', 'c']) {
      cart.setQtyForKey(_line(k));
    }

    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: ProjectsScreen()),
      ),
    );
    await t.pumpAndSettle();

    final activeLabel = '🛒 3 פריטים בעגלה ›';
    expect(find.text(activeLabel), findsOneWidget);
    // Adding to the live cart updates the active card immediately.
    cart.setQtyForKey(_line('d'));
    await t.pumpAndSettle();
    expect(find.text('🛒 4 פריטים בעגלה ›'), findsOneWidget);
    await t.binding.setSurfaceSize(null);
  });

  testWidgets('dark mode: titles on theme surfaces use the dark ink '
      '(were #1A1A1A on a dark card ≈ invisible)', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(500, 1600));
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const ProjectsScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
    Color? colorOf(String text) =>
        t.widget<Text>(find.text(text).first).style?.color;
    expect(colorOf('מגדל הרצליה — קומה 4'), BsTokens.inkDark);
    expect(colorOf('רח\' הנדיב 12, הרצליה'), BsTokens.mutedDark);
    // Light-fixed pills keep their light-surface ink (unchanged).
    expect(colorOf('🛒 0 פריטים בעגלה ›'), BsTokens.inkLight);
    await t.binding.setSurfaceSize(null);
  });
}
