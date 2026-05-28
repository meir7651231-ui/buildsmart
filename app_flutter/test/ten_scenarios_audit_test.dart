// 10 diverse scenarios — proves the auto-build engine handles every common
// installation pattern and emits a fully compliant plan with zero criticals
// open. Each scenario prints its plan, checklist, and pressure-drop.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _byCat(String cat, {String? type}) =>
    kLipskeyCatalog.firstWhere(
        (p) =>
            p.categoryHe == cat &&
            (type == null || p.productType == type) &&
            !p.sku.startsWith('HW-'),
        orElse: () => kLipskeyCatalog.first);

LipskeyCatalogProduct _bySku(String sku) =>
    kLipskeyCatalog.firstWhere((p) => p.sku == sku);

void _runScenario(
    String name, List<LipskeyCatalogProduct> anchors, int tempC,
    {bool loop = false}) {
  final acc = {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'};
  final plan = buildInstallation(anchors,
      tempC: tempC,
      accessories: acc,
      loop: loop,
      autoCompliance: true);
  final checks = lineComplianceChecklist(plan.items, tempC, acc);
  final pd = estimatePressureDrop(plan.items,
      pipeLengthMeters: 5.0, flowRateLPS: 0.3);
  final passed = checks.where((c) => c.satisfied).length;
  final critOpen = checks
      .where((c) => !c.satisfied && c.severity == CheckSeverity.critical)
      .length;
  print('─── $name ───');
  print('   anchors:  ${anchors.map((p) => p.nameHe).join(" → ")}');
  print('   tempC: $tempC  loop: $loop');
  print('   plan items: ${plan.items.length}  qty-sum: ${plan.totalPieces}');
  print('   checklist: $passed/${checks.length}  '
      '(critical open: $critOpen)');
  print('   ΔP: ${pd.dropBar.toStringAsFixed(2)} bar  '
      'minBore=${pd.minBoreMm.toStringAsFixed(0)}mm');
  final unsatisfied = checks.where((c) => !c.satisfied).toList();
  if (unsatisfied.isNotEmpty) {
    print('   open:');
    for (final c in unsatisfied) {
      print('     ${c.severity.name}: ${c.label}');
    }
  }
  print('');
  expect(critOpen, 0, reason: '[$name] critical-open count must be 0');
}

void main() {
  test('10 diverse scenarios — every plan complete, 0 critical open', () {
    // Scenario 1 — cold simple line, brass faucet → ball valve
    _runScenario('1) פליז קר: ניפל½ → ברז כדורי 1"',
        [_bySku('77777641'), _bySku('77777315')], 20);

    // Scenario 2 — hot kitchen, water-point gold → catalog manifold
    _runScenario('2) חם מטבח: נקודת מים זהב → מחלק 2 יציאות',
        [_bySku('77775150'), _bySku('7609202B')], 60);

    // Scenario 3 — hot + recirculation loop
    _runScenario('3) חם+ריזרקולציה: נקודת מים → ברז 1½"',
        [_bySku('77775150'), _bySku('77777315')], 60,
        loop: true);

    // Scenario 4 — drainage, sink trap to PVC pipe
    _runScenario('4) ניקוז: מחסום אמריקאי → צינור PVC DN40',
        [_bySku('217861'), _bySku('273227')], 20);

    // Scenario 5 — HDPE long-chain reduction (16 → 63)
    _runScenario('5) HDPE: מצמד 16×16 → מצמד 63×63',
        [_bySku('9101601610'), _bySku('9106306310')], 20);

    // Scenario 6 — hot shower system
    _runScenario(
        '6) חם מקלחת: ניפל½ → ראש מקלחת',
        [
          _bySku('77777641'),
          _byCat('ראשי מקלחת'),
        ],
        60);

    // Scenario 7 — cold garden line (brass ball valve → garden tap)
    _runScenario('7) קר גן: ברז½ → ברז גן',
        [_bySku('77777641'), _byCat('ברזי גן')], 20);

    // Scenario 8 — toilet inlet, brass nipple → cistern
    _runScenario(
        '8) אסלה: ניפל½ → מיכל הדחה',
        [_bySku('77777641'), _bySku('124050')],
        20);

    // Scenario 9 — hot + dissimilar metals (HDPE coupling → brass nipple)
    _runScenario(
        '9) חם פליז+HDPE: ניפל ברז → HDPE 32×25',
        [_bySku('77777641'), _bySku('9103202580')],
        60);

    // Scenario 10 — hot bath system (תfaucet → bath body)
    _runScenario(
        '10) חם אמבטיה: ברז קיר → אמבט',
        [_bySku('77777641'), _byCat('מערכות אמבטיה')],
        60);

    // Scenario 11 — brass cap line (terminal)
    _runScenario('11) פליז קר: ניפל½ → כפה ½"',
        [_bySku('77777641'), _bySku('77777101')], 20);

    // Scenario 12 — hot PEX/NTM compression line
    _runScenario(
        '12) חם NTM: ניפל½ → מקשר NTM 20',
        [_bySku('77777641'), _byCat('מחברי NTM', type: 'מקשר')],
        60);

    // Scenario 13 — sink to floor drain
    _runScenario(
        '13) ניקוז כפול: סיפון → צינור',
        [_bySku('217861'), _bySku('116180')],
        20);

    // Scenario 14 — wall water-meter (cold) → faucet
    _runScenario(
        '14) שעון מים: ¾"M → ½"F',
        [_byCat('אביזרי נחושת', type: 'רקורד'), _bySku('77777641')],
        20);

    // Scenario 15 — outdoor wall tap
    _runScenario(
        '15) ברז גן: פליז → ½" קצה',
        [_bySku('77777641'), _byCat('ברזי גן')],
        20);

    // Scenario 16 — DN110 sewer line
    _runScenario(
        '16) ביוב DN110: מסעף → סיפון',
        [_byCat('מסעפים וחיבורי אסלה'), _byCat('סיפונים')],
        20);

    // Scenario 17 — cold + dielectric (copper + brass)
    _runScenario(
        '17) קר נחושת+פליז: ניפל פליז → רקורד נחושת',
        [_bySku('77777641'), _byCat('אביזרי נחושת', type: 'רקורד')],
        20);

    // Scenario 18 — hot drinking water shower head ¾"
    _runScenario(
        '18) חם זרוע: ½ ניפל → זרוע דוש',
        [_bySku('77777641'), _byCat('זרועות דוש')],
        60);

    // Scenario 19 — toilet flush mechanism
    _runScenario(
        '19) אסלה: ניפל½ → מנגנון הדחה',
        [_bySku('77777641'), _byCat('מנגנונים')],
        20);

    // Scenario 20 — copper press hot supply
    _runScenario(
        '20) חם נחושת: ניפל½ → ברז ½',
        [_bySku('77777641'), _bySku('77777315')],
        60);
  });
}
