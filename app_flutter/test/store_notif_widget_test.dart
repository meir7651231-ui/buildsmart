import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget-level coverage of the store & notification UI flows we built —
/// behaviours that the pure-state tests can't see (taps, sheets, gestures).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pump(WidgetTester t, Widget screen) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: screen),
          ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    return ProviderScope.containerOf(t.element(find.byType(screen.runtimeType)));
  }

  Future<void> settle(WidgetTester t, [int frames = 5]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  group('notifications', () {
    testWidgets('"סמן הכל כנקרא" zeroes the unread count', (t) async {
      final c = await pump(t, const NotificationsScreen());
      expect(c.read(notifUnreadCountProvider), greaterThan(0));
      await t.tap(find.byTooltip('סמן הכל כנקרא'));
      await settle(t);
      expect(c.read(notifUnreadCountProvider), 0);
    });

    testWidgets('swiping a row dismisses it (dismissed set grows)', (t) async {
      final c = await pump(t, const NotificationsScreen());
      final before = c.read(notifDismissedIdsProvider).length;
      final row = find.byType(Dismissible);
      expect(row, findsWidgets);
      // endToStart in RTL = swipe toward the start edge (rightward, +dx).
      await t.fling(row.first, const Offset(500, 0), 1200);
      await settle(t);
      expect(c.read(notifDismissedIdsProvider).length, before + 1);
    });
  });

  group('store favorites', () {
    testWidgets('a favorited hub row opens in the מועדפים sheet (title key)',
        (t) async {
      final c = await pump(t, const StoreScreen());
      // Favourite a real hub row by title (the swipe path keys on title).
      c.read(storeFavoritesProvider.notifier).toggle('הסל שלי');
      await settle(t);
      // Before the key fix this showed an "empty favourites" toast instead of
      // a sheet, because the quick-action filtered by emoji, not title.
      await t.tap(find.text('מועדפים'));
      await settle(t);
      // Now visible both in the hub list AND inside the opened sheet.
      expect(find.text('הסל שלי'), findsAtLeastNWidgets(2));
    });
  });

  group('order tracking', () {
    testWidgets('order sheet shows the real status timeline, not a placeholder',
        (t) async {
      final c = await pump(t, const StoreScreen());
      c.read(storeSectionProvider.notifier).state = StoreSection.orders;
      await settle(t);
      await t.tap(find.text('BS-1234')); // seed order, stage = transit
      await settle(t, 6);
      expect(find.text('🚛 מעקב הזמנה'), findsOneWidget);
      expect(find.text('בהכנה'), findsWidgets);
      expect(find.text('נמסר'), findsWidgets);
      expect(find.textContaining('בבנייה'), findsNothing);
    });
  });
}
