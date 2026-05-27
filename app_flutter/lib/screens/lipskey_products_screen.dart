import 'dart:math';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/variant_families.dart' show productCanonicalKey;
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Category product list. Every product is a rich interactive card:
/// image-tap → fullscreen · card-tap → full sheet · name-word → filtered list
/// · SKU → copy · "+" → inline qty picker (no sheet) · ⓘ → full sheet.
class LipskeyProductsScreen extends StatelessWidget {
  const LipskeyProductsScreen({
    super.key,
    required this.category,
    required this.products,
  });

  final String category;
  final List<LipskeyCatalogProduct> products;

  static Route<void> route({
    required String category,
    required List<LipskeyCatalogProduct> products,
  }) =>
      MaterialPageRoute(
        builder: (_) =>
            LipskeyProductsScreen(category: category, products: products),
      );

  /// Open a filtered list of every catalog product whose name contains [word].
  /// Uses the inverted word-index for exact-word hits (O(1)), with a substring
  /// fallback for partial tokens (צעד 87).
  static void openWordSearch(BuildContext context, String word) {
    final w = word.trim();
    if (w.isEmpty) return;
    final indexed = (lipskeyWordIndex()[w] ?? const <String>[]).toSet();
    final hits = indexed.isNotEmpty
        ? kLipskeyCatalog.where((p) => indexed.contains(p.sku)).toList()
        : kLipskeyCatalog.where((p) => p.nameHe.contains(w)).toList();
    if (hits.isEmpty) return;
    Navigator.push(
      context,
      route(category: 'תוצאות: $w', products: hits),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: cs.onSurface,
          elevation: 0,
          scrolledUnderElevation: 2,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              Text('${products.length} מוצרים',
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.5), fontSize: 12)),
            ],
          ),
        ),
        body: LipskeyProductsList(products: products),
      ),
    );
  }
}

/// The product list body on its own, so it can be embedded in the catalog tab
/// (keeping the app bar and bottom nav fixed) instead of a full-screen route.
/// Honors the catalog `viewMode` (list ↔ grid) and `gridColumns` settings.
class LipskeyProductsList extends ConsumerStatefulWidget {
  const LipskeyProductsList({super.key, required this.products});

  final List<LipskeyCatalogProduct> products;

  @override
  ConsumerState<LipskeyProductsList> createState() =>
      _LipskeyProductsListState();
}

class _LipskeyProductsListState extends ConsumerState<LipskeyProductsList> {
  /// Per-slot override: originalSku → currentlyDisplayedSku.
  /// A slot ends up showing kLipskeyCatalog[currentSku] instead of the
  /// product it was created with.
  final Map<String, String> _swap = {};

  LipskeyCatalogProduct _displayed(LipskeyCatalogProduct orig) {
    final cur = _swap[orig.sku];
    if (cur == null || cur == orig.sku) return orig;
    return kLipskeyCatalog.firstWhere(
      (q) => q.sku == cur,
      orElse: () => orig,
    );
  }

  /// Build the visible slot list. Each slot has: (origSku, displayedProduct,
  /// allFamilySiblings). All canonical-family siblings collapse into ONE slot
  /// — the card uses [familySiblings] to render a "↻ X" cycle button so the
  /// user can switch between any of them (size/color/model/subtype variants
  /// AND pure SKU duplicates with identical names).
  List<(String origSku, LipskeyCatalogProduct shown, List<LipskeyCatalogProduct> siblings)>
      _visibleSlots() {
    final shown = <(String, LipskeyCatalogProduct, List<LipskeyCatalogProduct>)>[];
    // Pre-compute family → all products in widget.products with that key.
    final byFamily = <String, List<LipskeyCatalogProduct>>{};
    for (final p in widget.products) {
      byFamily.putIfAbsent(productListDedupeKey(p), () => []).add(p);
    }
    final seenFamily = <String>{};
    final seenSku = <String>{};
    for (final orig in widget.products) {
      final cur = _displayed(orig);
      if (seenSku.contains(cur.sku)) continue;
      final family = productListDedupeKey(cur);
      if (seenFamily.contains(family)) continue;
      seenSku.add(cur.sku);
      seenFamily.add(family);
      shown.add((orig.sku, cur, byFamily[family] ?? const []));
    }
    return shown;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(catalogSettingsProvider);
    final slots = _visibleSlots();
    if (settings.viewMode == CatalogViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: settings.gridColumns.clamp(1, 4),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.66,
        ),
        itemCount: slots.length,
        itemBuilder: (_, i) => LipskeyProductGridCard(
          key: ValueKey(slots[i].$1),
          product: slots[i].$2,
          products: widget.products,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final (origSku, shown, siblings) = slots[i];
        return _ProductRow(
          key: ValueKey(origSku),
          product: shown,
          categoryProducts: widget.products,
          familySiblings: siblings,
          onCycle: (next) => setState(() => _swap[origSku] = next.sku),
        );
      },
    );
  }
}

