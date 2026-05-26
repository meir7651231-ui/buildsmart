import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct? _find(String sku) {
  try { return kCompatCatalog.firstWhere((p) => p.sku == sku); }
  catch (_) { return null; }
}

void _show(String desc, String from, String to) {
  final f = _find(from), t = _find(to);
  if (f == null || t == null) { print('?? $desc — SKU חסר ($from/$to)'); return; }
  final sf = productSystems(f).map((s)=>s.name).join('+');
  final st = productSystems(t).map((s)=>s.name).join('+');
  final path = findShortestPath(f, t, maxDepth: 7, tempC: 20);
  final body = path == null ? 'אין נתיב'
      : '${path.length}: ${path.map((p) => p.nameHe).join(" → ")}';
  print('• $desc  [$sf→$st]\n     $body');
}

void main() {
  test('מגוון רחב', () {
    print('\n═══ חוצה-מערכת (צפוי: אין נתיב) ═══');
    _show('ניפל נחושת ½" → צינור אפור 110', '77777641', '116113');
    _show('NTM 16×16 → תעלת ניקוז',          '77401622', '77575327');
    _show('דיור ברז קיר → מחסום גלוי',        '777M2206', '116635');
    _show('ברז כיור → סיפון',                 '77777114', '77003221');
    _show('פקק נחושת ½" → ברך PVC 110',       '77778071', '142289');

    print('\n═══ אספקה תוך-מערכתי (צפוי: נתיב) ═══');
    _show('ניפל נחושת ½" → ברז מעבר פ.פ ½"',  '77777641', '77777201');
    _show('NTM 16×16 → NTM 20×20 (מעבר)',     '77401622', '77401028');
    _show('קיסר → ברז גן ½"',                 '779096G', '77777341');
    _show('אל-חוזר ½" → פקק נחושת ½"',        '77004401', '77778071');

    print('\n═══ ניקוז תוך-מערכתי (צפוי: נתיב) ═══');
    _show('מחסום גלוי → צינור אפור 110',      '116635', '116113');
    _show('תעלת ניקוז → צינור אפור DN50',     '77575327', '221022');
    _show('מולטי DN75 → ברך PVC 75',          '273216', '116033');

    print('\n═══ קבועות + מבני + דו-משמעי ═══');
    _show('קיסר → כיור (קצה)',                '779096G', '77771010');
    _show('כיור → צינור ניקוז (קצה)',         '77771010', '116113');
    _show('חבק תליה → ברז מעבר (מבני)',       '77006030', '77777201');
    _show('אטם כדורי DN50 → צינור אפור DN50', '506525', '221022');
  });
}
