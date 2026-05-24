import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/test_harness/types.dart';

const _validPersonaIds = <String>{
  'contractor',
  'manager',
  'store',
  'courier',
  'worker',
};

List<TestResult> testDsync() {
  final checks = <TestCheck>[];

  void add(String name, bool pass, {String? expected, String? got}) {
    checks.add(TestCheck(name: name, pass: pass, expected: expected, got: got));
  }

  add(
    'kPersonas מכיל 5 דמויות',
    kPersonas.length == 5,
    expected: '5',
    got: '${kPersonas.length}',
  );

  for (final p in kPersonas) {
    add(
      'persona id חוקי: ${p.id}',
      _validPersonaIds.contains(p.id),
      expected: _validPersonaIds.join('|'),
      got: p.id,
    );
  }

  add(
    'kCatalogCats אינו ריק',
    kCatalogCats.isNotEmpty,
    got: '${kCatalogCats.length}',
  );

  for (final cat in kCatalogCats) {
    add(
      'קטגוריה ${cat.id} עם title',
      cat.title.isNotEmpty,
      got: cat.title,
    );
    add(
      'קטגוריה ${cat.id} עם emoji',
      cat.emoji.isNotEmpty,
      got: cat.emoji,
    );
  }

  add(
    'kSmartProducts אינו ריק',
    kSmartProducts.isNotEmpty,
    got: '${kSmartProducts.length}',
  );

  add(
    'kSmartTreeCats אינו ריק',
    kSmartTreeCats.isNotEmpty,
    got: '${kSmartTreeCats.length}',
  );

  // Every smart product's category must exist in kSmartTreeCats
  final treeCats = kSmartTreeCats.toSet();
  final orphans = kSmartProducts.where((p) => !treeCats.contains(p.cat));
  add(
    'כל מוצר חכם משתייך לקטגוריה ידועה',
    orphans.isEmpty,
    expected: '0 יתומים',
    got: '${orphans.length}',
  );

  // smartProductsForCat must return non-empty for every cat
  for (final cat in kSmartTreeCats) {
    final list = smartProductsForCat(cat);
    add(
      'smartProductsForCat("$cat") מחזיר ≥1',
      list.isNotEmpty,
      got: '${list.length}',
    );
  }

  return [
    TestResult(
      id: 'dsync:core',
      category: TestCategory.dsync,
      label: 'סנכרון נתונים-תצוגה (אינווריאנטים)',
      area: 'אינווריאנטים',
      checks: checks,
    ),
  ];
}
