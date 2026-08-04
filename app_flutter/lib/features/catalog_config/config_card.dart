// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · Phase B/C — the GENERIC config CARD. ONE StatefulWidget that
// renders ANY [ProductConfigSchema] (the engine-derived model) directly: a CENTER
// image (or the fallback emoji) + a Row of spinning [WheelPicker]s (one per
// declared [AttributeDef]) + a qty stepper + הוסף-לסל / בנה-קו. ZERO per-product
// code — the card hardcodes NO elbow/manifold shape; it draws whatever the schema
// declares, so a new product is a data row (plan 🫀). SSOT:
// knowledge/CATALOG-CONFIG-PLAN.md (§B.1, § פאזה C).
//
// The live selection is a `Map<String,String>` keyed by [AttributeDef.id], seeded
// from each attribute's DEFAULT value (the `sortIndex == 0` value, else the
// first) and stored as its canonical form (`AttributeValue.canonical ?? labelHe`)
// — the same token the cart line carries (plan E.1). Spinning a wheel writes the
// newly-centred value in and re-renders. An empty [ProductConfigSchema.attributes]
// still renders (image + qty stepper + הוסף-לסל stay usable — plan 🛡️).
//
// GATING (plan G · byte-identical-off): a pure widget with NO `kCatalogConfig`
// branch of its own — reachable only through the gated dive SCREEN (behind
// `route()`/`if (kCatalogConfig)`), so it tree-shakes out in a default (OFF)
// build. No import path to it exists outside features/catalog_config/.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/wheel_picker.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Signature of the card's two bottom actions (הוסף-לסל · בנה-קו). The dive
/// screen wires these to `smartCart.add` / a "בקרוב" toast; null ⇒ the button is
/// inert. [selection] is keyed by [AttributeDef.id] → the chosen canonical value.
typedef ConfigCardAction = void Function(
  ProductConfigSchema schema,
  Map<String, String> selection,
  int qty,
);

/// The card-frame hairline — brand orange @ ~20% (const ARGB, no runtime opacity).
const Color _kCardBorder = Color(0x33FF7A18);

const double _kImageHeight = 140;
const double _kEmojiSize = 64;
const double _kStepIconSize = 18;

/// A wheel's Hebrew label style (muted, bold) — reused for the qty label.
const TextStyle _kLabelStyle = TextStyle(
  color: BsTokens.mutedLight,
  fontSize: BsTokens.typeLabel,
  fontWeight: FontWeight.w800,
);

/// The DEFAULT value of [attr] — the `sortIndex == 0` value, else the first.
/// A small bridge from the engine model to the card's seed (guarded caller — only
/// invoked for a non-empty [AttributeDef.values]).
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

/// THE generic config card. Stateful — it holds the live [_ConfigCardState._selection]
/// (seeded from each attribute's default) and the [_ConfigCardState._qty],
/// rebuilding on every wheel change. Generic: it renders whatever the schema
/// declares, with no per-product code.
class ConfigCard extends StatefulWidget {
  const ConfigCard({
    required this.schema,
    super.key,
    this.imageAsset,
    this.onAddToCart,
    this.onBuildLine,
  });

  /// The product's engine-derived declaration — the wheels the card renders.
  final ProductConfigSchema schema;

