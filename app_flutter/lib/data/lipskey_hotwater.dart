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
  // commercial pump island (DN40 BSP)
  _hw('HW-YSTR-40',         'מסנן Y DN40 (הגנת משאבה)',                  'Y-strainer DN40 (pump protection)'),
  _hw('HW-YSTR-32',         'מסנן Y DN32',                                'Y-strainer DN32'),
  _hw('HW-YSTR-15',         'מסנן Y DN15 (כניסת חזרה)',                   'Y-strainer DN15 (return protection)'),
  _hw('HW-FLEX-40',         'מחבר גמיש DN40 (ספיגת רעידות)',              'Flexible connector DN40 (vibration isolation)'),
  _hw('HW-FLEX-32',         'מחבר גמיש DN32',                              'Flexible connector DN32'),
  _hw('HW-PUMP-40',         'משאבת recirculation VSP DN40 (מסחרי)',        'Commercial VSP pump DN40'),
  _hw('HW-BALL-INLET-40',   'ברז כדורי 1½" (כניסת משאבה מסחרית)',         'Ball valve 1½" (commercial pump inlet)'),
  _hw('HW-BALL-40',         'ברז כדורי 1½" BSP',                           'Ball valve 1½" BSP'),
  _hw('HW-BALL-32',         'ברז כדורי 1¼" BSP',                           'Ball valve 1¼" BSP'),
  _hw('HW-CHECK-40',        'מסתם אל-חזור DN40 1½"',                       'Check valve DN40 1½"'),
  _hw('HW-CHECK-32',        'מסתם אל-חזור DN32 1¼"',                       'Check valve DN32 1¼"'),
  // copper press inline valves
  _hw('HW-BALL-CU-40',      'ברז כדורי DN40 (Press)',                       'Ball valve DN40 copper press'),
  _hw('HW-BALL-CU-32',      'ברז כדורי DN32 (Press)',                       'Ball valve DN32 copper press'),
  _hw('HW-BALL-CU-25',      'ברז כדורי DN25 (Press)',                       'Ball valve DN25 copper press'),
  _hw('HW-BALL-CU-20',      'ברז כדורי DN20 (Press)',                       'Ball valve DN20 copper press'),
  _hw('HW-CHECK-CU-20',     'מסתם אל-חזור DN20 (Press)',                    'Check valve DN20 copper press'),
  // bladder expansion tanks
  _hw('HW-BTANK-35',        'כלי התפשטות Bladder 35L (N₂)',                 'Bladder expansion tank 35L'),
  _hw('HW-BTANK-18',        'כלי התפשטות Bladder 18L (N₂)',                 'Bladder expansion tank 18L'),
  // instrumentation
  _hw('HW-GAUGE',           'מד לחץ 0–10 bar (¼" BSP)',                    'Pressure gauge 0–10 bar'),
  _hw('HW-DRAIN-12',        'ברז ניקוז/purge ½"',                           'Drain/purge valve ½"'),
  _hw('HW-PT1000',          'חיישן טמפ\' PT1000 + thermowell ½"',           'PT1000 temperature sensor ½" thermowell'),
  // copper pipes (larger DN)
  _hw('HW-CU-40',           'צינור נחושת Type L DN40',                      'Copper pipe Type L DN40'),
  _hw('HW-CU-32',           'צינור נחושת Type L DN32',                      'Copper pipe Type L DN32'),
  _hw('HW-CU-25',           'צינור נחושת Type L DN25',                      'Copper pipe Type L DN25'),
  _hw('HW-CU-20',           'צינור נחושת Type L DN20',                      'Copper pipe Type L DN20'),
  // adapters BSP ↔ copper DN40
  _hw('HW-ADP-BSP112-CU40', 'מצמד מעבר 1½" BSP → נחושת DN40',             'Adapter 1½" BSP → copper DN40'),
  _hw('HW-ADP-CU40-BSP112', 'מצמד מעבר נחושת DN40 → 1½" BSP',             'Adapter copper DN40 → 1½" BSP'),
  // copper reducers
  _hw('HW-RED-CU-40-32',    'מצמד מפחית נחושת DN40→DN32',                  'Copper reducer DN40→DN32'),
  _hw('HW-RED-CU-32-25',    'מצמד מפחית נחושת DN32→DN25',                  'Copper reducer DN32→DN25'),
  _hw('HW-RED-CU-25-20',    'מצמד מפחית נחושת DN25→DN20',                  'Copper reducer DN25→DN20'),
  _hw('HW-RED-CU-20-15',    'מצמד מפחית נחושת DN20→DN15',                  'Copper reducer DN20→DN15'),
  // dielectric unions — larger DN
  _hw('HW-DIELECTRIC-40',   'רקורד דיאלקטרי DN40',                          'Dielectric union DN40'),
  _hw('HW-DIELECTRIC-32',   'רקורד דיאלקטרי DN32',                          'Dielectric union DN32'),
  _hw('HW-DIELECTRIC-25',   'רקורד דיאלקטרי DN25',                          'Dielectric union DN25'),
  _hw('HW-DIELECTRIC-20',   'רקורד דיאלקטרי DN20',                          'Dielectric union DN20'),
  // expansion bellows
  _hw('HW-BELLOWS-40',      'מפצה התפשטות DN40 (Bellows)',                  'Expansion bellows DN40'),
  _hw('HW-BELLOWS-32',      'מפצה התפשטות DN32 (Bellows)',                  'Expansion bellows DN32'),
  _hw('HW-BELLOWS-25',      'מפצה התפשטות DN25 (Bellows)',                  'Expansion bellows DN25'),
  _hw('HW-BELLOWS-20',      'מפצה התפשטות DN20 (Bellows)',                  'Expansion bellows DN20'),
  // TMTV anti-scald
  _hw('HW-TMTV-32',         'שסתום ערבוב תרמוסטטי TMTV DN32 (set 60°C)',   'TMTV thermostatic mixing valve DN32'),
  _hw('HW-TMTV-25',         'שסתום ערבוב תרמוסטטי TMTV DN25 (set 55°C)',   'TMTV thermostatic mixing valve DN25'),
  _hw('HW-TMTV-20',         'שסתום ערבוב תרמוסטטי TMTV DN20 (set 45°C)',   'TMTV thermostatic mixing valve DN20'),
  _hw('HW-TMTV-15',         'שסתום ערבוב תרמוסטטי TMTV DN15 (set 45°C)',   'TMTV thermostatic mixing valve DN15'),
  // pre-set balancing valves
  _hw('HW-BALANCE-25',      'שסתום מאזן מוגדר-מראש DN25',                  'Pre-set balancing valve DN25'),
  _hw('HW-BALANCE-20',      'שסתום מאזן מוגדר-מראש DN20',                  'Pre-set balancing valve DN20'),
  // copper tees
  _hw('HW-TEE-CU-25',       'מסעף (טי) נחושת DN25',                         'Copper tee DN25'),
  _hw('HW-TEE-CU-20',       'מסעף (טי) נחושת DN20',                         'Copper tee DN20'),
  // manifolds
  _hw('HW-MANIFOLD-4',      'מחלק (מניפולד) 4 יציאות ½"',                   'Manifold 4×½" outlets'),
  _hw('HW-MANIFOLD-6',      'מחלק (מניפולד) 6 יציאות ½"',                   'Manifold 6×½" outlets'),
  // PEX-B 25×3.5
  _hw('HW-PEX-25',          'צינור PEX-B 25×3.5 (מסחרי)',                   'PEX-B pipe 25×3.5 (commercial)'),
  _hw('HW-PEX-RED-25-20',   'מצמד מפחית PEX-B 25×20',                      'PEX-B reducing coupler 25×20'),
  _hw('HW-ADP-112-PEX25',   'מצמד מעבר 1½" BSP → PEX-B 25',               'Adapter 1½" BSP → PEX-B 25'),
  _hw('HW-ADP-PEX25-CU25',  'מצמד מעבר PEX-B 25 × נחושת DN25',            'PEX-B 25 × copper DN25 adapter'),
  _hw('HW-ADP-PEX25-CU20',  'מצמד מעבר PEX-B 25 × נחושת DN20',            'PEX-B 25 × copper DN20 adapter'),
  // safety / compliance
  _hw('HW-DISINFECT',       'שסתום bypass תרמי (Legionella pasteurization)', 'Thermal disinfection bypass valve'),
  _hw('HW-SAMPLE',          'נקודת דיגום ¼" (בדיקות Legionella)',            'Legionella sampling port ¼"'),
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
  'HW-BTANK-35', 'HW-BTANK-18',
  'HW-GAUGE', 'HW-DRAIN-12', 'HW-PT1000',
  'HW-SAMPLE',
};

/// Catalog used by the compatibility / chain-builder screen: the full HDPE
/// cold-water catalogue plus the hot-water family.
final List<LipskeyCatalogProduct> kCompatCatalog = [
  ...kLipskeyCatalog,
  ...kHotWaterCatalog,
];
