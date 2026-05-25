import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter/material.dart';

// ── Level 1: שני מקטעים — אינסטלציה / סניטציה ───────────────────────────────
class LipskeyBrandScreen extends StatelessWidget {
  const LipskeyBrandScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const LipskeyBrandScreen());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFF0D0D1A),
              foregroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('ליפסקי ברקן',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  Text('אינסטלציה · סניטציה',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _BrandHeader(
                totalProducts: kLipskeyCatalog.length,
                totalCats: kLipskeySections
                    .fold(0, (s, sec) => s + sec.entries.length),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final section = kLipskeySections[i];
                    final prodCount = kLipskeyCatalog
                        .where((p) => section.entries
                            .any((e) => e.name == p.categoryHe))
                        .length;
                    final catCount = section.entries.length;
                    return _SectionCard(
                      section: section,
                      prodCount: prodCount,
                      catCount: catCount,
                      onTap: () => Navigator.push(
                        context,
                        LipskeySectionScreen.route(section: section),
                      ),
                    );
                  },
                  childCount: kLipskeySections.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader(
      {required this.totalProducts, required this.totalCats});
  final int totalProducts;
  final int totalCats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0D1B2A), Color(0xFF13132A)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF3D5A80).withOpacity(0.4), width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Text('🏭', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ליפסקי ברקן',
                    style: TextStyle(
                        color: Color(0xFF64FFDA),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text('$totalProducts מוצרים · $totalCats קטגוריות',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card (level 1) ────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.prodCount,
    required this.catCount,
    required this.onTap,
  });

  final LipskeySection section;
  final int prodCount;
  final int catCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13132A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF3D5A80).withOpacity(0.4),
              width: 0.8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(section.emoji,
                style: const TextStyle(fontSize: 38)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF3D5A80).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$prodCount מוצרים',
                          style: const TextStyle(
                              color: Color(0xFF64FFDA), fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    Text('$catCount קטגוריות',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Level 2: קטגוריות בתוך מקטע ──────────────────────────────────────────────
class LipskeySectionScreen extends StatelessWidget {
  const LipskeySectionScreen({super.key, required this.section});

  final LipskeySection section;

  static Route<void> route({required LipskeySection section}) =>
      MaterialPageRoute(
        builder: (_) => LipskeySectionScreen(section: section),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFF0D0D1A),
              foregroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${section.emoji} ${section.name}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(
                      'ליפסקי ברקן · ${section.entries.length} קטגוריות',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final entry = section.entries[i];
                    final products = kLipskeyCatalog
                        .where((p) => p.categoryHe == entry.name)
                        .toList();
                    return _CategoryCard(
                      entry: entry,
                      products: products,
                      onTap: products.isEmpty
                          ? null
                          : () => Navigator.push(
                                context,
                                LipskeyProductsScreen.route(
                                  category: entry.name,
                                  products: products,
                                ),
                              ),
                    );
                  },
                  childCount: section.entries.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category card (level 2) ───────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.entry,
    required this.products,
    required this.onTap,
  });

  final LipskeyCatEntry entry;
  final List<LipskeyCatalogProduct> products;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = products.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEmpty ? 0.4 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13132A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF3D5A80).withOpacity(0.4),
                width: 0.8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.emoji,
                  style: const TextStyle(fontSize: 38)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('בקרוב',
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11)),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D5A80)
                                .withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${products.length} מוצרים',
                              style: const TextStyle(
                                  color: Color(0xFF64FFDA),
                                  fontSize: 11)),
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
