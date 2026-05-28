import 'dart:math';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a SmartProduct-style bottom sheet for a Lipskey product.
/// [categoryProducts] = all products in the same Lipskey category (for brand variants).
void showLipskeyProductSheet(
  BuildContext context,
  LipskeyCatalogProduct product,
  List<LipskeyCatalogProduct> categoryProducts,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LipskeyProductSheet(
      product: product,
      categoryProducts: categoryProducts,
    ),
  );
}

/// Fullscreen pinch/zoom viewer for a product image or spec page.
void _openFullscreenAsset(BuildContext context, String asset, String emoji) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.92),
    builder: (_) => Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 5,
            child: Center(
              child: Image.asset(asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(emoji,
                      style: const TextStyle(fontSize: 96))),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: Material(
            color: Colors.black12,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.close, color: Colors.white)),
            ),
          ),
        ),
        const Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: Text('צבוט להגדלה · הקש לסגירה',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 12)),
        ),
      ],
    ),
  );
}

class LipskeyProductSheet extends ConsumerStatefulWidget {
  const LipskeyProductSheet({
    super.key,
    required this.product,
    required this.categoryProducts,
  });

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> categoryProducts;

  @override
  ConsumerState<LipskeyProductSheet> createState() =>
      _LipskeyProductSheetState();
}

enum _Unit { single, pack, pallet }

class _LipskeyProductSheetState extends ConsumerState<LipskeyProductSheet> {
  late int _selectedIdx;
  LipskeyCatalogProduct? _chipOverride;
  String? _openPickerKey; // 'type' | 'subtype' | 'model' | 'color'
  int? _activeStage;
  late Map<int, bool> _accSelected;
  int _qty = 1;
  _Unit _unit = _Unit.single;

  int get _unitMult => switch (_unit) {
        _Unit.single => 1,
        _Unit.pack => _current.qtyPack ?? 1,
        _Unit.pallet => _current.qtyPallet ?? 1,
      };

  /// Normalised DN-size set used for *matching* compatibility. Only sizes in
  /// a real dimension context — DN-prefixed, ratios (50/40), inch fractions —
  /// so packaging quantities ("75 כמות באריזה") and lengths ("200 ס"מ") are
  /// NOT treated as sizes.
  Set<String> _sizeSet(String name) {
    final out = <String>{};
    void addParts(String token) {
      out.add(token);
      for (final part in token.split('/')) {
        if (part.length >= 2 && RegExp(r'^\d+$').hasMatch(part)) out.add(part);
      }
    }

    for (final raw in name.split(RegExp(r'\s+'))) {
      final w = raw.trim();
      final up = w.toUpperCase();
      if (up.startsWith('DN') && RegExp(r'\d').hasMatch(w)) {
        addParts(up.replaceAll(RegExp(r'[^0-9/]'), ''));
      } else if (RegExp(r'^\d').hasMatch(w) && w.contains('/')) {
        addParts(w.replaceAll('"', '')); // 50/40 · 130/50 · 3/4
      } else if (w.contains('"') && RegExp(r'\d').hasMatch(w)) {
        out.add(w.replaceAll('"', '')); // 1.25 · 1¼
      }
      // bare numbers are intentionally ignored (ambiguous with qty/length)
    }
    return out.where((s) => s.length >= 2).toSet();
  }

  /// The distinct *connection ends* of a product — the atomic DN/inch sizes.
  /// A reducer "75/50" has two ends (75, 50); "DN50" has one (50).
  List<String> _connectionSizes(String name) {
    final set = _sizeSet(name);
    // atomic = numeric parts + inch tokens (drop the compound strings like 75/50)
    final atomic = set.where((s) => !s.contains('/')).toList();
    // preserve a stable, human order: larger DN first
    atomic.sort((a, b) {
      final na = int.tryParse(a), nb = int.tryParse(b);
      if (na != null && nb != null) return nb.compareTo(na);
      return a.compareTo(b);
    });
    return atomic;
  }

  /// Readable size tokens for the section subtitle.
  List<String> _sizeTokens(String name) => _connectionSizes(name);

  /// Material of a product, inferred from name/category (צעד 62).
  static String _material(LipskeyCatalogProduct p) {
    final n = p.nameHe + p.categoryHe;
    if (n.contains('נחושת')) return 'copper';
    if (n.contains('HDPE')) return 'hdpe';
    if (n.contains('PP') || n.contains('רב שכבתי')) return 'pp';
    if (n.contains('NTM') || n.contains('PEX')) return 'pex';
    return 'pvc'; // default drainage
  }

