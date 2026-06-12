// wave-4 · AI HUB — the two tools wired to REAL in-app data (no language model).
//
//   • 📦 חיזוי מלאי   → [computeStockForecast] folds the live orders engine
//     (captured line-item consumption history) + the live cart (on-hand) into a
//     per-product run-out forecast. Deterministic; empty (honest) with no lines.
//   • 📊 Analytics חכם → [computeAnalyticsInsights] folds the live orders engine
//     + budget + the real cheaper-alternatives scan into deterministic insights.
//
// Every expected number is hand-derived from the inputs in the test (the formula
// is what the helper must reproduce), so a formula change fails here. The
// remaining AI-hub tools (three-way / weather / wear) genuinely need an EXTERNAL
// data source (delivery+invoice docs · forecast API · IoT sensors) and stay a
// flagged sample — there is nothing real to compute, so they are not tested here.

import 'package:buildsmart/data/contractor_seeds.dart'
    show fMoney, kBudgetSpent, kBudgetTotal;
import 'package:buildsmart/logic/ai_hub_logic.dart';
import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── builders ──────────────────────────────────────────────────────────────
Order _order(
  String id,
  int sum,
  String stage, {
  DateTime? at,
  List<OrderLineItem> lines = const [],
}) =>
    Order(
      id: id,
      who: 'בוחן',
      site: 'אתר',
      items: lines.length,
      sum: sum,
      stage: stage,
      createdAt: at,
      lines: lines,
    );

OrderLineItem _line(String name, int qty) =>
    OrderLineItem(name: name, emoji: '📦', qty: qty, price: qty * 10);

SmartCartLine _cart(String name, int qty) => SmartCartLine(
      productKey: name,
      productName: name,
      productEmoji: '📦',
      brandName: 'מותג',
      brandPrice: 10,
      productQty: qty,
      accessories: const [],
    );

