// ─────────────────────────────────────────────────────────────────────────
// Polyroll / Heliroma PPR pipe-system catalog (importer: חוליות אגש"ח).
// Source PDF: PolyrollHeliroma_HE_020325 (40 pp). Standards: ת"י 5111-5.
//
// INGESTION TARGET — the full PDF holds ~779 SKUs. This file is the landing
// zone: it is SEEDED with real sample products (a few per category, taken
// verbatim from the PDF tables) so the new "צנרת PPR" branch is browsable and
// the sync tests stay green. To finish ingestion, append the remaining rows to
// [kPolyrollCatalog] under the matching kPpr* category constant — no other file
// needs to change.
//
// Row shape per PDF table: מק"ט חוליות (8-digit) · קוטר×עובי · SDR · d/S/d1.
// We keep the 8-digit חוליות code as [sku] and build [nameHe] = type + size.
// ─────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';

/// Brand id (see kBrands in brands.dart) carried by every Polyroll product.
const String kPolyrollBrand = 'פולירול';

// ── Category constants — each maps 1:1 to a catalog-tree leaf.lipskeyCategory.
const String kPprPipesSupply = 'צינורות PPR אספקת מים';
const String kPprPipesFiber = 'צינורות PPR פייזר';
const String kPprElbows = 'ברכיים PPR';
const String kPprTees = 'מסעפים PPR';
const String kPprCouplers = 'מצמדים PPR';
const String kPprAdapters = 'מתאמים PPR';
const String kPprSaddles = 'רוכבים PPR';
const String kPprPlugs = 'פקקים PPR';
const String kPprOmega = 'אומגה PPR';
const String kPprValves = 'ברזים PPR';
const String kPprCollars = 'צווארונים ואוגנים PPR';
const String kPprElectrofusion = 'אביזרי ריתוך חשמלי PPR';

/// Small helper so the seed list stays terse and consistent. All Polyroll
/// products share brand + (missing) imagery; only sku/name/category/page vary.
LipskeyCatalogProduct _ppr(
  String sku,
  String nameHe,
  String nameEn,
  String categoryHe,
  String categoryEn,
  String emoji,
  int page,
) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: nameEn,
      categoryHe: categoryHe,
      categoryEn: categoryEn,
      categoryEmoji: emoji,
      page: page,
      brand: kPolyrollBrand,
    );