  /// For one connection size — every other-category part that fits it,
  /// מדורג: אותו חומר תחילה (צעדים 62–63).
  List<LipskeyCatalogProduct> _partsForSize(
      LipskeyCatalogProduct p, String size) {
    final mat = _material(p);
    final gender = p.connectionGender; // 'male' wants 'female' and vice-versa
    final method = p.connectionMethod;
    final seen = <String>{p.sku};
    final all = <LipskeyCatalogProduct>[];
    for (final q in kLipskeyCatalog) {
      if (q.categoryHe == p.categoryHe) continue; // cross-category only
      if (!seen.add(q.sku)) continue;
      if (!_sizeSet(q.nameHe).contains(size)) continue;
      // צעד 60: a gendered end never mates with the same gender — drop it.
      if (gender != null &&
          q.connectionGender != null &&
          q.connectionGender == gender) {
        continue;
      }
      all.add(q);
    }
    // ranking (צעדים 61–63): same connection-method first, then same material,
    // then opposite gender (the true mate), then category name for stability.
    int methodRank(LipskeyCatalogProduct x) =>
        method == null || x.connectionMethod == null
            ? 1
            : (x.connectionMethod == method ? 0 : 2);
    int genderRank(LipskeyCatalogProduct x) => gender != null &&
            x.connectionGender != null &&
            x.connectionGender != gender
        ? 0
        : 1;
    all.sort((a, b) {
      final cmp = methodRank(a).compareTo(methodRank(b));
      if (cmp != 0) return cmp;
      final am = _material(a) == mat ? 0 : 1;
      final bm = _material(b) == mat ? 0 : 1;
      if (am != bm) return am - bm;
      final g = genderRank(a).compareTo(genderRank(b));
      if (g != 0) return g;
      return a.categoryHe.compareTo(b.categoryHe);
    });
    return all.take(12).toList();
  }

  /// Per-side connection groups: [(sizeLabel, fitting parts), ...].
  List<({String size, List<LipskeyCatalogProduct> parts})> _connectionGroups(
      LipskeyCatalogProduct p) {
    // צעד 68: a manual size override wins over name extraction.
    final sizes = kLipskeyConnectionSizeOverride[p.sku] ?? _connectionSizes(p.nameHe);
    final groups = <({String size, List<LipskeyCatalogProduct> parts})>[];
    for (final s in sizes) {
      final parts = _partsForSize(p, s);
      if (parts.isNotEmpty) groups.add((size: s, parts: parts));
    }
    // צעד 68: prepend confirmed manual pairings the size match missed.
    final overrideSkus = kLipskeyCompatPairOverride[p.sku] ?? const [];
    if (overrideSkus.isNotEmpty) {
      final extra = kLipskeyCatalog
          .where((q) => overrideSkus.contains(q.sku))
          .toList();
      if (extra.isNotEmpty) {
        if (groups.isEmpty) {
          groups.add((size: 'תואם', parts: extra));
        } else {
          final first = groups.first;
          final merged = [
            ...extra,
            ...first.parts.where((q) => !overrideSkus.contains(q.sku)),
          ];
          groups[0] = (size: first.size, parts: merged);
        }
      }
    }
    return groups;
  }

  /// Installation kit (צעד 64): the single best-ranked mate for each
  /// connection side — the minimal parts list to complete every joint of this
  /// product. De-duped by SKU so a part shared across sides appears once.
  List<LipskeyCatalogProduct> _installKit(LipskeyCatalogProduct p) {
    final kit = <LipskeyCatalogProduct>[];
    final seen = <String>{};
    for (final g in _connectionGroups(p)) {
      if (g.parts.isEmpty) continue;
      final top = g.parts.first; // rank #1 (same method/material, opp. gender)
      if (seen.add(top.sku)) kit.add(top);
    }
    return kit;
  }

