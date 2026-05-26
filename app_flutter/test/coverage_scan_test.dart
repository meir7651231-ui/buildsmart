import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('כיסוי VerifiedSpec לפי קטגוריה', () {
    final total = <String,int>{}, missing = <String,int>{};
    for (final p in kCompatCatalog) {
      total[p.categoryHe] = (total[p.categoryHe]??0)+1;
      if (kVerifiedSpecs[p.sku]==null) missing[p.categoryHe]=(missing[p.categoryHe]??0)+1;
    }
    final totalN = kCompatCatalog.length;
    final missN = kCompatCatalog.where((p)=>kVerifiedSpecs[p.sku]==null).length;
    print('\n[COVERAGE] ${totalN-missN}/$totalN עם spec (${((totalN-missN)*100/totalN).toStringAsFixed(1)}%)');
    print('קטגוריות עם הכי הרבה חוסר spec:');
    final cats = missing.keys.toList()..sort((a,b)=>missing[b]!.compareTo(missing[a]!));
    for (final c in cats.take(15)) {
      print('   ${missing[c]}/${total[c]} חסר — "$c"');
    }
  });

  test('איים — connectorים שמגיעים למעט מאוד שכנים', () {
    final conn = kCompatCatalog.where((p)=>kVerifiedSpecs[p.sku]!=null && flowRole(p)==FlowRole.connector).toList();
    var isolated=0, lowDeg=0;
    final samples=<String>[];
    for (final p in conn) {
      final deg = kCompatCatalog.where((q)=>q.sku!=p.sku && canConnect(p,q)).length;
      if (deg==0) isolated++;
      else if (deg<=1){ lowDeg++; if(samples.length<15) samples.add('deg=$deg ${p.sku}|${p.nameHe}'); }
    }
    print('\n[ISLANDS] connectorים מבודדים (deg=0): $isolated | דרגה נמוכה (deg=1): $lowDeg');
    for (final s in samples) print('   • $s');
  });
}
