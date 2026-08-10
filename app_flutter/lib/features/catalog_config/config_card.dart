// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · dive-bs2b — the GENERIC config CARD (owner's CLEAN layout). ONE
// StatefulWidget that renders ANY [ProductConfigSchema]: the FULL product name clean
// ABOVE, then a row (RTL) of a קוטר wheel on the RIGHT · a SQUARE image in the CENTRE
// · a כמות wheel on the LEFT. The IMAGE is the hero — dead-centre, never a grey box
// (no file → the big product EMOJI). NO band / slider / bar (the forbidden sins).
//
//   • The centre image is a SQUARE (~20% under the available width); the side
//     wheels are vertically CENTRED on it. Its ONLY overlay is a CLEAN value PILL
//     embedded at the bottom — the current values (e.g. `DN50 · 16×1/2 · 15°`) in
//     the brand accent, NO arrows and NO edge labels. The two axes SCROLL ON THE
//     IMAGE: a ↕ drag cycles attribute[1], a ↔ drag attribute[2], swapping the photo
//     and updating the pill (the image itself is the control).
//   • The side wheels are TAPPABLE value stacks (mockup `.wheel`): the diameter
//     attribute(s) on the RIGHT, qty on the LEFT — the centred value is
//     highlighted brand-orange (bigger + bold), the rest dimmed.
//   • Below: the two actions — הוסף-לסל (solid) + בנה-קו (outline). NO value line,
//     NO "הגלגלים של…" hint (owner: clean).
//
// PER-PRODUCT, DATA-DRIVEN (plan 🫀): the SAME frame draws whatever the schema
// declares — a manifold swaps the axes to ↕יציאות ↔צבע with the same קוטר+כמות
// wheels; ZERO per-product code. The live selection is a `Map<String,String>`
// keyed by [AttributeDef.id] (canonical tokens — the value the cart line carries),
// seeded from each attribute's default; spinning ANY axis/wheel re-resolves the
// centre image ([variantImageFor]) so the photo SWAPS to the selected variant SKU.
//
// PALETTE: the dive-bs2b hexes are mirrored as local consts (`_c*`) so the render
// matches the approved mockup 1:1; the dive screen keeps the card gated behind
// [kCatalogConfig] (byte-identical-off — no `kCatalogConfig` branch of its own,
// tree-shaken from a default OFF build). SSOT: knowledge/CATALOG-CONFIG-PLAN.md.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/catalog_taxonomy.dart'
    show materialOf, typeGroupOf;
import 'package:buildsmart/features/catalog_config/product_chips.dart'
    show chipValuesOf, variantByAxes;
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/wheel_picker.dart';
import 'package:flutter/material.dart';

/// Signature of the card's two bottom actions (הוסף-לסל · בנה-קו). The dive
/// screen wires these to `smartCart.add` / a "בקרוב" toast; null ⇒ the button is
/// inert. [selection] is keyed by [AttributeDef.id] → the chosen canonical value.
typedef ConfigCardAction = void Function(
  ProductConfigSchema schema,
  Map<String, String> selection,
  int qty,
);

// ── dive-bs2b palette (exact mockup hexes · 1:1 render) ───────────────────────
const Color _cCard = Color(0xFFFFFFFF); // --card
const Color _cInk = Color(0xFF232A33); // --ink
const Color _cLine = Color(0xFFECEEF2); // --line (secondary btn border)
const Color _cAccent = Color(0xFFEE6A2A); // --accent
const Color _cAccentSoft = Color(0x14EE6A2A); // accent @ 8% — פרטים button fill
const Color _cImgBg = Color(0xFFF5F7FA); // --imgbg (stage)

/// The card's soft shadow (`0 6px 16px rgba(35,42,51,.07)`).
const List<BoxShadow> _kCardShadow = [
  BoxShadow(color: Color(0x12232A33), blurRadius: 16, offset: Offset(0, 6)),
];

// ── geometry (mockup values) ──────────────────────────────────────────────────
const double _kWheelCol = 62; // .wheelcol — a full spinning wheel (owner)
const double _kColGap = 9; // .cols gap
const double _kStageRadius = 15; // .stage radius
const double _kCardRadius = 18; // .cfg radius
const double _kEmojiSize = 76; // .pic — the big fallback emoji
const double _kActionRadius = 13; // .primary/.secondary radius
const double _kDragStep = 24; // px of drag that advances one axis step
// (the old compact side-wheel window is gone — the side wheels are full spinners.)

