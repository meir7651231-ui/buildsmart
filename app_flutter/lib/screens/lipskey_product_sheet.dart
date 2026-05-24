import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/screens/lipskey_product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class LipskeyProductSheet extends StatefulWidget {
  const LipskeyProductSheet({
    super.key,
    required this.product,
    required this.categoryProducts,
  });

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> categoryProducts;

  @override
  State<LipskeyProductSheet> createState() => _LipskeyProductSheetState();
}

class _LipskeyProductSheetState extends State<LipskeyProductSheet> {
  late int _selectedIdx;
  int? _activeStage;
  late Map<int, bool> _accSelected;

  List<LipskeyCatAcc> get _accs =>
      kLipskeyAccByCategory[_current.categoryHe] ?? [];
  List<LipskeyCatStage> get _stages =>
      kLipskeyStagesByCategory[_current.categoryHe] ?? [];
  LipskeyCatalogProduct get _current =>
      widget.categoryProducts[_selectedIdx];

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
            color: Color(0xFF13132A),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  children: [
                    // ── Hero image ──────────────────────────────────────
                    _HeroImage(
                      product: p,
                      screenH: screenH,
                      onOpen360: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          LipskeyProductDetailScreen.route(p),
                        );
                      },
                    ),

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
                              Text(p.categoryHe,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
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
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3)),
                          if (p.nameEn.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(p.nameEn,
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic)),
                          ],
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

                    // ── Total & CTA ─────────────────────────────────────
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          if (_accTotal > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('אביזרים נבחרים:',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13)),
                                  Text('+ ₪$_accTotal',
                                      style: const TextStyle(
                                          color: Color(0xFF64FFDA),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  LipskeyProductDetailScreen.route(p),
                                );
                              },
                              icon: const Icon(Icons.view_in_ar,
                                  size: 18),
                              label: const Text('פתח מוצר 360°',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ── Hero image ────────────────────────────────────────────────────────────────
class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.product,
    required this.screenH,
    required this.onOpen360,
  });

  final LipskeyCatalogProduct product;
  final double screenH;
  final VoidCallback onOpen360;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen360,
      child: Container(
        height: screenH * 0.28,
        width: double.infinity,
        color: const Color(0xFF080815),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radial glow
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
            // Product image
            if (product.imageAsset != null)
              Image.asset(
                product.imageAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(product.categoryEmoji,
                    style: const TextStyle(fontSize: 72)),
              )
            else
              Text(product.categoryEmoji,
                  style: const TextStyle(fontSize: 72)),
            // 360° badge
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF64FFDA).withOpacity(0.6)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_in_ar,
                        color: Color(0xFF64FFDA), size: 14),
                    SizedBox(width: 4),
                    Text('360° סיבוב',
                        style: TextStyle(
                            color: Color(0xFF64FFDA),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
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
                    : const Color(0xFF0D0D1A),
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
                    child: p.imageAsset != null
                        ? Image.asset(p.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(
                                p.categoryEmoji,
                                style: const TextStyle(fontSize: 24),
                                textAlign: TextAlign.center))
                        : Text(p.categoryEmoji,
                            style: const TextStyle(fontSize: 24),
                            textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('#${p.sku}',
                        style: TextStyle(
                            color: selected
                                ? const Color(0xFF64FFDA)
                                : Colors.white38,
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
                : const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF64FFDA).withOpacity(0.5)
                  : Colors.white12,
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
                        Text(acc.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
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
                            color: Colors.white38, fontSize: 11)),
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
                            color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 4),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: selected
                        ? const Color(0xFF64FFDA)
                        : Colors.white24,
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
                : const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? (stage.isFinal
                      ? const Color(0xFF22C55E).withOpacity(0.6)
                      : const Color(0xFF64FFDA).withOpacity(0.5))
                  : Colors.white12,
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
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    if (isActive && stage.desc.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(stage.desc,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              Icon(
                isActive
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white38,
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
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Text(subtitle!,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
            ],
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, color: Colors.white10, indent: 20, endIndent: 20);
}

Widget _SpecRow(String emoji, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13)),
        ],
      ),
    );
