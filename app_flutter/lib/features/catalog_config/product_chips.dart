// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · the 18-chip taxonomy + WHEEL ALLOCATION (owner §4–§7).
// PURE + widget-free. The config card shows the product's wheels in a fixed
// PRIORITY order (§5) and allocates the top ones to fixed slots (§6): 🔩 side wheel
// A (right) = priority-1 · 🥇 primary (↕) = next · 🥈 secondary (↔) = the one after ·
// 🔢 qty always. GRADUATED (§7): as many wheels as chips (1→1, 2→2, 3→3), never an
// empty wheel; chips past the top 3 drop (the card caps).
//
// §4 — WHEELS FROM THE COMPREHENSIVE AXIS ENGINE (the root): most real products are
// brass/threaded, which the PPR engine ([configSchemaFor]) types for ≈0 of them. So
// the chips come from the EXISTING 17-axis projector [catAxesOf] (features/ring_dive/
// catalog_axes.dart) — סוג/חומר/מותג/קוטר-אינץ'/DN/מ"מ/מעבר/אורך/צבע/זווית/שיטה/מין/
// חדר/תכולה — run over a type-tile's TYPE GROUP (the clean-family peers that share a
// [typeKeyOf] · owner §1–§3, against fragmentation). The axes whose value VARIES
// across the peers (>1 value) are the wheels; each maps to the taxonomy priority; so
// grouping by the TYPE (ברך, צינור) — not the fragmented frame — makes those axes
// genuinely vary. [prioritizedSchema] feeds them,
// UNIONed over [configSchemaFor]'s real engine aggregation (kept for a mapped engine
// family — e.g. the manifolds' יציאות, which the axis engine has no wheel for).
//
// ZERO hand-rolled parsing — the axis engine already extracts every axis from any
// name/dims. GATING (byte-identical-off): pure, no `kCatalogConfig` branch; reachable
// only through the gated card ⇒ tree-shaken from a default (OFF) build.
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§chips).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/catalog_taxonomy.dart'
    show typeKeyOf;
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart' show odOf;
import 'package:buildsmart/features/ring_dive/catalog_axes.dart' show catAxesOf;
import 'package:buildsmart/features/word_finder/color_truth.dart'
    show isTrueColor;
import 'package:buildsmart/features/word_finder/material_taxonomy.dart'
    show canonicalMaterial;

/// Synthetic tradeId for engine/catalog-derived attributes (not a user Trade).
const String _kTradeId = 'catalog';

/// The 18-chip taxonomy priority (§5), keyed by the attribute id. Lower = first
/// (1 = the 🔩 side wheel). Both reducer ends map to the diameter band; the axis
/// engine's method/gender/room/capacity slot into the taxonomy too. An id not
/// listed sorts LAST ([_kUnknownPriority]) but is never dropped (§7).
const Map<String, int> kChipPriority = {
  'diameter': 1, // קוטר (inch / DN / mm — one size wheel)
  'diameter-large': 1, // קוטר (reducer big end)
  'diameter-small': 2, // קוטר-שני / מעבר
  'angle': 3, // זווית
  'ports': 4, // יציאות
  'length': 5, // אורך
  'height': 6, // גובה
  'kind': 7, // סוג
  'color': 8, // צבע
  'thread': 9, // תבריג
  'method': 9, // שיטה (connection method — the תבריג band)
  'structure': 10, // מבנה
  'gender': 10, // מין חיבור (the מבנה band)
  'shape': 11, // צורה
  'material': 12, // חומר
  'target': 13, // יעד / חדר
  'temp': 14, // טמפ'
  'capacity': 15, // תכולה (the תוספת band)
  'addon': 15, // תוספת
  'spout': 16, // פיה
  'brand': 17, // מותג
  'size': 18, // גודל
};

/// A chip the taxonomy does not list sorts LAST (§7 keeps every value-carrying wheel).
const int _kUnknownPriority = 99;

/// The taxonomy priority of an attribute [id] (§5) — [_kUnknownPriority] if unlisted.
int chipPriority(String id) => kChipPriority[id] ?? _kUnknownPriority;

