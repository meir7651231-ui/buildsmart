import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/test_harness/types.dart';

/// מאתר (finder) grouping + forgiving product search — the same guarantees
/// enforced by test/wiring_test.dart, mirrored here so the in-app
/// "רגרסיה מלאה" button covers them too. Reported under the catalog category.
List<TestResult> testFinder() {
  final results = <TestResult>[];
  final cats = {for (final p in kLipskeyCatalog) p.categoryHe};
  final named = kFinderGroups.where((g) => g.cats.isNotEmpty).toList();

  LipskeyCatalogProduct? findBy(bool Function(LipskeyCatalogProduct) f) {
    for (final p in kLipskeyCatalog) {
      if (f(p)) return p;
    }
    return null;
  }

  // ── groups ────────────────────────────────────────────────────────────────
  final owner = <String, String>{};
  final overlaps = <String>[];
  for (final g in named) {
    for (final c in g.cats) {
      if (owner.containsKey(c)) overlaps.add('$c (${owner[c]}/${g.label})');
      owner[c] = g.label;
    }
  }
  results.add(TestResult(
    id: 'finder:groups',
    category: TestCategory.catalog,
    label: 'מאתר — קבוצות',
    area: 'מאתר',
    checks: [
      TestCheck(
        name: 'קבוצות זרות (אין קטגוריה בשתי קבוצות)',
        pass: overlaps.isEmpty,
        expected: '0',
        got: '${overlaps.length}',
        detail: overlaps.take(3).join(' · '),
      ),
      TestCheck(
        name: 'קיימת קבוצת "אחר" (catch-all)',
        pass: kFinderGroups.any((g) => g.cats.isEmpty),
      ),
    ],
  ));

  // ── curated sub-types ───────────────────────────────────────────────────────
  final orphans = <String>[];
  final dupLabels = <String>[];
  final notInGroup = <String>[];
  for (final e in kFinderSubs.entries) {
    final group = named.firstWhere((g) => g.label == e.key,
        orElse: () => const FinderGroup('', '', {}));
    final covered = {for (final s in e.value) ...s.cats};
    final withProducts = group.cats.where(cats.contains).toSet();
    orphans.addAll(withProducts.difference(covered).map((c) => '${e.key}:$c'));
    final labels = [for (final s in e.value) s.label];
    if (labels.toSet().length != labels.length) dupLabels.add(e.key);
    for (final s in e.value) {
      for (final c in s.cats) {
        if (!group.cats.contains(c)) notInGroup.add('${e.key}:$c');
      }
    }
  }
  results.add(TestResult(
    id: 'finder:subs',
    category: TestCategory.catalog,
    label: 'מאתר — תת-סוגים מנוהלים',
    area: 'מאתר',
    checks: [
      TestCheck(
        name: 'מכסים כל קטגוריה עם מוצרים (אין יתום)',
        pass: orphans.isEmpty,
        expected: '0',
        got: '${orphans.length}',
        detail: orphans.take(3).join(' · '),
      ),
      TestCheck(
        name: 'תוויות ייחודיות (אין "ברזים ברזים")',
        pass: dupLabels.isEmpty,
        detail: dupLabels.join(' · '),
      ),
      TestCheck(
        name: 'קטגוריות תת-סוג שייכות לקבוצה',
        pass: notInGroup.isEmpty,
        detail: notInGroup.take(3).join(' · '),
      ),
    ],
  ));

  // ── forgiving search ────────────────────────────────────────────────────────
  final searchChecks = <TestCheck>[];
  final kitchen = findBy((p) => p.categoryHe == 'ברזי מטבח');
  if (kitchen != null) {
    searchChecks.add(TestCheck(
      name: 'מילת קטגוריה מוצאת ("מטבח")',
      pass: catalogProductMatchesQuery(kitchen, 'מטבח'),
    ));
    searchChecks.add(TestCheck(
      name: 'נפילה רכה AND→OR ("מטבח זזזזז")',
      pass: !catalogProductMatchesQuery(kitchen, 'מטבח זזזזז') &&
          catalogProductMatchesQuery(kitchen, 'מטבח זזזזז', requireAll: false),
    ));
  }
  final seat = findBy((p) => p.categoryHe == 'מושבי אסלה');
  final connector = findBy((p) => p.categoryHe == 'מסעפים וחיבורי אסלה');
  if (seat != null && connector != null) {
    searchChecks.add(TestCheck(
      name: '"שירותים" מדויק (אסלה כן, מחבר לא)',
      pass: catalogProductMatchesQuery(seat, 'שירותים') &&
          !catalogProductMatchesQuery(connector, 'שירותים'),
    ));
    searchChecks.add(TestCheck(
      name: 'דירוג: התאמת שם > מילה נרדפת',
      pass: searchRelevance(seat, 'מושב') > searchRelevance(seat, 'שירותים'),
    ));
  }
  final colored = findBy((p) => (p.color ?? '').trim().isNotEmpty);
  if (colored != null) {
    searchChecks.add(TestCheck(
      name: 'חיפוש לפי צבע',
      pass: catalogProductMatchesQuery(colored, colored.color!),
    ));
  }
  results.add(TestResult(
    id: 'finder:search',
    category: TestCategory.catalog,
    label: 'חיפוש מוצרים סלחני',
    area: 'מאתר',
    checks: searchChecks,
  ));

  return results;
}
