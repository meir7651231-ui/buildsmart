// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · the 18-chip taxonomy + WHEEL ALLOCATION (owner §4–§7).
// PURE + widget-free. The config card must show the product's wheels in a fixed
// PRIORITY order (§5) and allocate the top ones to the fixed slots (§6):
//   • 🔩 side wheel A (right)  = priority-1 chip · 🥇 primary (↕) = next ·
//   • 🥈 secondary (↔) = the one after · 🔢 qty — a fixed side wheel, always.
// GRADUATED (§7): show exactly as many wheels as the product HAS chips (1→1,
// 2→2, 3→3), never an empty wheel; chips beyond the top 3 drop (the card caps).
//
// §4 — WHEELS FROM THE NAME (the root): most real products are brass/threaded, and
// the PPR engine ([configSchemaFor]) types ≈0 of them. So the chips are parsed from
// the NAME (+ dims/p.color/odOf) across the product's VARIANT FAMILY (the frame
// siblings, [productCanonicalKey]) — a name PARSER, not PPR geometry — so all ~1,867
// products get typed wheels. [nameChips] emits קוטר/זווית/תבריג/יציאות/אורך/צבע from
// the family's names; [prioritizedSchema] UNIONs those over [configSchemaFor]'s
// engine attributes (engine wins a shared id, so the manifolds' real aggregation is
// kept) and RE-ORDERS the union by the taxonomy — the positional card lays it out.
//
// ZERO new geometry / ZERO hardcode: values come from odOf/dims/p.color/name-tokens;
// grouping reuses variant_families; the sort is the taxonomy. GATING
// (byte-identical-off): pure, no `kCatalogConfig` branch; reachable only through the
// gated card ⇒ tree-shaken from a default (OFF) build.
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§chips).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/variant_families.dart' show productCanonicalKey;
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart' show odOf;

/// Synthetic tradeId for engine/catalog-derived attributes (not a user Trade).
const String _kTradeId = 'catalog';