// ── §4 axis engine → taxonomy chips ─────────────────────────────────────────────

/// Map each [catAxesOf] axis id → the taxonomy chip id it fills (§5). The three
/// diameter SYSTEMS collapse to one קוטר chip (a family uses one system); the
/// navigation axes (group/world/cat) are NOT product wheels and are omitted.
const Map<String, String> _kAxisToChip = {
  'diamInch': 'diameter',
  'diamDn': 'diameter',
  'diamMm': 'diameter',
  'transition': 'diameter-small',
  'angle': 'angle',
  'length': 'length',
  'type': 'kind',
  'color': 'color',
  'method': 'method',
  'gender': 'gender',
  'material': 'material',
  'room': 'target',
  'capacity': 'capacity',
  'brand': 'brand',
};

/// The wheel HEADING per taxonomy chip id (§5 labels).
const Map<String, String> _kChipLabel = {
  'diameter': 'קוטר',
  'diameter-small': 'מעבר',
  'angle': 'זווית',
  'length': 'אורך',
  'kind': 'סוג',
  'color': 'צבע',
  'method': 'שיטה',
  'gender': 'מין חיבור',
  'material': 'חומר',
  'target': 'יעד',
  'capacity': 'תכולה',
  'brand': 'מותג',
};

AttributeKind _chipKind(String id) => switch (id) {
      'diameter' || 'diameter-small' => AttributeKind.dimension,
      'color' => AttributeKind.color,
      _ => AttributeKind.choice,
    };

AttributeDef _def(String id, List<AttributeValue> values) => AttributeDef(
      id: id,
      tradeId: _kTradeId,
      nameHe: _kChipLabel[id] ?? id,
      emoji: '',
      kind: _chipKind(id),
      values: values,
    );

/// Distinct values, in first-appearance order → [AttributeValue]s.
List<AttributeValue> _values(Iterable<String> raw) {
  final seen = <String>[];
  for (final r in raw) {
    final t = r.trim();
    if (t.isNotEmpty && !seen.contains(t)) seen.add(t);
  }
  return [
    for (var i = 0; i < seen.length; i++)
      AttributeValue(id: 'v$i', labelHe: seen[i], canonical: seen[i], sortIndex: i),
  ];
}

/// The TYPE-group peers of [p] within [universe] — the products that share [p]'s
/// clean [typeKeyOf] (family + canonical type word: every ברך/מרפק/זווית, any size or
/// angle, is ONE type · owner §1–§3). This is the SAME set the rail collapses to a
/// tile, so rail = types and card = that type's variations agree. The wheels
/// aggregate over it. Never empty (falls back to [p] when the type is a singleton).
List<LipskeyCatalogProduct> _typeGroup(
  LipskeyCatalogProduct p,
  List<LipskeyCatalogProduct> universe,
) {
  final key = typeKeyOf(p);
  final group = [
    for (final m in universe)
      if (typeKeyOf(m) == key) m,
  ];
  return group.isEmpty ? [p] : group;
}

/// DEFINING chips — shown even single-value: the SIZE (owner: "1/2\" is a diameter").
/// Diameter is THE primary config axis, so a type shows its קוטר even when the tile
/// holds one size. Every OTHER axis — color/type/material/… — is a wheel only when it
/// VARIES across the type group; grouping by the clean TYPE (owner §1–§3) is what
/// makes them vary (e.g. the 140-product צינור type spans שחור/אפור, so צבע surfaces
/// on its own — no need to force it, unlike the old fragmented frame grouping).
const Set<String> _kSizeChips = {'diameter', 'diameter-small'};

