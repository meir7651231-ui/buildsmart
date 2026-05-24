import 'dart:math';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
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
  static void openWordSearch(BuildContext context, String word) {
    final w = word.trim();
    if (w.isEmpty) return;
    final hits =
        kLipskeyCatalog.where((p) => p.nameHe.contains(w)).toList();
    if (hits.isEmpty) return;
    Navigator.push(
      context,
      route(category: 'תוצאות: $w', products: hits),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1116),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E1116),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              Text('${products.length} מוצרים',
                  style:
                      const TextStyle(color: Color(0xFF9AA3B2), fontSize: 12)),
            ],
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: products.length,
          itemBuilder: (_, i) => _ProductRow(
            product: products[i],
            categoryProducts: products,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
class _ProductRow extends ConsumerStatefulWidget {
  const _ProductRow({required this.product, required this.categoryProducts});

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> categoryProducts;

  @override
  ConsumerState<_ProductRow> createState() => _ProductRowState();
}

enum _Unit { single, pack, pallet }

class _ProductRowState extends ConsumerState<_ProductRow> {
  bool _open = false;
  int _qty = 1;
  _Unit _unit = _Unit.single;

  static const _brand = Color(0xFFFF7A18);
  static const _teal = Color(0xFF3DD9B0);
  static const _muted = Color(0xFF9AA3B2);
  static const _line = Color(0xFF252B36);

  LipskeyCatalogProduct get p => widget.product;

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      constraints: const BoxConstraints(minHeight: 138),
      decoration: BoxDecoration(
        color: const Color(0xFF181D26),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _open ? _brand : _line),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _image(),
            Expanded(child: _body()),
            _side(),
          ],
        ),
      ),
    );
  }

  // ── image (tap = fullscreen) + ✓ in-cart badge ───────────────────────────
  Widget _image() {
    return GestureDetector(
      onTap: _openImage,
      child: ClipRRect(
        borderRadius:
            const BorderRadius.horizontal(right: Radius.circular(14)),
        child: SizedBox(
          width: 88,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: const Color(0xFF10141B),
                alignment: Alignment.center,
                child: p.imageAsset != null
                    ? Image.asset(p.imageAsset!,
                        height: 84,
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
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2)),
                ),
                const SizedBox(width: 8),
                const Text('מחיר לפי ספק',
                    style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            // line 2: name words as tappable chips
            _NameWords(name: p.nameHe),
            const SizedBox(height: 8),
            // brand + sku
            Row(
              children: [
                Text(
                    p.brand == 'AQUATEC'
                        ? '💧 AQUATEC'
                        : '🏭 ${p.brand}',
                    style: const TextStyle(
                        color: Color(0xFF7FD0FF), fontSize: 10)),
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
                      style: const TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontFamily: 'monospace')),
                ),
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
      decoration: const BoxDecoration(
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
                    border: Border.all(color: const Color(0xFF3A4151)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('ⓘ',
                      style: TextStyle(color: _muted, fontSize: 10)),
                ),
                const SizedBox(width: 4),
                const Text('פרטים',
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
                    style: const TextStyle(color: Colors.white, fontSize: 17))),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10141B),
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
                    style: const TextStyle(
                        color: Colors.white,
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

// ── name split into tappable chips: words (teal) + sizes (orange) ───────────
class _NameWords extends StatelessWidget {
  const _NameWords({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return Wrap(
      spacing: 4,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final w in words)
          if (isSizeToken(w))
            // size / dimension — compatibility link (orange chip)
            GestureDetector(
              onTap: () => LipskeyProductsScreen.openWordSearch(context, w),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0x22FF7A18),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0x55FF7A18)),
                ),
                child: Text('📐 $w',
                    style: const TextStyle(
                        color: Color(0xFFFF9D4D),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
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
                style: const TextStyle(
                    color: Color(0xFF9AA3B2), fontSize: 12, height: 1.3)),
      ],
    );
  }
}
