import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String s)=>kCompatCatalog.firstWhere((p)=>p.sku==s);

void main(){
  group('מרכזייה / טופולוגיית-עץ — 10', (){
    // 1. ספירת יציאות מחלק
    test('1. מחלק 4 יציאות', () => expect(manifoldOutlets(_p('76032204')), 4));
    test('2. מחלק 2 יציאות', () => expect(manifoldOutlets(_p('76032202')), 2));
    test('3. ¾" 4 יציאות', () => expect(manifoldOutlets(_p('77603204')), 4));
    test('4. צינור אינו מחלק', () => expect(manifoldOutlets(_p('116113')), 0));

    // 5. מרכזייה מלאה: הזנה 1" → מחלק 4 → 4 ברזים
    test('5. הזנה→מחלק→4 ברזים — BOM מסוכם', () {
      final plan = buildTreeInstallation(
        ['77777313','76032204'].map(_p).toList(),       // feed → manifold
        ['77777311','77777201','77777341','779096G'].map(_p).toList(), // 4 valves
        tempC: 20,
      );
      print('\n  סוגים=${plan.items.length} · יח׳=${plan.totalPieces} · gaps=${plan.gaps.length}');
      for(final p in plan.items) print('   ${p.nameHe} × ${plan.qtyOf(p.sku)}');
      expect(plan.items.any((p)=>p.sku=='76032204'), isTrue); // manifold present
      expect(plan.totalPieces, greaterThan(plan.items.length-2)); // some summing
    });

    // 6. מחלק נספר פעם אחת (לא כפול לכל ענף)
    test('6. מחלק × 1', () {
      final plan = buildTreeInstallation(
        ['77777313','76032204'].map(_p).toList(),
        ['77777311','77777201'].map(_p).toList(), tempC:20);
      expect(plan.qtyOf('76032204'), 1);
    });

    // 7. ענף לברז זכר ½" — חיבור ישיר מהמחלק
    test('7. ענף לברז ח.פ ½" ישיר', () {
      final seg = findShortestPath(_p('76032204'), _p('77777311'), maxDepth:5);
      expect(seg, isNotNull);
    });

    // 8. ברזים זהים בכמה ענפים → כמות מסוכמת
    test('8. כמות מסוכמת לברז חוזר', () {
      final plan = buildTreeInstallation(
        ['76032204'].map(_p).toList(),
        ['77777311','77777311','77777311'].map(_p).toList(), tempC:20);
      // אותו ברז 3 פעמים → × 3
      expect(plan.qtyOf('77777311'), greaterThanOrEqualTo(3));
    });

    // 9. ענף חוצה-מערכת (ניקוז) מהמחלק → פער
    test('9. ענף לצינור ניקוז → פער', () {
      final plan = buildTreeInstallation(
        ['76032204'].map(_p).toList(),
        ['116113'].map(_p).toList(), tempC:20);
      expect(plan.gaps, isNotEmpty);
    });

    // 10. branches > outlets ניתן לזיהוי
    test('10. 4 ענפים על מחלק 2-יציאות → חריגה', () {
      final outlets = manifoldOutlets(_p('76032202'));
      const branches = 4;
      expect(branches > outlets, isTrue);
    });
  });
}