  void _addKitToCart(List<LipskeyCatalogProduct> kit) {
    final notifier = ref.read(smartCartProvider.notifier);
    for (final part in kit) {
      notifier.add(SmartCartLine(
        productKey: 'lip:${part.sku}',
        productName: part.nameHe,
        productEmoji: part.typeEmoji,
        brandName: part.brand,
        brandPrice: 0,
        productQty: 1,
        accessories: const [],
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('נוספו ${kit.length} חלקי ערכת-התקנה לסל ✓'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  /// Inch sizes show as e.g. 1.25" ; plain DN numbers as DN50.
  String _sizeLabel(String s) =>
      RegExp(r'^\d+$').hasMatch(s) ? 'DN$s' : '$s"';

  void _addToCart() {
    final p = _current;
    final accs = <SmartCartAcc>[];
    for (var i = 0; i < _accs.length; i++) {
      if (_accSelected[i] == true) {
        accs.add(SmartCartAcc(
          name: _accs[i].name,
          emoji: _accs[i].emoji,
          price: _accs[i].price ?? 0,
          qty: 1,
        ));
      }
    }
    ref.read(smartCartProvider.notifier).add(SmartCartLine(
          productKey: 'lip:${p.sku}',
          productName: p.nameHe,
          productEmoji: p.typeEmoji,
          brandName: p.brand,
          brandPrice: 0,
          productQty: _qty * _unitMult,
          accessories: accs,
        ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('נוסף לסל ✓'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context);
  }

  // צעד 78: per-product (SKU) link with category fallback.
  List<LipskeyCatAcc> get _accs =>
      lipskeyAccFor(_current.sku, _current.categoryHe);
  List<LipskeyCatStage> get _stages =>
      lipskeyStagesFor(_current.sku, _current.categoryHe);
  LipskeyCatalogProduct get _current =>
      _chipOverride ?? widget.categoryProducts[_selectedIdx];

  @override
  void initState() {
    super.initState();
    _selectedIdx =
        widget.categoryProducts.indexOf(widget.product).clamp(0, widget.categoryProducts.length - 1);
    _accSelected = {
      for (var i = 0; i < (_accs.length); i++) i: false,
    };
  }

  void _selectVariant(int i) {
    setState(() {
      _selectedIdx = i;
      _chipOverride = null;
      _openPickerKey = null;
      _accSelected = {for (var j = 0; j < _accs.length; j++) j: false};
      _activeStage = null;
    });
  }

  void _switchByChip(LipskeyCatalogProduct q) {
    setState(() {
      _chipOverride = q;
      _openPickerKey = null;
      _accSelected = {for (var j = 0; j < _accs.length; j++) j: false};
      _activeStage = null;
    });
  }

  int get _accTotal {
    var t = 0;
    for (var i = 0; i < _accs.length; i++) {
      if (_accSelected[i] == true) t += _accs[i].price ?? 0;
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final p = _current;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Close (X) — clear & prominent, top-left
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 2),
                  child: Material(
                    color: const Color(0xFFF5F5F5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(Icons.close, color: Color(0xFF1A1A1A), size: 22),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  children: [
                    // ── Hero image (tap = flip to spec) ─────────────────
                    _HeroImage(product: p, screenH: screenH),

                    const SizedBox(height: 16),

                    // ── Product header ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(p.categoryEmoji,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(p.categoryHe,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black38, fontSize: 12)),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: p.sku));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('מק"ט הועתק'),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text('#${p.sku}',
                                    style: const TextStyle(
                                        color: Color(0xFFFFB300),
                                        fontFamily: 'monospace',
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(p.nameHe,
                              style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3)),
                          if (p.nameEn.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(p.nameEn,
                                style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic)),
                          ],
                          const SizedBox(height: 8),
                          _InteractiveChips(
                            product: p,
                            openPickerKey: _openPickerKey,
                            onChipTap: (key) => setState(() {
                              _openPickerKey =
                                  _openPickerKey == key ? null : key;
                            }),
                            onVariantSelect: _switchByChip,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const _Divider(),
                    const SizedBox(height: 16),

                    // ── Variant selector ────────────────────────────────
                    if (widget.categoryProducts.length > 1) ...[
                      _SectionTitle(
                        emoji: '🔀',
                        title: 'בחר גרסה',
                        subtitle: '${widget.categoryProducts.length} אפשרויות',
                      ),
                      const SizedBox(height: 10),
                      _VariantSelector(
                        products: widget.categoryProducts,
                        selectedIdx: _selectedIdx,
                        onSelect: _selectVariant,
                      ),
                      const SizedBox(height: 16),
                      const _Divider(),
                      const SizedBox(height: 16),
                    ],

                    // ── Accessories ─────────────────────────────────────
                    if (_accs.isNotEmpty) ...[
                      _SectionTitle(
                        emoji: '🧰',
                        title: 'אביזרים נדרשים',
                        subtitle:
                            '${_accs.where((a) => a.must).length} חובה · ${_accs.where((a) => !a.must).length} אופציונלי',
                      ),
                      const SizedBox(height: 10),
                      ..._accs.asMap().entries.map((e) => _AccRow(
                            acc: e.value,
                            selected: _accSelected[e.key] ?? false,
                            onToggle: (v) =>
                                setState(() => _accSelected[e.key] = v),
                          )),
                      const SizedBox(height: 16),
                      const _Divider(),
                      const SizedBox(height: 16),
                    ],

                    // ── Installation stages ─────────────────────────────
                    if (_stages.isNotEmpty) ...[
                      _SectionTitle(
                        emoji: '📋',
                        title: 'שלבי התקנה',
                        subtitle: '${_stages.length} שלבים',
                      ),
                      const SizedBox(height: 10),
                      ..._stages.asMap().entries.map((e) => _StageRow(
                            stage: e.value,
                            index: e.key,
                            isActive: _activeStage == e.key,
                            onTap: () => setState(() =>
                                _activeStage =
                                    _activeStage == e.key ? null : e.key),
                          )),
                      const SizedBox(height: 16),
                      const _Divider(),
                      const SizedBox(height: 16),
                    ],

                    // ── Spec data ───────────────────────────────────────
                    if (p.color != null ||
                        p.qtyPack != null ||
                        p.qtyPallet != null ||
                        p.dims != null) ...[
                      _SectionTitle(emoji: '📐', title: 'מפרט'),
                      const SizedBox(height: 10),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            if (p.color != null)
                              _SpecRow('🎨', 'צבע', p.color!),
                            if (p.qtyPack != null)
                              _SpecRow('📦', 'כמות באריזה',
                                  '${p.qtyPack}'),
                            if (p.qtyPallet != null)
                              _SpecRow('🏗️', 'כמות במשטח',
                                  '${p.qtyPallet}'),
                            if (p.dims != null)
                              for (final e in p.dims!.entries)
                                if (e.value != null)
                                  _SpecRow('📐', e.key, '${e.value}'),
                            _SpecRow('📄', 'עמוד בקטלוג',
                                'עמוד ${p.page}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _Divider(),
                      const SizedBox(height: 16),
                    ],

                    // ── Qty + unit toggle + add to cart ─────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _QtyStepper(
                                qty: _qty,
                                onChanged: (v) =>
                                    setState(() => _qty = max(1, v)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _UnitToggle(
                                  unit: _unit,
                                  hasPack: p.qtyPack != null,
                                  hasPallet: p.qtyPallet != null,
                                  onChanged: (u) => setState(() => _unit = u),
                                ),
                              ),
                            ],
                          ),
                          if (_unit != _Unit.single)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'סה"כ ${_qty * _unitMult} יחידות',
                                style: const TextStyle(
                                    color: Color(0xFF9AA3B2), fontSize: 12),
                              ),
                            ),
                          if (_accTotal > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('אביזרים נבחרים:',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 13)),
                                  Text('+ ₪$_accTotal',
                                      style: const TextStyle(
                                          color: Color(0xFF3DD9B0),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7A18),
                                foregroundColor: const Color(0xFF1A1200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _addToCart,
                              icon: const Icon(Icons.shopping_cart, size: 19),
                              label: const Text('הוסף לסל',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── 🔧 חיבורים תואמים — לפי צד/מידה ──────────────────
                    ...(() {
                      final groups = _connectionGroups(p);
                      if (groups.isEmpty) return <Widget>[];
                      final multi = groups.length > 1;
                      final w = <Widget>[
                        const SizedBox(height: 16),
                        const _Divider(),
                        const SizedBox(height: 16),
                        _SectionTitle(
                          emoji: '🔧',
                          title: 'חיבורים תואמים',
                          subtitle: multi
                              ? '${groups.length} צדדים — מה מתחבר לכל מידה'
                              : 'מה מתחבר ל-${_sizeLabel(groups.first.size)}',
                        ),
                        const SizedBox(height: 6),
                      ];
                      // ── ערכת-התקנה: המתאם המומלץ לכל צד, בלחיצה אחת ──────
                      final kit = _installKit(p);
                      if (kit.length >= 2) {
                        w.add(Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x143DD9B0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x553DD9B0)),
                            ),
                            child: Row(
                              children: [
                                const Text('🧩', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('ערכת התקנה מומלצת',
                                          style: TextStyle(
                                              color: Color(0xFF1A1A1A),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700)),
                                      Text(
                                          '${kit.length} חלקים — מתאם לכל צד חיבור',
                                          style: const TextStyle(
                                              color: Color(0xFF9AA3B2),
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF3DD9B0),
                                    foregroundColor: const Color(0xFF06251C),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                  ),
                                  onPressed: () => _addKitToCart(kit),
                                  child: const Text('+ ערכה',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ));
                      }
                      for (var gi = 0; gi < groups.length; gi++) {
                        final g = groups[gi];
                        w.add(Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 8, 20, 6),
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0x22FF7A18),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: const Color(0x55FF7A18)),
                                  ),
                                  child: Text(
                                    multi
                                        ? '📐 צד ${gi + 1}: ${_sizeLabel(g.size)}'
                                        : '📐 ${_sizeLabel(g.size)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFFFF9D4D),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text('${g.parts.length} חלקים',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFF9AA3B2),
                                        fontSize: 11)),
                              ),
                            ],
                          ),
                        ));
                        w.add(SizedBox(
                          height: 132,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: g.parts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) => _RelatedCard(
                              product: g.parts[i],
                              onTap: () => showLipskeyProductSheet(
                                context,
                                g.parts[i],
                                kLipskeyCatalog
                                    .where((x) =>
                                        x.categoryHe == g.parts[i].categoryHe)
                                    .toList(),
                              ),
                            ),
                          ),
                        ));
                      }
                      return w;
                    })(),

