// BFS demo — 10 זוגות קצה-לקצה, SKUs מאומתים
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku,
        orElse: () => throw StateError('SKU not found: $sku'));

void main() {
  const pairs = [
    // 1. אסלה → אטם מנגית אקסנטר → זקיף אסלה DN110
    ('אסלה → זקיף אסלה (דרך אטם מנגית)', '77771006', '164873', 3),
    // 2. אסלה → צינור ניקוז DN110
    ('אסלה → צינור ניקוז DN110', '77771010', '116113', 3),
    // 3. אטם מנגית אקסנטר → זקיף אסלה (c110→c110)
    ('אטם מנגית אקסנטר → זקיף אסלה', '77777010', '164873', 2),
    // 4. מחסום DN32 → אטם DN32 → צינור DN32
    ('מחסום (סיפון) DN32 → צינור אפור DN32', '217861', '116180', 3),
    // 5. ברך DN110 → צינור PP DN110
    ('ברך PVC DN110 → צינור PP DN110', '142289', '224169', 2),
    // 6. צינור DN40 → אטם כדורי 50/40 → ברך DN50
    ('צינור DN40 → אטם מעבר 50/40 → ברך DN50', '116606', '116601', 3),
    // 7. מחסום DN40 → אטם DN40 → ברך DN40
    ('מחסום DN40 → אטם דו-צדדי DN40 → ברך DN40', '116649', '116624', 3),
    // 8. ברז כיור ½" → ניפל ½" → ברז מעבר פ.פ ½"
    ('ברז כיור ½" → ברז מעבר פ.פ ½"', '77777114', '77777201', 4),
    // 9. ברז גן ¾" → ניפל כפול ¾"
    ('ברז גן ¾" → ניפל כפול ¾"', '77777345', '77777642', 3),
    // 10. אל-חוזר ½" → ברז מעבר פ.פ ½" (דרך ניפל)
    ('אל-חוזר ½" → ברז מעבר פ.פ ½"', '77004401', '77777201', 3),
  ];

  group('BFS demo — 10 זוגות קצה-לקצה', () {
    for (final (desc, fromSku, toSku, maxHops) in pairs) {
      test(desc, () {
        final from = _p(fromSku);
        final to   = _p(toSku);
        final path = findShortestPath(from, to, maxDepth: maxHops, tempC: 20);
        if (path != null) {
          final steps = path.map((p) => p.nameHe).join(' → ');
          // ignore: avoid_print
          print('\n✅ [$desc] ${path.length} קישורים:\n   $steps');
          for (int i = 0; i < path.length - 1; i++) {
            expect(canConnect(path[i], path[i+1]), isTrue,
                reason: 'חיבור שבור: ${path[i].sku} → ${path[i+1].sku}');
          }
        } else {
          // ignore: avoid_print
          print('\n❌ [$desc] לא נמצא נתיב');
        }
        expect(path, isNotNull, reason: 'לא נמצא נתיב: $fromSku → $toSku');
      });
    }
  });
}
