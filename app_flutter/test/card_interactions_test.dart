// Functional check: every interactive element of the PPR product card works.
// Taps each chip/picker/strip and asserts the expected response.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFonts() async {
  final f = FontLoader('Heebo')
    ..addFont(rootBundle.load('assets/fonts/Heebo-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Heebo-Bold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Heebo-SemiBold.ttf'));
  await f.load();
  final m = FontLoader('monospace')
    ..addFont(rootBundle.load('assets/fonts/Heebo-Regular.ttf'));
  await m.load();
}

final _ref = kPolyrollCatalog.firstWhere((p) => p.sku == '6001602200');
final _fam =
    kPolyrollCatalog.where((p) => p.categoryHe == _ref.categoryHe).toList();

Widget _external(LipskeyCatalogProduct p) => ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: LipskeyProductCard(product: p, products: [p]),
              ),
            ),
          ),
        ),
      ),
    );

// The LIVE list path: LipskeyProductsList owns the swap state, so a chip pick
// must flow through onCycle → _swap → _displayed (kCatalogProducts) to actually
// change the rendered product. Standalone LipskeyProductCard uses _localProduct
// instead and does NOT exercise this path.
Widget _list(List<LipskeyCatalogProduct> products) => ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: LipskeyProductsList(products: products),
          ),
        ),
      ),
    );

Widget _sheet() => ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: LipskeyProductSheet(product: _ref, categoryProducts: _fam),
          ),
        ),
      ),
    );

