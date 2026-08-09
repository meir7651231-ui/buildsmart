// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · Phase A/B — the GATED dive SCREEN. Renders a catalog section
// as the design's open-rail dive: section title → families פתוחות (header) → a
// visible rail of product TILES. BuildSmart-dressed (RTL · orange · round ·
// emoji). Phase B: tapping a tile TOGGLES a generic config CARD that opens INLINE
// (accordion) under its rail while the rest of the rail stays visible (plan B.2);
// the card's schema is the ENGINE-derived [configSchemaFor] of the tile's real
// catalog product. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§המסך, phase A/B).
//
// ⚠️ LIVE (owner "תדליק"): the home renders this screen as a section (smart_home_screen
// · _CatalogConfigOpen) UNCONDITIONALLY, so it is compiled into every build (no longer
// tree-shaken / byte-identical). [route] below stays gated on `kCatalogConfig` as a
// secondary standalone entry the home embed does not use. Pilot section:
// `אביזרי קצה וחיבורים` ([pilotSectionNode]).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/features/catalog_config/browse_model.dart';
import 'package:buildsmart/features/catalog_config/catalog_config_flags.dart';
import 'package:buildsmart/features/catalog_config/catalog_taxonomy.dart'
    show materialOf, typeGroupOf;
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/variant_image.dart'
    show familyProducts, variantForSelection;
import 'package:buildsmart/features/internal_card/full_internal_card.dart'
    show FullInternalCard;
import 'package:buildsmart/features/internal_card/internal_card_flags.dart'
    show kInternalCard;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tile hairline — the brand orange at ~20% (const ARGB, no runtime opacity).
const Color _kTileBorder = Color(0x33FF7A18);

/// The rounded (radiusCard=20) white tile card shape — const so it never rebuilds.
const RoundedRectangleBorder _kTileShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(BsTokens.radiusCard)),
  side: BorderSide(color: _kTileBorder),
);

/// The same shape with a solid brand edge — the EXPANDED (open-card) tile.
const RoundedRectangleBorder _kTileShapeOpen = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(BsTokens.radiusCard)),
  side: BorderSide(color: BsTokens.brand, width: 2),
);

/// The live catalog product whose sku is [sku], or null (a fake/test tile or a
/// sku missing from the active universe → the caller skips the card). A firstWhere
/// over `resolvedCatalogProducts` with a null guard (no orElse throw).
LipskeyCatalogProduct? _product(String sku) {
  for (final product in resolvedCatalogProducts) {
    if (product.sku == sku) {
      return product;
    }
  }
  return null;
}

/// The card's MATERIAL-scoped universe — the products of [product]'s TYPE that
/// share its material (via [materialOf]), so `prioritizedSchema` builds wheels
/// listing only this material's sizes/angles (owner: "לפי הכותרת" — the card
/// filters to the tapped tile's material, not the whole cross-material type group).
List<LipskeyCatalogProduct> _materialUniverse(LipskeyCatalogProduct product) {
  final material = materialOf(product);
  return [
    for (final p in typeGroupOf(product, resolvedCatalogProducts))
      if (materialOf(p) == material) p,
  ];
}

/// The gated catalog-config dive screen (browse + inline card). STATEFUL only to
/// hold the accordion's [_CatalogConfigScreenState._expandedSku]; its browse data
/// stays the pure [browseAll] projection of the whole catalog into clean families →
/// type tiles. [onTapTile] is an OPTIONAL extra hook, fired alongside the toggle.
class CatalogConfigScreen extends ConsumerStatefulWidget {
  const CatalogConfigScreen({
    super.key,
    this.onTapTile,
    this.initialExpandedSku,
  });

  /// Optional extra tap hook, fired (in addition to toggling the inline card)
  /// when a tile is tapped. Null ⇒ only the accordion toggles.
  final void Function(ConfigTile tile)? onTapTile;

  /// The sku whose inline config card starts OPEN (else all collapsed) — the
  /// visual-verify entry uses it to render the accordion open in a static shot;
  /// null in every production route.
  final String? initialExpandedSku;

  /// The ONLY route factory — GATED. Returns null when the flag is OFF, so there
  /// is no live navigation path to this screen in a default (OFF) build.
  static Route<void>? route({void Function(ConfigTile tile)? onTapTile}) {
    if (!kCatalogConfig) {
      return null;
    }
    return MaterialPageRoute<void>(
      builder: (_) => CatalogConfigScreen(onTapTile: onTapTile),
    );
  }

