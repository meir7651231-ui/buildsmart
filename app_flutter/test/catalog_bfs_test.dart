// 10 BFS tests across updated catalog categories
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku,
        orElse: () => throw StateError('SKU not found: $sku'));

void main() {
  group('BFS — קטלוג מעודכן', () {

    // 1. ניקוז: ברך 110 → צינור אפור 110
    test('ברך PVC 110 → צינור אפור DN110', () {
      final path = findShortestPath(_p('142289'), _p('116113'), maxDepth: 3, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(3));
      for (int i = 0; i < path.length - 1; i++) {
        expect(canConnect(path[i], path[i+1]), isTrue,
            reason: '${path[i].sku} → ${path[i+1].sku}');
      }
    });

    // 2. ניקוז: מחסום גלוי DN32 → צינור אפור DN32
    test('מחסום גלוי DN32 → צינור אפור DN32', () {
      final path = findShortestPath(_p('217861'), _p('116180'), maxDepth: 3, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(3));
    });

    // 3. ניקוז: סיפון DN32 → מחסום גלוי DN32
    test('סיפון DN32 → מחסום גלוי DN32', () {
      final path = findShortestPath(_p('77771012'), _p('217861'), maxDepth: 3, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(3));
    });

    // 4. ניקוז: תעלת ניקוז DN50 → צינור אפור DN50
    test('תעלת ניקוז DN50 → צינור אפור DN50', () {
      final path = findShortestPath(_p('77575315'), _p('221022'), maxDepth: 3, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(3));
    });

    // 5. ניקוז: צינור PP DN110 → ברך PVC DN110
    test('צינור PP DN110 → ברך PVC DN110', () {
      final path = findShortestPath(_p('224169'), _p('142289'), maxDepth: 3, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(3));
    });

    // 6. אספקה: ברז כיור → מופה נחושת ½" (F×F coupler)
    test('ברז כיור ½" → מופה נחושת ½"', () {
      final path = findShortestPath(_p('77777114'), _p('77777104'), maxDepth: 4, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(4));
      for (int i = 0; i < path.length - 1; i++) {
        expect(canConnect(path[i], path[i+1]), isTrue,
            reason: '${path[i].sku} → ${path[i+1].sku}');
      }
    });

    // 7. אספקה: ניפל כפול ½" → ברז מעבר פ.פ ½"
    test('ניפל כפול ½" → ברז מעבר פ.פ ½"', () {
      expect(canConnect(_p('77777641'), _p('77777201')), isTrue);
    });

    // 8. אספקה: ברז מעבר ח.פ ¾" → ברז גן ¾" (דרך ניפל)
    test('ברז מעבר ח.פ ¾" → ברז גן ¾" (≤4 hops)', () {
      final path = findShortestPath(_p('77777312'), _p('77777345'), maxDepth: 4, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(4));
    });

    // 9. אספקה: אל-חוזר ½" → ברז מעבר פ.פ ½" (F×F + F×F → דרך ניפל M×M)
    test('אל-חוזר כלפה ½" → ברז מעבר פ.פ ½" (≤3 hops דרך ניפל)', () {
      final path = findShortestPath(_p('77004401'), _p('77777201'), maxDepth: 3, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב — ניפל כפול צריך להיות גשר');
      expect(path!.length, lessThanOrEqualTo(3));
      for (int i = 0; i < path.length - 1; i++) {
        expect(canConnect(path[i], path[i+1]), isTrue,
            reason: '${path[i].sku} → ${path[i+1].sku}');
      }
    });

    // 10. רב-שכבתי: צינור DN75 → ברך PVC DN75
    test('צינור רב-שכבתי DN75 → ברך PVC DN75', () {
      final path = findShortestPath(_p('273216'), _p('116033'), maxDepth: 3, tempC: 20);
      expect(path, isNotNull, reason: 'לא נמצא נתיב');
      expect(path!.length, lessThanOrEqualTo(3));
    });

  });
}
