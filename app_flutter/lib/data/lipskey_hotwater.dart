// Hot-water + recirculation product family (PEX / copper / brass).
//
// These complement the HDPE (cold-water) catalog so the compatibility engine
// can build a high-temperature line — and, just as important, REJECT HDPE
// products for hot-water service via the maxTempC ratings in kVerifiedSpecs.
//
// SKUs here mirror the entries added to kVerifiedSpecs (see
// lipskey_verified_connections.dart). They are synthetic ('HW-…') because the
// AQUATEC HDPE catalogue does not carry these items.

import 'package:buildsmart/data/lipskey_catalog.dart';

const _catHe   = 'מים חמים ו-recirculation';
const _catEn   = 'Hot Water & Recirculation';
const _catIcon = '🔥';

LipskeyCatalogProduct _hw(String sku, String nameHe, String nameEn) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: nameEn,
      categoryHe: _catHe,
      categoryEn: _catEn,
      categoryEmoji: _catIcon,
      page: 0,
      brand: 'AQUATEC',
    );

final List<LipskeyCatalogProduct> kHotWaterCatalog = [
  // pump side (brass interface + isolation)
  _hw('HW-PUMP-25',        'משאבת recirculation (יציאה 1")',      'Recirculation pump 1" outlet'),
  _hw('HW-BALL-INLET-1',   'ברז כדורי 1" (כניסת דוד/משאבה)',     'Ball valve 1" (boiler/pump inlet)'),
  _hw('HW-UNION-1',        'רקורד פליז 1" (ניתוק לתחזוקה)',       'Brass union 1" (serviceable)'),
  _hw('HW-BALL-1',         'ברז כדורי 1"',                         'Ball valve 1"'),
  // brass → PEX transition + PEX run
  _hw('HW-ADP-1-PEX20',    'מצמד מעבר פליז 1"×PEX 20',        'Brass adapter 1"×PEX 20'),
  _hw('HW-PEX-20',         'צינור PEX 20×2.8 (מים חמים)',     'PEX pipe 20×2.8 (hot water)'),
  _hw('HW-PEX-RED-20-16',  'מצמד מפחית PEX 20×16',            'PEX reducing coupler 20×16'),
  _hw('HW-PEX-16',         'צינור PEX 16×2.0 (מים חמים)',     'PEX pipe 16×2.0 (hot water)'),
  // PEX → copper transition + copper run
  _hw('HW-ADP-PEX16-CU15', 'מצמד מעבר PEX 16×נחושת DN15',     'PEX×copper adapter 16×DN15'),
  _hw('HW-CU-15',          'צינור נחושת Type L DN15',         'Copper pipe Type L DN15'),
  _hw('HW-BALL-15',        'ברז ניתוק DN15 (press)',          'Isolation valve DN15 (press)'),
  // manifold + shower
  _hw('HW-MANIFOLD-3',     'מחלק (מניפולד) 3 יציאות 1/2"',    'Manifold 3×1/2" outlets'),
  _hw('HW-SHOWER-ARM',     'זרוע מקלחת 1/2"',                 'Shower arm 1/2"'),
  _hw('HW-SHOWER-HEAD',    'ראש מקלחת 1/2"',                  'Shower head 1/2"'),
  // galvanic isolation + thermal expansion
  _hw('HW-DIELECTRIC-15',  'רקורד דיאלקטרי DN15 (הפרדה גלוונית)', 'Dielectric union DN15'),
  _hw('HW-EXP-COMP-20',    'מפצה התפשטות PEX 20',             'PEX expansion compensator 20'),
  // recirculation loop
  _hw('HW-TEE-RECIRC',     'מסעף (טי) recirculation DN15',    'Recirculation tee DN15'),
  _hw('HW-CHECK-15',       'מסתם אל-חזור DN15 (recirc)',      'Check valve DN15 (recirc)'),
  _hw('HW-BALANCE-15',     'שסתום מאזן תרמוסטטי DN15',        'Thermostatic balancing valve DN15'),
  _hw('HW-AIRVENT',        'מפוח אוויר אוטומטי 1/2"',          'Automatic air vent 1/2"'),
  // safety (closed hot loop)
  _hw('HW-PRV-34',         'שסתום פורק לחץ 3/4"',             'Pressure relief valve 3/4"'),
  _hw('HW-EXPVESSEL',      'כלי התפשטות תרמית',               'Thermal expansion vessel'),
  // installation accessories (not in series — wrap / support / seal)
  _hw('HW-INSUL',          'בידוד תרמי לצנרת',                'Pipe thermal insulation'),
  _hw('HW-CLIP',           'חבק/תושבת צינור',                 'Pipe clip / hanger'),
  _hw('HW-SEALANT',        'איטום תבריג PTFE / O-ring',       'Thread sealant PTFE / O-ring'),
];

/// SKUs that are accessories (no series connection — insulation, clips, seal).
const Set<String> kHotWaterAccessorySkus = {
  'HW-INSUL', 'HW-CLIP', 'HW-SEALANT',
};

/// Catalog used by the compatibility / chain-builder screen: the full HDPE
/// cold-water catalogue plus the hot-water family.
final List<LipskeyCatalogProduct> kCompatCatalog = [
  ...kLipskeyCatalog,
  ...kHotWaterCatalog,
];