  @override
  ConsumerState<CatalogConfigScreen> createState() =>
      _CatalogConfigScreenState();
}

class _CatalogConfigScreenState extends ConsumerState<CatalogConfigScreen> {
  /// The sku of the tile whose config card is open (accordion), or null. Only one
  /// card is open at a time; the rest of the rail stays visible (plan B.2).
  String? _expandedSku;

  @override
  void initState() {
    super.initState();
    _expandedSku = widget.initialExpandedSku;
  }

  void _toggleTile(ConfigTile tile) {
    widget.onTapTile?.call(tile);
    setState(() {
      _expandedSku = _expandedSku == tile.sku ? null : tile.sku;
    });
  }

  /// PLAN E.1 · הוסף-לסל — add a [SmartCartLine] that CARRIES the chosen
  /// [selection] (the configurator's picks) through the existing `smartCart.add`.
  /// The catalog has NO price field, so the price is the owner-decided stub
  /// ('לפי ספק' → 0); a variant is priced by the supplier downstream.
  void _onAddToCart(
    ProductConfigSchema schema,
    Map<String, String> selection,
    int qty,
  ) {
    final line = SmartCartLine(
      productKey: 'lip:${schema.sku}',
      productName: schema.nameHe,
      productEmoji: schema.emoji,
      brandName: '',
      brandPrice: 0,
      productQty: qty,
      accessories: const [],
      selection: selection,
    );
    ref.read(smartCartProvider.notifier).add(line);
    showToast(context, 'נוסף לסל');
  }

  /// PLAN E.2 · בנה-קו — deferred (the connection-graph endgame is gated
  /// separately); the button toasts "בקרוב" until that phase lands.
  void _onBuildLine(
    ProductConfigSchema schema,
    Map<String, String> selection,
    int qty,
  ) {
    showToast(context, 'בקרוב');
  }

  /// PLAN E.3 · פרטים — opens the INTERNAL product sheet for the SKU the current
  /// picks resolve to (the same variant the card's centre image shows). It must
  /// NEVER silently no-op: the vast majority of catalog tiles carry a CATEGORY
  /// familyId (not an engine family), so [variantForSelection]/[familyProducts]
  /// come back null/empty — the owner's bug ("עלה לי רק החיצוני לא הפנימי": only the
  /// external card came up, the internal sheet never did). So we fall back, in
  /// order, to the family's first member, then the tapped type's OWN catalog
  /// product ([_product] by sku) — opening something sensible over silence. The
  /// sheet's variant pager gets the family when we have one, else the product's
  /// catalog-category peers ([showLipskeyProductSheet] self-guards an empty list).
  void _onOpenDetails(
    ProductConfigSchema schema,
    Map<String, String> selection,
    int qty,
  ) {
    final family = familyProducts(schema, resolvedCatalogProducts);
    final product =
        variantForSelection(schema, selection, resolvedCatalogProducts) ??
            (family.isNotEmpty ? family.first : _product(schema.sku));
    if (product == null) {
      // Truly nothing to show — a foreign/test sku with no catalog row.
      return;
    }
    final siblings = family.isNotEmpty
        ? family
        : [
            for (final p in resolvedCatalogProducts)
              if (p.categoryHe == product.categoryHe) p,
          ];
    // The NEW image-first internal card (D1–D18) when its flag is on; the legacy
    // sheet stays as the flag-off fallback (byte-identical production).
    if (kInternalCard) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF232A33),
              elevation: 0.5,
              title: Text(
                product.nameHe,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            // Full-screen: the card fills the width edge-to-edge (no windowed
            // max-width), scrollable for its full height.
            body: SafeArea(
              child: SingleChildScrollView(
                child: FullInternalCard(product: product),
              ),
            ),
          ),
        ),
      );
      return;
    }
    showLipskeyProductSheet(context, product, siblings);
  }

  @override
  Widget build(BuildContext context) {
    // WHOLE catalog (owner §1·§2) — the 12 CLEAN families ([familyGroupOf], the
    // human-curated category groups) each holding its TYPE tiles ([typeWordOf], the
    // canonical word), against the 93-leaf fragmentation. The card's wheels carry the
    // variations (size/angle/color/…) of the tapped type.
    final browse = browseAll(resolvedCatalogProducts);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.bgLight,
          elevation: 0,
          scrolledUnderElevation: 2,
          title: Text(
            browse.titleHe,
            style: const TextStyle(
              color: BsTokens.brand,
              fontWeight: FontWeight.w900,
              fontSize: BsTokens.typeTitleMd,
            ),
          ),
        ),
        body: browse.families.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                // Bottom clearance so the LAST family ("אחר") scrolls clear of the
                // home's floating buttons (cart + keyboard FABs) that hover over the
                // bottom when this screen is embedded full-screen on the home (owner:
                // "אחר נחתך מתחת לכפתורים"). Harmless extra scroll on the standalone
                // route (no FABs there).
                padding: const EdgeInsets.fromLTRB(0, BsTokens.space3, 0, 104),
                itemCount: browse.families.length,
                itemBuilder: (context, i) => _FamilySection(
                  family: browse.families[i],
                  expandedSku: _expandedSku,
                  onToggle: _toggleTile,
                  onAddToCart: _onAddToCart,
                  onBuildLine: _onBuildLine,
                  onOpenDetails: _onOpenDetails,
                ),
              ),
      ),
    );
  }
}

