import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter/material.dart';

// ── Entry: main catalog categories that have Lipskey content ─────────────────
class LipskeyBrandScreen extends StatelessWidget {
  const LipskeyBrandScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const LipskeyBrandScreen());

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final cat in kCatalogCats)
        if (kMainCatToLipskey.containsKey(cat.title)) cat,
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080815),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(totalProducts: kLipskeyCatalog.length),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final cat = entries[i];
                    final subcats = kMainCatToLipskey[cat.title]!;
                    final count = kLipskeyCatalog
                        .where((p) => subcats.contains(p.categoryHe))
                        .length;
                    return _MainCatCard(
                      emoji: cat.emoji,
                      title: cat.title,
                      count: count,
                      subcatCount: subcats.length,
                      onTap: () => Navigator.push(
                        context,
                        LipskeySubCatScreen.route(
                          mainCat: cat.title,
                          mainEmoji: cat.emoji,
                          subcats: subcats,
                        ),
                      ),
                    );
                  },
                  childCount: entries.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.totalProducts});
  final int totalProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A1A2E)],
        ),
        border: Border(
            bottom: BorderSide(color: Color(0xFF3D5A80), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white70, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('קטלוג מוצרים',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    Text('בחר קטגוריה',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _StatChip('📦 $totalProducts מוצרים'),
              _StatChip(
                  '🗂️ ${kMainCatToLipskey.length} קטגוריות'),
              // Supplier badge — secondary info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D5A80).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3D5A80), width: 0.6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏭', style: TextStyle(fontSize: 11)),
                    SizedBox(width: 4),
                    Text('ליפסקי ברקן',
                        style: TextStyle(color: Color(0xFF64FFDA), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF3D5A80).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFF3D5A80), width: 0.6),
        ),
        child: Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 12)),
      );
}

// ── Main category card ────────────────────────────────────────────────────────
class _MainCatCard extends StatelessWidget {
  const _MainCatCard({
    required this.emoji,
    required this.title,
    required this.count,
    required this.subcatCount,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final int count;
  final int subcatCount;
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
            Text(emoji, style: const TextStyle(fontSize: 38)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D5A80).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count מוצרים',
                          style: const TextStyle(
                              color: Color(0xFF64FFDA), fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    Text('$subcatCount קבוצות',
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

// ── Level 2: Subcategory screen ───────────────────────────────────────────────
class LipskeySubCatScreen extends StatelessWidget {
  const LipskeySubCatScreen({
    super.key,
    required this.mainCat,
    required this.mainEmoji,
    required this.subcats,
  });

  final String mainCat;
  final String mainEmoji;
  final List<String> subcats;

  static Route<void> route({
    required String mainCat,
    required String mainEmoji,
    required List<String> subcats,
  }) =>
      MaterialPageRoute(
        builder: (_) => LipskeySubCatScreen(
          mainCat: mainCat,
          mainEmoji: mainEmoji,
          subcats: subcats,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final entries = <_SubCatEntry>[];
    for (final sub in subcats) {
      final products =
          kLipskeyCatalog.where((p) => p.categoryHe == sub).toList();
      if (products.isEmpty) continue;
      final emoji = products.first.categoryEmoji;
      entries.add(_SubCatEntry(name: sub, emoji: emoji, products: products));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080815),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              Text(mainEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mainCat,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text(
                        'ליפסקי ברקן · ${entries.length} קבוצות',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) =>
              _SubCatTile(entry: entries[i]),
        ),
      ),
    );
  }
}

class _SubCatEntry {
  final String name;
  final String emoji;
  final List<LipskeyCatalogProduct> products;
  const _SubCatEntry(
      {required this.name,
      required this.emoji,
      required this.products});
}

class _SubCatTile extends StatelessWidget {
  const _SubCatTile({required this.entry});
  final _SubCatEntry entry;

  @override
  Widget build(BuildContext context) {
    final thumbs = entry.products
        .where((p) => p.imageAsset != null)
        .take(4)
        .toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        LipskeyProductsScreen.route(
          category: entry.name,
          products: entry.products,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF13132A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF3D5A80).withOpacity(0.35),
              width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Text(entry.emoji,
                      style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text(
                            '${entry.products.length} מוצרים',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left,
                      color: Colors.white38, size: 20),
                ],
              ),
            ),
            if (thumbs.isNotEmpty)
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  itemCount: thumbs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFF0D0D1A),
                      child: Image.asset(
                        thumbs[i].imageAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(entry.emoji,
                              style: const TextStyle(
                                  fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
