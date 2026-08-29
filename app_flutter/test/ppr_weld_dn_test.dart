import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the W1 PPR weld-plan key bug (2026-06-08): the socket-
/// fusion weld plan (`_kPprWeldPlan`) was looked up via 'dn נומינלי' only, but
/// most polyroll PPR pipes (supply + faser) carry their diameter under
/// 'קוטר חיצוני', so `_kPprWeldPlan[null]` returned null and the weld plan
/// vanished. [pprWeldDn] now falls back to 'קוטר חיצוני'.
void main() {
  group('pprWeldDn — weld-plan diameter resolution', () {
    test('falls back to קוטר חיצוני when dn נומינלי is absent (the bug)', () {
      // mirrors polyroll sku 95016003 (PPR supply 25) — no 'dn נומינלי'.
      expect(pprWeldDn({'SDR': '6', 'PN': '20', 'קוטר חיצוני': '25'}), '25');
    });

    test('uses dn נומינלי when present', () {
      // mirrors polyroll sku 95270708 (faser 20×2.8).
      expect(pprWeldDn({'dn נומינלי': '20', 'de קוטר חיצוני': '20.0'}), '20');
    });

    test('prefers dn נומינלי over קוטר חיצוני when both exist', () {
      expect(pprWeldDn({'dn נומינלי': '32', 'קוטר חיצוני': '32'}), '32');
    });

    test('no diameter key → null (and null dims → null)', () {
      expect(pprWeldDn(null), isNull);
      expect(pprWeldDn({'SDR': '6'}), isNull);
    });
  });
}
