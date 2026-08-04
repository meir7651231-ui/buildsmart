// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · dive-bs2b — the GENERIC config CARD, rebuilt 1:1 to the APPROVED
// dive-bs2b mockup (NOT the abandoned dive-bs4 image-top / wheel-row). ONE
// StatefulWidget that renders ANY [ProductConfigSchema] as three columns in a row
// (RTL): a קוטר wheel on the RIGHT · a LARGE image STAGE in the centre (flex:1,
// min-height 150) · a כמות wheel on the LEFT. The IMAGE is the hero — dead-centre,
// never a grey box (no file → the big product EMOJI). There is NO band / slider /
// bar in the middle (the two forbidden sins).
//
//   • The centre stage carries FOUR edge labels — top `▲ name` + bottom
//     `values ▼` for the FIRST axis attribute (elbow → זווית), right `◀ name` +
//     left `first ▶` for the SECOND (elbow → אורך). The two axes SCROLL ON THE
//     IMAGE itself: a ↕ drag cycles attribute[0], a ↔ drag cycles attribute[1].
//   • The side wheels are TAPPABLE value stacks (mockup `.wheel`): the diameter
//     attribute(s) on the RIGHT, qty on the LEFT — the centred value is
//     highlighted brand-orange (bigger + bold), the rest dimmed.
//   • Below: a value line (`90° · 32 מ״מ`), a hint (`הגלגלים של ברך: …`) and the
//     two actions — הוסף-לסל (solid) + בנה-קו (outline).
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
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/variant_image.dart';
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
const Color _cDim = Color(0xFF7A828D); // --dim
const Color _cLine = Color(0xFFECEEF2); // --line (secondary btn border)
const Color _cAccent = Color(0xFFEE6A2A); // --accent
const Color _cAccentD = Color(0xFFCF551B); // --accent-d (header)
const Color _cImgBg = Color(0xFFF5F7FA); // --imgbg (stage)
const Color _cWheelOff = Color(0xFFB7BDC6); // dimmed wheel value

/// The card's soft shadow (`0 6px 16px rgba(35,42,51,.07)`).
const List<BoxShadow> _kCardShadow = [
  BoxShadow(color: Color(0x12232A33), blurRadius: 16, offset: Offset(0, 6)),
];

// ── geometry (mockup values) ──────────────────────────────────────────────────
const double _kWheelCol = 50; // .wheelcol flex:0 0 50px
const double _kColGap = 9; // .cols gap
const double _kStageMin = 150; // .stage min-height (the hero floor)
const double _kStageRadius = 15; // .stage radius
const double _kCardRadius = 18; // .cfg radius
const double _kHeroSize = 118; // the centred product image box
const double _kEmojiSize = 76; // .pic — the big fallback emoji
const double _kActionRadius = 13; // .primary/.secondary radius
const double _kDragStep = 24; // px of drag that advances one axis step
const int _kWheelWindow = 4; // values shown per side wheel (compact · mockup)

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

  @override
  State<ConfigCard> createState() => _ConfigCardState();
}

class _ConfigCardState extends State<ConfigCard> {
  late Map<String, String> _selection;
  late List<LipskeyCatalogProduct> _family;
  int _qty = 1;

  // Drag accumulators — a ↕/↔ drag on the image advances an axis by one step per
  // [_kDragStep] px travelled (reset on drag-end).
  double _accV = 0;
  double _accH = 0;

  @override
  void initState() {
    super.initState();
    _selection = _seed(widget.schema);
    _family = familyProducts(widget.schema, resolvedCatalogProducts);
  }