void main() {
  // ════════════════════════════════════════════════════════════════════════
  // 📦 חיזוי מלאי — computeStockForecast (orders history + live cart)
  // ════════════════════════════════════════════════════════════════════════
  group('computeStockForecast — REAL forecast over orders engine + cart', () {
    final d0 = DateTime(2026, 6, 1);
    final d10 = DateTime(2026, 6, 11); // 10-day span

    test('rate = Σqty / spanDays, stock = cart qty, days = round(stock/rate)',
        () {
      // מלט ordered 14 + 6 = 20 units across a 10-day window → rate 2/day.
      // 12 units staged in the cart now → 12 / 2 = 6 days runway.
      final orders = [
        _order('BS-1', 100, 'delivered', at: d0, lines: [_line('מלט', 14)]),
        _order('BS-2', 100, 'new', at: d10, lines: [_line('מלט', 6)]),
      ];
      final cart = [_cart('מלט', 12)];

      final preds = computeStockForecast(orders, cart, now: d10);

      expect(preds, hasLength(1));
      final p = preds.single;
      expect(p.name, 'מלט');
      expect(p.rate, 2); // (14+6)/10
      expect(p.stock, 12); // live cart
      expect(p.days, 6); // 12 / 2
      expect(p.urgent, isFalse); // 6 > 3
    });

    test('urgent (<=3 days) flag — fast consumption, little on hand', () {
      // 90 units over 9 days → 10/day; only 9 staged → 1 day → URGENT.
      final orders = [
        _order('BS-1', 100, 'delivered',
            at: DateTime(2026, 6, 1), lines: [_line('PEX', 45)]),
        _order('BS-2', 100, 'new',
            at: DateTime(2026, 6, 10), lines: [_line('PEX', 45)]),
      ];
      final preds = computeStockForecast(orders, [_cart('PEX', 9)],
          now: DateTime(2026, 6, 10));
      final p = preds.single;
      expect(p.rate, 10); // 90/9
      expect(p.days, 1); // round(9/10)
      expect(p.urgent, isTrue);
    });

    test('single order ⇒ 1-day span (no divide-by-zero), rate ≥ 1', () {
      final orders = [
        _order('BS-1', 100, 'new', at: DateTime(2026, 6, 1), lines: [
          _line('דבק', 3),
        ]),
      ];
      final p =
          computeStockForecast(orders, [_cart('דבק', 9)], now: DateTime(2026, 6, 1))
              .single;
      expect(p.rate, 3); // 3 units / 1-day span
      expect(p.days, 3); // 9 / 3
    });

    test('honest empty — seed-only engine (no captured lines) ⇒ no rows', () {
      // The four seed orders carry NO line items; nothing real to forecast.
      final n = OrdersEngineNotifier(persist: false);
      expect(n.state, hasLength(4));
      expect(computeStockForecast(n.state, const []), isEmpty);
    });

    test('product never ordered (only in cart) is NOT forecast', () {
      // No consumption history ⇒ no rate ⇒ excluded (honest).
      final preds = computeStockForecast(const [], [_cart('בלוקים', 50)]);
      expect(preds, isEmpty);
    });

    test('aggregates a product across MANY orders; sorts soonest-first', () {
      final orders = [
        // ברזל: 20 over 10 days → 2/day; cart 20 → 10 days.
        _order('BS-1', 1, 'delivered', at: d0, lines: [_line('ברזל', 10)]),
        _order('BS-2', 1, 'new', at: d10, lines: [_line('ברזל', 10)]),
        // צבע: 30 over 10 days → 3/day; cart 3 → 1 day (urgent, comes first).
        _order('BS-3', 1, 'delivered', at: d0, lines: [_line('צבע', 15)]),
        _order('BS-4', 1, 'new', at: d10, lines: [_line('צבע', 15)]),
      ];
      final cart = [_cart('ברזל', 20), _cart('צבע', 3)];
      final preds = computeStockForecast(orders, cart, now: d10);

      expect(preds.map((p) => p.name).toList(), ['צבע', 'ברזל']); // 1d < 10d
      expect(preds[0].days, 1);
      expect(preds[1].days, 10);
    });

    test('on-hand sums multiple cart lines of the same product', () {
      final orders = [
        _order('BS-1', 1, 'delivered', at: d0, lines: [_line('מלט', 5)]),
        _order('BS-2', 1, 'new', at: d10, lines: [_line('מלט', 5)]),
      ];
      // Two cart lines for מלט: 4 + 6 = 10 on hand; rate (5+5)/10 = 1 → 10 days.
      final preds =
          computeStockForecast(orders, [_cart('מלט', 4), _cart('מלט', 6)], now: d10);
      expect(preds.single.stock, 10);
      expect(preds.single.rate, 1);
      expect(preds.single.days, 10);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // 📊 Analytics חכם — computeAnalyticsInsights (orders + budget + alts)
  // ════════════════════════════════════════════════════════════════════════
  group('computeAnalyticsInsights — REAL insights over orders + budget', () {
    test('seed orders → verbatim totals (4 orders · Σ=5490 · 4 open/0 done)',
        () {
      final n = OrdersEngineNotifier(persist: false);
      final ins = computeAnalyticsInsights(n.state);

      // Σ sum of the four seed orders: 1240+680+3150+420.
      const seedSum = 1240 + 680 + 3150 + 420; // 5490
      expect(seedSum, 5490);

      final volume = ins.firstWhere((i) => i.ic == '📦');
      expect(volume.title, '4 הזמנות · ${fMoney(seedSum)} סה״כ רכש');

      final avg = ins.firstWhere((i) => i.ic == '💵');
      expect(avg.title, 'שווי הזמנה ממוצע: ${fMoney((seedSum / 4).round())}');

      // All four seed orders are open (none delivered).
      final flow = ins.firstWhere((i) => i.ic == '🚚');
      expect(flow.title, '4 הזמנות פתוחות · 0 סופקו');
    });

    test('open/delivered split tracks the live order stages', () {
      final orders = [
        _order('A', 1000, 'delivered'),
        _order('B', 2000, 'new'),
        _order('C', 3000, 'transit'),
      ];
      final ins = computeAnalyticsInsights(orders);
      expect(
        ins.firstWhere((i) => i.ic == '🚚').title,
        '2 הזמנות פתוחות · 1 סופקו',
      );
      // Σ = 6000, avg = 2000.
      expect(ins.firstWhere((i) => i.ic == '📦').title,
          '3 הזמנות · ${fMoney(6000)} סה״כ רכש');
      expect(ins.firstWhere((i) => i.ic == '💵').title,
          'שווי הזמנה ממוצע: ${fMoney(2000)}');
    });

    test('💰 savings insight = Σ of the REAL cheaper-alternatives scan', () {
      final ins = computeAnalyticsInsights(const []);
      final expectSave = aiAlternatives().fold<int>(0, (s, a) => s + a.save);
      expect(expectSave, greaterThan(0)); // catalog has cheaper brands
      final savings = ins.firstWhere((i) => i.ic == '💰');
      expect(savings.title, 'חיסכון אפשרי: ${fMoney(expectSave)}');
    });

    test('📊 budget insight = round(spent/total*100) + remaining (66% seed)',
        () {
      final ins = computeAnalyticsInsights(const []);
      final pct = (kBudgetSpent / kBudgetTotal * 100).round();
      expect(pct, 66); // 9840 / 15000
      final budget = ins.firstWhere((i) => i.ic == '📊');
      expect(budget.title, 'ניצול תקציב: $pct%');
      expect(budget.sub,
          'נותרו ${fMoney(kBudgetTotal - kBudgetSpent)} מתוך ${fMoney(kBudgetTotal)}');
    });

    test('empty orders → no order rows, but savings + budget still present', () {
      final ins = computeAnalyticsInsights(const []);
      expect(ins.any((i) => i.ic == '📦'), isFalse);
      expect(ins.any((i) => i.ic == '🚚'), isFalse);
      expect(ins.any((i) => i.ic == '💰'), isTrue); // catalog-derived
      expect(ins.any((i) => i.ic == '📊'), isTrue); // budget-derived
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // WIRING — the screen RENDERS the computed result over the live providers
  // (proves the tiles read the engine, not a const), via the public AIHubScreen.
  // ════════════════════════════════════════════════════════════════════════
  group('AI hub screen renders the COMPUTED tools', () {
    testWidgets('📊 Analytics tile shows live-engine numbers (seed budget 66%)',
        (t) async {
      await t.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AIHubScreen())),
      );
      await t.pumpAndSettle();

      await t.ensureVisible(find.text('Analytics חכם'));
      await t.pumpAndSettle();
      await t.tap(find.text('Analytics חכם'));
      await t.pumpAndSettle();

      // Computed-over-real note (not the old "מנוע אנליטיקה בשרת" placeholder).
      expect(find.textContaining('מחושב מנתוני אמת'), findsOneWidget);
      // The seed budget insight, computed: 9840/15000 → 66%.
      final pct = (kBudgetSpent / kBudgetTotal * 100).round();
      expect(find.textContaining('ניצול תקציב: $pct%'), findsOneWidget);
      // The 4 seed orders surface as a real order-count line.
      expect(find.textContaining('4 הזמנות'), findsWidgets);
    });

    testWidgets('📦 חיזוי מלאי honest empty-state on the seed engine', (t) async {
      await t.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AIHubScreen())),
      );
      await t.pumpAndSettle();

      await t.tap(find.text('חיזוי מלאי'));
      await t.pumpAndSettle();

      // Computed note + the no-data state (seed orders carry no lines).
      expect(find.textContaining('מחושב מתוך היסטוריית ההזמנות'), findsOneWidget);
      expect(find.textContaining('אין עדיין היסטוריית צריכה'), findsOneWidget);
    });
  });
}