/// Px of a HEADER horizontal drag that advances one MATERIAL page (owner).
const double _kMaterialDragStep = 64;

/// One family: a brand-accent header (emoji + title + MATERIAL label/dots) above
/// its OPEN horizontal rail of product tiles (design: "משפחות פתוחות"). A header
/// swipe pages the material (PPR → HDPE → נחושת · owner); the rail shows that
/// material's TYPES. When one of its tiles is [expandedSku], that tile's config
/// card opens INLINE below the rail (accordion). A tile whose sku resolves to no
/// catalog product (a stale/foreign sku) simply skips the card.
class _FamilySection extends StatefulWidget {
  const _FamilySection({
    required this.family,
    required this.expandedSku,
    required this.onToggle,
    required this.onAddToCart,
    required this.onBuildLine,
    required this.onOpenDetails,
  });

  final ConfigFamily family;
  final String? expandedSku;
  final void Function(ConfigTile tile) onToggle;

  /// Phase-E card actions, forwarded to the inline [ConfigCard] (הוסף-לסל /
  /// בנה-קו / פרטים) — the screen owns them so it can reach the cart provider,
  /// the toast, and the internal product sheet.
  final ConfigCardAction onAddToCart;
  final ConfigCardAction onBuildLine;
  final ConfigCardAction onOpenDetails;

  @override
  State<_FamilySection> createState() => _FamilySectionState();
}

class _FamilySectionState extends State<_FamilySection> {
  /// Which MATERIAL page the family is on — a header swipe walks it (owner).
  int _matIdx = 0;
  double _accH = 0; // header-drag accumulator (px)

  List<String> get _materials => widget.family.materials;

  String get _material => _materials.isEmpty
      ? ''
      : _materials[_matIdx.clamp(0, _materials.length - 1)];

  /// The tiles of the current material page.
  List<ConfigTile> get _tiles => widget.family.tilesFor(_material);

  String _label(String m) => m.isEmpty ? 'כללי' : m;

  void _onHeaderDrag(DragUpdateDetails d) {
    if (_materials.length < 2) return;
    _accH += d.delta.dx;
    while (_accH <= -_kMaterialDragStep) {
      _accH += _kMaterialDragStep;
      _stepMaterial(1); // drag left → next material
    }
    while (_accH >= _kMaterialDragStep) {
      _accH -= _kMaterialDragStep;
      _stepMaterial(-1);
    }
  }