/// The 18-chip taxonomy priority (§5) keyed by the attribute id. Lower = shown
/// first (1 = the 🔩 side wheel). Both reducer ends map to the diameter band. An
/// id the taxonomy does not list resolves to [_kUnknownPriority] (sorts last but
/// is never dropped).
const Map<String, int> kChipPriority = {
  'diameter': 1, // קוטר
  'diameter-large': 1, // קוטר (reducer big end)
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

/// A chip the taxonomy does not list sorts LAST (§7 keeps every value-carrying wheel).
const int _kUnknownPriority = 99;

/// The taxonomy priority of an attribute [id] (§5) — [_kUnknownPriority] if unlisted.
int chipPriority(String id) => kChipPriority[id] ?? _kUnknownPriority;

// ── §4 name parser ────────────────────────────────────────────────────────────

/// Length words a fitting name carries (the אורך chip).
const Set<String> _kLengthWords = {'קצר', 'בינוני', 'ארוך'};

/// An angle token — "45°", "90°" (the זווית chip).
final RegExp _kAngle = RegExp(r'\d+°');

/// A thread/inch token — 1/2" · 3/4″ · 1" (the תבריג chip; bare mm sizes are the
/// קוטר chip via odOf, so they never double-count here).
final RegExp _kInch = RegExp(r'\d+(?:/\d+)?\s*["״]');

/// Distinct values, in first-appearance order → [AttributeValue]s (label ==
/// canonical == the raw token).
List<AttributeValue> _values(Iterable<String> raw) {
  final seen = <String>[];
  for (final r in raw) {
    if (r.isNotEmpty && !seen.contains(r)) seen.add(r);
  }
  return [
    for (var i = 0; i < seen.length; i++)
      AttributeValue(
        id: 'v$i',
        labelHe: seen[i],
        canonical: seen[i],
        sortIndex: i,
      ),
  ];
}

AttributeDef _def(
  String id,
  String nameHe,
  AttributeKind kind,
  List<AttributeValue> values, {
  String? unitHe,
}) =>
    AttributeDef(
      id: id,
      tradeId: _kTradeId,
      nameHe: nameHe,
      emoji: '',
      kind: kind,
      values: values,
      unitHe: unitHe,
    );

/// The frame-group siblings of [p] within [universe] — the VARIANT family (same
/// [productCanonicalKey]); the chip values aggregate over it so a wheel carries
/// the family's real range. Never empty (falls back to [p] alone).
List<LipskeyCatalogProduct> _frameGroup(
  LipskeyCatalogProduct p,
  List<LipskeyCatalogProduct> universe,
) {
  final key = productCanonicalKey(p);
  final group = [
    for (final m in universe)
      if (productCanonicalKey(m) == key) m,
  ];
  return group.isEmpty ? [p] : group;
}

/// §4 — the typed chips PARSED FROM THE NAME (+ dims/p.color/odOf) across [p]'s
/// variant family. Emits only chips that carry a value (graduation · §7). Works
/// for ANY product, PPR or brass — the name already holds it.
List<AttributeDef> nameChips(
  LipskeyCatalogProduct p,
  List<LipskeyCatalogProduct> universe,
) {
  final group = _frameGroup(p, universe);
  final diameter = <String>[];
  final angle = <String>[];
  final thread = <String>[];
  final ports = <String>[];
  final length = <String>[];
  final color = <String>[];
  for (final m in group) {
    final od = odOf(m);
    if (od != null) diameter.add('$od');
    for (final a in _kAngle.allMatches(m.nameHe)) {
      angle.add(a.group(0)!);
    }
    for (final t in _kInch.allMatches(m.nameHe)) {
      thread.add(t.group(0)!.replaceAll(' ', ''));
    }
    final pr = m.dims?['יציאות'];
    if (pr != null) {
      ports.add('$pr');
    }
    for (final w in m.nameHe.split(RegExp(r'\s+'))) {
      if (_kLengthWords.contains(w)) length.add(w);
    }
    final c = m.color;
    if (c != null && c.isNotEmpty) color.add(c);
  }
  return [
    if (diameter.isNotEmpty)
      _def('diameter', 'קוטר', AttributeKind.dimension, _values(diameter),
          unitHe: 'מ"מ'),
    if (angle.isNotEmpty)
      _def('angle', 'זווית', AttributeKind.choice, _values(angle)),
    if (thread.isNotEmpty)
      _def('thread', 'תבריג', AttributeKind.choice, _values(thread)),
    if (ports.isNotEmpty)
      _def('ports', 'יציאות', AttributeKind.number, _values(ports)),
    if (length.isNotEmpty)
      _def('length', 'אורך', AttributeKind.choice, _values(length)),
    if (color.isNotEmpty)
      _def('color', 'צבע', AttributeKind.color, _values(color)),
  ];
}

/// The card's schema: [configSchemaFor]'s engine attributes UNIONed with the §4
/// [nameChips] (engine wins a shared id — keeps the manifolds' real aggregation),
/// RE-ORDERED by the 18-chip taxonomy (§5) so the POSITIONAL card lays the wheels
/// out per §6 (attr[0]=🔩 · attr[1]=↕ · attr[2]=↔). Graduated (§7) — value-less
/// chips are already omitted. [universe] flows to both sources (default
/// `resolvedCatalogProducts`).
ProductConfigSchema prioritizedSchema(
  LipskeyCatalogProduct p, {
  List<LipskeyCatalogProduct>? universe,
}) {
  final products = universe ?? resolvedCatalogProducts;
  final base = configSchemaFor(p, universe: products);
  final baseIds = {for (final a in base.attributes) a.id};
  final hasDiameter = baseIds.any((id) => id.startsWith('diameter'));
  final extra = [
    for (final c in nameChips(p, products))
      // engine wins a shared id; skip a bare 'diameter' when the engine already
      // carries a diameter band (e.g. the reducer's large/small ends).
      if (!baseIds.contains(c.id) && !(c.id == 'diameter' && hasDiameter)) c,
  ];
  final ordered = [...base.attributes, ...extra]
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
/// roster the card shows (before it caps at the top 3 + qty). For golden tests +
/// the coverage report.
List<String> chipRoster(
  LipskeyCatalogProduct p, {
  List<LipskeyCatalogProduct>? universe,
}) =>
    [for (final AttributeDef a in prioritizedSchema(p, universe: universe).attributes) a.id];