/// The כמות wheel ladder ceiling — a FULL spinning wheel 1…[_kMaxQty] (owner: "אני
/// רוצה להגיע 56… גלגל מלא"), so any quantity is a flick away, not tap-by-tap.
const int _kMaxQty = 999;

/// THE generic config card — see the file header. Stateful: it holds the live
/// [_ConfigCardState._selection] (seeded from each attribute's default), the
/// [_ConfigCardState._qty], and the memoized family candidate set the centre
/// image resolves against, rebuilding on every axis/wheel change. Generic — it
/// renders whatever the schema declares, with no per-product code.
class ConfigCard extends StatefulWidget {
  const ConfigCard({
    required this.schema,
    super.key,
    this.imageAsset,
    this.onAddToCart,
    this.onBuildLine,
    this.onOpenDetails,
  });

  /// The product's engine-derived declaration — the axes + wheels the card renders.
  final ProductConfigSchema schema;

  /// The tapped tile's base image asset (plan D · resolved through
  /// [resolveProductImage]); the per-selection variant image wins over it, and the
  /// family fallback / emoji win when both are absent (D.2 — never empty).
  final String? imageAsset;

  /// הוסף-לסל action. Null ⇒ the button is inert (no cart here).
  final ConfigCardAction? onAddToCart;

  /// בנה-קו action. Null ⇒ the button is inert.
  final ConfigCardAction? onBuildLine;

  /// פרטים — opens the internal product sheet for the current variant; null ⇒
  /// the image tap is inert.
  final ConfigCardAction? onOpenDetails;

  @override
  State<ConfigCard> createState() => _ConfigCardState();
}

class _ConfigCardState extends State<ConfigCard> {
  late Map<String, String> _selection;
  late List<LipskeyCatalogProduct> _family;

  /// The card's own catalog product (by sku), or null for a synthetic test schema —
  /// its values SEED the wheels so the card opens coherent to the tapped variant.
  LipskeyCatalogProduct? _cardProduct;

  /// [_cardProduct]'s chip-values — the axes IT actually carries. The card shows ONLY
  /// these wheels (so a plain 50/50 elbow never sprouts a מעבר wheel from the group's
  /// reducing siblings); a synthetic schema (no product) shows every declared axis.
  Map<String, Set<String>> _cardChips = const {};

  /// The family products with their chip-values precomputed once (the axis
  /// projection is heavy — a drag must not re-scan 200+ products every frame).
  List<(LipskeyCatalogProduct, Map<String, Set<String>>)> _familyChips = const [];
  int _qty = 1;

  // Drag accumulators — a ↕/↔ drag on the image advances an axis by one step per
  // [_kDragStep] px travelled (reset on drag-end).
  double _accV = 0;
  double _accH = 0;

  /// The axis whose value was LAST changed (a wheel spin or an image drag). The
  /// variant resolver resolves it FIRST so the just-moved axis WINS — dragging the
  /// angle finds a variant with the new angle (keeping the diameter when such a
  /// variant exists, else moving it) instead of the diameter-first greedy pinning
  /// the variant so the photo never swaps (owner: "משיכה של התמונות" — every drag
  /// direction must move a variant).
  String? _lastAxis;

  @override
  void initState() {
    super.initState();
    _resolveFamily();
    _selection = _seed(widget.schema);
  }

