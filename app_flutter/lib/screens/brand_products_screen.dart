import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_detail_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

class BrandProductsScreen extends StatelessWidget {
  const BrandProductsScreen({
    super.key,
    required this.brand,
    required this.node,
  });

  final Brand brand;
  final CatalogNode node;

  static Route<void> route({required Brand brand, required CatalogNode node}) =>
      MaterialPageRoute<void>(
        builder: (_) => BrandProductsScreen(brand: brand, node: node),
      );

  @override
  Widget build(BuildContext context) {
    // Lipskey & AQUATEC products both live in kLipskeyCatalog (the scraped
    // distributor PDF) — pull those matching the leaf's category.
    final lipskeyProducts =
        (brand.id == 'lipskey' || brand.id == 'aquatec') &&
                node.lipskeyCategory != null
            ? kLipskeyCatalog
                .where((p) => p.categoryHe == node.lipskeyCategory)
                .toList()
            : <LipskeyCatalogProduct>[];

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(brand.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${brand.name} · ${node.title}',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: lipskeyProducts.isNotEmpty
          ? _LipskeyList(products: lipskeyProducts)
          : _Placeholder(brand: brand, node: node),
    );
  }
}

// ── Lipskey real products list ────────────────────────────────────────────
class _LipskeyList extends StatelessWidget {
  const _LipskeyList({required this.products});
  final List<LipskeyCatalogProduct> products;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: products.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Color(0xFF2A2A2A), height: 1, indent: 16),
      itemBuilder: (_, i) {
        final p = products[i];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            LipskeyProductDetailScreen.route(p),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: p.imageAsset != null
                      ? Image.asset(
                          p.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Color(0xFF555555), size: 24),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image,
                              color: Color(0xFF555555), size: 24),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nameHe,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SKU ${p.sku}',
                              style: const TextStyle(
                                color: Color(0xFFFFB84D),
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          if (p.color != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              p.color!,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left,
                    color: Color(0xFF555555), size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Placeholder for brands without real data ──────────────────────────────
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.brand, required this.node});
  final Brand brand;
  final CatalogNode node;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(brand.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              brand.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'מוצרי "${node.title}" יוטמעו בקרוב',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BsTokens.brand.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'בינתיים — בדוק את ליפסקי ברקן',
                style: TextStyle(color: BsTokens.brand, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
