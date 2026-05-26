import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';
LipskeyCatalogProduct _p(String s)=>kCompatCatalog.firstWhere((p)=>p.sku==s);
void main(){
  group('לולאת recirculation — 10', (){
    // linear vs loop on the same anchors
    final anchors=['77777313','779096G','77777341']; // supply valves/faucet (loopable)
    test('1. לולאה ≥ לינארי בכמות', (){
      final lin=buildInstallation(anchors.map(_p).toList(),tempC:20);
      final lp =buildInstallation(anchors.map(_p).toList(),tempC:20,loop:true);
      print('\n  לינארי=${lin.totalPieces} · לולאה=${lp.totalPieces}');
      expect(lp.totalPieces, greaterThanOrEqualTo(lin.totalPieces));
    });
    test('2. לולאה לא מוסיפה עוגן כפול', (){
      final lp=buildInstallation(anchors.map(_p).toList(),tempC:20,loop:true);
      expect(lp.qtyOf('77777313'), 1); // first anchor still once
    });
    test('3. לולאה עם 2 עוגנים תקפה', (){
      final lp=buildInstallation(['77777311','77777341'].map(_p).toList(),tempC:20,loop:true);
      expect(lp.items, isNotEmpty);
    });
    test('4. לינארי ברירת-מחדל (loop=false)', (){
      final lin=buildInstallation(anchors.map(_p).toList(),tempC:20);
      expect(lin.items, isNotEmpty);
    });
    test('5. לולאה על עוגן יחיד = ללא שינוי', (){
      final lp=buildInstallation(['77777313'].map(_p).toList(),tempC:20,loop:true);
      expect(lp.items.length, 1);
    });
    test('6. חזרה לא ניתנת לחיבור → פער', (){
      // supply faucet loop back to a drain pipe can't close (cross-system)
      final lp=buildInstallation(['779096G','116113'].map(_p).toList(),tempC:20,loop:true);
      expect(lp.gaps, isNotEmpty);
    });
    test('7. כמות מסוכמת בלולאה', (){
      final lp=buildInstallation(anchors.map(_p).toList(),tempC:20,loop:true);
      expect(lp.totalPieces, greaterThan(0));
    });
    test('8. לולאה משמרת סוגים ייחודיים', (){
      final lp=buildInstallation(anchors.map(_p).toList(),tempC:20,loop:true);
      final skus=lp.items.map((e)=>e.sku).toSet();
      expect(skus.length, lp.items.length);
    });
    test('9. אביזרים עובדים עם לולאה', (){
      final lp=buildInstallation(anchors.map(_p).toList(),tempC:20,loop:true,accessories:{'HW-CLIP'});
      expect(lp.items.any((p)=>p.sku=='HW-CLIP'), isTrue);
    });
    test('10. לולאה דטרמיניסטית', (){
      final a=buildInstallation(anchors.map(_p).toList(),tempC:20,loop:true);
      final b=buildInstallation(anchors.map(_p).toList(),tempC:20,loop:true);
      expect(a.items.map((e)=>e.sku).toList(), b.items.map((e)=>e.sku).toList());
    });
  });
}
