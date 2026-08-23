// Derived-rows contract (clean-100 slice), widget tier: with a COMPANY
// catalog live, the 'קטגוריות' browse shows the imported categories (with
// counts) instead of the const plumbing taxonomy, and a derived row drills
// into the real product list — never the "בקרוב" placeholder. With the
// overlay OFF the default world is untouched (demo: verbatim const rows;
// profiled clean run: the honest vacuous blank).
//
// Harness = widget_test's own idiom: BuildSmartApp + enter a department +
// drive catalogSectionProvider to 'קטגוריות' (the keyboard-list seam).

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/departments_screen.dart'
    show homeDepartmentProvider;
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/state/app_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<LipskeyCatalogProduct> _company = [
  LipskeyCatalogProduct(
    sku: 'C-1', nameHe: 'ברז נשלף דגם א', nameEn: '', categoryHe: 'ברזים',
    categoryEn: '', categoryEmoji: '🚰', page: 0, brand: '',
  ),
  LipskeyCatalogProduct(
    sku: 'C-2', nameHe: 'ברז קיר דגם ב', nameEn: '', categoryHe: 'ברזים',
    categoryEn: '', categoryEmoji: '🚰', page: 0, brand: '',
  ),
  LipskeyCatalogProduct(
    sku: 'C-3', nameHe: 'כיור גרניט שחור', nameEn: '', categoryHe: 'כיורים',
    categoryEn: '', categoryEmoji: '', page: 0, brand: '',
  ),
];

void main() {
  tearDown(() => setCompanyCatalog(null));

  Future<ProviderContainer> openCategories(WidgetTester t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
    await t.pumpAndSettle();
    final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));
    // The browse renders inside an entered department (widget_test idiom).
    c.read(homeDepartmentProvider.notifier).state = 'אינסטלציה';
    c.read(catalogTreePathProvider.notifier).state = const [];
    c.read(catalogSectionProvider.notifier).state = 'קטגוריות';
    await t.pumpAndSettle();
    return c;
  }

  testWidgets('company overlay live → rows ARE the imported categories',
      (t) async {
    setCompanyCatalog(_company);
    await openCategories(t);
    expect(find.text('ברזים'), findsOneWidget);
    expect(find.text('כיורים'), findsOneWidget);
    expect(find.text('2 מוצרים'), findsOneWidget,
        reason: 'summary derives from the imported list');
    expect(find.text('ניקוז וצנרת'), findsNothing,
        reason: 'const plumbing taxonomy must not leak over a company catalog');
    expect(find.text('בקרוב'), findsNothing);
  });

  testWidgets('overlay OFF → the default world is untouched', (t) async {
    await openCategories(t);
    if (catalogEmptyForProfile(kAppProfile)) {
      // profiled clean run, nothing imported: the honest vacuous blank —
      // never the 0-count plumbing maze.
      expect(find.text('ברזים וכיורים'), findsNothing);
    } else {
      // define-less suite (= demo): the verbatim const rows, byte-identical.
      expect(find.text('ברזים וכיורים'), findsOneWidget);
    }
  });

  testWidgets('tapping a derived row drills to the real product list',
      (t) async {
    setCompanyCatalog(_company);
    await openCategories(t);
    await t.tap(find.text('ברזים'));
    await t.pumpAndSettle();
    expect(find.text('בקרוב'), findsNothing,
        reason: 'a derived category is a PRODUCT leaf, not a placeholder');
    expect(find.textContaining('ברז נשלף'), findsWidgets,
        reason: 'the imported products render in the drill list');
  });
}
