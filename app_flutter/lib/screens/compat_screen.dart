import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── filter state ─────────────────────────────────────────────────────────────

/// Gender filter: 'הכל' | 'זכר' | 'נקבה'
final compatGenderProvider = StateProvider<String>((_) => 'הכל');

/// Size filter: 'הכל' | '25' | '32' | '40' | '50' | '75' | '110'
final compatSizeProvider = StateProvider<String>((_) => 'הכל');

/// Method filter: 'הכל' | 'תבריג' | 'הדבקה' | 'אלקטרו'
final compatMethodProvider = StateProvider<String>((_) => 'הכל');

/// Text search within compat screen.
final compatSearchProvider = StateProvider<String>((_) => '');

/// The product whose "מה מתחבר?" sheet is open — null = none.
final compatAnchorProvider =
    StateProvider<LipskeyCatalogProduct?>((_) => null);

// ── helpers ──────────────────────────────────────────────────────────────────

String _genderLabel(String? g) => switch (g) {
      'male' => '♂ זכר',
      'female' => '♀ נקבה',
      _ => '⟷',
    };

Color _genderColor(String? g) => switch (g) {
      'male' => const Color(0xFF5B9CF6),
      'female' => const Color(0xFFFF7EB6),
      _ => const Color(0xFF9AA3B2),
    };

String _methodLabel(String? m) => switch (m) {
      'thread' => 'תבריג',
      'glue' => 'הדבקה',
      'electrofusion' => 'אלקטרו',
      _ => '',
    };

/// Returns true if [a] and [b] can physically connect.
/// Rules:
///  1. Must share at least one size token.
///  2. If both have explicit gender — must be opposite (male↔female).
///  3. Method: if both explicit — must match (thread↔thread, glue↔glue).
bool canConnect(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  if (a.sku == b.sku) return false;
  final sizesA = a.connectionSizes.toSet();
  final sizesB = b.connectionSizes.toSet();
  if (sizesA.isEmpty || sizesB.isEmpty) return false;
  if (sizesA.intersection(sizesB).isEmpty) return false;

  final gA = a.connectionGender;
  final gB = b.connectionGender;
  if (gA != null && gB != null && gA == gB) return false;

  final mA = a.connectionMethod;
  final mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) return false;

  return true;
}

/// All products that can connect to [anchor], sorted by same-category first.
List<LipskeyCatalogProduct> compatibleWith(LipskeyCatalogProduct anchor) {
  final results = kLipskeyCatalog.where((p) => canConnect(anchor, p)).toList()
    ..sort((a, b) {
      final sameA = a.categoryHe == anchor.categoryHe ? 0 : 1;
      final sameB = b.categoryHe == anchor.categoryHe ? 0 : 1;
      return sameA.compareTo(sameB);
    });
  return results;
}

// ── main widget ───────────────────────────────────────────────────────────────

class CompatScreen extends ConsumerWidget {
  const CompatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _CompatSearchBar(),
          _CompatFilters(),
          _CompatStats(),
          Expanded(child: _CompatList()),
        ],
      ),
    );
  }
}

// ── search bar ────────────────────────────────────────────────────────────────

class _CompatSearchBar extends ConsumerStatefulWidget {
  const _CompatSearchBar();

  @override
  ConsumerState<_CompatSearchBar> createState() => _CompatSearchBarState();
}

