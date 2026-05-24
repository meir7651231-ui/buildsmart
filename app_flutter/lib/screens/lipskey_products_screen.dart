import 'dart:math';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${products.length} מוצרים',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 0),
          itemBuilder: (context, i) => _ProductRow(
            product: products[i],
            onTap: () => showLipskeyProductSheet(
              context,
              products[i],
              products,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onTap});

  final LipskeyCatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF13132A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3D5A80).withOpacity(0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── תמונת מוצר ──────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
              child: Container(
                width: 90,
                height: 110,
                color: const Color(0xFF0D0D1A),
                child: _LeadingImage(product: product),
              ),
            ),
            const SizedBox(width: 12),

            // ── פרטים ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // שם + כפתור פרטים באותה שורה
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.nameHe,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D5A80).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF3D5A80), width: 0.7),
                            ),
                            child: const Text(
                              'פרטים',
                              style: TextStyle(
                                color: Color(0xFF64FFDA),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ספק + מק"ט
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D5A80).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: const Color(0xFF3D5A80), width: 0.5),
                          ),
                          child: const Text('🏭 ליפסקי ברקן',
                              style: TextStyle(
                                  color: Color(0xFF64FFDA), fontSize: 9)),
                        ),
                        const SizedBox(width: 6),
                        Text('#${product.sku}',
                            style: const TextStyle(
                                color: Color(0xFFFFB300),
                                fontFamily: 'monospace',
                                fontSize: 11)),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // שורת פרטים: צבע + כמות אריזה + כמות משטח
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (product.color != null)
                          _Chip(label: '🎨 ${product.color!}'),
                        if (product.qtyPack != null)
                          _Chip(label: '📦 ${product.qtyPack}'),
                        if (product.qtyPallet != null)
                          _Chip(label: '🏗️ ${product.qtyPallet}'),
                        if (product.dims != null)
                          for (final e in product.dims!.entries)
                            if (e.value != null) _Chip(label: '${e.key}: ${e.value}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      );
}

class _LeadingImage extends StatefulWidget {
  const _LeadingImage({required this.product});
  final LipskeyCatalogProduct product;

  @override
  State<_LeadingImage> createState() => _LeadingImageState();
}

class _LeadingImageState extends State<_LeadingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showSpec = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
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
    return GestureDetector(
      onTap: _flip,
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
                    child: _SpecThumb(product: p),
                  )
                : _ProductThumb(product: p),
          );
        },
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final asset = product.imageAsset;
    if (asset != null) {
      return SizedBox(
        width: 90,
        height: 110,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _SpecFallback(product: product),
        ),
      );
    }
    // No product photo — show the catalog spec page crop
    return _SpecFallback(product: product);
  }
}

class _SpecFallback extends StatelessWidget {
  const _SpecFallback({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 110,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            product.specImageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Text(product.categoryEmoji,
                  style: const TextStyle(fontSize: 36)),
            ),
          ),
          // Subtle overlay so the SKU badge reads on any background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                product.sku,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

class _SpecThumb extends StatelessWidget {
  const _SpecThumb({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 110,
      child: Image.asset(
        product.specImageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(product.categoryEmoji,
              style: const TextStyle(fontSize: 36)),
        ),
      ),
    );
  }
}