  /// The product's base image asset (plan D · resolved through
  /// [resolveProductImage]); null ⇒ the big emoji fallback (D.2 — never empty).
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
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _selection = _seed(widget.schema);
  }

  @override
  void didUpdateWidget(ConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A different product re-seeds the selection + qty (defensive — the screen
    // keys the card by sku, so the State is normally fresh per product anyway).
    if (oldWidget.schema.sku != widget.schema.sku) {
      _selection = _seed(widget.schema);
      _qty = 1;
    }
  }

  /// The default selection — each non-empty attribute's default token, keyed by
  /// [AttributeDef.id]. Empty when the schema declares no wheels (still usable).
  Map<String, String> _seed(ProductConfigSchema schema) => <String, String>{
        for (final attr in schema.attributes)
          if (attr.values.isNotEmpty) attr.id: _token(_defaultValue(attr)),
      };

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

  void _select(String id, String value) {
    setState(() {
      _selection[id] = value;
    });
  }

  void _incQty() {
    setState(() {
      _qty++;
    });
  }

  void _decQty() {
    setState(() {
      if (_qty > 1) {
        _qty--;
      }
    });
  }

  void _onAddToCart() {
    widget.onAddToCart?.call(
      widget.schema,
      Map<String, String>.of(_selection),
      _qty,
    );
  }

  void _onBuildLine() {
    widget.onBuildLine?.call(
      widget.schema,
      Map<String, String>.of(_selection),
      _qty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _imageArea(),
          const SizedBox(height: BsTokens.space4),
          _wheelsRow(),
          const SizedBox(height: BsTokens.space2),
          _qtyStepper(),
          const SizedBox(height: BsTokens.space4),
          _actionRow(),
        ],
      ),
    );
  }

  /// The CENTER image area (plan D) — the product's REAL base image resolved
  /// through the catalog resolver ([resolveProductImage]: absolute URL / CDN-
  /// cached / bundled asset), guarded by an errorBuilder that falls back to the
  /// schema emoji; no image ⇒ the big emoji (plan D.2 — never empty).
  ///
  /// PER-PRODUCT (per-SKU) only: the data has NO per-combination image matrix (a
  /// variant is its own SKU), so the image does NOT change on a wheel-spin — a
  /// per-selection swap is a deferred owner decision (plan D.1), not faked here.
  Widget _imageArea() {
    final image = widget.imageAsset;
    return Container(
      height: _kImageHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BsTokens.surfaceMid,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: image == null
          ? Text(
              widget.schema.emoji,
              style: const TextStyle(fontSize: _kEmojiSize),
            )
          : Image(
              image: resolveProductImage(image),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                widget.schema.emoji,
                style: const TextStyle(fontSize: _kEmojiSize),
              ),
            ),
    );
  }

  /// The wheels — a horizontal [Row] of vertical spinning [WheelPicker]s (one per
  /// declared [AttributeDef], each [Expanded] so they share the width). Spinning
  /// a wheel writes the newly-centred token into the live [_selection] (via
  /// [_select]) and rebuilds. GENERIC: it lays out whatever wheels the schema
  /// declares — 1, 3, or none (an empty schema ⇒ an empty row, still usable).
  Widget _wheelsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final attr in widget.schema.attributes)
          if (attr.values.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: BsTokens.space1),
                child: WheelPicker(
                  labelHe: attr.nameHe,
                  values: [for (final v in attr.values) v.labelHe],
                  selectedIndex: _selectedIndex(attr),
                  kind: attr.kind,
                  onSelected: (i) => _select(attr.id, _token(attr.values[i])),
                ),
              ),
            ),
      ],
    );
  }

  /// The qty stepper — − N + (min 1), held in state (plan goldens carry '+ כמות').
  Widget _qtyStepper() {
    return Row(
      children: [
        const Text('כמות', style: _kLabelStyle),
        const Spacer(),
        _qtyButton(icon: Icons.remove, onTap: _decQty),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
          child: Text(
            '$_qty',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: BsTokens.typeSubhead,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _qtyButton(icon: Icons.add, onTap: _incQty),
      ],
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: BsTokens.surfaceMid,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space2),
          child: Icon(icon, size: _kStepIconSize, color: BsTokens.inkLight),
        ),
      ),
    );
  }

  /// הוסף-לסל (brand filled) + בנה-קו (outline).
  Widget _actionRow() {
    return Row(
      children: [
        Expanded(child: _primaryButton('הוסף לסל', _onAddToCart)),
        const SizedBox(width: BsTokens.space3),
        Expanded(child: _outlineButton('בנה קו', _onBuildLine)),
      ],
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return Material(
      color: BsTokens.brand,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: BsTokens.cardLight,
                fontWeight: FontWeight.w800,
                fontSize: BsTokens.typeBody,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(String label, VoidCallback onTap) {
    return Material(
      color: BsTokens.cardLight,
      shape: const StadiumBorder(
        side: BorderSide(color: BsTokens.brand),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: BsTokens.brand,
                fontWeight: FontWeight.w800,
                fontSize: BsTokens.typeBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