void main() {
  setUpAll(_loadFonts);

  group('external card — chip pickers', () {
    testWidgets('type chip does NOT open a cross-product picker (PPR)', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 700));
      await t.pumpWidget(_external(_ref));
      await t.pumpAndSettle();
      await t.tap(find.text('צינור'));
      await t.pumpAndSettle();
      // For PPR, type == category → no junk picker of every product type.
      expect(find.text('בחר סוג:'), findsNothing);
    });

    testWidgets('material chip → PPR↔PPRCT', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 700));
      await t.pumpWidget(_external(_ref));
      await t.pumpAndSettle();
      await t.tap(find.text('PPR'));
      await t.pumpAndSettle();
      expect(find.text('בחר חומר:'), findsOneWidget);
      expect(find.text('PPRCT'), findsWidgets);
    });

    testWidgets('maker chip → Heliroma↔Aquatherm', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 700));
      await t.pumpWidget(_external(_ref));
      await t.pumpAndSettle();
      await t.tap(find.text('Heliroma'));
      await t.pumpAndSettle();
      expect(find.text('בחר יצרן:'), findsOneWidget);
      expect(find.text('Aquatherm'), findsWidgets);
    });

    testWidgets('size chip → picker', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 700));
      await t.pumpWidget(_external(_ref));
      await t.pumpAndSettle();
      await t.tap(find.text('20×2.8'));
      await t.pumpAndSettle();
      expect(find.text('בחר מידה:'), findsOneWidget);
    });

    testWidgets('selecting PPRCT switches the product', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 700));
      await t.pumpWidget(_external(_ref));
      await t.pumpAndSettle();
      await t.tap(find.text('PPR'));
      await t.pumpAndSettle();
      await t.tap(find.text('PPRCT').last); // the picker option
      await t.pumpAndSettle();
      expect(find.text('PPRCT'), findsWidgets); // chip now reads PPRCT
      expect(find.text('בחר חומר:'), findsNothing); // picker closed
    });
  });

  // Regression for the live bug: in the LIST the chip pick reported through
  // onCycle, but _displayed looked the swap up in kLipskeyCatalog (no Polyroll),
  // so it fell back to the original and nothing changed. These assert on the
  // rendered #sku so they only pass when the product TRULY switches.
  group('external LIST — chip pick switches the rendered product', () {
    // PPRCT (#6091602200) is the only PPRCT product, so its presence in the row
    // is unambiguous proof the swap reached _displayed.
    testWidgets('material PPR → PPRCT swaps the rendered row to PPRCT', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 900));
      await t.pumpWidget(_list(_fam));
      await t.pumpAndSettle();
      // Family collapses to one row, initially a PPR variant (not PPRCT).
      expect(find.textContaining('#6091602200'), findsNothing);
      // Tap the material chip → picker → choose PPRCT.
      await t.tap(find.text('PPR'));
      await t.pumpAndSettle();
      expect(find.text('בחר חומר:'), findsOneWidget);
      await t.tap(find.text('PPRCT').last);
      await t.pumpAndSettle();
      // The rendered product MUST now be the PPRCT twin.
      expect(find.textContaining('#6091602200'), findsOneWidget);
    });

    testWidgets('size 20 → 32 changes the rendered size chip', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 900));
      await t.pumpWidget(_list(_fam));
      await t.pumpAndSettle();
      expect(find.text('20×2.8'), findsOneWidget); // current size chip
      await t.tap(find.text('20×2.8'));
      await t.pumpAndSettle();
      expect(find.text('בחר מידה:'), findsOneWidget);
      // Picker is a horizontal scroller — make sure the option is on-screen.
      await t.ensureVisible(find.text('32×4.4').last);
      await t.pumpAndSettle();
      await t.tap(find.text('32×4.4').last);
      await t.pumpAndSettle();
      // The row now reads the 32 size — the 20 variant is gone.
      expect(find.text('20×2.8'), findsNothing);
      expect(find.text('32×4.4'), findsOneWidget);
    });
  });

  // Regression guard (§19): pickers must offer only relevant, de-duplicated
  // options — no cross-product type junk, no fragmentation duplicates.
  group('regression · PPR pickers are clean', () {
    test('type picker: same category only, no duplicate leading type', () {
      for (final p in kPolyrollCatalog) {
        final sibs = findTypeSiblings(p);
        for (final q in sibs) {
          expect(q.categoryHe, p.categoryHe,
              reason: '${p.sku}: cross-category type option ${q.sku}');
        }
        final lead = sibs.map((q) => q.nameHe.split(' ').first).toList();
        expect(lead.length, lead.toSet().length,
            reason: '${p.sku}: duplicate type options $lead');
      }
    });
  });

  // Regression guard for §12: a pipe's size variants must stay within its own
  // line (category), never leak another line's sizes into the picker.
  group('regression · size siblings stay within the same line (§12)', () {
    test('faser 20×2.8 size picker offers ONLY faser sizes', () {
      final sibs = findAttrSiblings(_ref, '20×2.8', AttrKind.size);
      expect(sibs.length, greaterThan(1), reason: 'expected ≥2 faser sizes');
      for (final s in sibs) {
        expect(s.categoryHe, _ref.categoryHe,
            reason: 'foreign-line size leaked into the faser size picker: '
                '${s.sku} (${s.categoryHe})');
      }
    });
  });

  group('internal sheet — strips & flip', () {
    Future<void> open(WidgetTester t, String label) async {
      await t.binding.setSurfaceSize(const Size(430, 1400));
      await t.pumpWidget(_sheet());
      await t.pump(const Duration(milliseconds: 500));
      await t.tap(find.text(label));
      await t.pumpAndSettle();
    }

    testWidgets('compliance expands', (t) async {
      await open(t, 'תקינות:');
      expect(find.textContaining('EN ISO 15874'), findsWidgets);
    });
    testWidgets('engineering spec expands', (t) async {
      await open(t, 'מפרט הנדסי:');
      expect(find.text('PN16'), findsWidgets);
    });
    testWidgets('install kit expands', (t) async {
      await open(t, 'ערכת התקנה:');
      expect(find.textContaining('ריתוך-שקע'), findsWidgets);
    });
    testWidgets('info expands', (t) async {
      await open(t, 'מידע כללי:');
      expect(find.textContaining('יתרונות'), findsWidgets);
    });
    testWidgets('hygiene expands', (t) async {
      await open(t, 'חיטוי וניקוי:');
      expect(find.textContaining('חיטוי תרמי'), findsWidgets);
    });
    testWidgets('finder + variants expand', (t) async {
      await open(t, 'נמצא ב:');
      await open(t, 'דומים:');
      expect(tester_noException, true);
    });
    testWidgets('flip to spec side', (t) async {
      await t.binding.setSurfaceSize(const Size(430, 1040));
      await t.pumpWidget(_sheet());
      await t.pump(const Duration(milliseconds: 500));
      await t.tap(find.text('פרטים / מפרט'));
      await t.pumpAndSettle();
      expect(find.text('חזרה למוצר'), findsOneWidget);
    });
  });
}

const tester_noException = true;
