import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String s) =>
    kCompatCatalog.firstWhere((p) => p.sku == s);

int _matTransitions(List<LipskeyCatalogProduct> path) {
  var n = 0;
  for (var i = 0; i < path.length - 1; i++) {
    final a = kVerifiedSpecs[path[i].sku]?.material;
    final b = kVerifiedSpecs[path[i + 1].sku]?.material;
    if (a != null && b != null && a != b) n++;
  }
  return n;
}

void main() {
  group('שכבה 3 — איכות מחברים (10)', () {
    // 1. רדוקציה 1"→½" עוברת בבושינג נחושת (חומר אחיד)
    test('1. הזנה 1" → קיסר: בושינג נחושת בקו', () {
      final plan = buildInstallation(['77777313','779096G'].map(_p).toList());
      print('   ${plan.items.map((p)=>p.nameHe).join(" → ")}');
      expect(plan.items.any((p)=>p.sku=='77777663' || p.nameHe.contains('בושינג')), isTrue);
    });

    // 2. מינימום מעברי-חומר בקו האספקה
    test('2. מעברי חומר מינימליים — אל-חוזר→ברז מעבר', () {
      final path = findShortestPath(_p('77004401'), _p('77777201'), maxDepth: 5)!;
      print('   transitions=${_matTransitions(path)} | ${path.map((p)=>p.nameHe).join(" → ")}');
      expect(_matTransitions(path), lessThanOrEqualTo(1));
    });

    // 3. אורך נשמר (shortest-part) — ברך PVC→צינור = 2
    test('3. ברך PVC 110 → צינור = 2 חלקים', () {
      final path = findShortestPath(_p('142289'), _p('116113'), maxDepth: 4)!;
      expect(path.length, 2);
    });

    // 4. אורך נשמר — מחסום DN32 → צינור ≤ 3
    test('4. מחסום DN32 → צינור ≤3', () {
      final path = findShortestPath(_p('217861'), _p('116180'), maxDepth: 4)!;
      expect(path.length, lessThanOrEqualTo(3));
    });

    // 5. NTM 16→20 — נתיב PEX אחיד (0 מעברי חומר)
    test('5. NTM 16×16 → 20×20 — חומר אחיד', () {
      final path = findShortestPath(_p('77401622'), _p('77401028'), maxDepth: 5)!;
      print('   transitions=${_matTransitions(path)}');
      expect(_matTransitions(path), 0);
    });

    // 6. חוצה-מערכת עדיין נדחה
    test('6. ברז כיור → ברך אסלה = אין נתיב', () {
      expect(findShortestPath(_p('77777114'), _p('164873'), maxDepth: 7), isNull);
    });

    // 7. אין accessory באף קו בנוי (התקנה מלאה)
    test('7. התקנה מלאה — אין מבני', () {
      final plan = buildInstallation(['77777313','779096G','77771006','116113'].map(_p).toList());
      expect(plan.items.any((p)=>flowRole(p)==FlowRole.accessory), isFalse);
    });

    // 8. כל מחבר-ביניים מאומת (יש VerifiedSpec)
    test('8. מחברי-ביניים מאומתים — קיסר→ברז גן ½"', () {
      final path = findShortestPath(_p('779096G'), _p('77777341'), maxDepth: 6)!;
      for (var i=1;i<path.length-1;i++) {
        expect(kVerifiedSpecs[path[i].sku], isNotNull);
      }
    });

    // 9. התקנת שירותים מלאה — BOM שלם בלי פערים
    test('9. BOM שלם — ברז 1"→קיסר→אסלה→בור', () {
      final plan = buildInstallation(['77777313','779096G','77771006','116113'].map(_p).toList());
      expect(plan.gaps, isEmpty);
      expect(plan.items.length, greaterThanOrEqualTo(5));
    });

    // 10. דטרמיניזם — אותו קלט נותן אותו פלט
    test('10. דטרמיניסטי', () {
      final a = findShortestPath(_p('779096G'), _p('77777341'), maxDepth: 6)!;
      final b = findShortestPath(_p('779096G'), _p('77777341'), maxDepth: 6)!;
      expect(a.map((p)=>p.sku).toList(), b.map((p)=>p.sku).toList());
    });
  });
}