/// A single product card, for embedding products beneath the drill rows.
/// Switches between the rich row and the compact grid cell per `viewMode`.
class LipskeyProductCard extends ConsumerWidget {
  const LipskeyProductCard({
    super.key,
    required this.product,
    required this.products,
  });

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ref.watch(catalogSettingsProvider).viewMode ==
        CatalogViewMode.grid;
    return grid
        ? LipskeyProductGridCard(product: product, products: products)
        : _ProductRow(product: product, categoryProducts: products);
  }
}

/// Pure: grid-card image inner padding + fallback-emoji size per
/// [CatalogImageSize]. Larger size ⇒ less padding (bigger image) + bigger emoji.
({double pad, double emoji}) gridCardImageMetrics(CatalogImageSize size) =>
    switch (size) {
      CatalogImageSize.small => (pad: 14, emoji: 30),
      CatalogImageSize.medium => (pad: 6, emoji: 40),
      CatalogImageSize.large => (pad: 0, emoji: 52),
    };

/// Compact vertical grid card — mirrors the legacy Preact `.product` card:
/// square image (✓ when in cart) · name (2 lines) · price · add/stepper bar.
class LipskeyProductGridCard extends ConsumerWidget {
  const LipskeyProductGridCard({
    super.key,
    required this.product,
    required this.products,
  });

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> products;

  static const _brand = Color(0xFFFF7A18);
  static const _ok = Color(0xFF1F8A4C);

  String get _key => 'lip:${product.sku}';

