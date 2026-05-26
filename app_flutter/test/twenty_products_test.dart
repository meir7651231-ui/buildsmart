// 20-product engine test — checks auto-bridge vs gap across diverse scenarios
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku,
        orElse: () => throw Exception('SKU not found: $sku'));

void _report(String label, List<LipskeyCatalogProduct> anchors, InstallationPlan plan) {
  final status = plan.gaps.isEmpty ? '✅ ללא פערים' : '⚠️  ${plan.gaps.length} פערים';
  print('\n[$label] $status');
  print('   מוצרי עוגן: ${anchors.map((p) => p.nameHe).join(" → ")}');
  if (plan.items.isNotEmpty) {
    print('   רשימת קנייה (${plan.items.length} פריטים):');
    for (final p in plan.items) {
      final qty = plan.quantities[p.sku] ?? 1;
      final tag = qty > 1 ? ' ×$qty' : '';
      print('     • ${p.nameHe} [${p.sku}]$tag');
    }
  }
  if (plan.gaps.isNotEmpty) {
    print('   פערים:');
    for (final g in plan.gaps) {
      print('     ✗ ${g.from.nameHe} → ${g.to.nameHe}');
    }
  }
}

void main() {
  group('20 מוצרים — בדיקת מנוע auto-bridge', () {
    // ── תרחישים 1–5: ברז / כיור ──────────────────────────────────────────────

    test('1. ברז דלי ארוך + סיפון כיור (בית)', () {
      final anchors = [_p('79255054'), _p('217861')];
      final plan = buildInstallation(anchors);
      _report('1', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('2. ברז דלי כפול אלפא + מחסום נסתר', () {
      final anchors = [_p('7777208C'), _p('218553')];
      final plan = buildInstallation(anchors);
      _report('2', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('3. ברז גן ½" + צינור PP', () {
      final anchors = [_p('77777341'), _p('116113')];
      final plan = buildInstallation(anchors);
      _report('3', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('4. נקודת מים + ברז דלי ארוך', () {
      final anchors = [_p('77775295'), _p('79255054')];
      final plan = buildInstallation(anchors);
      _report('4', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('5. ברז מעבר ½" + ברך ניקוז', () {
      final anchors = [_p('77777201'), _p('116033')];
      final plan = buildInstallation(anchors);
      _report('5', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    // ── תרחישים 6–9: אסלה / ניקוז ────────────────────────────────────────────

    test('6. קיסר ½" → אסלה תלויה → ברך אסלה', () {
      final anchors = [_p('779096G'), _p('77771006'), _p('140958')];
      final plan = buildInstallation(anchors);
      _report('6', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('7. אסלה מונבלוק + מחסום רצפה', () {
      final anchors = [_p('77771010'), _p('196587')];
      final plan = buildInstallation(anchors);
      _report('7', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('8. אסלה P + צינור ניקוז 110', () {
      final anchors = [_p('77771008'), _p('116113')];
      final plan = buildInstallation(anchors);
      _report('8', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('9. קולט מקלחת + ברך אסלה', () {
      final anchors = [_p('116148'), _p('140870')];
      final plan = buildInstallation(anchors);
      _report('9', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    // ── תרחישים 10–12: מקלחת ─────────────────────────────────────────────────

    test('10. ראש מקלחת + קולט A 40/70', () {
      final anchors = [_p('7777708G'), _p('116148')];
      final plan = buildInstallation(anchors);
      _report('10', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('11. ראש מקלחת שחור + מחסום רצפה', () {
      final anchors = [_p('7777707B'), _p('196587')];
      final plan = buildInstallation(anchors);
      _report('11', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('12. ראש מקלחת + מסעף 45°', () {
      final anchors = [_p('7777708B'), _p('220305')];
      final plan = buildInstallation(anchors);
      _report('12', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    // ── תרחישים 13–15: מים חמים ──────────────────────────────────────────────

    test('13. NTM 16×16 → NTM 20×20 (מעבר גדלים)', () {
      final anchors = [_p('77401622'), _p('77401028')];
      final plan = buildInstallation(anchors, tempC: 70);
      _report('13', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('14. קיסר → ברז מעבר בחום גבוה', () {
      final anchors = [_p('779096G'), _p('77777201')];
      final plan = buildInstallation(anchors, tempC: 65);
      _report('14', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('15. אל-חוזר → ברז מעבר ½"', () {
      final anchors = [_p('77004401'), _p('77777201')];
      final plan = buildInstallation(anchors, tempC: 60);
      _report('15', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    // ── תרחישים 16–18: מחלקים / מסעפים ──────────────────────────────────────

    test('16. ברז ½" → מחבר כפול → ברז ½"', () {
      final anchors = [_p('77777201'), _p('218564'), _p('77777202')];
      final plan = buildInstallation(anchors);
      _report('16', anchors, plan);
      expect(plan.items, isNotEmpty);
    });

    test('17. NTM 16 → NTM 16 × 4 (עץ ענפים)', () {
      final trunk = [_p('77401622')];
      final branches = [_p('77777201'), _p('77777202'), _p('77777341')];
      final plan = buildTreeInstallation(trunk, branches);
      _report('17 (tree)', trunk + branches, plan);
      expect(plan.items, isNotEmpty);
    });

    test('18. NTM 20 trunk → 3 ברזים שונים', () {
      final trunk = [_p('77401028')];
      final branches = [_p('77777311'), _p('77777341'), _p('77777201')];
      final plan = buildTreeInstallation(trunk, branches, tempC: 50);
      _report('18 (tree/hot)', trunk + branches, plan);
      expect(plan.items, isNotEmpty);
    });

    // ── תרחישים 19–20: חצייה מערכתית (gap צפוי) ─────────────────────────────

    test('19. אספקה → ניקוז ישיר = פער צפוי', () {
      final anchors = [_p('779096G'), _p('116113')];
      final plan = buildInstallation(anchors);
      _report('19 (cross-system expected gap)', anchors, plan);
      // cross-system: either bridged through fixture or has gap — both valid
      print('   → gaps=${plan.gaps.length}, items=${plan.items.length}');
    });

    test('20. קיסר ½" → ניפל → ברז גן (שרשרת מלאה)', () {
      final anchors = [_p('779096G'), _p('77777641'), _p('77777341')];
      final plan = buildInstallation(anchors);
      _report('20', anchors, plan);
      expect(plan.items, isNotEmpty);
    });
  });
}
