import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter/material.dart';

class LipskeyBrandScreen extends StatelessWidget {
  const LipskeyBrandScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const LipskeyBrandScreen());

  List<_CategoryEntry> _buildCategories() {
    final seen = <String, _CategoryEntry>{};
    final order = <String>[];
    for (final p in kLipskeyCatalog) {
      if (!seen.containsKey(p.categoryHe)) {
        seen[p.categoryHe] = _CategoryEntry(
          nameHe: p.categoryHe,
          emoji: p.categoryEmoji,
          products: [],
        );
        order.add(p.categoryHe);
      }
      seen[p.categoryHe]!.products.add(p);
    }
    return order.map((k) => seen[k]!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _buildCategories();

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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'ליפסקי ברקן',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'אינסטלציה וסניטציה',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _BrandHeader(categoryCount: categories.length),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final cat = categories[i];
                    return _CategoryCard(
                      entry: cat,
                      onTap: () => Navigator.push(
                        context,
                        LipskeyProductsScreen.route(
                          category: cat.nameHe,
                          products: cat.products,
                        ),
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

class _CategoryEntry {
  _CategoryEntry({
    required this.nameHe,
    required this.emoji,
    required this.products,
  });

  final String nameHe;
  final String emoji;
  final List<LipskeyCatalogProduct> products;
  int get count => products.length;
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.categoryCount});

  final int categoryCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3D5A80).withOpacity(0.4),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          const Text('🏭', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 10),
          const Text(
            'ליפסקי ברקן',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ספק אינסטלציה וסניטציה',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(label: '66 מוצרים'),
              const SizedBox(width: 8),
              _StatChip(label: '$categoryCount קטגוריות'),
              const SizedBox(width: 8),
              _StatChip(label: 'קטלוג 2024'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF13132A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3D5A80).withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.entry, required this.onTap});

  final _CategoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3D5A80),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: const Color(0xFF13132A),
                alignment: Alignment.center,
                child: Text(
                  entry.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.nameHe,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry.count} מוצרים',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