  SmartCartLine _line(int qty) => SmartCartLine(
        productKey: _key,
        productName: product.nameHe,
        productEmoji: product.typeEmoji,
        brandName: product.brand,
        brandPrice: 0,
        productQty: qty,
        accessories: const [],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final cart = ref.watch(smartCartProvider.notifier);
    final qty = ref.watch(smartCartProvider
        .select((lines) => lines
            .where((l) => l.productKey == _key)
            .fold<int>(0, (s, l) => s + l.productQty)));
    final inCart = qty > 0;
    final settings = ref.watch(catalogSettingsProvider);
    final compact = settings.compactMode;
    final img = gridCardImageMetrics(settings.imageSize);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inCart ? _ok : cs.outline.withOpacity(0.2),
          width: inCart ? 1.4 : 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // image (tap = sheet) + ✓ in-cart badge
          Expanded(
            child: GestureDetector(
              onTap: () => showLipskeyProductSheet(context, product, products),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(img.pad),
                    child: product.imageAsset != null
                        ? Image.asset(product.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(product.typeEmoji,
                                style: TextStyle(fontSize: img.emoji)))
                        : Text(product.typeEmoji,
                            style: TextStyle(fontSize: img.emoji)),
                  ),
                  if (inCart)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: _ok,
                        child: Text('✓',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // name + price (tap = sheet)
          GestureDetector(
            onTap: () => showLipskeyProductSheet(context, product, products),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, compact ? 3 : 6, 8, compact ? 2 : 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: compact ? 26 : 32,
                    child: Text(
                      product.nameHe,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'מחיר לפי ספק',
                    style: TextStyle(
                      color: Color(0xFF45575E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // stepper / add bar
          Container(
            padding: EdgeInsets.all(compact ? 4 : 6),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: cs.outline.withOpacity(0.15)),
              ),
            ),
            child: inCart
                ? Row(
                    children: [
                      _StepBtn(
                        icon: Icons.remove,
                        filled: false,
                        onTap: () => cart.setQtyForKey(_line(qty - 1)),
                      ),
                      Expanded(
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _StepBtn(
                        icon: Icons.add,
                        filled: true,
                        onTap: () => cart.setQtyForKey(_line(qty + 1)),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () => cart.setQtyForKey(_line(1)),
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: _brand,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'לעגלה',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.filled, required this.onTap});
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFFF7A18);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? brand : Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: brand, width: 1.2),
        ),
        child: Icon(icon,
            color: filled ? Colors.white : brand, size: 18),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
class _ProductRow extends ConsumerStatefulWidget {
  const _ProductRow({
    super.key,
    required this.product,
    required this.categoryProducts,
    this.familySiblings = const [],
    this.onCycle,
  });

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> categoryProducts;
  /// Every product in the same canonical-family (collapsed into this row).
  /// When length > 1 the card shows a ↻ button to cycle through them.
  final List<LipskeyCatalogProduct> familySiblings;
  /// Called when the user taps an attribute chip and cycles to a new sibling.
  /// The parent should update its swap state so the displayed product changes.
  final void Function(LipskeyCatalogProduct next)? onCycle;

  @override
  ConsumerState<_ProductRow> createState() => _ProductRowState();
}

enum _Unit { single, pack, pallet }

class _ProductRowState extends ConsumerState<_ProductRow> {
  bool _open = false;
  int _qty = 1;
  _Unit _unit = _Unit.single;
  /// Local cycle state for standalone cards (when no onCycle parent callback).
  LipskeyCatalogProduct? _localProduct;
  /// Inline attribute picker state — non-null when picker is open.
  AttrKind? _pickerKind;
  List<LipskeyCatalogProduct>? _pickerSiblings;

  static const _brand = Color(0xFFFF7A18);
  static const _teal = Color(0xFF3DD9B0);
  Color get _muted => Theme.of(context).colorScheme.onSurface.withOpacity(0.45);
  Color get _line => Theme.of(context).colorScheme.outline.withOpacity(0.2);

  /// Currently-displayed product — uses local state for standalone cards.
  LipskeyCatalogProduct get p => _localProduct ?? widget.product;

  @override
  void didUpdateWidget(_ProductRow old) {
    super.didUpdateWidget(old);
    if (old.product.sku != widget.product.sku) {
      _localProduct = null;
      _pickerKind = null;
      _pickerSiblings = null;
    }
  }

  /// The attribute value(s) of [product] for the given [kind].
  /// Matches the longest entry from the attribute list so that "ניקל מוברש"
  /// is returned instead of just "ניקל" when both words are present.
  String _attrVal(LipskeyCatalogProduct product, AttrKind kind) {
    final words = product.nameHe.split(RegExp(r'\s+'));
    final entries = switch (kind) {
      AttrKind.color => kLipskeyColors,
      AttrKind.model => kLipskeyModels,
      AttrKind.subtype => kLipskeySubtypes,
      AttrKind.size => const <String>[],
    };
    final sorted = [...entries]..sort((a, b) => b.length.compareTo(a.length));
    for (final entry in sorted) {
      if (entry.split(RegExp(r'\s+')).every(words.contains)) return entry;
    }
    return words.where((w) => _attrKindFor(w) == kind).join(' ');
  }

  void _cycleAttr(String word, AttrKind kind) {
    final siblings = findAttrSiblings(p, word, kind);
    if (siblings.length <= 1) return;
    setState(() {
      if (_pickerKind == kind) {
        _pickerKind = null;
        _pickerSiblings = null;
      } else {
        _pickerKind = kind;
        _pickerSiblings = siblings;
      }
    });
  }

  void _selectFromPicker(LipskeyCatalogProduct next) {
    final cb = widget.onCycle;
    setState(() {
      _pickerKind = null;
      _pickerSiblings = null;
      if (next.sku != p.sku) {
        if (cb != null) {
          // parent list owns the state — close and report
        } else {
          _localProduct = next;
        }
      }
    });
    if (next.sku != p.sku && cb != null) cb(next);
  }

  int get _unitMult => switch (_unit) {
        _Unit.single => 1,
        _Unit.pack => p.qtyPack ?? 1,
        _Unit.pallet => p.qtyPallet ?? 1,
      };

  bool get _inCart {
    final key = 'lip:${p.sku}';
    return ref.watch(smartCartProvider).any((l) => l.productKey == key);
  }

  void _addToCart() {
    ref.read(smartCartProvider.notifier).add(SmartCartLine(
          productKey: 'lip:${p.sku}',
          productName: p.nameHe,
          productEmoji: p.typeEmoji,
          brandName: p.brand,
          brandPrice: 0,
          productQty: _qty * _unitMult,
          accessories: const [],
        ));
  }

  /// Cycle to the next product in the canonical family (handles identical-name
  /// duplicates as well as attribute variants).
  void _cycleFamily() {
    final sibs = widget.familySiblings;
    if (sibs.length < 2) return;
    final idx = sibs.indexWhere((q) => q.sku == p.sku);
    final next = sibs[(idx < 0 ? 0 : (idx + 1) % sibs.length)];
    if (next.sku == p.sku) return;
    final cb = widget.onCycle;
    if (cb != null) {
      cb(next);
    } else {
      setState(() => _localProduct = next);
    }
  }

  void _openSheet() =>
      showLipskeyProductSheet(context, p, widget.categoryProducts);

  void _openImage() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Center(
            child: p.imageAsset != null
                ? Image.asset(p.imageAsset!, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Image.asset(p.specImageAsset, fit: BoxFit.contain))
                : Image.asset(p.specImageAsset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = ref.watch(catalogSettingsProvider).compactMode;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 3 : 6),
      constraints: BoxConstraints(minHeight: compact ? 104 : 138),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _open ? _brand : _line,
          width: _open ? 1.5 : 0.8,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _image(),
                Expanded(child: _body()),
                _side(),
              ],
            ),
          ),
          if (_pickerKind != null && _pickerSiblings != null)
            _attrPicker(),
        ],
      ),
    );
  }

  Widget _attrPicker() {
    final siblings = _pickerSiblings!;
    final kind = _pickerKind!;
    final label = switch (kind) {
      AttrKind.size => 'מידה',
      AttrKind.color => 'צבע',
      AttrKind.model => 'דגם',
      AttrKind.subtype => 'סוג',
    };
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _line, width: 0.8)),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('בחר $label:',
              style: TextStyle(
                  color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final sibling in siblings) ...[
                  GestureDetector(
                    onTap: () => _selectFromPicker(sibling),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sibling.sku == p.sku
                            ? _brand.withOpacity(0.12)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sibling.sku == p.sku
                              ? _brand
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                          width: sibling.sku == p.sku ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        _attrVal(sibling, kind).isEmpty
                            ? sibling.sku
                            : _attrVal(sibling, kind),
                        style: TextStyle(
                          color: sibling.sku == p.sku
                              ? _brand
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: sibling.sku == p.sku
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── image (tap = fullscreen) + ✓ in-cart badge ───────────────────────────
  Widget _image() {
    final sz = ref.watch(catalogSettingsProvider).imageSize;
    final w = switch (sz) {
      CatalogImageSize.small => 64.0,
      CatalogImageSize.medium => 88.0,
      CatalogImageSize.large => 112.0,
    };
    final h = switch (sz) {
      CatalogImageSize.small => 60.0,
      CatalogImageSize.medium => 84.0,
      CatalogImageSize.large => 106.0,
    };
    return GestureDetector(
      onTap: _openImage,
      child: ClipRRect(
        borderRadius:
            const BorderRadius.horizontal(right: Radius.circular(14)),
        child: SizedBox(
          width: w,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: p.imageAsset != null
                    ? Image.asset(p.imageAsset!,
                        height: h,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(p.typeEmoji,
                            style: const TextStyle(fontSize: 36)))
                    : Text(p.typeEmoji,
                        style: const TextStyle(fontSize: 36)),
              ),
              if (_inCart)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: _teal,
                    child: Text('✓',
                        style: TextStyle(
                            color: Color(0xFF06251C),
                            fontSize: 15,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── body: card-tap = sheet · name words tappable · price · brand · sku ────
  Widget _body() {
    return GestureDetector(
      onTap: _openSheet,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // line 1: category type + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(p.categoryHe,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2)),
                ),
                const SizedBox(width: 8),
                Text('מחיר לפי ספק',
                    style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            // line 2: name words as tappable chips — any attribute chip cycles
            _NameWords(product: p, onAttrTap: _cycleAttr, openKind: _pickerKind),
            const SizedBox(height: 8),
            // brand + sku
            Row(
              children: [
                Text(
                    p.brand == 'AQUATEC'
                        ? '💧 AQUATEC'
                        : '🏭 ${p.brand}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                        fontSize: 10)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: p.sku));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('מק"ט הועתק'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: Text('#${p.sku}',
                      style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontFamily: 'monospace')),
                ),
                if (widget.familySiblings.length > 1) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _cycleFamily,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x22FF7A18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x55FF7A18)),
                      ),
                      child: Text(
                        '↻ ${(widget.familySiblings.indexWhere((q) => q.sku == p.sku) + 1)}/${widget.familySiblings.length}',
                        style: const TextStyle(
                          color: Color(0xFFCC6614),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── side column: closed(+middle/details bottom) · open(units/qty/details) ─
  Widget _side() {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: _line)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // top zone
          SizedBox(
            height: 34,
            child: Center(child: _open ? _unitToggle() : const SizedBox()),
          ),
          // middle zone
          _open ? _stepper() : _plusBtn(),
          // bottom zone — details (opens sheet)
          GestureDetector(
            onTap: _openSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.4)),
                  ),
                  alignment: Alignment.center,
                  child: Text('ⓘ',
                      style: TextStyle(color: _muted, fontSize: 10)),
                ),
                const SizedBox(width: 4),
                Text('פרטים',
                    style: TextStyle(color: _muted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plusBtn() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _open = true;
          _qty = 1;
        });
        _addToCart();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: _brand, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: const Text('+',
            style: TextStyle(
                color: Color(0xFF1A1200),
                fontSize: 24,
                fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _unitToggle() {
    Widget opt(String label, _Unit u, {required bool enabled}) {
      final sel = _unit == u;
      return GestureDetector(
        onTap: enabled ? () => setState(() => _unit = u) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          color: sel ? _brand : Colors.transparent,
          child: Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: sel
                      ? const Color(0xFF1A1200)
                      : (enabled ? _muted : const Color(0xFF44495A)),
                  fontWeight: sel ? FontWeight.w800 : FontWeight.w400)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          opt('בודד', _Unit.single, enabled: true),
          opt('ארגז', _Unit.pack, enabled: p.qtyPack != null),
          opt('משטח', _Unit.pallet, enabled: p.qtyPallet != null),
        ],
      ),
    );
  }

  Widget _stepper() {
    Widget btn(String s, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 28,
            height: 30,
            child: Center(
                child: Text(s,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 17))),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(color: _brand),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn('−', () => setState(() => _qty = max(1, _qty - 1))),
          SizedBox(
            width: 30,
            child: Center(
                child: Text('$_qty',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 14))),
          ),
          btn('+', () => setState(() => _qty++)),
        ],
      ),
    );
  }
}


/// Hebrew noise words / prepositions that shouldn't be clickable search links.
const Set<String> kSearchStopWords = {
  'עם', 'של', 'את', 'או', 'ל', 'ה', 'ו', 'ב', 'כ', 'מ', 'על', 'אל',
  'ללא', 'בלי', 'כמות', 'באריזה', 'במשטח', 'יח', 'יחידות',
};

/// Size / dimension token — these define compatibility ("what connects to
/// what"), so they ARE clickable (find every part of the same size).
/// Examples: DN50 · 3/4" · 1¼" · 110 · 130/50 · 50/40.
bool isSizeToken(String w) {
  if (RegExp(r'^DN', caseSensitive: false).hasMatch(w)) return true;
  // numbers, fractions, ratios, inch marks, with optional × / - separators
  return RegExp(r'^[\d]+([./×x\-"׳״⅛¼½¾⅜⅝⅞]+[\d"׳״]*)*[\"׳״]?$')
          .hasMatch(w) &&
      RegExp(r'\d').hasMatch(w);
}

/// A plain word is a meaningful tappable link if it isn't a stop-word and
/// has length ≥ 2 (sizes are handled separately by [isSizeToken]).
bool isLinkableWord(String w) {
  if (w.length < 2) return false;
  if (kSearchStopWords.contains(w)) return false;
  if (isSizeToken(w)) return false; // styled as a size chip instead
  return true;
}

/// Kinds of attributes that are cyclable variants on a product card.
enum AttrKind { size, color, model, subtype }

/// Detect which attribute kind a word belongs to (or null for none).
AttrKind? _attrKindFor(String word) {
  if (isSizeToken(word)) return AttrKind.size;
  if (kLipskeyColors.contains(word)) return AttrKind.color;
  if (kLipskeyModels.contains(word)) return AttrKind.model;
  if (kLipskeySubtypes.contains(word)) return AttrKind.subtype;
  return null;
}

/// Emoji marker per attribute kind (shown on the chip).
String _attrEmoji(AttrKind k) => switch (k) {
      AttrKind.size => '📐',
      AttrKind.color => '🎨',
      AttrKind.model => '🏷',
      AttrKind.subtype => '📋',
    };

/// Drop every word that belongs to [kind] from a name. What remains is the
/// "frame" — the part of the name that should match between siblings.
/// Uses per-kind sub-word sets so that modifier words like "מוברש" (part of
/// "זהב מוברש" or "ניקל מוברש") are also stripped, giving consistent frames.
String _stripWordsOfKind(String name, AttrKind kind) {
  final Set<String> wordSet = switch (kind) {
    AttrKind.color => _kColorWords,
    AttrKind.model => _kModelWords,
    AttrKind.subtype => _kSubtypeWords,
    AttrKind.size => const {},
  };
  return name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && (kind == AttrKind.size ? !isSizeToken(w) : !wordSet.contains(w)))
      .join(' ')
      .trim();
}

/// All individual words that appear in any attribute-value entry (including
/// sub-words of multi-word entries such as "מוברש" from "ניקל מוברש").
/// Used by [productListDedupeKey] so that "שחור מט" and "שחור" collapse to the
/// same frame (both "מט" and "שחור" are stripped).
final _kAttrWordSet = <String>{
  for (final v in [...kLipskeyColors, ...kLipskeyModels, ...kLipskeySubtypes])
    ...v.split(RegExp(r'\s+')).where((w) => w.length >= 2),
};

// Per-kind sub-word sets — used by _stripWordsOfKind to strip ALL sub-words
// of a multi-word entry (e.g. "מוברש" from "ניקל מוברש") so that frames
// match across all color variants of a product family.
final _kColorWords = <String>{
  for (final v in kLipskeyColors) ...v.split(RegExp(r'\s+')).where((w) => w.length >= 2),
};
final _kModelWords = <String>{
  for (final v in kLipskeyModels) ...v.split(RegExp(r'\s+')).where((w) => w.length >= 2),
};
final _kSubtypeWords = <String>{
  for (final v in kLipskeySubtypes) ...v.split(RegExp(r'\s+')).where((w) => w.length >= 2),
};

/// Deduplication key for the product list view.  Two products get the same key
/// when they are variants of each other (same product, different attribute
/// values such as colour/size/model).
///
/// Intentionally does NOT include catalog page, pack qty or pallet qty —
/// variant products are sometimes printed on different catalogue pages.
String productListDedupeKey(LipskeyCatalogProduct p) {
  final stripped = p.nameHe
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !isSizeToken(w) && !_kAttrWordSet.contains(w))
      .join(' ');
  return '${p.brand}||${p.categoryHe}||$stripped';
}

