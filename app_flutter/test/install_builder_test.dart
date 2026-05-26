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
  final plan = buildInstallation(anchors, maxDepthPerSegment: 6, tempC: 20);
  print('\n🔧 $desc');
  print('   עוגנים: ${anchors.map((a)=>a.nameHe).join(" | ")}');
  print('   ── BOM שלם (${plan.items.length} פריטים) ──');
  for (var i = 0; i < plan.items.length; i++) {
    final p = plan.items[i];
    final isAnchor = skus.contains(p.sku);
    print('   ${(i+1).toString().padLeft(2)}. ${isAnchor ? "★" : " "} ${p.nameHe} [${p.sku}]');
  }
  if (plan.gaps.isNotEmpty) {
    print('   ⚠️ פערים לא מחוברים:');
    for (final g in plan.gaps) print('      ✗ ${g.from.nameHe} ↮ ${g.to.nameHe}');
  } else {
    print('   ✅ הקו שלם — בלי שחסר בורג');
  }
}

void main() {
  test('בניית התקנה מעוגנים', () {
    // התקנת אסלה: אספקה (ברז מעבר) → אסלה (קבועה) → צינור ניקוז 110
    _build('שירותים — אסלה מלאה', ['77777311', '77771006', '116113']);
    // התקנת כיור: ברז כיור → קבועה → ניקוז
    _build('כיור עם ברז', ['77777114', '77771006', '116113']);
    // אספקה בלבד — ברז גן ¾" → ברז כיור ½"
    _build('קו אספקה: ברז גן → ברז כיור', ['77777345', '77777114']);
  });
}
