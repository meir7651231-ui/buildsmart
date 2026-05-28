import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
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
  return [
    _coreChecks(),
    _brandsAndTreeChecks(),
  ];
}

TestResult _coreChecks() {
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
    add('קטגוריה ${cat.id} עם title', cat.title.isNotEmpty, got: cat.title);
    add('קטגוריה ${cat.id} עם emoji', cat.emoji.isNotEmpty, got: cat.emoji);
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

  final treeCats = kSmartTreeCats.toSet();
  final orphans = kSmartProducts.where((p) => !treeCats.contains(p.cat));
  add(
    'כל מוצר חכם משתייך לקטגוריה ידועה',
    orphans.isEmpty,
    expected: '0 יתומים',
    got: '${orphans.length}',
  );

  for (final cat in kSmartTreeCats) {
    final list = smartProductsForCat(cat);
    add(
      'smartProductsForCat("$cat") מחזיר ≥1',
      list.isNotEmpty,
      got: '${list.length}',
    );
  }

  return TestResult(
    id: 'dsync:core',
    category: TestCategory.dsync,
    label: 'סנכרון נתונים-תצוגה (אינווריאנטים)',
    area: 'אינווריאנטים',
    checks: checks,
  );
}

TestResult _brandsAndTreeChecks() {
  final checks = <TestCheck>[];

  void add(
    String name,
    bool pass, {
    String? expected,
    String? got,
    String? detail,
  }) {
    checks.add(
      TestCheck(name: name, pass: pass, expected: expected, got: got, detail: detail),
    );
  }

  // ── kBrands ──────────────────────────────────────────────────────────────
  add('kBrands מכיל ≥1 מותגים', kBrands.isNotEmpty, got: '${kBrands.length}');

  for (final b in kBrands) {
    add('מותג ${b.id}: id לא ריק', b.id.isNotEmpty, got: b.id);
    add('מותג ${b.id}: name לא ריק', b.name.isNotEmpty, got: b.name);
    add('מותג ${b.id}: emoji לא ריק', b.emoji.isNotEmpty, got: b.emoji);
    add(
      'מותג ${b.id}: color != 0',
      b.color != 0,
      got: '0x${b.color.toRadixString(16)}',
    );
  }

  for (final b in kBrands) {
    final found = brandById(b.id);
    add(
      'brandById("${b.id}") מחזיר מותג',
      found != null,
      got: found?.id ?? 'null',
    );
  }

  // ── kCatalogTree ─────────────────────────────────────────────────────────
  add(
    'kCatalogTree מכיל ≥1 קטגוריות ראשיות',
    kCatalogTree.isNotEmpty,
    got: '${kCatalogTree.length}',
  );

  final leaves = allLeaves();
  add('allLeaves() מחזיר ≥1 עלים', leaves.isNotEmpty, got: '${leaves.length}');

  final leavesNoBrands = leaves.where((l) => l.brandIds.isEmpty).toList();
  add(
    'כל עלה בעץ הקטלוג מכיל ≥1 brandId',
    leavesNoBrands.isEmpty,
    expected: '0 עלים בלי מותגים',
    got: '${leavesNoBrands.length}',
    detail: leavesNoBrands.map((l) => l.id).take(3).join(', '),
  );

  final brandIdSet = kBrands.map((b) => b.id).toSet();
  final unknownBrandRefs = <String>[];
  for (final l in leaves) {
    for (final bid in l.brandIds) {
      if (!brandIdSet.contains(bid)) unknownBrandRefs.add('${l.id}→$bid');
    }
  }
  add(
    'כל brandId בעץ הקטלוג קיים ב-kBrands',
    unknownBrandRefs.isEmpty,
    expected: '0 הפניות שבורות',
    got: '${unknownBrandRefs.length}',
    detail: unknownBrandRefs.take(3).join(', '),
  );

  final allIds = <String>[];
  void collectIds(CatalogNode n) {
    allIds.add(n.id);
    for (final c in n.children) {
      collectIds(c);
    }
  }
  for (final n in kCatalogTree) {
    collectIds(n);
  }
  final missingIds = allIds.where((id) => findCatalogNode(id) == null).toList();
  add(
    'findCatalogNode מוצא כל node בעץ',
    missingIds.isEmpty,
    expected: '0 nodes חסרים',
    got: '${missingIds.length}',
    detail: missingIds.take(3).join(', '),
  );

  // ── kLipskeyCatalog ──────────────────────────────────────────────────────
  add(
    'kLipskeyCatalog מכיל ≥1 מוצרים',
    kLipskeyCatalog.isNotEmpty,
    got: '${kLipskeyCatalog.length}',
  );

  var badLipskey = 0;
  for (final p in kLipskeyCatalog) {
    if (p.sku.isEmpty || p.nameHe.isEmpty || p.categoryHe.isEmpty) badLipskey++;
  }
  add(
    'כל מוצר ליפסקי עם sku+nameHe+categoryHe',
    badLipskey == 0,
    expected: '0 פגומים',
    got: '$badLipskey',
  );

  final lipskeyCategoryNames =
      kCatalogProducts.map((p) => p.categoryHe).toSet();
  final leavesWithLipskey = leaves.where((l) => l.lipskeyCategory != null).toList();
  final unmatchedLeaves = leavesWithLipskey
      .where((l) => !lipskeyCategoryNames.contains(l.lipskeyCategory))
      .toList();
  add(
    'כל lipskeyCategory בעלים מצביע לקטגוריה קיימת',
    unmatchedLeaves.isEmpty,
    expected: '0 קטגוריות שבורות',
    got: '${unmatchedLeaves.length}',
    detail: unmatchedLeaves.map((l) => l.lipskeyCategory).take(3).join(', '),
  );

  return TestResult(
    id: 'dsync:brands-tree',
    category: TestCategory.dsync,
    label: 'מותגים, עץ קטלוג וליפסקי',
    area: 'קטלוג',
    checks: checks,
  );
}
