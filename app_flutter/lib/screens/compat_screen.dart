import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── filter state ─────────────────────────────────────────────────────────────

final compatGenderProvider = StateProvider<String>((_) => 'הכל');
final compatSizeProvider = StateProvider<String>((_) => 'הכל');
final compatMethodProvider = StateProvider<String>((_) => 'הכל');
final compatSearchProvider = StateProvider<String>((_) => '');

// ── compatibility logic ───────────────────────────────────────────────────────

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

List<LipskeyCatalogProduct> compatibleWith(LipskeyCatalogProduct anchor) =>
    kLipskeyCatalog.where((p) => canConnect(anchor, p)).toList()
      ..sort((a, b) => (a.categoryHe == anchor.categoryHe ? 0 : 1)
          .compareTo(b.categoryHe == anchor.categoryHe ? 0 : 1));

List<LipskeyCatalogProduct> _filteredProducts(WidgetRef ref) {
  final gender = ref.watch(compatGenderProvider);
  final size = ref.watch(compatSizeProvider);
  final method = ref.watch(compatMethodProvider);
  final q = ref.watch(compatSearchProvider).trim().toLowerCase();
  return kLipskeyCatalog.where((p) {
    if (gender == 'זכר' && p.connectionGender != 'male') return false;
    if (gender == 'נקבה' && p.connectionGender != 'female') return false;
    if (size != 'הכל' && !p.connectionSizes.contains(size)) return false;
    if (method == 'תבריג' && p.connectionMethod != 'thread') return false;
    if (method == 'הדבקה' && p.connectionMethod != 'glue') return false;
    if (method == 'אלקטרו' && p.connectionMethod != 'electrofusion') return false;
    if (q.isNotEmpty &&
        !p.nameHe.toLowerCase().contains(q) &&
        !p.brand.toLowerCase().contains(q)) return false;
    return true;
  }).toList();
}

// ── label helpers ─────────────────────────────────────────────────────────────

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
      'thread' => '🔩 תבריג',
      'glue' => '💧 הדבקה',
      'electrofusion' => '⚡ אלקטרו',
      _ => '',
    };

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
          _CompatDivider(),
          Expanded(child: _CompatList()),
        ],
      ),
    );
  }
}

// ── search bar — same style as catalog search bar ────────────────────────────

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
    final hasText = ref.watch(compatSearchProvider).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Color(0xFF888888), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'חפש מוצר לתאימות...',
                  hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 14),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) =>
                    ref.read(compatSearchProvider.notifier).state = v,
              ),
            ),
            if (hasText)
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  ref.read(compatSearchProvider.notifier).state = '';
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.close, color: Color(0xFF888888), size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── filter chips — same style as _FilterChipsRow ────────────────────────────

class _CompatFilters extends ConsumerWidget {
  const _CompatFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(compatGenderProvider);
    final size = ref.watch(compatSizeProvider);
    final method = ref.watch(compatMethodProvider);
    final anyActive = gender != 'הכל' || size != 'הכל' || method != 'הכל';

    void setGender(String v) => ref.read(compatGenderProvider.notifier).state =
        gender == v ? 'הכל' : v;
    void setSize(String v) => ref.read(compatSizeProvider.notifier).state =
        size == v ? 'הכל' : v;
    void setMethod(String v) => ref.read(compatMethodProvider.notifier).state =
        method == v ? 'הכל' : v;

