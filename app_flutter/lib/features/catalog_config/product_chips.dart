// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · the 18-chip taxonomy + WHEEL ALLOCATION (owner spec §5–§7).
// PURE + widget-free. The config card must show the product's wheels in a fixed
// PRIORITY order (§5) and allocate the top ones to the fixed slots (§6):
//   • 🔩 side wheel A (right)  = priority-1 chip (usually קוטר; else the highest
//     chip the product has);
//   • 🥇 primary (↕ on image)  = the next chip;
//   • 🥈 secondary (↔ on image) = the one after that;
//   • 🔢 qty — a fixed side wheel, always (added by the card itself).
// GRADUATED (§7): show exactly as many wheels as the product HAS chips — 1→1,
// 2→2, 3→3 — never an empty wheel. Extra chips beyond the top 3 are dropped.
//
// ZERO new derivation / ZERO hardcode (owner: reuse the engines): the chips + their
// aggregated VALUES come straight from [configSchemaFor] (engine-derived over the
// live universe — קוטר from odOf, זווית from the elbow group, יציאות from dims,
// צבע from p.color, …). [prioritizedSchema] only RE-ORDERS those attributes by the
// taxonomy so the positional card lays them out per §6. A chip with no values is
// already omitted by [configSchemaFor] (M1), so graduation falls out for free.
//
// GATING (byte-identical-off): pure, no `kCatalogConfig` branch; reachable only
// through the gated card ⇒ tree-shaken from a default (OFF) build.
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§chips).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/domain/trade_schema.dart' show AttributeDef;
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';

/// The 18-chip taxonomy priority (§5) keyed by the attribute id [configSchemaFor]
/// emits. Lower = shown first (1 = the 🔩 side wheel). Both reducer ends map to the
/// diameter band (large = the primary קוטר, small = קוטר-שני). An id the engine
/// does not (yet) emit resolves through [chipPriority] to [_kUnknownPriority] so it
/// sorts last but is never dropped.
const Map<String, int> kChipPriority = {
  'diameter': 1, // קוטר
  'diameter-large': 1, // קוטר (the reducer's big end)
  'diameter-small': 2, // קוטר-שני
  'angle': 3, // זווית
  'ports': 4, // יציאות
  'length': 5, // אורך
  'height': 6, // גובה
  'kind': 7, // סוג
  'color': 8, // צבע
  'thread': 9, // תבריג
  'structure': 10, // מבנה
  'shape': 11, // צורה
  'material': 12, // חומר
  'target': 13, // יעד
  'temp': 14, // טמפ'
  'addon': 15, // תוספת
  'spout': 16, // פיה
  'brand': 17, // מותג
  'size': 18, // גודל
};

/// A chip the taxonomy does not list sorts LAST (never dropped — §7 keeps every
/// value-carrying wheel).
const int _kUnknownPriority = 99;

/// The taxonomy priority of an attribute [id] (§5) — [_kUnknownPriority] if unlisted.
int chipPriority(String id) => kChipPriority[id] ?? _kUnknownPriority;

/// [configSchemaFor] with its attributes RE-ORDERED by the 18-chip taxonomy (§5),
/// so the positional card lays them out per §6 (attr[0]=🔩 · attr[1]=↕ · attr[2]=↔).
/// Values/ids/kinds are untouched — only the ORDER changes; graduation (§7) is
/// inherited (the engine already omits value-less chips). [universe] flows through
/// to the engine's real-value aggregation (default `resolvedCatalogProducts`).
ProductConfigSchema prioritizedSchema(
  LipskeyCatalogProduct p, {
  List<LipskeyCatalogProduct>? universe,
}) {
  final base = configSchemaFor(p, universe: universe);
  final ordered = [...base.attributes]
    ..sort((a, b) => chipPriority(a.id).compareTo(chipPriority(b.id)));
  return ProductConfigSchema(
    sku: base.sku,
    nameHe: base.nameHe,
    familyId: base.familyId,
    emoji: base.emoji,
    attributes: ordered,
  );
}

/// The attribute ids of [p]'s prioritized schema, in taxonomy order — the wheel
/// roster the card will show (before the card caps it at the top 3 + qty). Handy
/// for the golden tests + the coverage report.
List<String> chipRoster(
  LipskeyCatalogProduct p, {
  List<LipskeyCatalogProduct>? universe,
}) =>
    [for (final AttributeDef a in prioritizedSchema(p, universe: universe).attributes) a.id];
