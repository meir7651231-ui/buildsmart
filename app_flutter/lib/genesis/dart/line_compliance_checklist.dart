import '../dart-data/line_compliance_checklist-uidata.dart';
// ⚛️ אטום-Dart (דרגת-חוזה) · lineComplianceChecklist
// מוצא: install_engine.dart:194-368 (origin/main — ‏lineComplianceChecklist; חוק-4).
//        זהו אטום נפרד ומלא — לא ה-compliance.dart הגנרי (עוזר-dedup).
//        עוגני-main: enum CheckSeverity :84 · LineCheck :86-93 · הגוף :241-367.
//        עוזרים-פרטיים verbatim: _galvanicallyDissimilar :158-164 (מקודם גם כאטום
//        עצמאי galvanically_dissimilar.dart) · _isDirectionalDevice :171-175
//        (⇒ is_directional_device.dart) · _directionalContext :181-188
//        (⇒ directional_context.dart). אטום אינו מייבא אטום (חוק-1/L1) ⇒ העוזרים
//        מוטבעים כאן כעותק-פרטי, ומקודמים בנפרד כברגים עצמאיים.
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       הקבועים _kHotThresholdC=60 (מקור:28) ו-_kIsolationValveSkus (:32-36)
//       הוטבעו כדאטה פנימית (לא הקשר/זהות/סוד).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `productMaterial(p)` (=kVerifiedSpecs[p.sku]?.material, מקור:61,242) → שקע
//     `materialOf(sku) → String?` (‏null כשאין spec).
//   • `lineIsSupply(chain)` (מקור:75-76,282, =any endSystems.contains(supply)) → שקע
//     `isSupplySku(sku) → bool`; ה-isSupply מחושב מקומית `chain.any((p)=>isSupplySku(p.sku))`.
//   • מחזיק-הקלט ChainPart = ארבעת השדות שהגוף קורא: sku · productType? · categoryHe ·
//     nameHe (‏nameHe נדרש לבדיקת-כיוון-ההתקנה החדשה; חוק-2 מינימום-הנדרש).
//
// ‏⚠️ תפר-s41 (trade) שב-main:205-239 **אינו** באטום: זו האצלה לפותר-מקצוע-אחר
//   (ProductConnectorSpec/ConnectionResolver — חיווט-דומיין ברמת-קופסה, לא פיזיקת-
//   אינסטלציה טהורה). האטום מגלם את ענף-האינסטלציה הקבוע (R1-2 KEYSTONE, main:241-367)
//   verbatim; קופסה הרוצה האצלת-מקצוע מחווטת אותה מעליו.
//
// התנהגות (מקור:241-367): מזהה את רכיבי-הבטיחות/עמידות שקו-חם/אספקה מחייב והאם
//   הם קיימים בשרשרת — ממיר סקירת-מומחה לשער-אוטומטי. הרשימה נבנית עם if-collection
//   verbatim (סדר, תנאים, תוויות, סיבות, חומרות — ביט-אחר-ביט). חדש מול ה-snapshot:
//   שובר-ואקום (isSupply && ברז-גן, :298-302) · בדיקת-כיוון פר-שסתום-חד-כיווני (:307-312) ·
//   dissimilar דרך _galvanicallyDissimilar (:251 — קבוצת-נחושת ∩ קבוצת-ברזל, לא עוד
//   "נחושת + 2 מתכות"; נחושת↔פליז שוב אינו מסומן).
//
// קלט:  chain       — רשימת ChainPart (sku · productType? · categoryHe · nameHe).
//       tempC       — טמפרטורת-הקו (int, °C).
//       accessories — קבוצת-SKU של אביזרים שאושרו ידנית (בידוד/חבק/איטום).
//       materialOf  — שקע: sku → תווית-חומר (String) או null (אין spec).
//       isSupplySku — שקע: sku → האם קצות-המוצר כוללים אספקה (bool).
// פלט:  List<LineCheck> — פריטי-הצ׳קליסט הפעילים לקו הזה.

/// Severity of a compliance check failure (verbatim: install_engine.dart:80-84).
/// critical → safety/code risk · warning → durability/performance · info → good practice.
enum CheckSeverity { critical, warning, info }

/// One compliance line-item (verbatim: install_engine.dart:86-93).
class LineCheck {
  const LineCheck(this.label, this.satisfied, this.why,
      {this.severity = CheckSeverity.warning});
  final String label;
  final bool satisfied;
  final String why;
  final CheckSeverity severity;
}

