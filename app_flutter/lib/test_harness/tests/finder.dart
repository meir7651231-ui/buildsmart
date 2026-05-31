import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';
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
    label: 'בית — קבוצות',
    area: 'בית',
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
      TestCheck(
        name: 'לכל קבוצה יש תיאור (desc)',
        pass: kFinderGroups.every((g) => g.desc.trim().isNotEmpty),
        expected: '${kFinderGroups.length}',
        got: '${kFinderGroups.where((g) => g.desc.trim().isNotEmpty).length}',
        detail: kFinderGroups
            .where((g) => g.desc.trim().isEmpty)
            .map((g) => g.label)
            .join(' · '),
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
    label: 'בית — תת-סוגים מנוהלים',
    area: 'בית',
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
    area: 'בית',
    checks: searchChecks,
  ));

  // ── size axis: numeric, family-coherent, no false-positives ──────────────
  final sizeChecks = <TestCheck>[];
  // 1. lexical 200·25·250·30 → numeric mm-group then cm-group
  final mixed = [
    SizeToken(label: '200 מ"מ', family: SizeFamily.mm, mm: 200),
    SizeToken(label: '25 ס"מ',  family: SizeFamily.cm, mm: 250),
    SizeToken(label: '250 מ"מ', family: SizeFamily.mm, mm: 250),
    SizeToken(label: '30 ס"מ',  family: SizeFamily.cm, mm: 300),
  ];
  sortSizeTokens(mixed);
  sizeChecks.add(TestCheck(
    name: 'מסנן גודל — מ"מ קודם ס"מ, מספרי',
    pass: mixed.map((t) => t.label).join('|') ==
        '200 מ"מ|250 מ"מ|25 ס"מ|30 ס"מ',
    expected: '200|250|25|30 (mm→cm)',
    got: mixed.map((t) => t.label).join('|'),
  ));
  // 2. "25 שנים" is not a size token
  sizeChecks.add(TestCheck(
    name: 'גודל — "25 שנים אחריות" אינו chip',
    pass: parseSizeTokens('ברז 25 שנים אחריות').isEmpty,
  ));
  // 3. angles are their own axis
  sizeChecks.add(TestCheck(
    name: 'גודל — 45° אינו chip גודל (זווית)',
    pass: parseSizeTokens('ברך 45°').isEmpty &&
        parseAngleTokens('ברך 45°').isNotEmpty,
  ));
  // 4. P13: rare fraction folds to ASCII for canvaskit
  sizeChecks.add(TestCheck(
    name: 'גודל — ⅜" מתקפל ל-3/8" (canvaskit font)',
    pass: parseSizeTokens('ברך ⅜"').first.label == '3/8"',
  ));
  results.add(TestResult(
    id: 'finder:size',
    category: TestCategory.catalog,
    label: 'מסנן גודל — נורמליזציה',
    area: 'בית',
    checks: sizeChecks,
  ));

  return results;
}