    Widget chip(String label, bool active, VoidCallback onTap, {Color? color}) {
      final c = color ?? BsTokens.brand;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active ? c.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? c : const Color(0xFF3A3A3A),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? c : const Color(0xFF888888),
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Row(
            children: [
              chip('♂ זכר', gender == 'זכר', () => setGender('זכר'),
                  color: const Color(0xFF5B9CF6)),
              chip('♀ נקבה', gender == 'נקבה', () => setGender('נקבה'),
                  color: const Color(0xFFFF7EB6)),
              chip('🔩 תבריג', method == 'תבריג', () => setMethod('תבריג')),
              chip('💧 הדבקה', method == 'הדבקה', () => setMethod('הדבקה')),
              chip('⚡ אלקטרו', method == 'אלקטרו', () => setMethod('אלקטרו')),
              if (anyActive) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ref.read(compatGenderProvider.notifier).state = 'הכל';
                    ref.read(compatSizeProvider.notifier).state = 'הכל';
                    ref.read(compatMethodProvider.notifier).state = 'הכל';
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF666666)),
                    ),
                    child: const Text('✕ איפוס',
                        style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              for (final s in [
                '25', '32', '40', '50', '63', '75', '90', '110', '160'
              ])
                chip(s, size == s, () => setSize(s),
                    color: BsTokens.brand),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompatDivider extends ConsumerWidget {
  const _CompatDivider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = _filteredProducts(ref);
    final gender = ref.watch(compatGenderProvider);
    final size = ref.watch(compatSizeProvider);
    final method = ref.watch(compatMethodProvider);
    final anyFilter = gender != 'הכל' || size != 'הכל' || method != 'הכל';
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
      child: Row(
        children: [
          Text('${products.length} מוצרים',
              style: const TextStyle(
                  color: Color(0xFF888888), fontSize: 12)),
          if (anyFilter) ...[
            const SizedBox(width: 6),
            const Text('·',
                style: TextStyle(color: Color(0xFF555555), fontSize: 12)),
            const SizedBox(width: 6),
            Text('מסונן',
                style: TextStyle(
                    color: BsTokens.brand,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
          const Spacer(),
          const Text('הקש ⇄ לתאימות',
              style: TextStyle(color: Color(0xFF444444), fontSize: 11)),
        ],
      ),
    );
  }
}

// ── list — same layout as _CatalogList ───────────────────────────────────────

class _CompatList extends ConsumerWidget {
  const _CompatList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = _filteredProducts(ref);
    if (products.isEmpty) {
      return const Center(
        child: Text('אין מוצרים תואמים לסינון הנוכחי',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
      );
    }
    return ListView.separated(
      key: const Key('compat-list'),
      itemCount: products.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 76, color: Color(0xFF2A2A2A)),
      itemBuilder: (_, i) => _CompatRow(product: products[i]),
    );
  }
}

// ── row — mirrors _CatalogRow exactly ────────────────────────────────────────

class _CompatRow extends ConsumerWidget {
  const _CompatRow({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(productFavoritesProvider).contains(product.sku);
    final matches = compatibleWith(product);
    final gender = product.connectionGender;
    final sizes = product.connectionSizes;
    final method = product.connectionMethod;

    // preview line: gender + sizes + method
    final parts = <String>[
      if (gender != null) _genderLabel(gender),
      if (sizes.isNotEmpty) sizes.map((s) => 'DN$s').join(' · '),
      if (method != null) _methodLabel(method),
    ];
    final preview = parts.isEmpty ? 'אין נתוני חיבור' : parts.join('  ');

    // badge = number of compatible products
    final hasBadge = matches.isNotEmpty;

    return InkWell(
      onTap: () => _showCompatSheet(context, product, matches),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // avatar circle — same as _CatalogRow
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: product.imageAsset != null
                  ? ClipOval(
                      child: Image.asset(
                        product.imageAsset!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          product.typeEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                  : Text(product.typeEmoji,
                      style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            // text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nameHe,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // gender tag instead of time
                      if (gender != null)
                        Text(
                          _genderLabel(gender),
                          style: TextStyle(
                            color: _genderColor(gender),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // compat badge — same style as catalog badge
                      GestureDetector(
                        onTap: () =>
                            _showCompatSheet(context, product, matches),
                        child: hasBadge
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3DD9B0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '⇄ ${matches.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF06251C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF3A3A3A)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '⊘',
                                  style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 12),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // fav button on right edge
            GestureDetector(
              onTap: () =>
                  ref.read(productFavoritesProvider.notifier).toggle(product.sku),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFav
                    ? const Color(0xFFFF4D6D)
                    : const Color(0xFF3A3A3A),
              ),
            ),
          ],
        ),
      ),
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
  const CompatSheet(
      {super.key, required this.anchor, required this.matches});
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(anchor.typeEmoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('מה מתחבר ל...',
                              style: TextStyle(
                                  color: Color(0xFF9AA3B2), fontSize: 11)),
                          Text(anchor.nameHe,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    // gender tag
                    if (anchor.connectionGender != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _genderColor(anchor.connectionGender)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _genderColor(anchor.connectionGender)
                                  .withOpacity(0.5)),
                        ),
                        child: Text(
                          _genderLabel(anchor.connectionGender),
                          style: TextStyle(
                            color: _genderColor(anchor.connectionGender),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF252B36)),
              // count
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                        fontWeight: FontWeight.w600,
                      ),
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
                                color: Color(0xFF9AA3B2), fontSize: 13)),
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
                        height: 1, indent: 76, color: Color(0xFF2A2A2A)),
                    itemBuilder: (ctx, i) {
                      final p = matches[i];
                      final isFav = ref
                          .watch(productFavoritesProvider)
                          .contains(p.sku);
                      final g = p.connectionGender;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showLipskeyProductSheet(
                            ctx,
                            p,
                            kLipskeyCatalog
                                .where(
                                    (x) => x.categoryHe == p.categoryHe)
                                .toList(),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2A2A2A),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: p.imageAsset != null
                                    ? ClipOval(
                                        child: Image.asset(p.imageAsset!,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Text(p.typeEmoji,
                                                    style: const TextStyle(
                                                        fontSize: 22))))
                                    : Text(p.typeEmoji,
                                        style: const TextStyle(
                                            fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(p.nameHe,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                        if (g != null)
                                          Text(_genderLabel(g),
                                              style: TextStyle(
                                                  color: _genderColor(g),
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.connectionSizes
                                          .map((s) => 'DN$s')
                                          .join(' · '),
                                      style: const TextStyle(
                                          color: Color(0xFF888888),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
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
                                      : const Color(0xFF3A3A3A),
                                ),
                              ),
                            ],
                          ),
                        ),
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
