import 'dart:math';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final withSpec = kCompatCatalog.where((p) => kVerifiedSpecs[p.sku] != null).toList();

  test('A. יתומים — connector/fixture שלא מתחבר לכלום', () {
    final orphans = <String>[];
    for (final p in withSpec) {
      if (flowRole(p) == FlowRole.accessory) continue;
      final any = kCompatCatalog.any((q) => q.sku != p.sku && canConnect(p, q));
      if (!any) orphans.add('${p.sku}|${p.nameHe}|${p.categoryHe}');
    }
    print('\n[A] יתומים: ${orphans.length}/${withSpec.length}');
    for (final o in orphans.take(20)) print('   ⚠️ $o');
  });

  test(timeout: const Timeout(Duration(minutes:3)), 'B. סימטריה דו-כיוונית (מדגם 200)', () {
    final rnd = Random(7);
    var asym = 0;
    for (var i = 0; i < 40; i++) {
      final a = withSpec[rnd.nextInt(withSpec.length)];
      final b = withSpec[rnd.nextInt(withSpec.length)];
      final ab = findShortestPath(a, b, maxDepth: 5) != null;
      final ba = findShortestPath(b, a, maxDepth: 5) != null;
      if (ab != ba) { asym++; if (asym<=10) print('   ⚠️ אסימטרי: ${a.sku}↔${b.sku} ($ab/$ba)'); }
    }
    print('\n[B] אסימטריות: $asym/200');
    expect(asym, 0);
  });

  test(timeout: const Timeout(Duration(minutes:3)), 'C. דליפת חוצה-מערכת (כל זוג supply×drain במדגם)', () {
    final supply = withSpec.where((p) => productSystems(p).length==1 && productSystems(p).contains(WaterSystem.supply)).toList();
    final drain  = withSpec.where((p) => productSystems(p).length==1 && productSystems(p).contains(WaterSystem.drainage)).toList();
    final rnd = Random(11);
    var leaks = 0, checked = 0;
    for (var i = 0; i < 40; i++) {
      final s = supply[rnd.nextInt(supply.length)];
      final d = drain[rnd.nextInt(drain.length)];
      checked++;
      final path = findShortestPath(s, d, maxDepth: 6);
      if (path != null) { leaks++; if (leaks<=10) print('   🔴 דליפה: ${s.nameHe} → ${d.nameHe}: ${path.map((p)=>p.nameHe).join(" → ")}'); }
    }
    print('\n[C] דליפות חוצה-מערכת: $leaks/$checked (supply=${supply.length}, drain=${drain.length})');
    expect(leaks, 0);
  });

  test(timeout: const Timeout(Duration(minutes:3)), 'D. איכות מחברים במדגם תוך-מערכתי (300)', () {
    final rnd = Random(13);
    var built = 0, badQ = 0;
    for (var i = 0; i < 40; i++) {
      final a = withSpec[rnd.nextInt(withSpec.length)];
      final b = withSpec[rnd.nextInt(withSpec.length)];
      final path = findShortestPath(a, b, maxDepth: 5);
      if (path == null) continue;
      built++;
      for (var j = 1; j < path.length - 1; j++) {
        final mid = path[j];
        if (flowRole(mid) == FlowRole.accessory ||
            flowRole(mid) == FlowRole.fixture ||
            kVerifiedSpecs[mid.sku] == null) {
          badQ++;
          if (badQ <= 10) print('   🚩 ${a.sku}→${b.sku}: מחבר בעייתי ${mid.nameHe} (${flowRole(mid).name})');
          break;
        }
      }
    }
    print('\n[D] קווים שנבנו: $built, עם מחבר בעייתי: $badQ');
    expect(badQ, 0);
  });

  test('E. התאמת גודל-שם (DN mm)', () {
    final dnRe = RegExp(r'(?<![0-9])(16|20|25|32|40|50|63|75|90|110|125|160)(?![0-9])');
    final mism = <String>[];
    for (final p in withSpec) {
      final m = dnRe.allMatches(p.nameHe).map((x)=>x.group(1)!).toSet();
      if (m.isEmpty) continue;
      final spec = kVerifiedSpecs[p.sku]!;
      final ends = spec.ends.map((e)=>e.size).toSet();
      // name mentions a DN that no end has → possible mismatch
      final missing = m.where((s)=>!ends.contains(s)).toList();
      if (missing.isNotEmpty && ends.isNotEmpty) {
        mism.add('${p.sku}|${p.nameHe}| name=$m ends=$ends');
      }
    }
    print('\n[E] חשד אי-התאמת גודל-שם: ${mism.length}');
    for (final x in mism.take(25)) print('   ? $x');
  });
}