  void _stepMaterial(int dir) {
    final next = (_matIdx + dir).clamp(0, _materials.length - 1);
    if (next != _matIdx) setState(() => _matIdx = next);
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles;
    final multi = _materials.length > 1;

    // The one open tile in the CURRENT material page → its inline card below.
    Widget? inlineCard;
    for (final tile in tiles) {
      if (tile.sku == widget.expandedSku) {
        final product = _product(tile.sku);
        if (product != null) {
          inlineCard = Padding(
            padding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              BsTokens.space2,
              BsTokens.space4,
              0,
            ),
            child: ConfigCard(
              key: ValueKey<String>(tile.sku),
              // schema scoped to the tile's MATERIAL (owner: "לפי הכותרת") — the
              // wheels list only this material's sizes/angles, not the whole type
              // group across materials.
              schema: prioritizedSchema(
                product,
                universe: _materialUniverse(product),
              ),
              imageAsset: tile.imageAsset,
              onAddToCart: widget.onAddToCart,
              onBuildLine: widget.onBuildLine,
              onOpenDetails: widget.onOpenDetails,
            ),
          );
        }
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SWIPEABLE header — a horizontal drag pages the MATERIAL (owner: "מושך
        // את הכותרת → סוג החומר"); the label + dots signal the swipe, the rail
        // below shows that material's types.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: multi ? _onHeaderDrag : null,
          onHorizontalDragEnd: multi ? (_) => _accH = 0 : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ProductThumb(
                      imageAsset: widget.family.representativeImage,
                      emoji: widget.family.emoji,
                      width: 38,
                      height: 38,
                      emojiSize: 20,
                      radius: 9,
                    ),
                    const SizedBox(width: BsTokens.space3),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: widget.family.titleHe,
                              style: const TextStyle(
                                color: BsTokens.brand,
                                fontSize: BsTokens.typeSubhead,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (multi)
                              TextSpan(
                                text: '  ·  ${_label(_material)}',
                                style: const TextStyle(
                                  color: BsTokens.brandDark,
                                  fontSize: BsTokens.typeSubhead,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    _CountBadge(count: widget.family.count),
                  ],
                ),
                if (multi) ...[
                  const SizedBox(height: 6),
                  _MaterialDots(count: _materials.length, index: _matIdx),
                ],
              ],
            ),
          ),
        ),
        SizedBox(
          height: 116,
          child: ListView.separated(
            // reset the type scroll when the material page changes.
            key: ValueKey<String>('${widget.family.id}:$_material'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
            itemCount: tiles.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: BsTokens.space3),
            itemBuilder: (context, i) {
              final tile = tiles[i];
              return _Tile(
                tile: tile,
                selected: tile.sku == widget.expandedSku,
                onTap: () => widget.onToggle(tile),
              );
            },
          ),
        ),
        if (inlineCard != null) inlineCard,
        const SizedBox(height: BsTokens.space3),
      ],
    );
  }
}

/// A single product tile — a rounded white card (emoji + name), tappable. The tap
/// toggles the inline card; [selected] (its card is open) draws a solid brand edge.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.tile,
    required this.selected,
    required this.onTap,
  });

  final ConfigTile tile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Material(
        color: BsTokens.cardLight,
        clipBehavior: Clip.antiAlias,
        shape: selected ? _kTileShapeOpen : _kTileShape,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Layer 3 tile: the REAL product image (emoji fallback · never
                // an empty box).
                _ProductThumb(
                  imageAsset: tile.imageAsset,
                  emoji: tile.emoji,
                  height: 54,
                  emojiSize: 30,
                  radius: 10,
                ),
                const SizedBox(height: BsTokens.space2),
                Text(
                  tile.nameHe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: BsTokens.typeLabel,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A product image resolved through the catalog resolver ([resolveProductImage]),
/// with an EMOJI fallback (plan D.2 · never an empty box): a null asset OR a failed
/// load (offline / CDN error) shows [emoji] on the light image pad. Fills the
/// available width when [width] is null (a rail tile), else a fixed square (the
/// family sub-header thumb).
class _ProductThumb extends StatelessWidget {
  const _ProductThumb({
    required this.imageAsset,
    required this.emoji,
    required this.height,
    required this.emojiSize,
    this.width,
    this.radius = 12,
  });

  final String? imageAsset;
  final String emoji;
  final double height;
  final double emojiSize;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final asset = imageAsset;
    final fallback = Text(emoji, style: TextStyle(fontSize: emojiSize));
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: BsTokens.bgLightAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: asset == null
          ? fallback
          : Image(
              image: resolveProductImage(asset),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
    );
  }
}

/// The family sub-header product-count pill (mockup `.cnt` — brand fill, white).
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space2,
        vertical: 2,
      ),
      decoration: const BoxDecoration(
        color: BsTokens.brand,
        borderRadius: BorderRadius.all(Radius.circular(BsTokens.radiusPill)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: BsTokens.typeCaption,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// The MATERIAL pager dots on a swipeable family header — a wide brand pill for
/// the current material, muted dots for the rest, with a ↔ cue that the header
/// swipes between materials (owner).
class _MaterialDots extends StatelessWidget {
  const _MaterialDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '↔',
          style: TextStyle(
            color: BsTokens.mutedLight,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        for (var i = 0; i < count; i++)
          Container(
            width: i == index ? 14 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == index ? BsTokens.brand : const Color(0xFFCFD4DA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

/// Shown when the pilot section resolves to no families (no products / missing
/// section) — the plan's "אין פריטים" null-fallback state.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📦', style: TextStyle(fontSize: 48)),
          SizedBox(height: BsTokens.space3),
          Text(
            'אין פריטים',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontSize: BsTokens.typeTitleSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
