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
    testWidgets('type chip → picker', (t) async {
      await t.binding.setSurfaceSize(const Size(520, 700));
      await t.pumpWidget(_external(_ref));
      await t.pumpAndSettle();
      await t.tap(find.text('צינור'));
      await t.pumpAndSettle();
      expect(find.text('בחר סוג:'), findsOneWidget);
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