  @override
  void didUpdateWidget(ConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A different product re-seeds the selection + qty + candidate set (defensive
    // — the screen keys the card by sku, so the State is normally fresh anyway).
    if (oldWidget.schema.sku != widget.schema.sku) {
      _selection = _seed(widget.schema);
      _family = familyProducts(widget.schema, resolvedCatalogProducts);
      _qty = 1;
    }
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

  /// The default selection — each non-empty attribute's default token, keyed by
  /// [AttributeDef.id]. Empty when the schema declares no wheels (still usable).
  Map<String, String> _seed(ProductConfigSchema schema) => <String, String>{
        for (final attr in schema.attributes)
          if (attr.values.isNotEmpty) attr.id: _token(_defaultValue(attr)),
      };

  /// The declared attributes that carry values, in order.
  List<AttributeDef> get _usable => <AttributeDef>[
        for (final attr in widget.schema.attributes)
          if (attr.values.isNotEmpty) attr,
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

  /// The centre image asset (plan D · never empty): the per-selection variant SKU
  /// wins, then the tapped tile image, then the family fallback; all null ⇒ the
  /// caller shows the big schema emoji.
  String? _resolvedImageAsset() {
    final variant = variantImageFor(widget.schema, _selection, _family);
    return variant ??
        widget.imageAsset ??
        familyFallbackImage(widget.schema, _family);
  }

  void _select(String id, String value) =>
      setState(() => _selection[id] = value);

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

  // ── the positional axis/wheel map (data-driven) ─────────────────────────────
  // diameter attribute(s) → the RIGHT side wheel(s); the rest → the image axes
  // (first ↕, second ↔). So elbow → [angle↕, length↔, diameter▸]; manifold →
  // [ports↕, color↔, diameter▸] — same frame, labels swap.
  List<AttributeDef> get _diameterAttrs =>
      [for (final a in _usable) if (a.id.startsWith('diameter')) a];
  List<AttributeDef> get _axisAttrs =>
      [for (final a in _usable) if (!a.id.startsWith('diameter')) a];

  AttributeDef? get _primary => _axisAttrs.isNotEmpty ? _axisAttrs[0] : null;
  AttributeDef? get _secondary =>
      _axisAttrs.length > 1 ? _axisAttrs[1] : null;

  /// The side (right) wheels — diameter(s) first, then any axis attribute beyond
  /// the two the image carries (rare: keeps every declared wheel reachable).
  List<AttributeDef> get _rightWheels => [
        ..._diameterAttrs,
        if (_axisAttrs.length > 2) ..._axisAttrs.sublist(2),
      ];

  /// The short family name for the header/hint ('ברך 90°' → 'ברך', 'מחלק' → 'מחלק').
  String get _familyShort => widget.schema.familyId.split(' ').first;

  @override
  Widget build(BuildContext context) {
    // RTL is intrinsic to the card (the dive screen is RTL; forcing it here keeps
    // the right=קוטר / left=כמות geometry correct even hosted LTR — e.g. a test).
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 13),
        decoration: BoxDecoration(
          color: _cCard,
          borderRadius: BorderRadius.circular(_kCardRadius),
          boxShadow: _kCardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            const SizedBox(height: 9),
            _cols(),
            const SizedBox(height: 3),
            _valueLine(),
            const SizedBox(height: 9),
            _hint(),
            const SizedBox(height: 9),
            _actions(),
          ],
        ),
      ),
    );
  }

  /// `.cfghd` — the summary + a decorative ✕, in accent-dark.
  Widget _header() {
    final parts = <String>[
      _familyShort,
      for (final a in _usable) _selectedLabel(a),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              parts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _cAccentD,
              ),
            ),
          ),
          const Text(
            '✕',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _cAccentD,
            ),
          ),
        ],
      ),
    );
  }

  /// `.cols` — RIGHT diameter wheel · CENTRE image stage (flex:1) · LEFT qty wheel.
  /// [IntrinsicHeight] lets the side wheels stretch to the stage's height (the
  /// stage's min-height 150 drives the row — the hero floor).
  Widget _cols() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sideWheels(_rightWheels),
          const SizedBox(width: _kColGap),
          Expanded(child: _stage()),
          const SizedBox(width: _kColGap),
          _qtyWheel(),
        ],
      ),
    );
  }

  /// The centre STAGE — the light image pad with the hero image dead-centre and
  /// four axis labels on the four edges; a ↕/↔ drag on it cycles the two axes.
  /// NO band / slider (the forbidden sin) — the image IS the focus.
  Widget _stage() {
    final primary = _primary;
    final secondary = _secondary;
    return ConstrainedBox(
      key: const Key('configStage'),
      constraints: const BoxConstraints(minHeight: _kStageMin),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _cImgBg,
          borderRadius: BorderRadius.circular(_kStageRadius),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: primary == null
              ? null
              : (d) => _onVerticalDrag(d, primary),
          onVerticalDragEnd: (_) => _accV = 0,
          onHorizontalDragUpdate: secondary == null
              ? null
              : (d) => _onHorizontalDrag(d, secondary),
          onHorizontalDragEnd: (_) => _accH = 0,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: KeyedSubtree(
                    key: const Key('configImageCenter'),
                    child: _hero(),
                  ),
                ),
              ),
              if (primary != null) ...[
                _edge(top: 6, child: _axisLabel('▲ ${primary.nameHe}')),
                _edge(
                  bottom: 18,
                  child: _axisLabel(
                    '${[for (final v in primary.values) v.labelHe].join('·')} ▼',
                  ),
                ),
              ],
              if (secondary != null) ...[
                _edge(right: 7, child: _axisLabel('◀ ${secondary.nameHe}')),
                _edge(
                  left: 7,
                  child: _axisLabel('${secondary.values.first.labelHe} ▶'),
                ),
              ],
              _edge(
                bottom: 6,
                child: const Text(
                  'תמונת-מוצר · מתחלפת לפי הבחירה',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: _cDim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The hero — the REAL per-selection image (swaps on every pick), falling back
  /// to the big product emoji (never a grey box · D.2).
  Widget _hero() {
    final asset = _resolvedImageAsset();
    if (asset == null) {
      return _emoji();
    }
    return SizedBox(
      width: _kHeroSize,
      height: _kHeroSize,
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

  /// A single edge label positioned against the stage box. Top/bottom labels span
  /// the full width and centre horizontally; side labels (left/right) span the
  /// full height and centre vertically — so all four sit on the stage's edges.
  Widget _edge({
    required Widget child,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final side = left != null || right != null;
    return Positioned(
      top: side ? 0 : top,
      bottom: side ? 0 : bottom,
      left: side ? left : 0,
      right: side ? right : 0,
      child: Center(child: child),
    );
  }

  /// An orange axis label (`▲ זווית`, `◀ אורך`, …).
  Widget _axisLabel(String text) => Text(
        text,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _cAccent,
        ),
      );

  /// The RIGHT side wheel column — the diameter attribute(s) as COMPACT tappable
  /// value stacks (mockup `.wheel`). Empty ⇒ a fixed-width spacer so the image
  /// stays centred between the two edges.
  Widget _sideWheels(List<AttributeDef> attrs) {
    if (attrs.isEmpty) {
      return const SizedBox(width: _kWheelCol);
    }
    return SizedBox(
      width: _kWheelCol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var w = 0; w < attrs.length; w++) ...[
            if (w > 0) const SizedBox(height: 8),
            _colHeader(attrs[w].nameHe),
            ..._wheelCells(attrs[w]),
          ],
        ],
      ),
    );
  }

  /// The visible window of a wheel — [_kWheelWindow] values centred on the
  /// selection (one above it, mockup-style), clamped to the ladder ends. A real
  /// family diameter ladder can hold 30+ values; the wheel shows a COMPACT slice
  /// (tapping a shown neighbour recentres it) instead of a giant column.
  ({int start, int end}) _window(int n, int sel) {
    if (n <= _kWheelWindow) {
      return (start: 0, end: n);
    }
    var start = sel - 1;
    if (start < 0) {
      start = 0;
    }
    if (start > n - _kWheelWindow) {
      start = n - _kWheelWindow;
    }
    return (start: start, end: start + _kWheelWindow);
  }

  /// The tappable cells of one wheel, over its visible [_window].
  List<Widget> _wheelCells(AttributeDef attr) {
    final sel = _selectedIndex(attr);
    final w = _window(attr.values.length, sel);
    return [
      for (var i = w.start; i < w.end; i++)
        _wheelValue(
          text: attr.values[i].labelHe,
          on: i == sel,
          onTap: () => _select(attr.id, _token(attr.values[i])),
        ),
    ];
  }

  /// The LEFT qty wheel — 1…4 as tappable values (mockup `כמות`).
  Widget _qtyWheel() {
    return SizedBox(
      width: _kWheelCol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _colHeader('כמות'),
          for (var q = 1; q <= 4; q++)
            _wheelValue(
              text: '$q',
              on: _qty == q,
              onTap: () => setState(() => _qty = q),
            ),
        ],
      ),
    );
  }

  /// A wheel column heading (`.colh` — muted, small, bold).
  Widget _colHeader(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _cDim,
          ),
        ),
      );

  /// One tappable wheel value (`.wheel .w`). Selected ⇒ brand fill, white, bigger
  /// + bold; unselected ⇒ dimmed grey.
  Widget _wheelValue({
    required String text,
    required bool on,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: on
            ? BoxDecoration(
                color: _cAccent,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: on ? Colors.white : _cWheelOff,
            fontSize: on ? 14 : 12,
            fontWeight: on ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// `.vn` — the current headline (`90° · 32 מ״מ`): the first axis value + the
  /// diameter value with its unit. Falls back to the product name when the schema
  /// declares no wheels.
  Widget _valueLine() {
    final primary = _primary;
    final diameter = _diameterAttrs.isNotEmpty ? _diameterAttrs.first : null;
    final parts = <String>[
      if (primary != null) _selectedLabel(primary),
      if (diameter != null)
        diameter.unitHe == null
            ? _selectedLabel(diameter)
            : '${_selectedLabel(diameter)} ${diameter.unitHe}',
    ];
    return Center(
      child: Text(
        parts.isEmpty ? widget.schema.nameHe : parts.join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: _cInk,
        ),
      ),
    );
  }

  /// `.hint` — the per-product wheel roster (`הגלגלים של ברך: זווית · אורך · קוטר · כמות`).
  Widget _hint() {
    final names = <String>[
      if (_primary != null) _primary!.nameHe,
      if (_secondary != null) _secondary!.nameHe,
      for (final a in _diameterAttrs) a.nameHe,
      'כמות',
    ];
    return Text(
      'הגלגלים של $_familyShort: ${names.join(' · ')}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: _cAccent,
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