                    // ── Related / similar products (same category) ──────
                    ...(() {
                      final related = widget.categoryProducts
                          .where((x) => x.sku != p.sku)
                          .take(8)
                          .toList();
                      if (related.isEmpty) return <Widget>[];
                      return <Widget>[
                        const SizedBox(height: 16),
                        const _Divider(),
                        const SizedBox(height: 16),
                        _SectionTitle(emoji: '🔗', title: 'מוצרים נלווים / דומים'),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 132,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: related.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) => _RelatedCard(
                              product: related[i],
                              onTap: () {
                                final idx = widget.categoryProducts
                                    .indexOf(related[i]);
                                if (idx >= 0) _selectVariant(idx);
                              },
                            ),
                          ),
                        ),
                      ];
                    })(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── qty stepper ─────────────────────────────────────────────────────────────
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget b(String s, VoidCallback t) => InkWell(
          onTap: t,
          child: SizedBox(
              width: 38,
              height: 44,
              child: Center(
                  child: Text(s,
                      style: const TextStyle(
                          color: Color(0xFF1A1A1A), fontSize: 20)))),
        );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFFF7A18)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          b('−', () => onChanged(qty - 1)),
          SizedBox(
              width: 34,
              child: Center(
                  child: Text('$qty',
                      style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 17,
                          fontWeight: FontWeight.w800)))),
          b('+', () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

// ── unit toggle: בודד / ארגז / משטח ──────────────────────────────────────────
class _UnitToggle extends StatelessWidget {
  const _UnitToggle({
    required this.unit,
    required this.hasPack,
    required this.hasPallet,
    required this.onChanged,
  });
  final _Unit unit;
  final bool hasPack;
  final bool hasPallet;
  final ValueChanged<_Unit> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget opt(String label, _Unit u, bool enabled) {
      final sel = unit == u;
      return Expanded(
        child: InkWell(
          onTap: enabled ? () => onChanged(u) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            color: sel ? const Color(0xFFFF7A18) : Colors.transparent,
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: sel
                        ? const Color(0xFF1A1200)
                        : (enabled
                            ? const Color(0xFF9AA3B2)
                            : const Color(0xFF44495A)),
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w500)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          opt('בודד', _Unit.single, true),
          opt('ארגז', _Unit.pack, hasPack),
          opt('משטח', _Unit.pallet, hasPallet),
        ],
      ),
    );
  }
}

