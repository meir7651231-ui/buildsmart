import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/courier_dashboard_screen.dart';
import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/screens/store_profile_screen.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// T9 — supplier-side persona role-apps (🏪 חנות + 🛵 שליח). Guards the verbatim
/// SYS_ORDERS seed + supporting tables (proto 06 §1/§7), and the shared
/// store↔courier advance engine — now UNIFIED onto the manager's
/// `ordersEngineProvider`, so a store/courier advance is visible to the manager
/// live (one source of truth). Also checks both screens render real content. R8.

/// A container whose shared engine does NOT touch SharedPreferences, so unit
/// tests stay deterministic. The store/courier `sysOrdersProvider` is a live
/// view of this same engine.
ProviderContainer _container() => ProviderContainer(
  overrides: [
    ordersEngineProvider.overrideWith((ref) => OrdersEngineNotifier(persist: false)),
  ],
);

SysOrder _sys(ProviderContainer c, String id) =>
    c.read(sysOrdersProvider).firstWhere((o) => o.id == id);
String _eng(ProviderContainer c, String id) =>
    c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage;

void main() {
  group('SYS_ORDERS seed + tables (verbatim, R8)', () {
    test('4 demo orders, verbatim id/who/site/stage/lines', () {
      expect(kSysOrdersSeed.length, 4);
      expect(
        kSysOrdersSeed.map((o) => o.id),
        ['BS-1042', 'BS-1041', 'BS-1040', 'BS-1039'],
      );
      expect(kSysOrdersSeed[0].who, 'יוסי כהן');
      expect(kSysOrdersSeed[0].site, 'מגדל הרצליה');
      expect(kSysOrdersSeed[0].stage, OrderStage.newOrder);
      expect(kSysOrdersSeed[1].stage, OrderStage.preparing);
      expect(kSysOrdersSeed[2].stage, OrderStage.ready);
      expect(kSysOrdersSeed[3].stage, OrderStage.transit);
      expect(kSysOrdersSeed[0].lines.first.name, 'ברז לכיור');
      expect(kSysOrdersSeed[0].lines.first.qty, 2);
    });

    test('STORES / HAUL_TYPES / portal tables verbatim', () {
      expect(kStores.map((s) => s.name), [
        'מחסני אינסטלציה תל-אביב',
        'ספקי סניטריה השרון',
        'חומרי בניין הרצליה',
      ]);
      expect(kHaulTypes.map((h) => h.name), ['משלוח קטן', 'טנדר', 'משאית']);
      expect(kDistZones.length, 4);
      expect(kBulkTiers.map((b) => b.discount), [0, 5, 9, 14]);
      expect(kFleet.first.driver, 'אבי');
      expect(kOrderStageLabel[OrderStage.delivered], 'נמסר ✓');
    });
  });

  group('shared engine — store ↔ courier ↔ manager, ONE source of truth', () {
    test('store advances new→preparing→ready→pickup, then stops', () {
      final c = _container();
      addTearDown(c.dispose);
      final n = c.read(sysOrdersProvider.notifier);
      n.storeAdvance('BS-1042');
      expect(_sys(c, 'BS-1042').stage, OrderStage.preparing);
      n.storeAdvance('BS-1042');
      expect(_sys(c, 'BS-1042').stage, OrderStage.ready);
      n.storeAdvance('BS-1042'); // hand off to courier (ready→pickup)
      expect(_sys(c, 'BS-1042').stage, OrderStage.pickup);
      n.storeAdvance('BS-1042'); // courier owns it from here — no-op
      expect(_sys(c, 'BS-1042').stage, OrderStage.pickup);
    });

    test('a store advance is visible to the MANAGER live (unified engine)', () {
      final c = _container();
      addTearDown(c.dispose);
      expect(_eng(c, 'BS-1042'), 'new');
      c.read(sysOrdersProvider.notifier).storeAdvance('BS-1042');
      // The very same order the manager dashboard reads is now 'preparing'.
      expect(_eng(c, 'BS-1042'), 'preparing');
    });

    test('courier advances pickup→transit→delivered after the store hands off', () {
      final c = _container();
      addTearDown(c.dispose);
      final n = c.read(sysOrdersProvider.notifier);
      // BS-1040 is seeded `ready`; the courier does NOT own ready→pickup now (the
      // store hands off), so courierAdvance on `ready` is a no-op.
      n.courierAdvance('BS-1040'); // no-op on ready
      expect(_sys(c, 'BS-1040').stage, OrderStage.ready);
      n.storeAdvance('BS-1040'); // store hands off: ready→pickup
      expect(_sys(c, 'BS-1040').stage, OrderStage.pickup);
      n.courierAdvance('BS-1040'); // pickup→transit (courier received it)
      expect(_sys(c, 'BS-1040').stage, OrderStage.transit);
      expect(_eng(c, 'BS-1040'), 'transit');
      n.courierAdvance('BS-1040'); // transit→delivered
      expect(_sys(c, 'BS-1040').stage, OrderStage.delivered);
      n.courierAdvance('BS-1040'); // no-op
      expect(_sys(c, 'BS-1040').stage, OrderStage.delivered);
    });

    test('a store-readied order becomes a courier job (cross-role)', () {
      final c = _container();
      addTearDown(c.dispose);
      final n = c.read(sysOrdersProvider.notifier);
      expect(c.read(sysOrdersProvider).courierJobs('truck').any((o) => o.id == 'BS-1042'), isFalse);
      n.storeAdvance('BS-1042'); // preparing
      n.storeAdvance('BS-1042'); // ready
      expect(c.read(sysOrdersProvider).courierJobs('truck').any((o) => o.id == 'BS-1042'), isTrue);
    });

    test('vehicle gating: a small bike cannot carry a truck order', () {
      final c = _container();
      addTearDown(c.dispose);
      expect(c.read(sysOrdersProvider).courierJobs('small').any((o) => o.id == 'BS-1040'), isFalse);
      expect(c.read(sysOrdersProvider).courierJobs('truck').any((o) => o.id == 'BS-1040'), isTrue);
    });

    test('simulate places a fresh new order through the shared engine', () {
      final c = _container();
      addTearDown(c.dispose);
      final before = c.read(sysOrdersProvider).length;
      final id = c.read(sysOrdersProvider.notifier).simulateIncomingOrder();
      final orders = c.read(sysOrdersProvider);
      expect(orders.length, before + 1);
      expect(orders.first.id, id);
      expect(orders.first.stage, OrderStage.newOrder);
      // It lands in the manager's engine too (contractor/store/manager share it).
      expect(c.read(ordersEngineProvider).any((o) => o.id == id), isTrue);
    });

    test('deliveredRevenue counts ONLY delivered orders (#87.2)', () {
      final c = _container();
      addTearDown(c.dispose);
      // Seed has BS-1039 in transit and none delivered — revenue must be 0
      // (a mutation that counts transit/pickup flips this immediately).
      expect(c.read(sysOrdersProvider).deliveredRevenue, 0);
      final n = c.read(sysOrdersProvider.notifier);
      n.storeAdvance('BS-1042'); // preparing
      n.storeAdvance('BS-1042'); // ready
      n.storeAdvance('BS-1042'); // pickup (hand-off)
      n.courierAdvance('BS-1042'); // transit
      expect(c.read(sysOrdersProvider).deliveredRevenue, 0);
      n.courierAdvance('BS-1042'); // delivered
      final sum =
          kSysOrdersSeed.firstWhere((o) => o.id == 'BS-1042').sum;
      expect(c.read(sysOrdersProvider).deliveredRevenue, sum,
          reason: 'מחזור שנמסר = סכום ההזמנות שנמסרו בלבד, נגזר מהמנוע החי');
    });
  });

  testWidgets('store dashboard renders verbatim content + advances an order', (
    tester,
  ) async {
    // #65 gate: seed a store session so the board (not the gate) renders.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"store","username":"lipskey","displayName":"ליפסקי","demo":false}',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersEngineProvider.overrideWith((ref) => OrdersEngineNotifier(persist: false)),
        ],
        child: const MaterialApp(home: StoreDashboardScreen()),
      ),
    );
    await tester.pump();
    // Lazy boardAuthProvider _load() → gate swaps to the board.
    await tester.pump(const Duration(milliseconds: 100));

    // #87.1 (F-20) — the AppBar title is the LIVE identity now: business-name
    // override → session.displayName ('ליפסקי') → kStores.first.name. With no
    // saved business profile the session displayName wins.
    expect(find.text('🏪 ליפסקי'), findsOneWidget);
    expect(find.text('שלום 👋'), findsOneWidget);
    // The home subtitle carries the SAME live identity (not the demo seed).
    expect(
      find.textContaining('ליפסקי — מה שצריך טיפול עכשיו'),
      findsOneWidget,
    );
    expect(find.textContaining('בבנייה'), findsNothing);

    // #77/#78: the top '📥 הזמנות' pill is gone — the orders PIPELINE now
    // lives on the default בית tab (bottom nav). Scroll down to the card.
    await tester.scrollUntilVisible(
      find.text('📦 BS-1042'),
      200,
      // The board now hosts several Scrollables (stats row, list, nav) —
      // drive the main vertical ListView explicitly.
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('📦 BS-1042'), findsOneWidget);
    await tester.ensureVisible(find.text('✓ אשר וקבל להכנה'));
    // #87.2 — the home tab grew (the delivered-side stats row), so a minimal
    // ensureVisible can park the CTA right behind the fixed bottom nav (56px,
    // 5 tabs now). Nudge the main list a bit further so the tap really lands.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
    await tester.pump();
    expect(find.text('✓ אשר וקבל להכנה'), findsOneWidget);
    await tester.tap(find.text('✓ אשר וקבל להכנה'));
    await tester.pump();
    expect(find.text('📦 סמן כמוכן — העבר לשליח'), findsWidgets);
  });

  testWidgets('הטאב החמישי "אזור אישי" של הספק נפתח — StoreProfileBody (#87.5)', (
    tester,
  ) async {
    // #65 gate: seed a store session so the board (not the gate) renders.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"store","username":"lipskey","displayName":"ליפסקי","demo":false}',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersEngineProvider.overrideWith((ref) => OrdersEngineNotifier(persist: false)),
        ],
        child: const MaterialApp(home: StoreDashboardScreen()),
      ),
    );
    await tester.pump();
    // Lazy boardAuthProvider _load() → gate swaps to the board.
    await tester.pump(const Duration(milliseconds: 100));

    // #87.5 — a REAL labeled fifth bottom tab (type: fixed keeps the label
    // visible). The AppBar person-icon is a Tooltip, not a Text — so this
    // finder hits exactly the nav label.
    expect(find.text('אזור אישי'), findsOneWidget);
    await tester.tap(find.text('אזור אישי'));
    await tester.pump();
    // storeProfileProvider lazy load (empty prefs → honest fallbacks).
    await tester.pump(const Duration(milliseconds: 100));

    // KNOWN LIB ISSUE (reported, do not fix here): _StorePersonalAreaCard
    // (store_profile_screen.dart) wraps its 3 ListTiles in a color-decorated
    // Container with no Material in between, so Flutter's debug-only
    // 'ListTile background color or ink splashes may be invisible' assertion
    // fires 3× on first build (the worker's _PersonalAreaCard shares the
    // pattern). Drain ONLY that known warning so this test keeps guarding the
    // tab wiring; once the lib wraps the tiles in a Material, takeException()
    // returns null and this block is a no-op.
    final pending = tester.takeException();
    if (pending != null) {
      expect(
        '$pending',
        anyOf(
          contains('Multiple exceptions'),
          contains('ListTile background color'),
        ),
        reason: 'חריגה לא-מוכרת בבניית טאב האזור האישי של הספק: $pending',
      );
    }

    // The tab body IS the supplier's own personal area (F-21.2).
    expect(find.byType(StoreProfileBody), findsOneWidget);
    // Identity card: business-name override is empty → the session
    // displayName, plus the verbatim '@username · ספק' meta row.
    expect(find.text('ליפסקי'), findsOneWidget);
    expect(find.text('@lipskey · ספק'), findsOneWidget);
    // Live store-wide stats card (#87.2) renders off the shared engine.
    expect(find.text('📊 סטטיסטיקת חנות'), findsOneWidget);
  });

  testWidgets('courier dashboard renders verbatim content', (tester) async {
    // #65 gate: seed a courier session so the board (not the gate) renders.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"courier","username":"dudi","displayName":"דוד","demo":false}',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersEngineProvider.overrideWith((ref) => OrdersEngineNotifier(persist: false)),
        ],
        child: const MaterialApp(home: CourierDashboardScreen()),
      ),
    );
    await tester.pump();
    // Lazy boardAuthProvider _load() → gate swaps to the vehicle-pick step.
    await tester.pump(const Duration(milliseconds: 100));

    // #72 flow: session gate → vehicle gate first (no board content yet).
    expect(find.text('🛵 שליח'), findsOneWidget);
    expect(find.text('הרכב שלי היום'), findsOneWidget);
    expect(find.text('משאית'), findsWidgets);

    // Pick the truck → the board home renders for the logged courier (דוד).
    await tester.tap(find.text('משאית').first);
    await tester.pump();

    expect(find.text('שלום דוד 🛵'), findsOneWidget);
    // BS-1040 (ready, truck) is a truck job — but the store owns the hand-off,
    // so the courier sees it VIEW-ONLY (awaiting) until it is handed off (two-step).
    expect(find.text('📦 BS-1040'), findsOneWidget);
    expect(find.text('⏳ ממתין למסירה מהחנות'), findsWidgets);
    expect(find.textContaining('בבנייה'), findsNothing);
  });
}
