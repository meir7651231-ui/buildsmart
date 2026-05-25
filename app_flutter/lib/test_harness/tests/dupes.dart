import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/test_harness/types.dart';

List<TestResult> testDupes() {
  final checks = <TestCheck>[];

  // No two catalog categories share an id
  final catIds = kCatalogCats.map((c) => c.id).toList();
  final catIdSet = catIds.toSet();
  checks.add(TestCheck(
    name: 'אין כפילות ב-id של kCatalogCats',
    pass: catIdSet.length == catIds.length,
    expected: '${catIds.length}',
    got: '${catIdSet.length}',
  ));

  // No two catalog categories share a title
  final byTitle = <String, List<String>>{};
  for (final c in kCatalogCats) {
    (byTitle[c.title] ??= []).add(c.id);
  }
  final titleClashes = byTitle.entries.where((e) => e.value.length > 1).toList();
  checks.add(TestCheck(
    name: 'אין קטגוריות בעלות title זהה',
    pass: titleClashes.isEmpty,
    detail: titleClashes.isEmpty
        ? ''
        : titleClashes
            .take(3)
            .map((e) => '"${e.key}" → ${e.value.join(', ')}')
            .join(' · '),
  ));

  // No two smart products share a key
  final keys = kSmartProducts.map((p) => p.key).toList();
  final keySet = keys.toSet();
  checks.add(TestCheck(
    name: 'אין כפילות ב-key של kSmartProducts',
    pass: keySet.length == keys.length,
    expected: '${keys.length}',
    got: '${keySet.length}',
  ));

  // No two smart products share a name+cat
  final byNameCat = <String, List<String>>{};
  for (final p in kSmartProducts) {
    (byNameCat['${p.cat}::${p.name}'] ??= []).add(p.key);
  }
  final ncClashes =
      byNameCat.entries.where((e) => e.value.length > 1).toList();
  checks.add(TestCheck(
    name: 'אין מוצרים חכמים עם name+cat זהה',
    pass: ncClashes.isEmpty,
    detail: ncClashes.isEmpty
        ? ''
        : ncClashes
            .take(3)
            .map((e) => '${e.key} → ${e.value.join(', ')}')
            .join(' · '),
  ));

  // Within each smart product, accessory names are unique
  final accDupes = <String>[];
  for (final p in kSmartProducts) {
    final accNames = p.acc.map((a) => a.name).toList();
    if (accNames.toSet().length != accNames.length) {
      accDupes.add(p.key);
    }
  }
  checks.add(TestCheck(
    name: 'אביזרים בתוך כל מוצר חכם — ללא כפילות שמות',
    pass: accDupes.isEmpty,
    expected: '0 מוצרים פגומים',
    got: accDupes.isEmpty ? '0' : '${accDupes.length}: ${accDupes.take(3).join(", ")}',
  ));

  // ── kBrands uniqueness ────────────────────────────────────────────────────
  final brandIds = kBrands.map((b) => b.id).toList();
  final brandIdSet = brandIds.toSet();
  checks.add(TestCheck(
    name: 'אין כפילות ב-id של kBrands',
    pass: brandIdSet.length == brandIds.length,
    expected: '${brandIds.length}',
    got: '${brandIdSet.length}',
  ));

  final brandNames = kBrands.map((b) => b.name).toList();
  final brandNameSet = brandNames.toSet();
  checks.add(TestCheck(
    name: 'אין כפילות ב-name של kBrands',
    pass: brandNameSet.length == brandNames.length,
    expected: '${brandNames.length}',
    got: '${brandNameSet.length}',
  ));

  // ── kCatalogTree node id uniqueness ──────────────────────────────────────
  final nodeIds = <String>[];
  void walkTree(CatalogNode n) {
    nodeIds.add(n.id);
    for (final c in n.children) {
      walkTree(c);
    }
  }
  for (final n in kCatalogTree) {
    walkTree(n);
  }
  final nodeIdSet = nodeIds.toSet();
  checks.add(TestCheck(
    name: 'אין כפילות ב-id של nodes בעץ הקטלוג',
    pass: nodeIdSet.length == nodeIds.length,
    expected: '${nodeIds.length}',
    got: '${nodeIdSet.length}',
  ));

  // ── kCatalogTree leaf lipskeyCategory uniqueness ─────────────────────────
  final leaves = allLeaves();
  final lipskeyCategories = <String>[];
  for (final l in leaves) {
    if (l.lipskeyCategory != null) lipskeyCategories.add(l.lipskeyCategory!);
  }
  final lipskeyCatSet = lipskeyCategories.toSet();
  checks.add(TestCheck(
    name: 'אין כפילות ב-lipskeyCategory בין עלים',
    pass: lipskeyCatSet.length == lipskeyCategories.length,
    expected: '${lipskeyCategories.length}',
    got: '${lipskeyCatSet.length}',
  ));

  return [
    TestResult(
      id: 'dupes:core',
      category: TestCategory.dupes,
      label: 'בדיקת זהויות וכפילויות',
      area: 'נתונים',
      checks: checks,
    ),
  ];
}