/// §4 — the wheels from [catAxesOf] over [p]'s type group: the axes mapped to
/// taxonomy chips. The SIZE chip ([_kSizeChips]) always shows (the defining
/// property); a DESCRIPTIVE axis (color/type/material/…) shows only when it VARIES
/// across the peers (>1 value — otherwise it is context, not a wheel · §7).
List<AttributeDef> axisChips(
  LipskeyCatalogProduct p,
  List<LipskeyCatalogProduct> universe,
) {
  final group = _typeGroup(p, universe);
  // chip id → ordered distinct values across the family.
  final agg = <String, List<String>>{};
  void add(String chipId, String value) {
    // §4 — one material space: fold brass→copper, PE→HDPE etc. (canonicalMaterial)
    // so a type that spells one material two ways yields ONE חומר value, not a
    // spurious wheel. Idempotent for the axis engine's already-canonical keys.
    final v = chipId == 'material' ? canonicalMaterial(value) : value;
    // §4 — color_truth: the catalog miscodes metal FINISHES (נחושת/כרום/ניקל) into
    // the color field; [isTrueColor] keeps only real colours off the צבע wheel, so a
    // finish never poses as a colour (it belongs on the חומר axis).
    if (chipId == 'color' && !isTrueColor(v)) return;
    final list = agg.putIfAbsent(chipId, () => <String>[]);
    if (!list.contains(v)) list.add(v);
  }

  for (final m in group) {
    var memberHasDiameter = false;
    catAxesOf(m).forEach((axis, values) {
      final chipId = _kAxisToChip[axis];
      if (chipId == null) return; // a navigation axis, not a product wheel
      if (chipId == 'diameter') memberHasDiameter = true;
      for (final v in values) {
        add(chipId, v);
      }
    });
    // Size fallback: a bare trailing mm ("פקק 32") the axis engine's tokenizer
    // skips but odOf reads — so a size-only base product still gets its קוטר.
    if (!memberHasDiameter) {
      final od = odOf(m);
      if (od != null) add('diameter', '$od');
    }
  }
  return [
    for (final e in agg.entries)
      if (e.value.length > 1 || _kSizeChips.contains(e.key)) _def(e.key, _values(e.value)),
  ];
}

/// The card's schema: [configSchemaFor]'s real engine aggregation (kept ONLY for a
/// mapped engine family — the manifolds' יציאות etc.; a base-card fallback is dropped
/// so the §4 axis wheels win) UNIONed with [axisChips] (the engine wins a shared id),
/// then RE-ORDERED by the 18-chip taxonomy (§5) so the POSITIONAL card lays the wheels
/// out per §6. Graduated (§7). [universe] flows to both (default `resolvedCatalogProducts`).
ProductConfigSchema prioritizedSchema(
  LipskeyCatalogProduct p, {
  List<LipskeyCatalogProduct>? universe,
}) {
  final products = universe ?? resolvedCatalogProducts;
  final base = configSchemaFor(p, universe: products);
  // Keep the engine's attributes ONLY when it typed a real family (not the base
  // fallback, whose diameter is a generic template — the axis engine's real family
  // sizes are better).
  final engine =
      base.familyId == p.categoryHe ? const <AttributeDef>[] : base.attributes;
  final engineIds = {for (final a in engine) a.id};
  final hasDiameter = engineIds.any((id) => id.startsWith('diameter'));
  final extra = [
    for (final c in axisChips(p, products))
      if (!engineIds.contains(c.id) && !(c.id == 'diameter' && hasDiameter)) c,
  ];
  final ordered = [...engine, ...extra]
    ..sort((a, b) {
      final byPriority = chipPriority(a.id).compareTo(chipPriority(b.id));
      return byPriority != 0 ? byPriority : a.id.compareTo(b.id);
    });
  return ProductConfigSchema(
    sku: base.sku,
    nameHe: base.nameHe,
    familyId: base.familyId,
    emoji: base.emoji,
    attributes: ordered,
  );
}

/// The attribute ids of [p]'s prioritized schema, in taxonomy order — the wheel
/// roster (before the card caps at the top 3 + qty). For golden tests + coverage.
List<String> chipRoster(
  LipskeyCatalogProduct p, {
  List<LipskeyCatalogProduct>? universe,
}) =>
    [for (final AttributeDef a in prioritizedSchema(p, universe: universe).attributes) a.id];
