import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end purchase journey, run for 10 different real catalog products.
/// Each case drives every button from the catalog search, through the product
/// sheet, the cart FAB, the store cart (stepper + summary), and checkout to
/// confirmation — asserting both the UI and the underlying providers at every
/// stage. If any button in the chain breaks for a product, its case goes red.
void main() {
  // 10 diverse SKUs spanning trap / cover / branch / thread / flush / brass /
  // HDPE / NTM / float categories.
  const cases = <(String sku, String name)>[
    ('217861', 'מחסום (סיפון) אמריקאי 1.25" לכיור רחצה'),
    ('610918', 'מכסה עגול עליון קבוע לבן'),
    ('118220', 'מסעף 45° DN110 עם תבריג · כולל 3 אומים ו-3 אטמים'),
    ('116209', 'מחבר כפול'),
    ('77110166', 'דיור מערכת שטיפה דולפין פלוס ניקל'),
    ('77Z3080A', 'מכסה נחושת עגול 4"'),
    ('77001191', 'מחבר טלסקופי כפול 1/2"'),
    ('9102501231', 'זווית HDPE הברגה חיצונית 25×1/2"'),
    ('77405428', 'זווית פנימית NTM 20×3/4"'),
    ('77777482', 'מצוף נחושת 3/4"'),
  ];

  Widget app() => const ProviderScope(child: BuildSmartApp());

  ProviderContainer containerOf(WidgetTester t) =>
      ProviderScope.containerOf(t.element(find.byType(HomeShell)));

  Future<void> runJourney(WidgetTester t, String sku, String name) async {
    await t.pumpWidget(app());
    await t.pumpAndSettle();

    // 1 · catalog boots
    expect(find.text('BuildSmart'), findsOneWidget);

    // 2 · open the search panel and query the SKU
    final field = find.byType(TextField).first;
    await t.tap(field);
    await t.pumpAndSettle();
    await t.enterText(field, sku);
    await t.pumpAndSettle();
    expect(find.text(name), findsAtLeastNWidgets(1),
        reason: 'search did not surface $sku ($name)');

    // 3 · open the product sheet
    await t.ensureVisible(find.text(name).first);
    await t.tap(find.text(name).first);
    await t.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);

    // 4 · add to cart (CTA lives in a lazy ListView → scroll it in)
    final sheetScroll = find
        .descendant(
          of: find.byType(DraggableScrollableSheet),
          matching: find.byType(Scrollable),
        )
        .first;
    await t.scrollUntilVisible(find.text('הוסף לסל'), 250,
        scrollable: sheetScroll);
    await t.pumpAndSettle();
    await t.tap(find.text('הוסף לסל'));
    await t.pumpAndSettle();

    final lines = containerOf(t).read(smartCartProvider);
    expect(lines.length, 1, reason: 'cart should hold exactly one line');
    expect(lines.single.productKey, 'lip:$sku');
    expect(lines.single.productName, name);
    expect(lines.single.productQty, 1);

    // 5 · jump to the store via the cart FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await t.tap(find.byType(FloatingActionButton));
    await t.pumpAndSettle();

    // 6 · open the cart section
    await t.tap(find.text('🛒 הסל'));
    await t.pumpAndSettle();
    expect(find.textContaining(name), findsAtLeastNWidgets(1));

    final cartScroll = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;

    // 7 · the + stepper raises the (real) cart-line quantity
    int smartQty() => containerOf(t)
        .read(smartCartProvider)
        .fold<int>(0, (s, l) => s + l.productQty);
    final before = smartQty();
    await t.scrollUntilVisible(find.byIcon(Icons.add).first, 120,
        scrollable: cartScroll);
    await t.pumpAndSettle();
    final midY = t.getRect(cartScroll).center.dy;
    final adds = find.byIcon(Icons.add);
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < adds.evaluate().length; i++) {
      final d = (t.getCenter(adds.at(i)).dy - midY).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    await t.tap(adds.at(best));
    await t.pumpAndSettle();
    final after = smartQty();
    expect(after, before + 1, reason: 'stepper + did not raise quantity');

    // 8 · checkout
    await t.scrollUntilVisible(find.textContaining('הזמן עכשיו'), 250,
        scrollable: cartScroll);
    expect(find.text('סה"כ לתשלום'), findsOneWidget);
    await t.tap(find.textContaining('הזמן עכשיו'));
    await t.pumpAndSettle();
    expect(find.text('אישור הזמנה'), findsOneWidget);

    // 9 · confirm the order
    await t.tap(find.text('אישור הזמנה'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('אושרה'), findsAtLeastNWidgets(1));
  }

  for (final c in cases) {
    testWidgets('journey · ${c.$1} — ${c.$2}', (t) async {
      await runJourney(t, c.$1, c.$2);
    });
  }

  // ── catalog-wide sheet render sweep ─────────────────────────────────────
  // One product per distinct category (all 69), fully scrolled, asserting the
  // product sheet renders with no overflow/render error for any category's
  // layout. (This is what catches _RelatedCard-style overflows broadly.)
  testWidgets('every category product sheet renders without overflow',
      (t) async {
    final seen = <String>{};
    final perCategory = [
      for (final p in kLipskeyCatalog)
        if (seen.add(p.categoryHe)) p,
    ];

    final bad = <String>[];
    for (final p in perCategory) {
      final cat =
          kLipskeyCatalog.where((x) => x.categoryHe == p.categoryHe).toList();
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LipskeyProductSheet(product: p, categoryProducts: cat),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      String? err = t.takeException()?.toString();

      // Scroll the whole sheet so every (lazy) section is laid out.
      final scroll = find.byType(Scrollable);
      if (scroll.evaluate().isNotEmpty) {
        for (var i = 0; i < 10 && err == null; i++) {
          await t.drag(scroll.first, const Offset(0, -350));
          await t.pump();
          err = t.takeException()?.toString();
        }
      }
      if (err != null) bad.add('${p.categoryHe} (#${p.sku}): $err');
    }

    expect(bad, isEmpty,
        reason: 'product sheets with render errors:\n${bad.join('\n')}');
  });

  // ── HARD sweep ──────────────────────────────────────────────────────────
  // Every one of the 935 products, under the app's largest text scale (1.15 =
  // "טקסט גדול") on a narrow small-phone (340×680) — the real stress that
  // breaks fixed-height layouts. Fully scrolled; asserts no overflow anywhere.
  testWidgets('HARD · all 935 sheets render at large text + narrow phone',
      (t) async {
    await t.binding.setSurfaceSize(const Size(340, 680));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final bad = <String>[];
    for (final p in kLipskeyCatalog) {
      final cat =
          kLipskeyCatalog.where((x) => x.categoryHe == p.categoryHe).toList();
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => MediaQuery(
                data: MediaQuery.of(ctx)
                    .copyWith(textScaler: const TextScaler.linear(1.15)),
                child: Scaffold(
                  body:
                      LipskeyProductSheet(product: p, categoryProducts: cat),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      String? err = t.takeException()?.toString();
      final scroll = find.byType(Scrollable);
      if (scroll.evaluate().isNotEmpty) {
        for (var i = 0; i < 8 && err == null; i++) {
          await t.drag(scroll.first, const Offset(0, -400));
          await t.pump();
          err = t.takeException()?.toString();
        }
      }
      if (err != null) {
        bad.add('${p.categoryHe} #${p.sku}: ${err.split('\n').first}');
      }
    }

    expect(bad, isEmpty,
        reason: '${bad.length}/935 sheets overflow under large text + narrow '
            'width:\n${bad.take(25).join('\n')}');
  });
}
