import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku);

bool _hasAccessory(List<LipskeyCatalogProduct> path) =>
    path.any((p) => flowRole(p) == FlowRole.accessory);

void main() {
  group('שכבה 1+2 — 10 בדיקות', () {
    // 1. הבעיה המקורית: ברז 2" → קיסר → אסלה → בור — בלי מתלה
    test('1. התקנת שירותים 2" — בלי פריט מבני', () {
      final plan = buildInstallation(
          ['77777316','779096G','77771006','116113'].map(_p).toList());
      for (final p in plan.items) {
        print('   ${p.nameHe} [${p.sku}] = ${flowRole(p).name}');
        expect(flowRole(p) == FlowRole.accessory, isFalse,
            reason: 'פריט מבני בקו: ${p.nameHe}');
      }
    });

    // 2. מתלה מתכוונן לא נכנס לקו בנוי (חסום ע"י שכבה 2 — אין VerifiedSpec)
    test('2. מתלה מתכוונן לא מופיע בקו בנוי', () {
      expect(kVerifiedSpecs['77701185'], isNull); // אין geometry → לא auto-insert
      final plan = buildInstallation(
          ['77777313','779096G','77771006','116113'].map(_p).toList());
      expect(plan.items.any((p) => p.sku == '77701185'), isFalse);
    });

    // 3. חוצה-מערכת עדיין נדחה
    test('3. קיסר → צינור ניקוז 4" = אין נתיב', () {
      expect(findShortestPath(_p('779096G'), _p('116113'), maxDepth: 7), isNull);
    });

    // 4. אספקה תוך-מערכתי עדיין עובד, בלי מבני
    test('4. אל-חוזר → ברז מעבר פ.פ ½"', () {
      final path = findShortestPath(_p('77004401'), _p('77777201'), maxDepth: 5);
      expect(path, isNotNull);
      expect(_hasAccessory(path!), isFalse);
    });

    // 5. ניקוז תוך-מערכתי עדיין עובד
    test('5. ברך PVC 110 → צינור אפור 110', () {
      final path = findShortestPath(_p('142289'), _p('116113'), maxDepth: 3);
      expect(path, isNotNull);
      expect(_hasAccessory(path!), isFalse);
    });

    // 6. NTM מעבר גדלים — מחברים מאומתים בלבד
    test('6. NTM 16×16 → NTM 20×20', () {
      final path = findShortestPath(_p('77401622'), _p('77401028'), maxDepth: 5);
      expect(path, isNotNull);
      for (final p in path!) { expect(_hasAccessory([p]), isFalse); }
    });

    // 7. כל מחבר-ביניים חייב VerifiedSpec
    test('7. מחברי ביניים מאומתים — קיסר → ברז גן ½"', () {
      final path = findShortestPath(_p('779096G'), _p('77777341'), maxDepth: 6);
      expect(path, isNotNull);
      for (var i = 1; i < path!.length - 1; i++) {
        expect(kVerifiedSpecs[path[i].sku], isNotNull,
            reason: 'מחבר בלי spec: ${path[i].nameHe}');
        expect(flowRole(path[i]), FlowRole.connector);
      }
    });

    // 8. קבועה רק כקצה — אסלה לא באמצע
    test('8. אסלה אינה מחבר-אמצע', () {
      final path = findShortestPath(_p('779096G'), _p('77771006'), maxDepth: 6);
      expect(path, isNotNull);
      for (var i = 1; i < path!.length - 1; i++) {
        expect(flowRole(path[i]), isNot(FlowRole.fixture));
      }
    });

    // 9. התקנה מלאה אסלה — נשארת שלמה ובלי מבני
    test('9. ברז 1" → קיסר → אסלה → בור', () {
      final plan = buildInstallation(
          ['77777313','779096G','77771006','116113'].map(_p).toList());
      print('   BOM=${plan.items.length}, gaps=${plan.gaps.length}');
      for (final p in plan.items) {
        print('   • ${p.nameHe} [${p.sku}] (${flowRole(p).name})');
      }
      expect(_hasAccessory(plan.items), isFalse);
    });

    // 10. דרישת flowRole — דגימת קטגוריות
    test('10. סיווג תפקיד-זרימה תקין', () {
      expect(flowRole(_p('116113')), FlowRole.connector);   // צינור
      expect(flowRole(_p('77771006')), FlowRole.fixture);    // אסלה
      expect(flowRole(_p('77006030')), FlowRole.accessory);  // חבק תליה
      expect(flowRole(_p('77777641')), FlowRole.connector);  // ניפל
    });
  });
}