/// Pure input holder — the four fields the checklist reads off each product.
class ChainPart {
  final String sku;
  final String? productType;
  final String categoryHe;
  final String nameHe;
  const ChainPart(this.sku, this.categoryHe,
      {this.productType, this.nameHe = ''});
}

/// Temperature (°C) at/above which a line counts as "hot" (verbatim: install_engine.dart:28).
const _kHotThresholdC = 60;

/// Isolation ball valves — any one satisfies the shut-off requirement
/// (verbatim: install_engine.dart:32-36).
const _kIsolationValveSkus = {
  'HW-BALL-INLET-1', 'HW-BALL-INLET-40',
  'HW-BALL-1', 'HW-BALL-15', 'HW-BALL-40', 'HW-BALL-32',
  'HW-BALL-CU-40', 'HW-BALL-CU-32', 'HW-BALL-CU-25', 'HW-BALL-CU-20',
};

/// Galvanic corrosion needs a dielectric union only between DISSIMILAR metal
/// GROUPS: copper-group (נחושת/פליז) joined to iron-group (פלדה/נירוסטה). Same-group
/// joints (copper↔brass) are benign and must NOT be flagged (verbatim: :158-164).
bool _galvanicallyDissimilar(Iterable<String> mats) {
  const copperGroup = {'${k1}', '${k2}'};
  const ironGroup = {'${k3}', '${k4}'};
  final s = mats.toSet();
  return s.intersection(copperGroup).isNotEmpty &&
      s.intersection(ironGroup).isNotEmpty;
}

/// A one-way (directional) flow device — copper check valve (אל-חזור/אלחוזר) or
/// sewage backflow preventer (category 'אל חזור') (verbatim: install_engine.dart:171-175).
bool _isDirectionalDevice(ChainPart p) {
  if (p.categoryHe == '${k5}') return true;
  final n = p.nameHe.replaceAll('-', '').replaceAll(' ', '');
  return n.contains('${k6}') || n.contains('${k7}');
}

/// Where a directional device at [i] sits in the built [chain], named by its
/// neighbours (verbatim: install_engine.dart:181-188).
String _directionalContext(List<ChainPart> chain, int i) {
  final up = i > 0 ? chain[i - 1].nameHe : null;
  final down = i < chain.length - 1 ? chain[i + 1].nameHe : null;
  if (up != null && down != null) return '${k8}$up${k9}$down"';
  if (down != null) return '${k10}$down")';
  if (up != null) return '${k11}$up")';
  return '${k12}';
}

