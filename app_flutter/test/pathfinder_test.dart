// BFS pathfinder regression — 10 end-to-end pairs
// Tests findShortestPath() across realistic plumbing scenarios.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku,
        orElse: () => throw StateError('SKU not found: $sku'));

void main() {
  // Each case: (description, fromSku, toSku, tempC, expectFound, maxHops)
  const cases = [
    // 1. ברז כניסת דוד → משאבת recirc  (direct BSP 1" ↔ BSP 1")
    ('ברז כניסת דוד → משאבת recirc 1"',
     'HW-BALL-INLET-1', 'HW-PUMP-25', 60, true, 3),

    // 2. משאבה → ברז כדורי 1"  (BSP 1" through)
    ('משאבת recirc → ברז כדורי 1"',
     'HW-PUMP-25', 'HW-BALL-1', 60, true, 3),

    // 3. ברז כדורי 1" → מצמד מעבר 1"×PEX20  (BSP→PEX)
    ('ברז כדורי 1" → מצמד מעבר 1"×PEX20',
     'HW-BALL-1', 'HW-ADP-1-PEX20', 60, true, 3),

    // 4. מצמד מעבר → צינור PEX 20  (PEX press)
    ('מצמד מעבר 1"×PEX20 → צינור PEX 20',
     'HW-ADP-1-PEX20', 'HW-PEX-20', 60, true, 3),

    // 5. צינור PEX 20 → מחלק 3 יציאות  (PEX→BSP manifold inlet)
    ('צינור PEX 20 → מחלק 3 יציאות',
     'HW-PEX-20', 'HW-MANIFOLD-3', 60, true, 4),

    // 6. מסנן Y DN40 → משאבת VSP DN40  (commercial pump island)
    ('מסנן Y DN40 → משאבת VSP DN40',
     'HW-YSTR-40', 'HW-PUMP-40', 60, true, 3),

    // 7. משאבת VSP DN40 → מחבר גמיש DN40  (vibration isolation)
    ('משאבת VSP DN40 → מחבר גמיש DN40',
     'HW-PUMP-40', 'HW-FLEX-40', 60, true, 3),

    // 8. צינור נחושת DN25 → שסתום TMTV DN25  (anti-scald)
    ('צינור נחושת DN25 → TMTV DN25',
     'HW-CU-25', 'HW-TMTV-25', 60, true, 3),

    // 9. ברז כניסת דוד 1" → מחלק 3 יציאות  (full residential path ≤7 hops)
    ('ברז כניסת דוד 1" → מחלק 3 יציאות (נתיב מלא)',
     'HW-BALL-INLET-1', 'HW-MANIFOLD-3', 60, true, 7),

    // 10. מסנן Y DN40 → מסתם אל-חזור DN40  (no direct link — needs pump between)
    ('מסנן Y DN40 → מסתם אל-חזור DN40',
     'HW-YSTR-40', 'HW-CHECK-40', 60, true, 5),
  ];

  group('findShortestPath — 10 תרחישים', () {
    for (final (desc, fromSku, toSku, tempC, expectFound, maxHops)
        in cases) {
      test(desc, () {
        final from = _p(fromSku);
        final to   = _p(toSku);
        final path = findShortestPath(from, to,
            maxDepth: maxHops, tempC: tempC);

        if (expectFound) {
          expect(path, isNotNull,
              reason: 'לא נמצא נתיב: $fromSku → $toSku');
          expect(path!.first.sku, equals(fromSku),
              reason: 'נקודת ההתחלה שגויה');
          expect(path.last.sku, equals(toSku),
              reason: 'נקודת הסיום שגויה');
          expect(path.length, lessThanOrEqualTo(maxHops),
              reason: 'נתיב ארוך מדי: ${path.length} > $maxHops');
          // verify every consecutive pair actually connects
          for (int i = 0; i < path.length - 1; i++) {
            expect(canConnect(path[i], path[i + 1]), isTrue,
                reason: 'חיבור שבור: ${path[i].sku} → ${path[i+1].sku}');
          }
        } else {
          expect(path, isNull,
              reason: 'נמצא נתיב כשלא היה צפוי');
        }
      });
    }
  });
}
