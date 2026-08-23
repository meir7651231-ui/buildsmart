import 'dart:math';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final withSpec = kCompatCatalog.where((p) => kVerifiedSpecs[p.sku] != null).toList();

  test('A. יתומים — connector/fixture שלא מתחבר לכלום (שער: אין יתומים חדשים)', () {
    // 7 פערי-כיסוי ידועים ב-kVerifiedSpecs (מידה/תבריג נישתי שעדיין לא שודך):
    // מאריכי-ברז 3/8×3/8, אל-חזור 3", צינור-ניקוז-מזגן. allow-listed כדי שהשער
    // יתפוס יתום *חדש* (רגרסיה אמיתית) בלי להיכשל על הפערים המתועדים האלה.
    // TODO(data/קטלגן): להוסיף specs ל-3/8 + 3" + צינור-מזגן ולצמצם את הרשימה.
    const knownOrphans = {
      '77383815', '77383820', '77383825', '77383830', '77383840',
      '77004408', '9899',
    };
    final orphans = <String>[];
    for (final p in withSpec) {
      if (flowRole(p) == FlowRole.accessory) continue;
      final any = kCompatCatalog.any((q) => q.sku != p.sku && canConnect(p, q));
      if (!any) orphans.add('${p.sku}|${p.nameHe}|${p.categoryHe}');
    }
    print('\n[A] יתומים: ${orphans.length}/${withSpec.length}');
    for (final o in orphans.take(20)) print('   ⚠️ $o');
    final unexpected =
        orphans.where((o) => !knownOrphans.contains(o.split('|').first)).toList();
    expect(unexpected, isEmpty,
        reason: 'יתומים חדשים (מחוץ ל-allowlist): ${unexpected.length}\n'
            '${unexpected.join("\n")}');
  });

  test(timeout: const Timeout(Duration(minutes:3)), 'B. סימטריה דו-כיוונית (מדגם 40)', () {
    final rnd = Random(7);
    var asym = 0;
    for (var i = 0; i < 40; i++) {
      final a = withSpec[rnd.nextInt(withSpec.length)];
      final b = withSpec[rnd.nextInt(withSpec.length)];
      final ab = findShortestPath(a, b, maxDepth: 5) != null;
      final ba = findShortestPath(b, a, maxDepth: 5) != null;
      if (ab != ba) { asym++; if (asym<=10) print('   ⚠️ אסימטרי: ${a.sku}↔${b.sku} ($ab/$ba)'); }
    }
    print('\n[B] אסימטריות: $asym/40');
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

  test(timeout: const Timeout(Duration(minutes:3)), 'D. איכות מחברים במדגם תוך-מערכתי (40)', () {
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

  test('E. התאמת גודל-שם (DN mm) — דיאגנוסטיקה בלבד (heuristic, לא שער)', () {
    // Print-only BY DESIGN: ה-regex תופס כל מספר DN-דמוי בשם, כולל המון false-
    // positives (אורכים "15 ס\"מ"/"50 מ׳", תבריג "3/8") → 116 חשודים שרובם רעש.
    // שער-קשיח (isEmpty/baseline) היה שביר (נשבר על גידול-קטלוג תמים) ורועש —
    // נשאר ככלי-אבחון לסריקה-בעין, לא כ-invariant.
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
