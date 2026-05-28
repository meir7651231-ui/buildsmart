import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:buildsmart/test_harness/types.dart';

/// מנוע התקנה ותאימות (install + compatibility engine) — the same guarantees
/// enforced by test/compat_50_samples_test, test/full_compliance_audit_test,
/// test/pressure_drop_test and test/install_kit_test, mirrored here so the
/// in-app "רגרסיה מלאה" button exercises the engine too. Reported under the
/// dedicated [TestCategory.engine] bucket.
///
/// Source-of-truth rule for a real physical mate (mirrors
/// related_info._reallyMates):
///   • directMatesWith — thread / press / drain joint, always a real joint
///   • pipeSharedWith  — compression socket: counts only when EXACTLY ONE of
///                       {source, other} is a pipe-product (a coupling cannot
///                       attach to another coupling — both need a pipe between).
List<TestResult> testEngine() {
  final results = <TestResult>[];

  final specced =
      kLipskeyCatalog.where((p) => kVerifiedSpecs.containsKey(p.sku)).toList();

  bool isPipe(LipskeyCatalogProduct p) {
    final t = p.productType ?? '';
    return t == 'צינור' || t == 'צנרת' || t == 'גמיש' || t == 'מאריך';
  }

  bool reallyMates(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
    final sa = kVerifiedSpecs[a.sku], sb = kVerifiedSpecs[b.sku];
    if (sa == null || sb == null) return false;
    final aPipe = isPipe(a), bPipe = isPipe(b);
    for (final eA in sa.ends) {
      for (final eB in sb.ends) {
        if (eA.directMatesWith(eB)) return true;
        if (eA.pipeSharedWith(eB) && aPipe != bPipe) {
          final m1 = sa.material, m2 = sb.material;
          if (m1 == m2) return true;
          const drainage = {'PVC', 'PP', 'רב-שכבתי', 'ceramic'};
          if (drainage.contains(m1) && drainage.contains(m2)) return true;
        }
      }
    }
    return false;
  }

  // ── 1. תאימות — אין חיבורי שווא ───────────────────────────────────────────
  // Sample a spread of specced products and verify every compat hit is a real
  // physical mate. A snappy in-app pass samples ~16 products (the full 808-row
  // sweep lives in `flutter test`).
  {
    final samples = <LipskeyCatalogProduct>[];
    final step = specced.isEmpty ? 1 : (specced.length ~/ 16).clamp(1, 9999);
    for (var i = 0; i < specced.length && samples.length < 16; i += step) {
      samples.add(specced[i]);
    }
    var totalHits = 0;
    var invalid = 0;
    var noLabel = 0;
    final firstBad = <String>[];
    final firstBlank = <String>[];
    for (final src in samples) {
      for (final h in compatibleProductsFor(src)) {
        totalHits++;
        if (!reallyMates(src, h)) {
          invalid++;
          if (firstBad.length < 3) firstBad.add('${src.sku}↔${h.sku}');
        }
        if (connectionExplainHe(src, h).isEmpty) {
          noLabel++;
          if (firstBlank.length < 3) firstBlank.add('${src.sku}↔${h.sku}');
        }
      }
    }
    results.add(TestResult(
      id: 'engine:compat-valid',
      category: TestCategory.engine,
      label: 'תאימות — כל חיבור הוא מפגש פיזי אמיתי',
      area: 'תאימות',
      checks: [
        TestCheck(
          name: 'אין חיבורי שווא ($totalHits חיבורים ב-${samples.length} דגימות)',
          pass: invalid == 0,
          expected: '0',
          got: '$invalid',
          detail: firstBad.join(' · '),
        ),
        TestCheck(
          name: 'לכל חיבור יש תווית "למה זה מתחבר"',
          pass: noLabel == 0,
          expected: '0',
          got: '$noLabel',
          detail: firstBlank.join(' · '),
        ),
      ],
    ));
  }

  // ── 2. תאימות — מצמד לא מתחבר למצמד ──────────────────────────────────────
  // The classic false-positive: a coupling (fitting) listed as connecting to
  // another coupling. Both are fittings with compression ends, so neither a
  // direct mate nor a pipe-share applies — the list must contain zero couplings.
  {
    final coupling = specced.where((p) {
      final t = p.productType ?? '';
      return t == 'מצמד' || t == 'ניפל' || t == 'מופה';
    });
    final checks = <TestCheck>[];
    if (coupling.isEmpty) {
      checks.add(const TestCheck(
        name: 'לא נמצא מצמד/ניפל מאומת לבדיקה (דילוג)',
        pass: true,
      ));
    } else {
      final src = coupling.first;
      final srcType = src.productType ?? '';
      final hits = compatibleProductsFor(src);
      final sameKind =
          hits.where((h) => (h.productType ?? '') == srcType).toList();
      checks.add(TestCheck(
        name: '$srcType (${src.sku}) — אפס חיבורים ל-$srcType אחר',
        pass: sameKind.isEmpty,
        expected: '0',
        got: '${sameKind.length}',
        detail: sameKind.take(3).map((p) => p.sku).join(' · '),
      ));
      checks.add(TestCheck(
        name: 'כל חיבור שמוצג באמת מתחבר',
        pass: hits.every((h) => reallyMates(src, h)),
      ));
    }
    results.add(TestResult(
      id: 'engine:no-fitting-to-fitting',
      category: TestCategory.engine,
      label: 'תאימות — מצמד אינו מתחבר למצמד',
      area: 'תאימות',
      checks: checks,
    ));
  }

  // ── 3. מנוע התקנה — בניית שרשרת ──────────────────────────────────────────
  // Build a real installation between two supply anchors and assert the engine
  // produced a connected plan (items present, no open gaps for a mating pair).
  {
    final supply = specced
        .where((p) => productSystems(p).contains(WaterSystem.supply))
        .toList();
    final checks = <TestCheck>[];
    if (supply.length < 2) {
      checks.add(const TestCheck(
          name: 'אין מספיק עוגני הזנה לבדיקה (דילוג)', pass: true));
    } else {
      // Pick the first pair that mates so the chain is guaranteed buildable.
      LipskeyCatalogProduct a = supply.first;
      LipskeyCatalogProduct? b;
      outer:
      for (var i = 0; i < supply.length; i++) {
        for (var j = i + 1; j < supply.length && j < i + 40; j++) {
          if (reallyMates(supply[i], supply[j])) {
            a = supply[i];
            b = supply[j];
            break outer;
          }
        }
      }
      b ??= supply[1];
      final plan = buildInstallation([a, b], tempC: 20);
      checks.add(TestCheck(
        name: 'נבנתה שרשרת עם פריטים (${a.sku} → ${b.sku})',
        pass: plan.items.length >= 2,
        expected: '≥2',
        got: '${plan.items.length}',
      ));
      checks.add(TestCheck(
        name: 'אין פערים פתוחים בזוג מתחבר',
        pass: plan.gaps.isEmpty,
        expected: '0',
        got: '${plan.gaps.length}',
      ));
    }
    results.add(TestResult(
      id: 'engine:install-build',
      category: TestCategory.engine,
      label: 'מנוע התקנה — בניית שרשרת',
      area: 'התקנה',
      checks: checks,
    ));
  }

  // ── 4. תקינות — אפס קריטי פתוח בקו חם ────────────────────────────────────
  // With autoCompliance on, a hot line must close EVERY critical compliance
  // check (shutoff / PRV / Bladder / TMTV / dielectric …) by construction.
  {
    final supply = specced
        .where((p) => productSystems(p).contains(WaterSystem.supply))
        .toList();
    final checks = <TestCheck>[];
    if (supply.length < 2) {
      checks.add(const TestCheck(
          name: 'אין מספיק עוגני הזנה לבדיקה (דילוג)', pass: true));
    } else {
      LipskeyCatalogProduct a = supply.first;
      LipskeyCatalogProduct? b;
      outer:
      for (var i = 0; i < supply.length; i++) {
        for (var j = i + 1; j < supply.length && j < i + 40; j++) {
          if (reallyMates(supply[i], supply[j])) {
            a = supply[i];
            b = supply[j];
            break outer;
          }
        }
      }
      b ??= supply[1];
      const acc = {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'};
      final plan = buildInstallation([a, b],
          tempC: 60, accessories: acc, autoCompliance: true);
      final list = plan.compliance(60, acc);
      final crit =
          list.where((c) => c.severity == CheckSeverity.critical).toList();
      final open = crit.where((c) => !c.satisfied).toList();
      checks.add(TestCheck(
        name: 'אפס בדיקות קריטיות פתוחות (${crit.length} קריטיות נבדקו)',
        pass: open.isEmpty,
        expected: '0',
        got: '${open.length}',
        detail: open.take(3).map((c) => c.label).join(' · '),
      ));
    }
    results.add(TestResult(
      id: 'engine:auto-compliance',
      category: TestCategory.engine,
      label: 'תקינות — אפס קריטי פתוח (correct-by-construction)',
      area: 'תקינות',
      checks: checks,
    ));
  }

  // ── 5. נפילת לחץ — מספרים שפויים ─────────────────────────────────────────
  {
    final supply = specced
        .where((p) => productSystems(p).contains(WaterSystem.supply))
        .toList();
    final checks = <TestCheck>[];
    if (supply.length < 2) {
      checks.add(const TestCheck(name: 'אין עוגנים לבדיקה (דילוג)', pass: true));
    } else {
      LipskeyCatalogProduct a = supply.first;
      LipskeyCatalogProduct? b;
      outer:
      for (var i = 0; i < supply.length; i++) {
        for (var j = i + 1; j < supply.length && j < i + 40; j++) {
          if (reallyMates(supply[i], supply[j])) {
            a = supply[i];
            b = supply[j];
            break outer;
          }
        }
      }
      b ??= supply[1];
      final plan = buildInstallation([a, b], tempC: 20);
      final pd = estimatePressureDrop(plan.items,
          pipeLengthMeters: 5, flowRateLPS: 0.3);
      checks
        ..add(TestCheck(
          name: 'ΔP בטווח הנדסי שפוי (0 < ΔP < 20 בר)',
          pass: pd.dropBar > 0 && pd.dropBar < 20,
          got: '${pd.dropBar.toStringAsFixed(2)} בר',
        ))
        ..add(TestCheck(
          name: 'קוטר מינימלי חיובי',
          pass: pd.minBoreMm > 0,
          got: '${pd.minBoreMm.toStringAsFixed(0)}mm',
        ));
    }
    results.add(TestResult(
      id: 'engine:pressure-drop',
      category: TestCategory.engine,
      label: 'נפילת לחץ — אומדן פיזיקלי שפוי',
      area: 'לחץ',
      checks: checks,
    ));
  }

  // ── 6. ערכת התקנה — נגזרת כלים מהקצוות ───────────────────────────────────
  {
    final threaded = specced.where((p) {
      final s = kVerifiedSpecs[p.sku]!;
      return s.ends.any((e) =>
          e.type == EndType.bspMale || e.type == EndType.bspFemale);
    });
    final checks = <TestCheck>[];
    if (threaded.isEmpty) {
      checks.add(
          const TestCheck(name: 'לא נמצא מוצר מוברג לבדיקה (דילוג)', pass: true));
    } else {
      final p = threaded.first;
      final kit = installKitFor(p);
      checks.add(TestCheck(
        name: 'מוצר מוברג (${p.sku}) — נגזרים כלי עבודה',
        pass: kit != null && kit.tools > 0,
        got: kit == null ? 'null' : '${kit.tools} כלים',
      ));
    }
    results.add(TestResult(
      id: 'engine:install-kit',
      category: TestCategory.engine,
      label: 'ערכת התקנה — נגזרת אוטומטית מהקצוות',
      area: 'ערכה',
      checks: checks,
    ));
  }

  return results;
}
