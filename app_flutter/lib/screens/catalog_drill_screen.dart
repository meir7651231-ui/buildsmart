import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/brand_products_screen.dart';
import 'package:buildsmart/screens/catalog_screen.dart' show openSmartProductSheet;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Recursive drill screen — renders a single level of the catalog tree.
/// If [node] has children → show child grid (drill deeper on tap).
/// If [node] is a leaf → show its brand grid (open BrandProductsScreen).
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
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: path.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(32),
                child: _Breadcrumb(path: path, current: node!.title),
              ),
      ),
      body: !isRoot && node!.isLeaf
          ? _BrandsView(node: node!)
          : _CategoryGrid(
              nodes: children,
              parentPath: isRoot ? const [] : [...path, node!],
            ),
    );
  }
}

// ── Breadcrumb at the top ─────────────────────────────────────────────────
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.path, required this.current});
  final List<CatalogNode> path;
  final String current;

  @override
  Widget build(BuildContext context) {
    final parts = [...path.map((n) => n.title), current];
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.chevron_left,
                      color: Color(0xFF666666), size: 14),
                ),
              Text(
                parts[i],
                style: TextStyle(
                  color: i == parts.length - 1
                      ? Colors.white
                      : const Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: i == parts.length - 1
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Category grid (internal nodes) ────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.nodes, required this.parentPath});
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
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: nodes.length,
      itemBuilder: (_, i) {
        final n = nodes[i];
        return _CategoryCard(
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
    // Leaf with a linked SmartProduct → open the unified brand-picker sheet.
    if (n.isLeaf && n.smartKey != null) {
      final product = smartProductByKey(n.smartKey!);
      if (product != null) {
        openSmartProductSheet(context, product);
        return;
      }
    }
    // Otherwise keep drilling (or show the raw brands view for a bare leaf).
    Navigator.push(
      context,
      CatalogDrillScreen.nodeRoute(node: n, path: parentPath),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.node, required this.onTap});
  final CatalogNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String subtitle;
    if (!node.isLeaf) {
      subtitle = '${node.children.length} תת־קטגוריות';
    } else if (node.smartKey != null) {
      final p = smartProductByKey(node.smartKey!);
      subtitle = p != null ? '${p.brands.length} מותגים לבחירה' : 'בחירת מותג';
    } else {
      subtitle = '${node.brandIds.length} מותגים';
    }
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: BsTokens.brand.withAlpha(40),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(node.emoji, style: const TextStyle(fontSize: 36)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    final realCount = brand.id == 'lipskey' && node.lipskeyCategory != null
        ? kLipskeyCatalog
            .where((p) => p.categoryHe == node.lipskeyCategory)
            .length
        : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFF1A1A1A),
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
                          color: Colors.white,
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