// ── related product mini-card ────────────────────────────────────────────────
class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.product, required this.onTap});
  final LipskeyCatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: product.imageAsset != null
                  ? Image.asset(product.imageAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                          child: Text(product.typeEmoji,
                              style: const TextStyle(fontSize: 28))))
                  : Center(
                      child: Text(product.typeEmoji,
                          style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(product.nameHe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF1A1A1A), fontSize: 11, height: 1.25)),
            ),
            const SizedBox(height: 3),
            Text('#${product.sku}',
                style: const TextStyle(
                    color: Color(0xFF9AA3B2),
                    fontSize: 9,
                    fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

// ── Hero flip card ────────────────────────────────────────────────────────────
class _HeroImage extends StatefulWidget {
  const _HeroImage({
    required this.product,
    required this.screenH,
  });

  final LipskeyCatalogProduct product;
  final double screenH;

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showSpec = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showSpec) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _showSpec = !_showSpec);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return SizedBox(
      height: widget.screenH * 0.30,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final angle = _anim.value * pi;
          final showingSpec = angle > pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showingSpec
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _SpecSide(
                      product: p,
                      onFlip: _flip,
                      onZoom: () => _openFullscreenAsset(
                          context, p.specImageAsset, p.typeEmoji),
                    ),
                  )
                : _ProductSide(
                    product: p,
                    onFlip: _flip,
                    onZoom: () => _openFullscreenAsset(
                        context,
                        p.imageAsset ?? p.specImageAsset,
                        p.typeEmoji),
                  ),
          );
        },
      ),
    );
  }
}