/// Find products in the same category that share the same frame as [p] (after
/// stripping all words of [kind]) and have at least one word of [kind] in their
/// name. These are the siblings that the chip should cycle through.
List<LipskeyCatalogProduct> findAttrSiblings(
  LipskeyCatalogProduct p,
  String word,
  AttrKind kind,
) {
  final pFrame = _stripWordsOfKind(p.nameHe, kind);
  if (pFrame.length < 2) return [p];
  return kLipskeyCatalog.where((q) {
    if (q.categoryHe != p.categoryHe) return false;
    if (_stripWordsOfKind(q.nameHe, kind) != pFrame) return false;
    return q.nameHe
        .split(RegExp(r'\s+'))
        .any((w) => _attrKindFor(w) == kind);
  }).toList();
}

// ── name split into tappable chips: attribute chips (orange) + words (teal) ─
class _NameWords extends StatelessWidget {
  const _NameWords({required this.product, this.onAttrTap, this.openKind});
  final LipskeyCatalogProduct product;
  /// Tap handler for any attribute chip. Receives the clicked word and its
  /// kind so the card can cycle to the next sibling for that attribute.
  final void Function(String word, AttrKind kind)? onAttrTap;
  /// The attribute kind whose picker is currently open — that chip gets orange styling.
  final AttrKind? openKind;

