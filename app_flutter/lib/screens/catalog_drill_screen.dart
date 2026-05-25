import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/brand_products_screen.dart';
import 'package:buildsmart/screens/catalog_screen.dart' show openSmartProductSheet;
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Recursive drill screen — renders a single level of the catalog tree.
/// If [node] has children → show child list (drill deeper on tap).
/// If [node] is a leaf → show its brand list (open BrandProductsScreen).
/// [rootNodes] = top-level entry (when [node] is null).
class CatalogDrillScreen extends StatelessWidget {
  const CatalogDrillScreen({super.key, this.node, this.path = const []});

  final CatalogNode? node;
  final List<CatalogNode> path; // breadcrumb stack

  static Route<void> rootRoute() => MaterialPageRoute<void>(
        builder: (_) => const CatalogDrillScreen(),
      );

  static Route<void> nodeRoute({
    required CatalogNode node,
    required List<CatalogNode> path,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) => CatalogDrillScreen(node: node, path: path),
      );

  @override
  Widget build(BuildContext context) {
    final isRoot = node == null;
    final title = isRoot ? 'קטלוג קטגוריות' : node!.title;
    final children = isRoot ? kCatalogTree : node!.children;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DrillBar(title: title),
            Expanded(
              child: !isRoot && node!.isLeaf
                  ? _BrandsView(node: node!)
                  : _CategoryList(
                      nodes: children,
                      parentPath: isRoot ? const [] : [...path, node!],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fixed top drill bar — search-pill look, but a navigation control ───────
// Back button (one level up) + the current category as a pressed orange chip
// with an X that cancels the whole drill (pops back to the catalog).
class _DrillBar extends StatelessWidget {
  const _DrillBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7EA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF555555), size: 20),
            tooltip: 'חזרה',
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                decoration: BoxDecoration(
                  color: BsTokens.brand,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
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

// ── Category list (internal nodes) — rows styled like the main catalog ─────
class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.nodes, required this.parentPath});
  final List<CatalogNode> nodes;
  final List<CatalogNode> parentPath;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const Center(
        child: Text(
          'אין קטגוריות',
          style: TextStyle(color: Color(0xFF888888), fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      itemCount: nodes.length,
      itemBuilder: (_, i) {
        final n = nodes[i];
        return _CategoryRow(
          node: n,
          onTap: () => _onNodeTap(context, n, parentPath),
        );
      },
    );
  }

  void _onNodeTap(
    BuildContext context,
    CatalogNode n,
    List<CatalogNode> parentPath,
  ) {
    if (n.isLeaf) {
      // Leaf with real catalog products → open the product list. Each product
      // opens the full card (image · ספק · מפרט · ברקוד · אביזרים · הוסף לסל).
      if (n.lipskeyCategory != null) {
        final products = kLipskeyCatalog
            .where((p) => p.categoryHe == n.lipskeyCategory)
            .toList();
        if (products.isNotEmpty) {
          Navigator.push(
            context,
            LipskeyProductsScreen.route(
              category: n.title,
              products: products,
            ),
          );
          return;
        }
      }
      // No real SKUs (e.g. grohe/hamat placeholder) → fall back to the
      // smart-product brand-picker sheet so the leaf still does something.
      if (n.smartKey != null) {
        final product = smartProductByKey(n.smartKey!);
        if (product != null) {
          openSmartProductSheet(context, product);
          return;
        }
      }
    }
    // Internal node → keep drilling.
    Navigator.push(
      context,
      CatalogDrillScreen.nodeRoute(node: n, path: parentPath),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.node, required this.onTap});
  final CatalogNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String subtitle;
    if (!node.isLeaf) {
      subtitle = '${node.children.length} תת־קטגוריות';
    } else if (node.lipskeyCategory != null) {
      final count = kLipskeyCatalog
          .where((p) => p.categoryHe == node.lipskeyCategory)
          .length;
      subtitle = '$count מוצרים';
    } else if (node.smartKey != null) {
      final p = smartProductByKey(node.smartKey!);
      subtitle = p != null ? '${p.brands.length} דגמים' : 'דגמים';
    } else {
      subtitle = '${node.brandIds.length} מותגים';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BsTokens.brand, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(node.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.title,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: BsTokens.brand.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: BsTokens.brand,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left,
                    color: Color(0xFFB0B0B8), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Brands view (leaf node) ────────────────────────────────────────────────
class _BrandsView extends StatelessWidget {
  const _BrandsView({required this.node});
  final CatalogNode node;

  @override
  Widget build(BuildContext context) {
    final brands = node.brandIds
        .map(brandById)
        .whereType<Brand>()
        .toList();
    if (brands.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'אין מותגים זמינים בקטגוריה זו עדיין.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
          child: Text(
            '${brands.length} מותגים זמינים',
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (final b in brands) _BrandCard(brand: b, node: node),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand, required this.node});
  final Brand brand;
  final CatalogNode node;

  @override
  Widget build(BuildContext context) {
    // For Lipskey + matching category — count real products from kLipskeyCatalog.
    final realCount =
        (brand.id == 'lipskey' || brand.id == 'aquatec') &&
                node.lipskeyCategory != null
            ? kLipskeyCatalog
                .where((p) => p.categoryHe == node.lipskeyCategory)
                .length
            : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            BrandProductsScreen.route(brand: brand, node: node),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(brand.color).withAlpha(120),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(brand.color).withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(brand.emoji,
                      style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        brand.tagline,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (realCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(brand.color).withAlpha(60),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$realCount מוצרים',
                            style: TextStyle(
                              color: Color(brand.color),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'בקרוב',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left,
                    color: Color(0xFF555555), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
