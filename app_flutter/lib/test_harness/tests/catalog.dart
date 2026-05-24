import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/test_harness/types.dart';

/// Catalog data-integrity — same checks as scripts/catalog_qa.py `audit`,
/// run in-app so every change is gated like the rest of the regression suite.
/// HARD failures: garbled · empty · duplicate SKU · unmapped category.
/// SOFT (reported, not failing): no-size · no-image · same-name variants.
List<TestResult> testCatalog() {
  final results = <TestResult>[];

  // ── HARD: data validity ───────────────────────────────────────────────────
  final hard = <TestCheck>[];
  final products = kLipskeyCatalog;

  // 1. no empty names
  final empty = products.where((p) => p.nameHe.trim().isEmpty).toList();
  hard.add(TestCheck(
    name: 'אין שמות ריקים',
    pass: empty.isEmpty,
    expected: '0',
    got: '${empty.length}',
    detail: empty.take(3).map((p) => p.sku).join(', '),
  ));

  // 2. no garbled names (packaging text / gershayim / merged fields)
  bool garbled(String n) =>
      n.contains('|') ||
      n.contains('כמות') ||
      n.contains('״') ||
      n.contains('“') ||
      _balancedParens(n) == false;
  final bad = products.where((p) => garbled(p.nameHe)).toList();
  hard.add(TestCheck(
    name: 'אין שמות פגומים (זבל/גרשיים/סוגריים)',
    pass: bad.isEmpty,
    expected: '0',
    got: '${bad.length}',
    detail: bad.take(3).map((p) => '${p.sku}: ${p.nameHe}').join(' · '),
  ));

  // 3. digit glued to Hebrew letter (broken RTL scrape)
  final stuck = products.where((p) => _hasStuckDigit(p.nameHe)).toList();
  hard.add(TestCheck(
    name: 'אין מספר תקוע במילה',
    pass: stuck.isEmpty,
    expected: '0',
    got: '${stuck.length}',
    detail: stuck.take(3).map((p) => '${p.sku}: ${p.nameHe}').join(' · '),
  ));

  // 4. unique SKU
  final seen = <String, int>{};
  for (final p in products) {
    seen[p.sku] = (seen[p.sku] ?? 0) + 1;
  }
  final dups = seen.entries.where((e) => e.value > 1).toList();
  hard.add(TestCheck(
    name: 'מק"ט ייחודי (אין כפילויות)',
    pass: dups.isEmpty,
    expected: '0',
    got: '${dups.length}',
    detail: dups.take(5).map((e) => e.key).join(', '),
  ));

  // 5. required fields present
  final missing = products
      .where((p) => p.sku.isEmpty || p.categoryHe.isEmpty)
      .toList();
  hard.add(TestCheck(
    name: 'כל מוצר עם sku + categoryHe',
    pass: missing.isEmpty,
    expected: '0',
    got: '${missing.length}',
  ));

  // 6. every product category is reachable in the drill tree
  final treeCats = _treeLipskeyCategories();
  final prodCats = products.map((p) => p.categoryHe).toSet();
  final unmapped = prodCats.difference(treeCats);
  hard.add(TestCheck(
    name: 'כל קטגוריה ממופה בעץ הצלילה',
    pass: unmapped.isEmpty,
    expected: '0 לא-ממופות',
    got: '${unmapped.length}',
    detail: unmapped.take(5).join(', '),
  ));

  results.add(TestResult(
    id: 'catalog:hard',
    category: TestCategory.catalog,
    label: 'תקינות נתוני הקטלוג (${products.length} מוצרים)',
    area: 'שגיאות קשות',
    checks: hard,
  ));

  // ── SOFT: completeness (informational — pass, but report counts) ──────────
  final soft = <TestCheck>[];
  final noSize = products.where((p) => !_hasSize(p.nameHe)).length;
  final noImg = products.where((p) => p.imageFile == null).length;
  soft.add(TestCheck(
    name: 'מוצרים עם גודל DN (לתאימות)',
    pass: true,
    got: '${products.length - noSize}/${products.length}',
    detail: 'חסרים: $noSize',
  ));
  soft.add(TestCheck(
    name: 'מוצרים עם תמונה',
    pass: true,
    got: '${products.length - noImg}/${products.length}',
    detail: 'חסרים: $noImg',
  ));
  soft.add(TestCheck(
    name: 'מספר קטגוריות',
    pass: true,
    got: '${prodCats.length}',
  ));

  results.add(TestResult(
    id: 'catalog:coverage',
    category: TestCategory.catalog,
    label: 'כיסוי ושלמות (לא חוסם)',
    area: 'שלמות',
    checks: soft,
  ));

  // ── מנוע התאימות — רגרסיה (צעדים 65–66) ───────────────────────────────────
  final compat = <TestCheck>[];
  // reducer with two ends
  final reducer = products.firstWhere(
    (p) => lipskeyConnectionSizes(p.nameHe).length >= 2,
    orElse: () => products.first,
  );
  compat.add(TestCheck(
    name: 'מוצר-מעבר מזוהה עם ≥2 קצוות',
    pass: reducer.connectionSizes.length >= 2,
    got: '${reducer.sku}: ${reducer.connectionSizes}',
  ));
  // a DN50 product finds compatible cross-category parts
  bool fitsDN50(LipskeyCatalogProduct p) => p.connectionSizes.contains('50');
  final dn50 = products.where(fitsDN50).toList();
  final cats50 = dn50.map((p) => p.categoryHe).toSet();
  compat.add(TestCheck(
    name: 'DN50 מתפרס על כמה קטגוריות (תאימות חוצה)',
    pass: cats50.length >= 3,
    expected: '≥3 קטגוריות',
    got: '${cats50.length} קטגוריות · ${dn50.length} חלקים',
  ));
  // packaging/length numbers must NOT be read as sizes
  compat.add(TestCheck(
    name: 'כמות/אורך אינם נקראים כמידה',
    pass: lipskeyConnectionSizes('צינור אורך 200 ס"מ 20 כמות באריזה').isEmpty,
    detail: '${lipskeyConnectionSizes('צינור אורך 200 ס"מ 20 כמות באריזה')}',
  ));

  results.add(TestResult(
    id: 'catalog:compat',
    category: TestCategory.catalog,
    label: 'מנוע תאימות — מה מתחבר למה',
    area: 'תאימות',
    checks: compat,
  ));

  return results;
}

bool _balancedParens(String n) => '('.allMatches(n).length == ')'.allMatches(n).length;

final _stuck = RegExp(r'\d[א-ת]|[א-ת]\d');
bool _hasStuckDigit(String n) => _stuck.hasMatch(n);

final _size = RegExp(r'DN\s?\d+|\d+/\d+|\d+["׳״]|\b(?:32|40|50|60|75|90|110|130|160|200)\b');
bool _hasSize(String n) => _size.hasMatch(n);

Set<String> _treeLipskeyCategories() {
  final out = <String>{};
  void walk(CatalogNode n) {
    if (n.lipskeyCategory != null) out.add(n.lipskeyCategory!);
    for (final c in n.children) {
      walk(c);
    }
  }

  for (final n in kCatalogTree) {
    walk(n);
  }
  return out;
}