  @override
  Widget build(BuildContext context) {
    final words = product.nameHe.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return Wrap(
      spacing: 4,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final w in words)
          if (_attrKindFor(w) != null)
            _AttrChip(
              word: w,
              kind: _attrKindFor(w)!,
              product: product,
              onTap: onAttrTap,
              isOpen: openKind == _attrKindFor(w),
            )
          else if (isLinkableWord(w))
            GestureDetector(
              onTap: () => LipskeyProductsScreen.openWordSearch(context, w),
              child: Text(w,
                  style: const TextStyle(
                      color: Color(0xFF3DD9B0),
                      fontSize: 12,
                      height: 1.3,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF2A5E52))),
            )
          else
            Text(w,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                    height: 1.3)),
      ],
    );
  }
}

/// One attribute chip in the product name. Gray by default; turns orange when
/// its picker is open (isOpen=true). Tap opens the inline picker (if siblings
/// exist); a second tap on the same chip closes it.
class _AttrChip extends StatelessWidget {
  const _AttrChip({
    required this.word,
    required this.kind,
    required this.product,
    required this.onTap,
    this.isOpen = false,
  });
  final String word;
  final AttrKind kind;
  final LipskeyCatalogProduct product;
  final void Function(String word, AttrKind kind)? onTap;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final hasSiblings =
        onTap != null && findAttrSiblings(product, word, kind).length > 1;
    final bgColor = isOpen ? const Color(0x22FF7A18) : const Color(0x10888888);
    final borderColor = isOpen ? const Color(0x55FF7A18) : const Color(0x30888888);
    final textColor = isOpen ? const Color(0xFFFF9D4D) : const Color(0xFF909090);
    return GestureDetector(
      onTap: hasSiblings ? () => onTap!(word, kind) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          hasSiblings ? '${_attrEmoji(kind)} $word ⟳' : '${_attrEmoji(kind)} $word',
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Strip size tokens from a product name to get its "base name" (the model
/// without dimensions). Used to find sibling products at different sizes.
String _stripSizeTokens(String name) {
  return name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !isSizeToken(w))
      .join(' ')
      .trim();
}

/// Same-model siblings at different sizes. Two products are siblings when they
/// share the same category and the same name with size tokens removed.
/// Returns [p] alone when [p] has no size token (so we don't invent siblings
/// out of unrelated same-named products).
List<LipskeyCatalogProduct> findSizeSiblings(LipskeyCatalogProduct p) {
  final base = _stripSizeTokens(p.nameHe);
  if (base.length < 3) return [p];
  if (base == p.nameHe) return [p]; // no size token in name → no variants
  return kLipskeyCatalog
      .where((q) => q.categoryHe == p.categoryHe && _stripSizeTokens(q.nameHe) == base)
      .toList();
}

/// Pick the first size token from a product name as a short label.
String _sizeLabel(LipskeyCatalogProduct p) {
  final sizeWords = p.nameHe
      .split(RegExp(r'\s+'))
      .where(isSizeToken)
      .toList();
  return sizeWords.isEmpty ? p.sku : sizeWords.join(' ');
}

/// First numeric value in a size label (e.g. "1/2\"" → 1, "DN50" → 50). Used
/// to sort size siblings in an intuitive order.
double _firstSizeNum(String s) {
  final m = RegExp(r'\d+(?:\.\d+)?').firstMatch(s);
  if (m == null) return 0;
  return double.tryParse(m.group(0)!) ?? 0;
}