  @override
  void didUpdateWidget(ConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A different product re-seeds the selection + qty + candidate set (defensive
    // — the screen keys the card by sku, so the State is normally fresh anyway).
    if (oldWidget.schema.sku != widget.schema.sku) {
      _resolveFamily();
      _selection = _seed(widget.schema);
      _qty = 1;
    }
  }

  /// Resolves the card's product ([_cardProduct]), its VARIANT family, and the
  /// family's precomputed chip-values ([_familyChips]). The family is the TYPE
  /// GROUP ([typeGroupOf]) SCOPED TO THE CARD'S MATERIAL (owner: the card filters
  /// to the tapped tile's material — a PPR ברך shows only PPR sizes/angles, never
  /// mixed with HDPE/נחושת). So the wheels + the drag variant-swap stay within one
  /// material. Empty when the sku is not a live catalog product (a synthetic test
  /// schema).
  void _resolveFamily() {
    for (final p in resolvedCatalogProducts) {
      if (p.sku == widget.schema.sku) {
        _cardProduct = p;
        _cardChips = chipValuesOf(p);
        final material = materialOf(p);
        _family = [
          for (final m in typeGroupOf(p, resolvedCatalogProducts))
            if (materialOf(m) == material) m,
        ];
        _familyChips = [for (final m in _family) (m, chipValuesOf(m))];
        return;
      }
    }
    _cardProduct = null;
    _cardChips = const {};
    _family = const <LipskeyCatalogProduct>[];
    _familyChips = const [];
  }

  /// The DEFAULT value of [attr] — the `sortIndex == 0` value, else the first
  /// (guarded caller — only invoked for a non-empty [AttributeDef.values]).
  AttributeValue _defaultValue(AttributeDef attr) {
    for (final v in attr.values) {
      if (v.sortIndex == 0) {
        return v;
      }
    }
    return attr.values.first;
  }

  /// The selection TOKEN for [v] — its canonical form, else the label (the value
  /// the cart line stores; keeps a machine-stable pick where one exists).
  String _token(AttributeValue v) => v.canonical ?? v.labelHe;

  /// The initial selection — SEEDED from the card's own product ([_cardProduct]) so
  /// the card opens COHERENT to the tapped variant (owner: the name/image must match
  /// it). An axis the product carries → its value; an axis it LACKS → left unseeded
  /// (it must not constrain the variant match, only display its wheel's first value).
  /// A synthetic schema (no product) → each attribute's default, as before.
  Map<String, String> _seed(ProductConfigSchema schema) {
    final out = <String, String>{};
    for (final attr in schema.attributes) {
      if (attr.values.isEmpty) continue;
      final pv = _cardChips[attr.id];
      if (pv != null && pv.isNotEmpty) {
        out[attr.id] = pv.first;
      } else if (_cardProduct == null) {
        out[attr.id] = _token(_defaultValue(attr));
      }
    }
    return out;
  }

  /// The CONFIGURABLE axes — physical/variant properties a user actually dials to
  /// pick a SKU (size · angle · length · ports · reducer · colour). EXCLUDES the
  /// descriptive filters (סוג/שיטה/מין/מותג/יעד/תכולה): those describe WHAT the
  /// product IS, don't distinguish a variant, and cycling them on a drag changed
  /// nothing (owner: "משיכה… משנים את השם ואת התמונה" — a drag must move a variant).
  static const Set<String> _kConfigAxes = {
    'diameter',
    'diameter-small',
    'angle',
    'length',
    'ports',
    'transition',
    'color',
    'material',
  };

  /// The wheels/drags the card USES, in taxonomy order — a configurable
  /// ([_kConfigAxes]) attribute that carries values AND that the card's PRODUCT
  /// actually holds ([_cardChips]); a synthetic schema (no product) skips the
  /// product-coherence gate. So קוטר leads the side wheel and the two image drags
  /// cycle real variant axes, never a descriptive filter that leaves the SKU put.
  List<AttributeDef> get _usable => <AttributeDef>[
        for (final attr in widget.schema.attributes)
          if (attr.values.isNotEmpty &&
              _kConfigAxes.contains(attr.id) &&
              (_cardProduct == null || (_cardChips[attr.id]?.isNotEmpty ?? false)))
            attr,
      ];

  /// The wheel index for [attr] under the live selection — the position of the
  /// value whose token matches, else 0 (tolerant — a stale pick never throws).
  int _selectedIndex(AttributeDef attr) {
    final token = _selection[attr.id];
    for (var i = 0; i < attr.values.length; i++) {
      if (_token(attr.values[i]) == token) {
        return i;
      }
    }
    return 0;
  }

  /// The label of [attr]'s currently-selected value (guarded — usable attrs
  /// always carry values).
  String _selectedLabel(AttributeDef attr) =>
      attr.values[_selectedIndex(attr)].labelHe;

  /// The best-matching variant for the live selection — GREEDY by the shown wheels
  /// (diameter → primary → secondary): filter the family by each in turn, narrowing
  /// only when the filter is non-empty, so the changed axis wins and an axis the
  /// product lacks is skipped. The first of the narrowed set. null ⇒ no family (a
  /// synthetic schema). This is what makes the photo + name SWAP on a drag.
  LipskeyCatalogProduct? _variant() {
    final ids = [for (final a in _usable.take(3)) a.id];
    // Resolve the LAST-moved axis first so a drag on it always wins (the changed
    // axis picks its variant); the rest keep their taxonomy order behind it.
    final order = (_lastAxis != null && ids.contains(_lastAxis))
        ? [_lastAxis!, for (final id in ids) if (id != _lastAxis) id]
        : ids;
    return variantByAxes(_familyChips, _selection, order);
  }

  /// The centre image asset (plan D · never empty): the per-selection variant SKU
  /// wins (so the photo SWAPS on every pick), then the tapped tile image, then the
  /// family's first photo; all null ⇒ the caller shows the big schema emoji.
  String? _resolvedImageAsset() {
    final variant = _variant()?.imageAsset;
    if (variant != null) return variant;
    if (widget.imageAsset != null) return widget.imageAsset;
    for (final p in _family) {
      if (p.imageAsset != null) return p.imageAsset;
    }
    return null;
  }

  void _select(String id, String value) => setState(() {
        _selection[id] = value;
        _lastAxis = id; // the just-moved axis resolves first in _variant()
      });

  /// Move [attr]'s selection by [dir] (clamped to the ladder ends).
  void _stepAxis(AttributeDef attr, int dir) {
    final i = _selectedIndex(attr);
    final next = (i + dir).clamp(0, attr.values.length - 1);
    if (next != i) {
      _select(attr.id, _token(attr.values[next]));
    }
  }

  void _onVerticalDrag(DragUpdateDetails d, AttributeDef axis) {
    _accV += d.delta.dy;
    while (_accV <= -_kDragStep) {
      _accV += _kDragStep;
      _stepAxis(axis, 1); // drag up → next value
    }
    while (_accV >= _kDragStep) {
      _accV -= _kDragStep;
      _stepAxis(axis, -1);
    }
  }

  void _onHorizontalDrag(DragUpdateDetails d, AttributeDef axis) {
    _accH += d.delta.dx;
    while (_accH <= -_kDragStep) {
      _accH += _kDragStep;
      _stepAxis(axis, 1); // drag left → next value
    }
    while (_accH >= _kDragStep) {
      _accH -= _kDragStep;
      _stepAxis(axis, -1);
    }
  }

  void _onAddToCart() =>
      widget.onAddToCart?.call(widget.schema, Map.of(_selection), _qty);

  void _onBuildLine() =>
      widget.onBuildLine?.call(widget.schema, Map.of(_selection), _qty);

  /// פרטים — open the internal product sheet for the live variant. Shared by the
  /// centre-image tap AND the dedicated "📄 פרטים" button so both routes carry the
  /// identical (schema, selection, qty) snapshot.
  void _onOpenDetails() =>
      widget.onOpenDetails?.call(widget.schema, Map.of(_selection), _qty);

  // ── the POSITIONAL wheel map (owner spec §6, taxonomy-ordered by the schema) ──
  // The schema arrives priority-ordered (prioritizedSchema), so the slots are
  // strictly positional: attr[0] = 🔩 side wheel A (right, usually קוטר) · attr[1]
  // = 🥇 primary (↕ on the image) · attr[2] = 🥈 secondary (↔). qty is a fixed
  // side wheel the card always adds. GRADUATED (§7): only the wheels that exist
  // render; chips beyond the top 3 are dropped (the image can carry two axes).
  AttributeDef? get _sideA => _usable.isNotEmpty ? _usable[0] : null;

  /// The ↕ drag axis — the 2nd config axis, falling back to the 1st (קוטר) so a
  /// vertical drag ALWAYS cycles a variant (owner: "משיכה למעלה ולמטה משנים את
  /// השם ואת התמונה"), even on a product that carries only one axis.
  AttributeDef? get _primary => _usable.length > 1
      ? _usable[1]
      : (_usable.isNotEmpty ? _usable[0] : null);

  /// The ↔ drag axis — the 3rd config axis, falling back to the 1st (קוטר) so a
  /// HORIZONTAL drag is never dead (owner: "משיכה לימין ולשמאל משנים…"): a
  /// two-axis product drags diameter left/right and its 2nd axis up/down.
  AttributeDef? get _secondary => _usable.length > 2
      ? _usable[2]
      : (_usable.isNotEmpty ? _usable[0] : null);

  /// The RIGHT side wheel — the priority-1 chip alone (§6 · 🔩). Empty ⇒ a spacer.
  List<AttributeDef> get _rightWheels =>
      _sideA == null ? const <AttributeDef>[] : <AttributeDef>[_sideA!];

  @override
  Widget build(BuildContext context) {
    // RTL is intrinsic to the card (the dive screen is RTL).
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: _cCard,
          borderRadius: BorderRadius.circular(_kCardRadius),
          boxShadow: _kCardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CLEAN layout (owner): full product name above; the side wheels
            // (קוטר · כמות) STAY; a BIG centre image carrying only a clean
            // current-value pill — no edge arrows/labels, no "הגלגלים של…" hint.
            _fullName(),
            const SizedBox(height: 10),
            _cols(),
            // A dedicated, clearly-labelled פרטים affordance under the image — the
            // image tap alone was missable (owner: "עלה לי רק החיצוני"). Only when a
            // details handler is wired (else no dead control).
            if (widget.onOpenDetails != null) ...[
              const SizedBox(height: 10),
              _detailsButton(),
            ],
            const SizedBox(height: 12),
            _actions(),
          ],
        ),
      ),
    );
  }

  /// The FULL product name, clean, above the image (owner). Reflects the live
  /// selection's variant when one resolves, else the schema's base name.
  Widget _fullName() {
    return Text(
      _variant()?.nameHe ?? widget.schema.nameHe,
      key: const Key('configFullName'),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: _cInk,
        height: 1.15,
      ),
    );
  }

  /// The current selected values, CLEAN — no arrows, no axis names (owner: only the
  /// present values, embedded on the image). The top few (by taxonomy priority) so
  /// it stays a tight pill, e.g. `DN50 · 1/2×16 · 15°`.
  String _currentValues() =>
      [for (final a in _usable.take(3)) _selectedLabel(a)].join(' · ');

  /// The clean current-values pill embedded on the image (no arrows · owner).
  Widget _valuesPill() {
    // MATCH the brand palette (owner) — the same accent-orange as the selected wheel
    // values + the הוסף-לסל CTA, white text; not the old dark-ink pill.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _cAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _currentValues(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// `.cols` — RIGHT קוטר wheel · a SQUARE centre image · LEFT כמות wheel, the wheels
  /// vertically centred on the square (owner).
  Widget _cols() {
    return LayoutBuilder(
      builder: (context, c) {
        // A SQUARE centre image (owner: "מרובע באמצע"), ~20% smaller than the full
        // available width; the side wheels are vertically CENTRED on it (owner:
        // "מרכז את אמצע הגלגלים ביחס אליו") — IntrinsicHeight + center aligns the
        // wheel columns' middle with the square's middle.
        final avail = c.maxWidth - 2 * _kWheelCol - 2 * _kColGap;
        final square = avail.clamp(150.0, 184.0);
        return IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sideWheels(_rightWheels),
              SizedBox(
                key: const Key('configStage'),
                width: square,
                height: square,
                child: _stage(),
              ),
              _qtyWheel(),
            ],
          ),
        );
      },
    );
  }

  /// The centre STAGE — a SQUARE image pad: the hero photo FILLS it (padding leaves
  /// room for the clean current-value pill at the bottom). NO edge arrows/labels
  /// (owner); a ↕/↔ drag scrolls the two axes + swaps the photo.
  Widget _stage() {
    final primary = _primary;
    final secondary = _secondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _cImgBg,
        borderRadius: BorderRadius.circular(_kStageRadius),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOpenDetails == null ? null : _onOpenDetails,
        onVerticalDragUpdate:
            primary == null ? null : (d) => _onVerticalDrag(d, primary),
        onVerticalDragEnd: (_) => _accV = 0,
        onHorizontalDragUpdate:
            secondary == null ? null : (d) => _onHorizontalDrag(d, secondary),
        onHorizontalDragEnd: (_) => _accH = 0,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 46),
                child: KeyedSubtree(
                  key: const Key('configImageCenter'),
                  child: _hero(),
                ),
              ),
            ),
            if (_usable.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Center(child: _valuesPill()),
              ),
          ],
        ),
      ),
    );
  }

  /// The hero — the REAL per-selection image (swaps on every pick) FILLING the
  /// square pad (BoxFit.contain), falling back to the big product emoji (never a
  /// grey box · D.2).
  Widget _hero() {
    final asset = _resolvedImageAsset();
    if (asset == null) {
      return Center(child: _emoji());
    }
    return Center(
      child: Image(
        image: resolveProductImage(asset),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _emoji(),
      ),
    );
  }

  Widget _emoji() => Text(
        widget.schema.emoji,
        style: const TextStyle(fontSize: _kEmojiSize, height: 1),
      );

  /// The RIGHT side wheel — the priority-1 chip (usually קוטר) as a FULL spinning
  /// [WheelPicker] (owner: "גלגל מלא", not tap-by-tap). Each row is the bare
  /// canonical DN (the `· ½"` inch hint rides the values pill · keeps the slim
  /// column readable); a fling settles on any value → [_select] updates the
  /// image/name/pill. Empty ⇒ a fixed-width spacer so the image stays centred.
  Widget _sideWheels(List<AttributeDef> attrs) {
    if (attrs.isEmpty) {
      return const SizedBox(width: _kWheelCol);
    }
    final attr = attrs.first;
    return SizedBox(
      width: _kWheelCol,
      child: WheelPicker(
        labelHe: attr.nameHe,
        values: [for (final v in attr.values) v.canonical ?? v.labelHe],
        selectedIndex: _selectedIndex(attr),
        onSelected: (i) => _select(attr.id, _token(attr.values[i])),
        kind: attr.kind,
      ),
    );
  }

  /// The LEFT כמות wheel — a FULL spinning [WheelPicker] 1…[_kMaxQty] (owner: a
  /// flick reaches 56, not 55 taps). Settling on a row sets [_qty].
  Widget _qtyWheel() {
    return SizedBox(
      width: _kWheelCol,
      child: WheelPicker(
        labelHe: 'כמות',
        values: [for (var q = 1; q <= _kMaxQty; q++) '$q'],
        selectedIndex: (_qty - 1).clamp(0, _kMaxQty - 1),
        onSelected: (i) => setState(() => _qty = i + 1),
        kind: AttributeKind.dimension,
      ),
    );
  }

  /// The dedicated "📄 פרטים" affordance — a full-width, brand-accent-tinted button
  /// under the image that opens the internal product sheet through the SAME
  /// [ConfigCard.onOpenDetails] path as the centre-image tap. A clear, reliable
  /// target the image's ↕/↔ drag recognizers can never steal (owner: the tap alone
  /// was missable). Consistent with the card (tokens · RTL · accent).
  Widget _detailsButton() {
    return Material(
      key: const Key('configOpenDetails'),
      color: _cAccentSoft,
      borderRadius: BorderRadius.circular(_kActionRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _onOpenDetails,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📄', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'פרטים',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _cAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// `.actions` — הוסף-לסל (solid brand, flex:1) + בנה-קו (outline, intrinsic).
  Widget _actions() {
    return Row(
      children: [
        Expanded(child: _primaryButton('+ הוסף לסל', _onAddToCart)),
        const SizedBox(width: 8),
        _secondaryButton('בנה קו', _onBuildLine),
      ],
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return Material(
      key: const Key('configAddToCart'),
      color: _cAccent,
      borderRadius: BorderRadius.circular(_kActionRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(String label, VoidCallback onTap) {
    return Material(
      key: const Key('configBuildLine'),
      color: _cCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kActionRadius),
        side: const BorderSide(color: _cLine, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _cInk,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