class _CompatSearchBarState extends ConsumerState<_CompatSearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF252B36),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Color(0xFF9AA3B2), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'חפש מוצר לתאימות...',
                  hintStyle:
                      TextStyle(color: Color(0xFF9AA3B2), fontSize: 14),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) =>
                    ref.read(compatSearchProvider.notifier).state = v,
              ),
            ),
            if (ref.watch(compatSearchProvider).isNotEmpty)
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  ref.read(compatSearchProvider.notifier).state = '';
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child:
                      Icon(Icons.close, color: Color(0xFF9AA3B2), size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── filter chips ─────────────────────────────────────────────────────────────

class _CompatFilters extends ConsumerWidget {
  const _CompatFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(compatGenderProvider);
    final size = ref.watch(compatSizeProvider);
    final method = ref.watch(compatMethodProvider);

    Widget chip(String label, bool active, VoidCallback onTap,
        {Color? activeColor}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? (activeColor ?? const Color(0xFFFF7A18))
                : const Color(0xFF252B36),
            borderRadius: BorderRadius.circular(16),
            border: active
                ? null
                : Border.all(color: const Color(0xFF3A4151)),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active
                      ? (active && activeColor != null
                          ? Colors.white
                          : const Color(0xFF1A1200))
                      : const Color(0xFF9AA3B2),
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w400)),
        ),
      );
    }

    void setGender(String v) =>
        ref.read(compatGenderProvider.notifier).state =
            gender == v ? 'הכל' : v;
    void setSize(String v) =>
        ref.read(compatSizeProvider.notifier).state =
            size == v ? 'הכל' : v;
    void setMethod(String v) =>
        ref.read(compatMethodProvider.notifier).state =
            method == v ? 'הכל' : v;

    final anyActive =
        gender != 'הכל' || size != 'הכל' || method != 'הכל';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gender row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(
            children: [
              chip('♂ זכר', gender == 'זכר', () => setGender('זכר'),
                  activeColor: const Color(0xFF5B9CF6)),
              chip('♀ נקבה', gender == 'נקבה', () => setGender('נקבה'),
                  activeColor: const Color(0xFFFF7EB6)),
              const SizedBox(width: 16),
              chip('תבריג', method == 'תבריג',
                  () => setMethod('תבריג')),
              chip('הדבקה', method == 'הדבקה',
                  () => setMethod('הדבקה')),
              chip('אלקטרו', method == 'אלקטרו',
                  () => setMethod('אלקטרו')),
            ],
          ),
        ),
        // Size row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              for (final s in ['25', '32', '40', '50', '63', '75', '90', '110', '160'])
                chip(s, size == s, () => setSize(s)),
              if (anyActive) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ref.read(compatGenderProvider.notifier).state = 'הכל';
                    ref.read(compatSizeProvider.notifier).state = 'הכל';
                    ref.read(compatMethodProvider.notifier).state = 'הכל';
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF8B2020)),
                    ),
                    child: const Text('✕ איפוס',
                        style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── stats bar ─────────────────────────────────────────────────────────────────

class _CompatStats extends ConsumerWidget {
  const _CompatStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = _filteredProducts(ref);
    final gender = ref.watch(compatGenderProvider);
    final size = ref.watch(compatSizeProvider);
    final method = ref.watch(compatMethodProvider);
    final anyFilter = gender != 'הכל' || size != 'הכל' || method != 'הכל';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      color: const Color(0xFF0E1116),
      child: Row(
        children: [
          Text('${products.length} מוצרים',
              style: const TextStyle(
                  color: Color(0xFF9AA3B2),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          if (anyFilter) ...[
            const SizedBox(width: 6),
            const Text('·',
                style: TextStyle(color: Color(0xFF3A4151), fontSize: 12)),
            const SizedBox(width: 6),
            const Text('מסונן',
                style: TextStyle(
                    color: Color(0xFFFF7A18),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
          const Spacer(),
          const Text('הקש ⇄ לתאימות',
              style:
                  TextStyle(color: Color(0xFF3A4151), fontSize: 11)),
        ],
      ),
    );
  }
}

// ── filtered products helper ──────────────────────────────────────────────────

List<LipskeyCatalogProduct> _filteredProducts(WidgetRef ref) {
  final gender = ref.watch(compatGenderProvider);
  final size = ref.watch(compatSizeProvider);
  final method = ref.watch(compatMethodProvider);
  final query = ref.watch(compatSearchProvider).trim().toLowerCase();

  return kLipskeyCatalog.where((p) {
    if (gender == 'זכר' && p.connectionGender != 'male') return false;
    if (gender == 'נקבה' && p.connectionGender != 'female') return false;
    if (size != 'הכל' && !p.connectionSizes.contains(size)) return false;
    if (method == 'תבריג' && p.connectionMethod != 'thread') return false;
    if (method == 'הדבקה' && p.connectionMethod != 'glue') return false;
    if (method == 'אלקטרו' && p.connectionMethod != 'electrofusion') {
      return false;
    }
    if (query.isNotEmpty &&
        !p.nameHe.toLowerCase().contains(query) &&
        !p.brand.toLowerCase().contains(query)) return false;
    return true;
  }).toList();
}

// ── product list ─────────────────────────────────────────────────────────────

class _CompatList extends ConsumerWidget {
  const _CompatList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = _filteredProducts(ref);
    if (products.isEmpty) {
      return const Center(
        child: Text('אין מוצרים תואמים לסינון הנוכחי',
            style: TextStyle(color: Color(0xFF9AA3B2), fontSize: 14)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(
          height: 1, indent: 72, color: Color(0xFF1E2330)),
      itemBuilder: (_, i) => _CompatRow(product: products[i]),
    );
  }
}

// ── single row ────────────────────────────────────────────────────────────────

class _CompatRow extends ConsumerWidget {
  const _CompatRow({required this.product});
  final LipskeyCatalogProduct product;

  static const _bg = Color(0xFF0E1116);
  static const _line = Color(0xFF1E2330);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(productFavoritesProvider).contains(product.sku);
    final gender = product.connectionGender;
    final sizes = product.connectionSizes;
    final method = product.connectionMethod;
    final matches = compatibleWith(product);

    return GestureDetector(
      onTap: () => showLipskeyProductSheet(
        context,
        product,
        kLipskeyCatalog
            .where((p) => p.categoryHe == product.categoryHe)
            .toList(),
      ),
      child: Container(
        color: _bg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // thumbnail
            _Thumb(product: product),
            const SizedBox(width: 12),
            // main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // category label
                  Text(product.categoryHe,
                      style: const TextStyle(
                          color: Color(0xFF9AA3B2),
                          fontSize: 10,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  // name
                  Text(product.nameHe,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3)),
                  const SizedBox(height: 6),
                  // tag row
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      if (gender != null)
                        _Tag(
                            label: _genderLabel(gender),
                            color: _genderColor(gender),
                            bg: _genderColor(gender).withOpacity(0.12)),
                      for (final s in sizes)
                        _Tag(
                            label: 'DN$s',
                            color: const Color(0xFFFF7A18),
                            bg: const Color(0x22FF7A18)),
                      if (method != null)
                        _Tag(
                            label: _methodLabel(method),
                            color: const Color(0xFF3DD9B0),
                            bg: const Color(0x223DD9B0)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // right column: compat button + fav
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // compat button
                GestureDetector(
                  onTap: () => _showCompatSheet(context, product, matches),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: matches.isEmpty
                          ? const Color(0xFF1E2330)
                          : const Color(0xFF1A2C1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: matches.isEmpty
                              ? const Color(0xFF3A4151)
                              : const Color(0xFF3DD9B0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          matches.isEmpty ? '⊘' : '⇄',
                          style: TextStyle(
                              fontSize: 14,
                              color: matches.isEmpty
                                  ? const Color(0xFF3A4151)
                                  : const Color(0xFF3DD9B0)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          matches.isEmpty ? 'אין' : '${matches.length}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: matches.isEmpty
                                  ? const Color(0xFF3A4151)
                                  : const Color(0xFF3DD9B0)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // fav
                GestureDetector(
                  onTap: () => ref
                      .read(productFavoritesProvider.notifier)
                      .toggle(product.sku),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isFav
                        ? const Color(0xFFFF4D6D)
                        : const Color(0xFF3A4151),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── thumbnail ─────────────────────────────────────────────────────────────────

class _Thumb extends StatelessWidget {
  const _Thumb({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF181D26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      alignment: Alignment.center,
      child: product.imageAsset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                product.imageAsset!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Text(product.typeEmoji,
                        style: const TextStyle(fontSize: 26)),
              ),
            )
          : Text(product.typeEmoji,
              style: const TextStyle(fontSize: 26)),
    );
  }
}

// ── tag chip ──────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag(
      {required this.label, required this.color, required this.bg});
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ── compat sheet ──────────────────────────────────────────────────────────────

void _showCompatSheet(
  BuildContext context,
  LipskeyCatalogProduct anchor,
  List<LipskeyCatalogProduct> matches,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CompatSheet(anchor: anchor, matches: matches),
  );
}

class CompatSheet extends ConsumerWidget {
  const CompatSheet({super.key, required this.anchor, required this.matches});
  final LipskeyCatalogProduct anchor;
  final List<LipskeyCatalogProduct> matches;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141920),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4151),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Text(anchor.typeEmoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('מה מתחבר ל...',
                              style: const TextStyle(
                                  color: Color(0xFF9AA3B2),
                                  fontSize: 11)),
                          Text(
                            anchor.nameHe,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    // anchor tags
                    Wrap(
                      spacing: 4,
                      children: [
                        if (anchor.connectionGender != null)
                          _Tag(
                              label: _genderLabel(anchor.connectionGender),
                              color: _genderColor(anchor.connectionGender),
                              bg: _genderColor(anchor.connectionGender)
                                  .withOpacity(0.12)),
                        for (final s in anchor.connectionSizes)
                          _Tag(
                              label: 'DN$s',
                              color: const Color(0xFFFF7A18),
                              bg: const Color(0x22FF7A18)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF252B36)),
              // result count
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      matches.isEmpty
                          ? 'לא נמצאו מוצרים תואמים'
                          : '${matches.length} מוצרים תואמים',
                      style: TextStyle(
                          color: matches.isEmpty
                              ? const Color(0xFF9AA3B2)
                              : const Color(0xFF3DD9B0),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (matches.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⊘',
                            style: TextStyle(
                                fontSize: 48, color: Color(0xFF3A4151))),
                        SizedBox(height: 12),
                        Text('אין מוצרים בקטלוג שמתחברים לפריט זה',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF9AA3B2),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 72,
                        color: Color(0xFF1E2330)),
                    itemBuilder: (ctx, i) {
                      final p = matches[i];
                      final isFav = ref
                          .watch(productFavoritesProvider)
                          .contains(p.sku);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: _Thumb(product: p),
                        title: Text(p.nameHe,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        subtitle: Wrap(
                          spacing: 4,
                          children: [
                            if (p.connectionGender != null)
                              _Tag(
                                  label: _genderLabel(p.connectionGender),
                                  color: _genderColor(p.connectionGender),
                                  bg: _genderColor(p.connectionGender)
                                      .withOpacity(0.12)),
                            for (final s in p.connectionSizes)
                              _Tag(
                                  label: 'DN$s',
                                  color: const Color(0xFFFF7A18),
                                  bg: const Color(0x22FF7A18)),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () => ref
                              .read(productFavoritesProvider.notifier)
                              .toggle(p.sku),
                          child: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: isFav
                                ? const Color(0xFFFF4D6D)
                                : const Color(0xFF3A4151),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showLipskeyProductSheet(
                            ctx,
                            p,
                            kLipskeyCatalog
                                .where((x) => x.categoryHe == p.categoryHe)
                                .toList(),
                          );
                        },
                      );
                    },
                  ),
                ),
              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}
