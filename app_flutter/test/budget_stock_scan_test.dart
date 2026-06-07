// Track T3 C/D/E DoD guard (new budget_/stock_/scan_ screens).
//   C · תקציב   — budget math (pct=66%) + editor / category / adjust mutations.
//   D · מלאי    — kStockDemo(11) · 2 tabs · move flips a key's location.
//   E · סריקה   — 4 kPlanTypes · scan→cart (cheapest offer, qty 1).
// Pure logic + StateNotifier behaviour; sources noted to index.html line anchors.
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/screens/budget_screen.dart';
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:buildsmart/screens/stock_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── T3.C · תקציב ──────────────────────────────────────────────────────────
  group('T3.C budget [L7150]', () {
    test('seeds from kBudget* — pct=66% (9840/15000) [L7162]', () {
      final n = BudgetNotifier();
      expect(n.state.total, kBudgetTotal);
      expect(n.state.spent, kBudgetSpent);
      expect(n.state.pct, 66);
      expect(n.state.left, kBudgetTotal - kBudgetSpent); // 5160
      expect(n.state.categories, hasLength(4));
    });

    test('left turns negative on overspend [L7196]', () {
      final n = BudgetNotifier()..setTotals(15000, 16000);
      expect(n.state.left, -1000);
      expect(n.state.pct, 107);
    });

    test('adjustSpent(+/-) — add / remove a cost [L7291]', () {
      final n = BudgetNotifier();
      final base = n.state.spent;
      n.adjustSpent(1, 500);
      expect(n.state.spent, base + 500);
      n.adjustSpent(-1, 200);
      expect(n.state.spent, base + 300);
      n.adjustSpent(-1, 1 << 20); // cannot go below 0
      expect(n.state.spent, 0);
    });

    test('category save / add / delete (keep >=1) [L7259-7278]', () {
      final n = BudgetNotifier();
      n.saveCategory(0, 'אינסטלציה', 4000);
      expect(n.state.categories[0].amount, 4000);
      final i = n.addCategory();
      expect(n.state.categories, hasLength(5));
      n.saveCategory(i, 'גינון', 300);
      expect(n.state.categories.last.name, 'גינון');
      // delete down to 1 — last delete is a no-op
      while (n.state.categories.length > 1) {
        n.deleteCategory(0);
      }
      expect(n.state.categories, hasLength(1));
      n.deleteCategory(0);
      expect(n.state.categories, hasLength(1));
    });

    test('category share sums to ~1 over Σamount', () {
      final cats = BudgetNotifier().state.categories;
      final sum = cats.fold<int>(0, (s, c) => s + c.amount);
      expect(sum, kBudgetSpent); // Σ categories == spent (proto invariant)
      final shareSum =
          cats.fold<double>(0, (s, c) => s + c.amount / sum);
      expect(shareSum, closeTo(1.0, 1e-9));
    });
  });

  // ── T3.D · מלאי ───────────────────────────────────────────────────────────
  group('T3.D stock [L6202]', () {
    test('seeds 11 items from kStockDemo', () {
      final n = StockNotifier();
      expect(n.state, hasLength(11));
      expect(n.state['סרט טפלון'], 'warehouse');
      expect(n.state['ברזי ניל זוויתיים'], 'site');
    });

    test('move flips warehouse <-> site [L8237]', () {
      final n = StockNotifier();
      expect(n.state['סרט טפלון'], 'warehouse');
      n.move('סרט טפלון');
      expect(n.state['סרט טפלון'], 'site');
      n.move('סרט טפלון');
      expect(n.state['סרט טפלון'], 'warehouse');
    });

    test('move on unknown key is a no-op', () {
      final n = StockNotifier();
      final before = Map<String, String>.from(n.state);
      n.move('לא קיים');
      expect(n.state, before);
    });

    test('tabs partition the seed (7 warehouse + 4 site = 11)', () {
      final n = StockNotifier();
      final wh = n.state.values.where((v) => v == 'warehouse').length;
      final site = n.state.values.where((v) => v == 'site').length;
      expect(wh + site, 11);
      expect(site, 4); // ברזי ניל ×3 + אטם גומי לברז
    });
  });

  // ── T3.E · סריקה-תפריט ────────────────────────────────────────────────────
  group('T3.E scan→cart [L9658]', () {
    test('4 plan types — each scans to >=1 cart line', () {
      expect(kPlanTypes, hasLength(4));
      for (final p in kPlanTypes) {
        final lines = scanPlanCartLines(p);
        final withStores = p.zones.fold<int>(0,
            (s, z) => s + z.items.where((it) => it.stores.isNotEmpty).length);
        expect(lines.length, withStores, reason: p.label);
        expect(lines, isNotEmpty);
      }
    });

    test('every line uses the cheapest store, qty 1, scan: key', () {
      for (final p in kPlanTypes) {
        final byName = {
          for (final z in p.zones)
            for (final it in z.items) it.name: it,
        };
        for (final l in scanPlanCartLines(p)) {
          final it = byName[l.productName]!;
          final cheapest =
              it.stores.map((s) => s.price).reduce((a, b) => a < b ? a : b);
          expect(l.brandPrice, cheapest);
          expect(l.productQty, 1);
          expect(l.productKey, startsWith('scan:${p.key}:'));
        }
      }
    });

    test('plumbing אסלה → cheapest אבן קיסר 740 (verbatim §9b)', () {
      final plumbing = kPlanTypes.firstWhere((p) => p.key == 'plumbing');
      final toilet = scanPlanCartLines(plumbing)
          .firstWhere((l) => l.productName.contains('אסלה'));
      expect(toilet.brandName, 'אבן קיסר');
      expect(toilet.brandPrice, 740);
    });

    test('scan→cart adds the lines to the real smart-cart', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final plumbing = kPlanTypes.firstWhere((p) => p.key == 'plumbing');
      final lines = scanPlanCartLines(plumbing);
      final cart = c.read(smartCartProvider.notifier);
      for (final l in lines) {
        cart.add(l);
      }
      expect(c.read(smartCartProvider), hasLength(lines.length));
    });

    // R9 modal sheet (canonical) — openScanPlanSheet with a planKey deep-link
    // (menu leaf wiring) skips the picker and auto-starts that plan's scan.
    testWidgets('openScanPlanSheet planKey auto-starts the plan scan',
        (tester) async {
      late BuildContext sheetContext;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  sheetContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      openScanPlanSheet(sheetContext, planKey: 'plumbing');
      await tester.pump(); // open the sheet
      await tester.pump(); // post-frame deep-link _start

      // Picker title is gone (it auto-started); the scanning view is showing.
      expect(find.text('📐 סרוק תוכנית עבודה'), findsNothing);
      expect(find.text('מנתח את תצורת הבנייה ומחלץ כמויות חומרים…'), findsOneWidget);

      // Let the 4-step scan timer finish → results phase reveals the summary.
      await tester.pump(const Duration(milliseconds: 750 * 4));
      await tester.pumpAndSettle();
      expect(find.textContaining('זוהו'), findsOneWidget);
    });
  });
}
