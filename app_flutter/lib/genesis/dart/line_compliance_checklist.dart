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
  const copperGroup = {'נחושת', 'פליז'};
  const ironGroup = {'פלדה', 'נירוסטה'};
  final s = mats.toSet();
  return s.intersection(copperGroup).isNotEmpty &&
      s.intersection(ironGroup).isNotEmpty;
}

/// A one-way (directional) flow device — copper check valve (אל-חזור/אלחוזר) or
/// sewage backflow preventer (category 'אל חזור') (verbatim: install_engine.dart:171-175).
bool _isDirectionalDevice(ChainPart p) {
  if (p.categoryHe == 'אל חזור') return true;
  final n = p.nameHe.replaceAll('-', '').replaceAll(' ', '');
  return n.contains('אלחזור') || n.contains('אלחוזר');
}

/// Where a directional device at [i] sits in the built [chain], named by its
/// neighbours (verbatim: install_engine.dart:181-188).
String _directionalContext(List<ChainPart> chain, int i) {
  final up = i > 0 ? chain[i - 1].nameHe : null;
  final down = i < chain.length - 1 ? chain[i + 1].nameHe : null;
  if (up != null && down != null) return 'בין "$up" ל-"$down"';
  if (down != null) return 'בכניסת הקו (לפני "$down")';
  if (up != null) return 'ביציאת הקו (אחרי "$up")';
  return 'בקו';
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
          ((p.productType == 'ברז' || p.productType == 'ברז גן') &&
              (p.categoryHe == 'ברזי מעבר' ||
                  p.categoryHe == 'ברזי ניל' ||
                  p.categoryHe == 'ברזי דלי')))
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
          p.productType == 'מחלק' ||
          p.productType == 'ראש מקלחת' ||
          p.productType == 'מקלח' ||
          p.categoryHe == 'מחלקים' ||
          p.categoryHe == 'ראשי מקלחת' ||
          p.categoryHe == 'מערכות אמבטיה' ||
          p.categoryHe == 'ערכות רחצה');

  // Supply-side compliance only applies to a pressurised supply line — a
  // gravity drainage line (traps + drain pipe) doesn't take an isolation valve.
  final isSupply = chain.any((p) => isSupplySku(p.sku));
  // A garden tap / hose outlet can back-siphon dirty water into the potable
  // supply; code requires a vacuum-breaker (anti-siphon) device. No such product
  // exists in the catalog yet, so this surfaces the requirement (warning).
  final hasGardenOutlet = chain.any(
      (p) => p.categoryHe == 'ברזי גן' || p.categoryHe == 'ציוד גן');

  return [
    if (isSupply)
      LineCheck(
          recirc
              ? 'ברז ניתוק ×3 (כניסת דוד + אחרי משאבה + מניפולד)'
              : 'ברז ניתוק לתחזוקה',
          recirc ? isolationCount >= 3 : isolationCount >= 1,
          'בידוד אזורי לתחזוקה',
          severity: CheckSeverity.critical),
    if (isSupply && hasGardenOutlet)
      LineCheck('שובר-ואקום למניעת זרימה-חוזרת', false,
          'ברז-גן/חיבור-צינור דורש הגנה מפני זרימה-חוזרת למי-שתייה — '
          'אין מק"ט בקטלוג, יש לספק בנפרד',
          severity: CheckSeverity.warning),
    // One check PER directional device: name it + where it sits, so the installer
    // can orient EACH valve for flow. The engine can't reject a backwards mount
    // (a check valve's two ends are modelled identically) — but it pinpoints
    // which valve, and between which two parts, to orient.
    for (var i = 0; i < chain.length; i++)
      if (_isDirectionalDevice(chain[i]))
        LineCheck('כיוון התקנה: ${chain[i].nameHe}', false,
            'שסתום חד-כיווני ${_directionalContext(chain, i)} — '
            'התקן בכיוון-הזרימה (אוריינטציה אינה מאומתת אוטומטית)',
            severity: CheckSeverity.warning),
    if (recirc) ...[
      LineCheck('שסתום אל-חזור', has({'HW-CHECK-15'}),
          'מונע זרימה הפוכה בלולאה', severity: CheckSeverity.critical),
      LineCheck('שסתום מאזן / TRV', has({'HW-BALANCE-15'}),
          'איזון הלולאה', severity: CheckSeverity.critical),
      LineCheck('מפוח אוויר', has({'HW-AIRVENT'}),
          'פליטת אוויר בלולאה', severity: CheckSeverity.warning),
    ],
    if (dissimilar)
      LineCheck('רקורד דיאלקטרי', has({'HW-DIELECTRIC-15'}),
          'הפרדה גלוונית בין מתכות', severity: CheckSeverity.critical),
    if (hasPex)
      LineCheck('מפצה התפשטות PEX', has({'HW-EXP-COMP-20'}),
          'PEX מתרחב בחום', severity: CheckSeverity.warning),
    if (hot)
      LineCheck('שסתום פורק לחץ (PRV)', has({'HW-PRV-34'}),
          'מערכת חמה סגורה', severity: CheckSeverity.critical),
    if (hot)
      LineCheck('כלי התפשטות (Bladder Tank)',
          has({'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL'}),
          'ממברנת EPDM מפרידה N₂ ממים — חובה בכל קו חם סגור',
          severity: CheckSeverity.critical),
    if (hasCommercialPump) ...[
      LineCheck('מסנן Y (הגנת משאבה)',
          has({'HW-YSTR-40', 'HW-YSTR-32', 'HW-YSTR-15'}),
          'מונע חלקיקים מלפגוע במשאבה', severity: CheckSeverity.warning),
      LineCheck('מחבר גמיש (ספיגת רעידות)',
          has({'HW-FLEX-40', 'HW-FLEX-32'}),
          'מבודד רעידות המשאבה מהצנרת', severity: CheckSeverity.warning),
    ],
    if (hasManifoldOrShower)
      LineCheck('ברז ערבוב נגד כוויה (TMTV)',
          has({'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15'}),
          'מגביל את המים ל-45°C ביציאה כדי למנוע כוויה',
          severity: CheckSeverity.critical),
    if (hasCommercialPump && hasManifoldOrShower)
      LineCheck('שסתום מאזן לכל ענף (Balancing Valve)',
          has({'HW-BALANCE-25', 'HW-BALANCE-20', 'HW-BALANCE-15'}),
          'מאזן לחץ בין ענפים במערכת מסחרית', severity: CheckSeverity.warning),
    if (hasCommercialPump && hot)
      LineCheck('מעקף חום נגד חיידק לגיונלה (EN 806)',
          has({'HW-DISINFECT'}),
          'פסטור 70°C/3 דקות אחת לשבוע', severity: CheckSeverity.critical),
    if (recirc)
      LineCheck('נקודת דגימת מים (לגיונלה)',
          has({'HW-SAMPLE'}),
          'נדרש לבדיקות מים תקתיות', severity: CheckSeverity.warning),
    if (hot)
      LineCheck('בידוד תרמי', acc('HW-INSUL'),
          'הפסדי חום + סכנת כוויות', severity: CheckSeverity.warning),
    LineCheck('חבקים/תמיכת צנרת', acc('HW-CLIP'),
        'קיבוע ושיפוע', severity: CheckSeverity.info),
    LineCheck('איטום מעברים (Press/PTFE/O-ring)', acc('HW-SEALANT'),
        'אטימות כל מעבר', severity: CheckSeverity.info),
  ];
}