/// Detects the safety/durability components a hot line requires and whether the
/// current chain includes them — turning expert review into an automatic gate.
List<LineCheck> lineComplianceChecklist(
  List<ChainPart> chain,
  int tempC,
  Set<String> accessories, {
  required String? Function(String sku) materialOf,
  required bool Function(String sku) isSupplySku,
}) {
  final skus = chain.map((p) => p.sku).toSet();
  final mats =
      chain.map((p) => materialOf(p.sku)).whereType<String>().toSet();
  bool has(Set<String> ok) => skus.any(ok.contains);
  bool acc(String s) => accessories.contains(s);

  final hot = tempC >= _kHotThresholdC;
  final hasPex = mats.contains('PEX');
  final recirc = skus.contains('HW-PUMP-25') || skus.contains('HW-TEE-RECIRC');
  // Galvanic risk: a copper-group metal joined to an iron-group metal
  // (see _galvanicallyDissimilar) — catches brass↔steel and any↔stainless.
  final dissimilar = _galvanicallyDissimilar(mats);
  // Count BOTH synthetic and real catalog ball valves as shutoffs.
  final isolationCount = chain
      .where((p) =>
          _kIsolationValveSkus.contains(p.sku) ||
          ((p.productType == '${k13}' || p.productType == '${k14}') &&
              (p.categoryHe == '${k15}' ||
                  p.categoryHe == '${k16}' ||
                  p.categoryHe == '${k17}')))
      .length;

  final hasCommercialPump = skus.contains('HW-PUMP-40');
  // Recognise BOTH synthetic hot-water SKUs AND real catalog products by
  // type/category — a "מחלק" (distribution manifold) or shower head from
  // the regular Lipskey catalog also needs TMTV anti-scald in a hot line.
  final hasManifoldOrShower = has({
        'HW-MANIFOLD-3', 'HW-MANIFOLD-4', 'HW-MANIFOLD-6',
        'HW-SHOWER-HEAD',
        'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15',
      }) ||
      chain.any((p) =>
          p.productType == '${k18}' ||
          p.productType == '${k19}' ||
          p.productType == '${k20}' ||
          p.categoryHe == '${k21}' ||
          p.categoryHe == '${k22}' ||
          p.categoryHe == '${k23}' ||
          p.categoryHe == '${k24}');

  // Supply-side compliance only applies to a pressurised supply line — a
  // gravity drainage line (traps + drain pipe) doesn't take an isolation valve.
  final isSupply = chain.any((p) => isSupplySku(p.sku));
  // A garden tap / hose outlet can back-siphon dirty water into the potable
  // supply; code requires a vacuum-breaker (anti-siphon) device. No such product
  // exists in the catalog yet, so this surfaces the requirement (warning).
  final hasGardenOutlet = chain.any(
      (p) => p.categoryHe == '${k25}' || p.categoryHe == '${k26}');

  return [
    if (isSupply)
      LineCheck(
          recirc
              ? '${k27}'
              : '${k28}',
          recirc ? isolationCount >= 3 : isolationCount >= 1,
          '${k29}',
          severity: CheckSeverity.critical),
    if (isSupply && hasGardenOutlet)
      LineCheck('${k30}', false,
          '${k31}'
          '${k32}',
          severity: CheckSeverity.warning),
    // One check PER directional device: name it + where it sits, so the installer
    // can orient EACH valve for flow. The engine can't reject a backwards mount
    // (a check valve's two ends are modelled identically) — but it pinpoints
    // which valve, and between which two parts, to orient.
    for (var i = 0; i < chain.length; i++)
      if (_isDirectionalDevice(chain[i]))
        LineCheck('${k33}${chain[i].nameHe}', false,
            '${k34}${_directionalContext(chain, i)} — '
            '${k35}',
            severity: CheckSeverity.warning),
    if (recirc) ...[
      LineCheck('${k36}', has({'HW-CHECK-15'}),
          '${k37}', severity: CheckSeverity.critical),
      LineCheck('${k38}', has({'HW-BALANCE-15'}),
          '${k39}', severity: CheckSeverity.critical),
      LineCheck('${k40}', has({'HW-AIRVENT'}),
          '${k41}', severity: CheckSeverity.warning),
    ],
    if (dissimilar)
      LineCheck('${k42}', has({'HW-DIELECTRIC-15'}),
          '${k43}', severity: CheckSeverity.critical),
    if (hasPex)
      LineCheck('${k44}', has({'HW-EXP-COMP-20'}),
          '${k45}', severity: CheckSeverity.warning),
    if (hot)
      LineCheck('${k46}', has({'HW-PRV-34'}),
          '${k47}', severity: CheckSeverity.critical),
    if (hot)
      LineCheck('${k48}',
          has({'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL'}),
          '${k49}',
          severity: CheckSeverity.critical),
    if (hasCommercialPump) ...[
      LineCheck('${k50}',
          has({'HW-YSTR-40', 'HW-YSTR-32', 'HW-YSTR-15'}),
          '${k51}', severity: CheckSeverity.warning),
      LineCheck('${k52}',
          has({'HW-FLEX-40', 'HW-FLEX-32'}),
          '${k53}', severity: CheckSeverity.warning),
    ],
    if (hasManifoldOrShower)
      LineCheck('${k54}',
          has({'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15'}),
          '${k55}',
          severity: CheckSeverity.critical),
    if (hasCommercialPump && hasManifoldOrShower)
      LineCheck('${k56}',
          has({'HW-BALANCE-25', 'HW-BALANCE-20', 'HW-BALANCE-15'}),
          '${k57}', severity: CheckSeverity.warning),
    if (hasCommercialPump && hot)
      LineCheck('${k58}',
          has({'HW-DISINFECT'}),
          '${k59}', severity: CheckSeverity.critical),
    if (recirc)
      LineCheck('${k60}',
          has({'HW-SAMPLE'}),
          '${k61}', severity: CheckSeverity.warning),
    if (hot)
      LineCheck('${k62}', acc('HW-INSUL'),
          '${k63}', severity: CheckSeverity.warning),
    LineCheck('${k64}', acc('HW-CLIP'),
        '${k65}', severity: CheckSeverity.info),
    LineCheck('${k66}', acc('HW-SEALANT'),
        '${k67}', severity: CheckSeverity.info),
  ];
}