class _ProductSide extends StatelessWidget {
  const _ProductSide({
    required this.product,
    required this.onFlip,
    required this.onZoom,
  });
  final LipskeyCatalogProduct product;
  final VoidCallback onFlip;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onZoom, // tap image → fullscreen zoom
      child: Container(
        color: const Color(0xFFF5F6FA),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [
                    const Color(0xFF3D5A80).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Image.asset(
              product.imageAsset ?? product.specImageAsset,
              fit: product.imageAsset != null ? BoxFit.contain : BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(product.typeEmoji,
                    style: const TextStyle(fontSize: 72)),
              ),
            ),
            // zoom hint (top-right)
            const Positioned(
              top: 10,
              right: 10,
              child: _ZoomHint(),
            ),
            // "פרטים / מפרט" button — flips to the spec page
            Positioned(
              bottom: 10,
              left: 10,
              child: GestureDetector(
                onTap: onFlip,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.description_outlined,
                          color: Color(0xFF1A1200), size: 14),
                      SizedBox(width: 5),
                      Text('פרטים / מפרט',
                          style: TextStyle(
                              color: Color(0xFF1A1200),
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomHint extends StatelessWidget {
  const _ZoomHint();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.zoom_in, color: Colors.black54, size: 14),
            SizedBox(width: 4),
            Text('הגדלה',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _SpecSide extends StatelessWidget {
  const _SpecSide({
    required this.product,
    required this.onFlip,
    required this.onZoom,
  });
  final LipskeyCatalogProduct product;
  final VoidCallback onFlip;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onZoom, // tap spec → fullscreen zoom
      child: Container(
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              product.specImageAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Text(product.typeEmoji,
                    style: const TextStyle(fontSize: 72)),
              ),
            ),
            // zoom hint
            const Positioned(top: 10, right: 10, child: _ZoomHint()),
            // back-to-product button
            Positioned(
              bottom: 10,
              left: 10,
              child: GestureDetector(
                onTap: onFlip,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined,
                          color: Color(0xFF1A1200), size: 14),
                      SizedBox(width: 5),
                      Text('חזרה למוצר',
                          style: TextStyle(
                              color: Color(0xFF1A1200),
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Variant selector ──────────────────────────────────────────────────────────
class _VariantSelector extends StatelessWidget {
  const _VariantSelector({
    required this.products,
    required this.selectedIdx,
    required this.onSelect,
  });

  final List<LipskeyCatalogProduct> products;
  final int selectedIdx;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final p = products[i];
          final selected = i == selectedIdx;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF3D5A80).withOpacity(0.3)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF3D5A80).withOpacity(0.3),
                  width: selected ? 1.5 : 0.8,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.asset(
                        p.imageAsset ?? p.specImageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                            p.typeEmoji,
                            style: const TextStyle(fontSize: 24),
                            textAlign: TextAlign.center)),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('#${p.sku}',
                        style: TextStyle(
                            color: selected
                                ? const Color(0xFF64FFDA)
                                : const Color(0xFF888888),
                            fontSize: 9,
                            fontFamily: 'monospace'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Accessory row ─────────────────────────────────────────────────────────────
class _AccRow extends StatelessWidget {
  const _AccRow({
    required this.acc,
    required this.selected,
    required this.onToggle,
  });

  final LipskeyCatAcc acc;
  final bool selected;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: GestureDetector(
        onTap: () => onToggle(!selected),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF3D5A80).withOpacity(0.2)
                : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF64FFDA).withOpacity(0.5)
                  : const Color(0xFFEEEEEE),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Text(acc.emoji,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(acc.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        if (acc.must)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFFF6B35),
                                  width: 0.6),
                            ),
                            child: const Text('חובה',
                                style: TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(acc.why,
                        style: const TextStyle(
                            color: Color(0xFF888888), fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (acc.price != null)
                    Text('₪${acc.price}',
                        style: const TextStyle(
                            color: Color(0xFF64FFDA),
                            fontSize: 13,
                            fontWeight: FontWeight.w700))
                  else
                    const Text('—',
                        style: TextStyle(
                            color: Color(0xFF888888), fontSize: 13)),
                  const SizedBox(height: 4),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: selected
                        ? const Color(0xFF64FFDA)
                        : Colors.black12,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stage row ─────────────────────────────────────────────────────────────────
class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  final LipskeyCatStage stage;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? (stage.isFinal
                    ? const Color(0xFF22C55E).withOpacity(0.12)
                    : const Color(0xFF3D5A80).withOpacity(0.2))
                : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? (stage.isFinal
                      ? const Color(0xFF22C55E).withOpacity(0.6)
                      : const Color(0xFF64FFDA).withOpacity(0.5))
                  : const Color(0xFFEEEEEE),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: stage.isFinal
                      ? const Color(0xFF22C55E).withOpacity(0.2)
                      : const Color(0xFF3D5A80).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: TextStyle(
                        color: stage.isFinal
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF64FFDA),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Text(stage.emoji,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stage.label,
                        style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    if (isActive && stage.desc.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(stage.desc,
                          style: const TextStyle(
                              color: Colors.black38, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              Icon(
                isActive
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: const Color(0xFF888888),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(
      {required this.emoji, required this.title, this.subtitle});
  final String emoji;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(emoji,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 11)),
              ),
            ],
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, color: Color(0xFFEEEEEE), indent: 20, endIndent: 20);
}

Widget _SpecRow(String emoji, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.black38, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF1A1A1A), fontSize: 13)),
        ],
      ),
    );

/// Interactive attribute chips (צעד 71+).
/// All four chip kinds use frame-based sibling detection:
/// orange border = has same-frame siblings with a different attribute value.
class _InteractiveChips extends StatelessWidget {
  const _InteractiveChips({
    required this.product,
    required this.openPickerKey,
    required this.onChipTap,
    required this.onVariantSelect,
  });

  final LipskeyCatalogProduct product;
  final String? openPickerKey; // 'type' | 'subtype' | 'model' | 'color'
  final void Function(String key) onChipTap;
  final void Function(LipskeyCatalogProduct) onVariantSelect;

  static const _colorModifiers = {'מוברש', 'מט'};

  // ── צבע: frame-based (אותו סוג, צבע שונה) ───────────────────────────────
  static String _colorFrame(LipskeyCatalogProduct p) => p.nameHe
      .split(RegExp(r'\s+'))
      .where((w) => kindOf(w) != AttrKind.color && !_colorModifiers.contains(w))
      .join(' ');

  static List<LipskeyCatalogProduct> _variantsColor(LipskeyCatalogProduct p) {
    final frame = _colorFrame(p);
    final seen = <String>{};
    final all = <LipskeyCatalogProduct>[];
    for (final q in kLipskeyCatalog) {
      if (q.categoryHe != p.categoryHe) continue;
      final v = q.colorVariant;
      if (v == null || v.isEmpty) continue;
      if (_colorFrame(q) != frame) continue;
      if (seen.add(v)) all.add(q);
    }
    all.sort((a, b) {
      if (a.sku == p.sku) return -1;
      if (b.sku == p.sku) return 1;
      return (a.colorVariant ?? '').compareTo(b.colorVariant ?? '');
    });
    return all;
  }

  // ── תת-סוג: frame-based (אותו סוג, תת-סוג שונה) ─────────────────────────
  static List<LipskeyCatalogProduct> _variantsSubtype(
      LipskeyCatalogProduct p) {
    const kind = AttrKind.subtype;
    final frame = p.nameHe
        .split(RegExp(r'\s+'))
        .where((w) => kindOf(w) != kind)
        .join(' ');
    final seen = <String>{};
    final all = <LipskeyCatalogProduct>[];
    for (final q in kLipskeyCatalog) {
      if (q.categoryHe != p.categoryHe) continue;
      final v = variantValue(q, kind);
      if (v.isEmpty) continue;
      if (q.nameHe
              .split(RegExp(r'\s+'))
              .where((w) => kindOf(w) != kind)
              .join(' ') !=
          frame) continue;
      if (seen.add(v)) all.add(q);
    }
    all.sort((a, b) {
      if (a.sku == p.sku) return -1;
      if (b.sku == p.sku) return 1;
      return variantValue(a, kind).compareTo(variantValue(b, kind));
    });
    return all;
  }

  // ── סוג מורכב: multi-word types first, then type+qualifier ──────────────
  static String _resolveCompoundType(LipskeyCatalogProduct p) {
    final name = p.nameHe;
    final words = name.split(RegExp(r'\s+'));

    // Multi-word types matched as substring (longest first).
    final multiWord = kLipskeyTypes.where((t) => t.contains(' ')).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final t in multiWord) {
      if (name.contains(t)) return t;
    }

    // Single-word type + optional trailing qualifier.
    for (final typeWord in kLipskeyTypes) {
      if (typeWord.contains(' ')) continue;
      final idx = words.indexOf(typeWord);
      if (idx < 0) continue;
      if (idx + 1 >= words.length) return typeWord;
      final next = words[idx + 1];
      if (kindOf(next) != null) return typeWord;
      if (_colorModifiers.contains(next)) return typeWord;
      if (next.length > 2 &&
          (next.startsWith('ל') || next.startsWith('ב'))) return typeWord;
      return '$typeWord $next';
    }
    return '';
  }

  // ── סוג: category-wide (כל הסוגים בקטגוריה, כמו findTypeSiblings) ────────
  static List<LipskeyCatalogProduct> _variantsType(LipskeyCatalogProduct p) {
    final compound = _resolveCompoundType(p);
    if (compound.isEmpty) return [];
    final byCompound = <String, LipskeyCatalogProduct>{compound: p};
    for (final q in kLipskeyCatalog) {
      if (q.categoryHe != p.categoryHe) continue;
      final qc = _resolveCompoundType(q);
      if (qc.isEmpty || byCompound.containsKey(qc)) continue;
      byCompound[qc] = q;
    }
    if (byCompound.length <= 1) return [];
    return byCompound.values.toList()
      ..sort((a, b) {
        if (a.sku == p.sku) return -1;
        if (b.sku == p.sku) return 1;
        return _resolveCompoundType(a).compareTo(_resolveCompoundType(b));
      });
  }

  // ── דגם: category-wide (כל הדגמים בקטגוריה, כמו findAttrSiblings(model)) ─
  static List<LipskeyCatalogProduct> _variantsModel(LipskeyCatalogProduct p) {
    final seen = <String>{};
    final all = <LipskeyCatalogProduct>[];
    for (final q in kLipskeyCatalog) {
      if (q.categoryHe != p.categoryHe) continue;
      final m = q.brandModel;
      if (m == null || m.isEmpty) continue;
      if (seen.add(m)) all.add(q);
    }
    if (all.length <= 1) return [];
    return all
      ..sort((a, b) {
        if (a.sku == p.sku) return -1;
        if (b.sku == p.sku) return 1;
        return (a.brandModel ?? '').compareTo(b.brandModel ?? '');
      });
  }

  // ── Unified sibling check & picker options ───────────────────────────────
  static bool _hasSiblings(LipskeyCatalogProduct p, String key) {
    switch (key) {
      case 'type':
        return _variantsType(p).isNotEmpty;
      case 'model':
        return _variantsModel(p).isNotEmpty;
      case 'color':
        final myVal = p.colorVariant;
        if (myVal == null || myVal.isEmpty) return false;
        final frame = _colorFrame(p);
        return kLipskeyCatalog.any((q) {
          final qv = q.colorVariant;
          return q.categoryHe == p.categoryHe &&
              q.sku != p.sku &&
              qv != null &&
              qv.isNotEmpty &&
              qv != myVal &&
              _colorFrame(q) == frame;
        });
      case 'subtype':
        return _variantsSubtype(p).length > 1;
      default:
        return false;
    }
  }

  // Returns (display label, target product) for each picker option.
  static List<(String, LipskeyCatalogProduct)> _pickerOptions(
      LipskeyCatalogProduct p, String key) {
    switch (key) {
      case 'type':
        return _variantsType(p).map((q) {
          final ct = _resolveCompoundType(q);
          final label = ct.contains(' ') ? ct.split(' ').last : ct;
          return (label, q);
        }).toList();
      case 'model':
        return _variantsModel(p)
            .map((q) => (q.brandModel ?? '', q))
            .toList();
      case 'color':
        return _variantsColor(p)
            .map((q) => (q.colorVariant ?? '', q))
            .toList();
      case 'subtype':
        return _variantsSubtype(p)
            .map((q) => (variantValue(q, AttrKind.subtype), q))
            .toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = product.parsedName;
    final compound = _resolveCompoundType(product);

    final entries = <({String label, String value, Color color, String key})>[
      if (parsed.type != null)
        (
          label: 'סוג',
          value: compound.isNotEmpty ? compound : parsed.type!,
          color: const Color(0xFFFF9D4D),
          key: 'type',
        ),
      if (parsed.subtype != null)
        (
          label: 'תת-סוג',
          value: parsed.subtype!,
          color: const Color(0xFF7FD0FF),
          key: 'subtype',
        ),
      if (parsed.brand != null)
        (
          label: 'דגם',
          value: parsed.brand!,
          color: const Color(0xFFFF9D4D),
          key: 'model',
        ),
      if (parsed.variant != null)
        (
          label: 'גוון',
          value: parsed.variant!,
          color: const Color(0xFFC9A7FF),
          key: 'color',
        ),
    ];
    if (entries.isEmpty) return const SizedBox.shrink();

    final activeOptions = openPickerKey != null
        ? _pickerOptions(product, openPickerKey!)
        : <(String, LipskeyCatalogProduct)>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final c in entries) _buildChip(c)],
        ),
        if (openPickerKey != null && activeOptions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ChipPickerRow(
            options: activeOptions,
            currentSku: product.sku,
            onSelect: onVariantSelect,
          ),
        ],
      ],
    );
  }

  Widget _buildChip(({String label, String value, Color color, String key}) c) {
    final tappable = _hasSiblings(product, c.key);
    final isOpen = openPickerKey == c.key;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? c.color.withValues(alpha: 0.22)
            : c.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: tappable
              ? const Color(0xFFFF9D4D)
              : c.color.withValues(alpha: 0.35),
          width: tappable ? 1.5 : 1.0,
        ),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: '${c.label} ',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 10),
          ),
          TextSpan(
            text: c.value,
            style: TextStyle(
              color: c.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (tappable)
            TextSpan(
              text: isOpen ? ' ×' : ' ›',
              style: const TextStyle(color: Color(0xFFFF9D4D), fontSize: 10),
            ),
        ]),
      ),
    );
    if (!tappable) return chip;
    return GestureDetector(onTap: () => onChipTap(c.key), child: chip);
  }
}

class _ChipPickerRow extends StatelessWidget {
  const _ChipPickerRow({
    required this.options,
    required this.currentSku,
    required this.onSelect,
  });

  final List<(String, LipskeyCatalogProduct)> options;
  final String currentSku;
  final void Function(LipskeyCatalogProduct) onSelect;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFFF9D4D).withValues(alpha: 0.4)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final opt in options)
            _PickerOption(
              value: opt.$1,
              isSelected: opt.$2.sku == currentSku,
              onTap: () => onSelect(opt.$2),
            ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF9D4D).withValues(alpha: 0.2)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF9D4D) : const Color(0xFF444444),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFFFF9D4D) : const Color(0xFFCCCCCC),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
