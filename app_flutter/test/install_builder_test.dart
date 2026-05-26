import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct? _f(String sku) {
  try { return kCompatCatalog.firstWhere((p) => p.sku == sku); }
  catch (_) { return null; }
}

void _build(String desc, List<String> skus) {
  final anchors = [for (final s in skus) _f(s)].whereType<LipskeyCatalogProduct>().toList();
  if (anchors.length != skus.length) { print('?? $desc — SKU חסר'); return; }
  final plan = buildInstallation(anchors, maxDepthPerSegment: 7, tempC: 20);
  print('\n🔧 $desc');
  print('   ── BOM (${plan.items.length} פריטים) ──');
  for (var i = 0; i < plan.items.length; i++) {
    final p = plan.items[i];
    final sys = productSystems(p).map((s)=>s.name=='supply'?'אספקה':'ניקוז').join('+');
    final star = skus.contains(p.sku) ? '★ עוגן' : '  מחבר';
    print('   ${(i+1).toString().padLeft(2)}. $star  ${p.nameHe} [${p.sku}]  ($sys)');
  }
  if (plan.gaps.isNotEmpty) {
    print('   ⚠️ פערים (חסר חיבור):'); for (final g in plan.gaps) print('      ✗ ${g.from.nameHe} ↮ ${g.to.nameHe}');
  } else { print('   ✅ הקו שלם — בלי שחסר בורג'); }
}

void main() {
  test('שירותים — צינור הזנה גדול', () {
    _build('ברז הזנה 2" → קיסר → אסלה → בור ניקוז',
        ['77777316', '779096G', '77771006', '116113']);
    _build('ברז הזנה 1" → קיסר → אסלה → בור ניקוז',
        ['77777313', '779096G', '77771006', '116113']);
  });
}
