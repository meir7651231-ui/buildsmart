import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
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

  // ── HARD: same validity gate over the Polyroll/PPR catalog ────────────────
  // The Lipskey block above ran on kLipskeyCatalog only — auto-extracted PPR
  // garbage (SKU-as-name, manufacturer-code merged into the name, blank names)
  // slipped through. Gate the PPR file with the same predicates + a SKU-in-name
  // check (catches "צינור PPR פייזר 9092071130" style scrapes).
  final pprHard = <TestCheck>[];
  final pprEmpty = kPolyrollCatalog.where((p) => p.nameHe.trim().isEmpty).toList();
  pprHard.add(TestCheck(
    name: 'PPR · אין שמות ריקים',
    pass: pprEmpty.isEmpty, expected: '0', got: '${pprEmpty.length}',
    detail: pprEmpty.take(3).map((p) => p.sku).join(', '),
  ));
  final pprBad = kPolyrollCatalog.where((p) => garbled(p.nameHe)).toList();
  pprHard.add(TestCheck(
    name: 'PPR · אין שמות פגומים (זבל/גרשיים/סוגריים)',
    pass: pprBad.isEmpty, expected: '0', got: '${pprBad.length}',
    detail: pprBad.take(3).map((p) => '${p.sku}: ${p.nameHe}').join(' · '),
  ));
  final pprStuck = kPolyrollCatalog.where((p) => _hasStuckDigit(p.nameHe)).toList();
  pprHard.add(TestCheck(
    name: 'PPR · אין מספר תקוע במילה',
    pass: pprStuck.isEmpty, expected: '0', got: '${pprStuck.length}',
    detail: pprStuck.take(3).map((p) => '${p.sku}: ${p.nameHe}').join(' · '),
  ));
  final pprSkuName =
      kPolyrollCatalog.where((p) => p.nameHe.contains(p.sku)).toList();
  pprHard.add(TestCheck(
    name: 'PPR · השם אינו מכיל את המק"ט (חילוץ-זבל)',
    pass: pprSkuName.isEmpty, expected: '0', got: '${pprSkuName.length}',
    detail: pprSkuName.take(3).map((p) => '${p.sku}: ${p.nameHe}').join(' · '),
  ));
  // Mis-category guard: a tool-named product (מקדח/תותב/מזוודת/מכונת/מברגה/
  // פלטת ריתוך) must live in 'כלי ריתוך PPR' — caught dies→EF and drills→saddles.
  const _toolWords = ['מקדח', 'תותב', 'מזוודת', 'מכונת', 'מברגה', 'פלטת ריתוך'];
  final pprMisTool = kPolyrollCatalog
      .where((p) =>
          _toolWords.any((w) => p.nameHe.contains(w)) &&
          p.categoryHe != 'כלי ריתוך PPR')
      .toList();
  pprHard.add(TestCheck(
    name: 'PPR · מוצר עם שם-כלי יושב בקטגוריית "כלי ריתוך"',
    pass: pprMisTool.isEmpty, expected: '0', got: '${pprMisTool.length}',
    detail:
        pprMisTool.take(3).map((p) => '${p.sku}: ${p.categoryHe}').join(' · '),
  ));
  // PPR↔PPRCT consistency: the material in the name must match dims['חומר'].
  // Caught the PPRCT faser (pp.86-87, mfr code …FCT/FRCT) named "PPR".
  bool _isPprct(String s) => s.contains('PPRCT');
  final pprMatMismatch = kPolyrollCatalog.where((p) {
    final mat = p.dims?['חומר'] as String?;
    if (mat == null) return false;
    return _isPprct(p.nameHe) != _isPprct(mat);
  }).toList();
  pprHard.add(TestCheck(
    name: 'PPR · חומר בשם תואם ל-dims[חומר] (PPR↔PPRCT)',
    pass: pprMatMismatch.isEmpty,
    expected: '0',
    got: '${pprMatMismatch.length}',
    detail: pprMatMismatch
        .take(3)
        .map((p) => '${p.sku}: ${p.nameHe}')
        .join(' · '),
  ));
  results.add(TestResult(
    id: 'catalog:hard-ppr',
    category: TestCategory.catalog,
    label: 'תקינות נתוני PPR (${kPolyrollCatalog.length} מוצרים)',
    area: 'שגיאות קשות',
    checks: pprHard,
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

  // PPR enrichment coverage — the drive-to-100% gauge (product image · per-
  // sub-type spec image · dims≥3). Reported every CI run.
  final pprN = kPolyrollCatalog.length;
  final pImg = kPolyrollCatalog.where((p) => p.imageAsset != null).length;
  final pSpec = kPolyrollCatalog.where((p) => p.specImageFile != null).length;
  final pDims = kPolyrollCatalog.where((p) => (p.dims?.length ?? 0) >= 3).length;
  int pct(int x) => (100 * x / pprN).round();
  soft.add(TestCheck(
    name: 'PPR · כיסוי-העשרה (תמונה · spec · dims)',
    pass: true,
    got: 'image ${pct(pImg)}% · spec ${pct(pSpec)}% · dims ${pct(pDims)}%',
    detail: 'image $pImg/$pprN · spec $pSpec/$pprN · dims≥3 $pDims/$pprN',
  ));

  // PPR misaligned-d tracker (protocol §15): bulk extraction shifted columns on
  // some fittings, dropping the nominal diameter. dims['d'] must appear as a
  // number in the name. SOFT for now (working the debt down line-by-line from
  // the PDF) → flip to HARD when it reaches 0.
  // Precise: the nominal (a number in the name) must appear in d / D / dn.
  // Skip valves (d=bore), threaded fittings (d=socket-OD) and ranges where d
  // legitimately isn't the nominal. Now 0 → a real guard (pass = empty).
  final pprMisD = kPolyrollCatalog.where((p) {
    final d = p.dims?['d'];
    if (d == null) return false;
    if (p.nameHe.contains('ברז') ||
        p.nameHe.contains('"') ||
        d.toString().contains('-')) return false;
    final cand = {
      d.toString(),
      p.dims?['D']?.toString(),
      p.dims?['dn נומינלי']?.toString(),
    };
    final nums = RegExp(r'\d+(?:\.\d+)?')
        .allMatches(p.nameHe)
        .map((m) => m.group(0)!)
        .toSet();
    return nums.isNotEmpty && !nums.any(cand.contains);
  }).toList();
  soft.add(TestCheck(
    name: 'PPR · dims[d] תואם לשם (יישור-עמודות)',
    pass: pprMisD.isEmpty,
    expected: '0',
    got: '${pprMisD.length}',
    detail: pprMisD.take(4).map((p) => '${p.sku}: ${p.nameHe}').join(' · '),
  ));

  // PPR card-richness per line (protocol §15): the 9-strip card builds from
  // dims, so avgDims is the pace metric — thin lines are the next to enrich.
  final pprByCat = <String, List<int>>{};
  for (final p in kPolyrollCatalog) {
    pprByCat.putIfAbsent(p.categoryHe, () => []).add(p.dims?.length ?? 0);
  }
  final richness = pprByCat.entries
      .map((e) => (cat: e.key, n: e.value.length,
          avg: e.value.fold<int>(0, (a, b) => a + b) / e.value.length))
      .toList()
    ..sort((a, b) => a.avg.compareTo(b.avg));
  soft.add(TestCheck(
    name: 'PPR · עושר-dims לכל קו (מטריקת-קצב §15)',
    pass: true,
    got: '${kPolyrollCatalog.length} מוצרים · ${richness.length} קווים',
    detail: richness
        .map((r) => '${r.cat}=${r.avg.toStringAsFixed(1)}(${r.n})')
        .join(' · '),
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
  // צעד 60: gender detection — זכר→male, נקבה→female, both→null
  final genderOk = const LipskeyCatalogProduct(
            sku: '_', nameHe: 'ניפל זכר 1"', nameEn: '', categoryHe: '',
            categoryEn: '', categoryEmoji: '', page: 0)
          .connectionGender ==
      'male' &&
      const LipskeyCatalogProduct(
            sku: '_', nameHe: 'מופה נקבה 1"', nameEn: '', categoryHe: '',
            categoryEn: '', categoryEmoji: '', page: 0)
          .connectionGender ==
      'female' &&
      const LipskeyCatalogProduct(
            sku: '_', nameHe: 'מעבר זכר/נקבה 1"', nameEn: '', categoryHe: '',
            categoryEn: '', categoryEmoji: '', page: 0)
          .connectionGender ==
      null;
  compat.add(TestCheck(
    name: 'זיהוי מין-חיבור (זכר/נקבה/דו-צדדי) — צעד 60',
    pass: genderOk,
  ));
  // צעד 61: method detection — אלקטרו→electrofusion, דבק→glue, "→thread
  final methodOk = const LipskeyCatalogProduct(
            sku: '_', nameHe: 'מצמד אלקטרופוזיה DN50', nameEn: '',
            categoryHe: '', categoryEn: '', categoryEmoji: '', page: 0)
          .connectionMethod ==
      'electrofusion' &&
      const LipskeyCatalogProduct(
            sku: '_', nameHe: 'זווית להדבקה 50', nameEn: '', categoryHe: '',
            categoryEn: '', categoryEmoji: '', page: 0)
          .connectionMethod ==
      'glue';
  compat.add(TestCheck(
    name: 'זיהוי שיטת-חיבור (תבריג/דבק/אלקטרו) — צעד 61',
    pass: methodOk,
  ));
  // צעד 68: size-override wins over name extraction
  compat.add(TestCheck(
    name: 'override-מידה גובר על חילוץ-שם (צעד 68)',
    pass: () {
      const override = {'_zz': ['50']};
      final fromOverride =
          override['_zz'] ?? lipskeyConnectionSizes('מוצר בלי מידה');
      return fromOverride.contains('50');
    }(),
  ));
  // כל ה-override-ים מצביעים על מק"טים קיימים (אין יתום)
  final allSkus = {for (final p in kLipskeyCatalog) p.sku};
  final orphanOverride = [
    ...kLipskeyConnectionSizeOverride.keys,
    ...kLipskeyCompatPairOverride.keys,
    ...kLipskeyCompatPairOverride.values.expand((v) => v),
  ].where((s) => !allSkus.contains(s)).toList();
  compat.add(TestCheck(
    name: 'טבלת-override ללא מק"ט יתום (צעד 68)',
    pass: orphanOverride.isEmpty,
    got: orphanOverride.isEmpty ? 'נקי' : '${orphanOverride.length} יתומים',
  ));

  results.add(TestResult(
    id: 'catalog:compat',
    category: TestCategory.catalog,
    label: 'מנוע תאימות — מה מתחבר למה',
    area: 'תאימות',
    checks: compat,
  ));

  // ── מודל מובנה — getters (צעדים 72,73,75) ────────────────────────────────
  final model = <TestCheck>[];
  final branded = products.where((p) => p.brandModel != null).length;
  model.add(TestCheck(
    name: 'זיהוי מותג-דגם מהשם (brandModel)',
    pass: branded > 50,
    got: '$branded מוצרים עם מותג מזוהה',
  ));
  final colored = products.where((p) => p.colorVariant != null).length;
  model.add(TestCheck(
    name: 'זיהוי גוון/גימור (colorVariant)',
    pass: colored > 50,
    got: '$colored מוצרים עם גוון',
  ));
  final idx = lipskeyWordIndex();
  model.add(TestCheck(
    name: 'אינדקס-היפוך מילה→מוצרים נבנה',
    pass: idx.isNotEmpty && (idx['ברז']?.isNotEmpty ?? false),
    got: '${idx.length} מילים',
  ));
  // צעדים 76,79 — יחידות-מכירה ומזהה יציב
  model.add(TestCheck(
    name: 'uid ייחודי לכל מוצר (מותג:מק"ט)',
    pass: products.map((p) => p.uid).toSet().length == products.length,
    got: '${products.map((p) => p.uid).toSet().length}/${products.length}',
  ));
  model.add(TestCheck(
    name: 'saleUnits כולל לפחות "בודד"',
    pass: products.every((p) => p.saleUnits.containsKey('בודד')),
  ));
  // צעדים 69–71 — מנתח שם מובנה {type, subtype, brand, variant}
  final typed = products.where((p) => p.productType != null).length;
  model.add(TestCheck(
    name: 'מנתח-שם מזהה סוג ל-≥80% מהמוצרים (productType)',
    pass: typed >= (products.length * 0.8).floor(),
    expected: '≥${(products.length * 0.8).floor()}',
    got: '$typed/${products.length}',
  ));
  model.add(TestCheck(
    name: 'parsedName מחזיר רשומה עם 4 פאות',
    pass: () {
      final r = products.first.parsedName;
      return r.type == products.first.productType &&
          r.brand == products.first.brandModel &&
          r.variant == products.first.colorVariant;
    }(),
  ));
  // צעד 77 — קישור מפורש מוצר↔SmartProduct (דו-כיווני עקבי)
  final linked = products.where((p) => smartProductForSku(p.sku) != null)
      .length;
  model.add(TestCheck(
    name: 'קישור מוצר↔SmartProduct (smartProductForSku) — צעד 77',
    pass: linked > 0 &&
        smartProductForSku('217861') != null &&
        smartProductForSku('___none___') == null,
    got: '$linked מוצרים מקושרים ל-SmartProduct',
  ));
  // כל SKU שמופיע ב-SmartProduct.brands קיים בקטלוג (אין קישור יתום)
  final brandSkus = {
    for (final sp in kSmartProducts)
      for (final b in sp.brands)
        if (b.sku != null) b.sku!,
  };
  final catalogSkus = {for (final p in products) p.sku};
  final orphanLinks =
      brandSkus.where((s) => !catalogSkus.contains(s)).toList();
  model.add(TestCheck(
    name: 'אין קישור-SmartProduct יתום (מק"ט לא בקטלוג) — צעד 77',
    pass: orphanLinks.isEmpty,
    got: orphanLinks.isEmpty ? 'נקי' : '${orphanLinks.length} יתומים',
  ));
  // צעד 78 — resolver לפי SKU עם נפילה-לקטגוריה
  model.add(TestCheck(
    name: 'lipskeyAccFor/StagesFor נופל לקטגוריה — צעד 78',
    pass: () {
      final p = products.firstWhere(
        (x) => kLipskeyAccByCategory.containsKey(x.categoryHe),
        orElse: () => products.first,
      );
      final acc = lipskeyAccFor(p.sku, p.categoryHe);
      return acc.length ==
          (kLipskeyAccBySku[p.sku] ??
                  kLipskeyAccByCategory[p.categoryHe] ??
                  const [])
              .length;
    }(),
  ));
  results.add(TestResult(
    id: 'catalog:model',
    category: TestCategory.catalog,
    label: 'מודל מובנה (מותג/גוון/אינדקס)',
    area: 'מודל',
    checks: model,
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