/// SEED products (real rows from the PDF). Append the rest here to ingest.
final List<LipskeyCatalogProduct> kPolyrollCatalog = [
  // ── צינורות אספקת מים — PN20 / SDR6 (עמ' 17) ────────────────────────────
  _ppr('95016002', 'צינור PPR אספקת מים 20', 'PPR Supply Pipe 20',
      kPprPipesSupply, 'PPR Supply Pipes', '🔵', 17),
  _ppr('95016003', 'צינור PPR אספקת מים 25', 'PPR Supply Pipe 25',
      kPprPipesSupply, 'PPR Supply Pipes', '🔵', 17),
  _ppr('95016004', 'צינור PPR אספקת מים 32', 'PPR Supply Pipe 32',
      kPprPipesSupply, 'PPR Supply Pipes', '🔵', 17),
  _ppr('95016005', 'צינור PPR אספקת מים 40', 'PPR Supply Pipe 40',
      kPprPipesSupply, 'PPR Supply Pipes', '🔵', 17),
  _ppr('95016006', 'צינור PPR אספקת מים 50', 'PPR Supply Pipe 50',
      kPprPipesSupply, 'PPR Supply Pipes', '🔵', 17),

  // ── צינורות פייזר (מחוזק סיבי זכוכית) — PN16 / SDR7.4 (עמ' 18) ───────────
  _ppr('95270708', 'צינור PPR פייזר 20', 'PPR Faser Pipe 20', kPprPipesFiber,
      'PPR Faser Pipes', '🟦', 18),
  _ppr('95270710', 'צינור PPR פייזר 25', 'PPR Faser Pipe 25', kPprPipesFiber,
      'PPR Faser Pipes', '🟦', 18),
  _ppr('95270712', 'צינור PPR פייזר 32', 'PPR Faser Pipe 32', kPprPipesFiber,
      'PPR Faser Pipes', '🟦', 18),
  _ppr('95270714', 'צינור PPR פייזר 40', 'PPR Faser Pipe 40', kPprPipesFiber,
      'PPR Faser Pipes', '🟦', 18),
  _ppr('95270718', 'צינור PPR פייזר 63', 'PPR Faser Pipe 63', kPprPipesFiber,
      'PPR Faser Pipes', '🟦', 18),
  _ppr('95270724', 'צינור PPR פייזר 110', 'PPR Faser Pipe 110', kPprPipesFiber,
      'PPR Faser Pipes', '🟦', 18),

  // ── ברכיים — ריתוך 45°/90°, פנים/פנים + פנים/חוץ (עמ' 18-19) ─────────────
  _ppr('92117102', 'ברך PPR 45° 20', 'PPR Elbow 45° 20', kPprElbows,
      'PPR Elbows', '↪️', 18),
  _ppr('92117104', 'ברך PPR 45° 32', 'PPR Elbow 45° 32', kPprElbows,
      'PPR Elbows', '↪️', 18),
  _ppr('92117042', 'ברך PPR 90° 20', 'PPR Elbow 90° 20', kPprElbows,
      'PPR Elbows', '↪️', 18),
  _ppr('92117044', 'ברך PPR 90° 32', 'PPR Elbow 90° 32', kPprElbows,
      'PPR Elbows', '↪️', 18),
  _ppr('92117046', 'ברך PPR 90° 50', 'PPR Elbow 90° 50', kPprElbows,
      'PPR Elbows', '↪️', 18),
  _ppr('92317122', 'ברך PPR 45° פנים חוץ 20', 'PPR Elbow 45° M/F 20', kPprElbows,
      'PPR Elbows', '↪️', 19),
  _ppr('92317062', 'ברך PPR 90° פנים חוץ 20', 'PPR Elbow 90° M/F 20', kPprElbows,
      'PPR Elbows', '↪️', 19),

  // ── מסעפים — ריתוך + מצרה (עמ' 19-20) ────────────────────────────────────
  _ppr('94117202', 'מסעף PPR 20', 'PPR Tee 20', kPprTees, 'PPR Tees', '🔱', 19),
  _ppr('94117204', 'מסעף PPR 32', 'PPR Tee 32', kPprTees, 'PPR Tees', '🔱', 19),
  _ppr('94117206', 'מסעף PPR 50', 'PPR Tee 50', kPprTees, 'PPR Tees', '🔱', 19),
  _ppr('94517251', 'מסעף PPR מצרה 20x25x20', 'PPR Reducing Tee 20x25x20',
      kPprTees, 'PPR Tees', '🔱', 20),

  // ── מצמדים — ריתוך + מצרה (עמ' 21-22) ───────────────────────────────────
  _ppr('91117002', 'מצמד PPR 20', 'PPR Coupler 20', kPprCouplers,
      'PPR Couplers', '🔗', 21),
  _ppr('91117004', 'מצמד PPR 32', 'PPR Coupler 32', kPprCouplers,
      'PPR Couplers', '🔗', 21),
  _ppr('91117006', 'מצמד PPR 50', 'PPR Coupler 50', kPprCouplers,
      'PPR Couplers', '🔗', 21),
  _ppr('91517603', 'מצמד PPR מצרה 25/20', 'PPR Reducing Coupler 25/20',
      kPprCouplers, 'PPR Couplers', '🔗', 22),
  _ppr('91517606', 'מצמד PPR מצרה 32/25', 'PPR Reducing Coupler 32/25',
      kPprCouplers, 'PPR Couplers', '🔗', 22),

  // ── מתאמים — ריתוך/הברגה עגול (עמ' 33) ──────────────────────────────────
  _ppr('9091021008', 'מתאם PPR הברגה פנימי 20x½"', 'PPR Adapter F-thread 20x½"',
      kPprAdapters, 'PPR Adapters', '🔩', 33),
  _ppr('9091021010', 'מתאם PPR הברגה פנימי 20x¾"', 'PPR Adapter F-thread 20x¾"',
      kPprAdapters, 'PPR Adapters', '🔩', 33),
  _ppr('9091021208', 'מתאם PPR הברגה חיצוני 20x½"', 'PPR Adapter M-thread 20x½"',
      kPprAdapters, 'PPR Adapters', '🔩', 33),

  // ── רוכבים — ריתוך (עמ' 23) ─────────────────────────────────────────────
  _ppr('98217741', 'רוכב PPR 40/20', 'PPR Saddle 40/20', kPprSaddles,
      'PPR Saddles', '🪢', 23),
  _ppr('98217744', 'רוכב PPR 50/20', 'PPR Saddle 50/20', kPprSaddles,
      'PPR Saddles', '🪢', 23),
  _ppr('98217770', 'רוכב PPR 110/20', 'PPR Saddle 110/20', kPprSaddles,
      'PPR Saddles', '🪢', 23),

  // ── פקקים — פקק סופי (עמ' 21) ───────────────────────────────────────────
  _ppr('98117702', 'פקק PPR סופי 20', 'PPR End Plug 20', kPprPlugs,
      'PPR Plugs', '🔘', 21),
  _ppr('98117704', 'פקק PPR סופי 32', 'PPR End Plug 32', kPprPlugs,
      'PPR Plugs', '🔘', 21),
  _ppr('98117706', 'פקק PPR סופי 50', 'PPR End Plug 50', kPprPlugs,
      'PPR Plugs', '🔘', 21),

  // ── אומגה — קטע מעבר (עמ' 21) ───────────────────────────────────────────
  _ppr('95116502', 'אומגה PPR קטע מעבר 20', 'PPR Omega Bridge 20', kPprOmega,
      'PPR Omega', '🛟', 21),
  _ppr('95116503', 'אומגה PPR קטע מעבר 25', 'PPR Omega Bridge 25', kPprOmega,
      'PPR Omega', '🛟', 21),
  _ppr('95116504', 'אומגה PPR קטע מעבר 32', 'PPR Omega Bridge 32', kPprOmega,
      'PPR Omega', '🛟', 21),

  // ── ברזים — מעבר ישר + כדורי בין אוגנים (עמ' 41) ────────────────────────
  _ppr('99040808', 'ברז PPR מעבר ישר 20', 'PPR Straight Valve 20', kPprValves,
      'PPR Valves', '🚰', 41),
  _ppr('99040810', 'ברז PPR מעבר ישר 25', 'PPR Straight Valve 25', kPprValves,
      'PPR Valves', '🚰', 41),
  _ppr('99040812', 'ברז PPR מעבר ישר 32', 'PPR Straight Valve 32', kPprValves,
      'PPR Valves', '🚰', 41),
  _ppr('99041602', 'ברז PPR כדורי בין אוגנים 90', 'PPR Ball Valve 90',
      kPprValves, 'PPR Valves', '🚰', 42),

  // ── צווארונים ואוגנים — צווארון לאוגן כולל אטם (עמ' 46) ─────────────────
  _ppr('98417805', 'צווארון PPR לאוגן 40', 'PPR Stub Flange 40', kPprCollars,
      'PPR Collars & Flanges', '⭕', 46),
  _ppr('98417806', 'צווארון PPR לאוגן 50', 'PPR Stub Flange 50', kPprCollars,
      'PPR Collars & Flanges', '⭕', 46),
  _ppr('98417807', 'צווארון PPR לאוגן 63', 'PPR Stub Flange 63', kPprCollars,
      'PPR Collars & Flanges', '⭕', 46),

  // ── אביזרי ריתוך חשמלי (Electrofusion) (עמ' 53) ─────────────────────────
  _ppr('6005302063', 'ברך PPR ריתוך חשמלי 45° 63', 'PPR Electrofusion Elbow 45° 63',
      kPprElectrofusion, 'PPR Electrofusion', '⚡', 53),
  _ppr('6005302090', 'ברך PPR ריתוך חשמלי 45° 90', 'PPR Electrofusion Elbow 45° 90',
      kPprElectrofusion, 'PPR Electrofusion', '⚡', 53),
  _ppr('6005360063', 'ברך PPR ריתוך חשמלי 90° 63', 'PPR Electrofusion Elbow 90° 63',
      kPprElectrofusion, 'PPR Electrofusion', '⚡', 53),
  _ppr('6005360110', 'ברך PPR ריתוך חשמלי 90° 110', 'PPR Electrofusion Elbow 90° 110',
      kPprElectrofusion, 'PPR Electrofusion', '⚡', 53),
];

/// Unified catalog = Lipskey (auto-generated) + Polyroll (PPR). The catalog
/// tree drill reads this so leaves of either brand resolve to their products.
final List<LipskeyCatalogProduct> kCatalogProducts = [
  ...kLipskeyCatalog,
  ...kPolyrollCatalog,
];

/// Ordered list of the Polyroll leaf categories (handy for ingestion tooling
/// and for asserting tree↔data parity in tests).
const List<String> kPprCategories = [
  kPprPipesSupply,
  kPprPipesFiber,
  kPprElbows,
  kPprTees,
  kPprCouplers,
  kPprAdapters,
  kPprSaddles,
  kPprPlugs,
  kPprOmega,
  kPprValves,
  kPprCollars,
  kPprElectrofusion,
];
