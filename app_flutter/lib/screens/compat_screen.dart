import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── colors — exact match to _CatalogRow in catalog_screen.dart ───────────────
const _bg       = Color(0xFFFFFFFF);
const _surface  = Color(0xFFF5F5F5);   // avatar circle bg, search bar, chips
const _divider  = Color(0xFFF5F5F5);   // same as catalog divider
const _title    = Color(0xFF1A1A1A);   // exact match: TextStyle(color: Color(0xFF1A1A1A))
const _sub      = Color(0xFF888888);   // exact match: TextStyle(color: Color(0xFF888888))
const _brand    = BsTokens.brand;      // orange

// ── filter state ─────────────────────────────────────────────────────────────

final compatGenderProvider  = StateProvider<String>((_) => 'הכל');
final compatSizeProvider    = StateProvider<String>((_) => 'הכל');
final compatMethodProvider  = StateProvider<String>((_) => 'הכל');
final compatSearchProvider  = StateProvider<String>((_) => '');

// ── compatibility logic ───────────────────────────────────────────────────────

bool canConnect(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  if (a.sku == b.sku) return false;

  // Must share at least one DN size
  final sA = a.connectionSizes.toSet();
  final sB = b.connectionSizes.toSet();
  if (sA.isEmpty || sB.isEmpty || sA.intersection(sB).isEmpty) return false;

  // Both must have a defined gender AND be opposite (male↔female).
  // If either is unknown we can't confirm a physical connection.
  final gA = a.connectionGender, gB = b.connectionGender;
  if (gA == null || gB == null) return false;
  if (gA == gB) return false;

  // If both have a connection method it must match (thread↔thread, etc.)
  final mA = a.connectionMethod, mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) return false;

  return true;
}

List<LipskeyCatalogProduct> compatibleWith(LipskeyCatalogProduct anchor) =>
    kLipskeyCatalog.where((p) => canConnect(anchor, p)).toList()
      ..sort((a, b) => (a.categoryHe == anchor.categoryHe ? 0 : 1)
          .compareTo(b.categoryHe == anchor.categoryHe ? 0 : 1));

List<LipskeyCatalogProduct> _filtered(WidgetRef ref) {
  final g = ref.watch(compatGenderProvider);
  final s = ref.watch(compatSizeProvider);
  final m = ref.watch(compatMethodProvider);
  final q = ref.watch(compatSearchProvider).trim().toLowerCase();
  return kLipskeyCatalog.where((p) {
    if (g == 'זכר'    && p.connectionGender  != 'male')          return false;
    if (g == 'נקבה'   && p.connectionGender  != 'female')        return false;
    if (s != 'הכל'   && !p.connectionSizes.contains(s))          return false;
    if (m == 'תבריג'  && p.connectionMethod  != 'thread')        return false;
    if (m == 'הדבקה'  && p.connectionMethod  != 'glue')          return false;
    if (m == 'אלקטרו' && p.connectionMethod  != 'electrofusion') return false;
    if (q.isNotEmpty  && !p.nameHe.toLowerCase().contains(q) &&
        !p.brand.toLowerCase().contains(q)) return false;
    return true;
  }).toList();
}

// ── label helpers ─────────────────────────────────────────────────────────────

String _gLbl(String? g) => switch (g) {
  'male'   => '♂ זכר',
  'female' => '♀ נקבה',
  _        => '⟷',
};

Color _gColor(String? g) => switch (g) {
  'male'   => const Color(0xFF3B82F6),
  'female' => const Color(0xFFEC4899),
  _        => _sub,
};

String _mLbl(String? m) => switch (m) {
  'thread'        => '🔩 תבריג',
  'glue'          => '💧 הדבקה',
  'electrofusion' => '⚡ אלקטרו',
  _               => '',
};

// ── main widget ───────────────────────────────────────────────────────────────

class CompatScreen extends ConsumerWidget {
  const CompatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Material resets DefaultTextStyle to dark on a light surface,
    // so Text widgets without explicit color render readable (not white-on-white).
    return const Material(
      color: _bg,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          _SearchBar(),
          _Filters(),
          _StatsRow(),
          Expanded(child: _List()),
        ]),
      ),
    );
  }
}

// ── search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();
  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hasText = ref.watch(compatSearchProvider).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE7E7EA),  // matches catalog search bar
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: _sub, size: 18),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _ctrl,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: _title, fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'חפש מוצר לתאימות...',
              hintStyle: TextStyle(color: _sub, fontSize: 14),
              isDense: true, contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) =>
                ref.read(compatSearchProvider.notifier).state = v,
          )),
          if (hasText)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                ref.read(compatSearchProvider.notifier).state = '';
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.close, color: _sub, size: 16),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── filter chips ──────────────────────────────────────────────────────────────

class _Filters extends ConsumerWidget {
  const _Filters();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender  = ref.watch(compatGenderProvider);
    final size    = ref.watch(compatSizeProvider);
    final method  = ref.watch(compatMethodProvider);
    final anyOn   = gender != 'הכל' || size != 'הכל' || method != 'הכל';

    void setG(String v) => ref.read(compatGenderProvider.notifier).state  = gender == v ? 'הכל' : v;
    void setS(String v) => ref.read(compatSizeProvider.notifier).state    = size   == v ? 'הכל' : v;
    void setM(String v) => ref.read(compatMethodProvider.notifier).state  = method == v ? 'הכל' : v;

    Widget chip(String lbl, bool on, VoidCallback fn, {Color? c}) {
      final col = c ?? _brand;
      return GestureDetector(
        onTap: fn,
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: on ? col.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? col : const Color(0xFFD1D5DB), width: on ? 1.5 : 1),
          ),
          child: Text(lbl,
              style: TextStyle(
                color: on ? col : _sub,
                fontSize: 12,
                fontWeight: on ? FontWeight.w700 : FontWeight.w400)),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Row(children: [
          chip('♂ זכר',    gender == 'זכר',    () => setG('זכר'),    c: const Color(0xFF3B82F6)),
          chip('♀ נקבה',   gender == 'נקבה',   () => setG('נקבה'),   c: const Color(0xFFEC4899)),
          chip('🔩 תבריג', method == 'תבריג',  () => setM('תבריג')),
          chip('💧 הדבקה', method == 'הדבקה',  () => setM('הדבקה')),
          chip('⚡ אלקטרו',method == 'אלקטרו', () => setM('אלקטרו')),
          if (anyOn) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ref.read(compatGenderProvider.notifier).state = 'הכל';
                ref.read(compatSizeProvider.notifier).state   = 'הכל';
                ref.read(compatMethodProvider.notifier).state = 'הכל';
              },
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: const Text('✕ איפוס',
                    style: TextStyle(color: _sub, fontSize: 12)),
              ),
            ),
          ],
        ]),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
        child: Row(children: [
          for (final s in ['25','32','40','50','63','75','90','110','160'])
            chip(s, size == s, () => setS(s)),
        ]),
      ),
    ]);
  }
}

// ── stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count  = _filtered(ref).length;
    final anyOn  = ref.watch(compatGenderProvider) != 'הכל' ||
                   ref.watch(compatSizeProvider)   != 'הכל' ||
                   ref.watch(compatMethodProvider) != 'הכל';
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
      child: Row(children: [
        Text('$count מוצרים',
            style: const TextStyle(color: _sub, fontSize: 12)),
        if (anyOn) ...[
          const SizedBox(width: 6),
          const Text('·', style: TextStyle(color: _sub, fontSize: 12)),
          const SizedBox(width: 6),
          Text('מסונן', style: TextStyle(
              color: _brand, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
        const Spacer(),
        const Text('הקש ⇄ לתאימות',
            style: TextStyle(color: _sub, fontSize: 11)),
      ]),
    );
  }
}

// ── list ──────────────────────────────────────────────────────────────────────

class _List extends ConsumerWidget {
  const _List();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = _filtered(ref);
    if (products.isEmpty) {
      return const Center(child: Text('אין מוצרים תואמים לסינון',
          style: TextStyle(color: _sub, fontSize: 14)));
    }
    return ColoredBox(
      color: _bg,
      child: ListView.separated(
        key: const Key('compat-list'),
        itemCount: products.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 76, color: _divider),
        itemBuilder: (_, i) => _Row(product: products[i]),
      ),
    );
  }
}

// ── row — mirrors _CatalogRow with light palette ──────────────────────────────

class _Row extends ConsumerWidget {
  const _Row({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = compatibleWith(product);
    final gender  = product.connectionGender;
    final sizes   = product.connectionSizes;
    final method  = product.connectionMethod;

    final previewParts = <String>[
      if (sizes.isNotEmpty) sizes.map((s) => 'DN$s').join(' · '),
      if (method != null) _mLbl(method),
    ];
    final preview = previewParts.isEmpty ? 'אין נתוני חיבור' : previewParts.join('  ');

    return InkWell(
      onTap: () => _showSheet(context, product, matches),
      child: ColoredBox(
        color: _bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            // avatar circle
            Container(
              width: 50, height: 50,
              decoration: const BoxDecoration(color: _surface, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: product.imageAsset != null
                  ? ClipOval(child: Image.asset(product.imageAsset!,
                      width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Text(product.typeEmoji, style: const TextStyle(fontSize: 24))))
                  : Text(product.typeEmoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            // text
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(product.nameHe,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _title, fontSize: 15, fontWeight: FontWeight.w600))),
                  if (gender != null)
                    Text(_gLbl(gender),
                        style: TextStyle(color: _gColor(gender),
                            fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Expanded(child: Text(preview, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _sub, fontSize: 13))),
                  // compat badge
                  GestureDetector(
                    onTap: () => _showSheet(context, product, matches),
                    child: matches.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
                            ),
                            child: Text('⇄ ${matches.length}',
                                style: const TextStyle(
                                    color: Color(0xFF059669), fontSize: 12,
                                    fontWeight: FontWeight.w700)))
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _divider),
                            ),
                            child: const Text('⊘',
                                style: TextStyle(color: _sub, fontSize: 12))),
                  ),
                ]),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

// ── compat sheet ──────────────────────────────────────────────────────────────

void _showSheet(BuildContext ctx, LipskeyCatalogProduct anchor,
    List<LipskeyCatalogProduct> matches) {
  showModalBottomSheet<void>(
    context: ctx,
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
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            // handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _divider, borderRadius: BorderRadius.circular(2)),
            ),
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: _surface, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(anchor.typeEmoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('מה מתחבר ל...',
                        style: TextStyle(color: _sub, fontSize: 11)),
                    Text(anchor.nameHe, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _title, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                )),
                if (anchor.connectionGender != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _gColor(anchor.connectionGender).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _gColor(anchor.connectionGender).withOpacity(0.4)),
                    ),
                    child: Text(_gLbl(anchor.connectionGender),
                        style: TextStyle(
                            color: _gColor(anchor.connectionGender),
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
              ]),
            ),
            const Divider(height: 1, color: _divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(children: [
                Text(
                  matches.isEmpty ? 'לא נמצאו מוצרים תואמים' : '${matches.length} מוצרים תואמים',
                  style: TextStyle(
                    color: matches.isEmpty ? _sub : const Color(0xFF059669),
                    fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
            if (matches.isEmpty)
              const Expanded(child: Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⊘', style: TextStyle(fontSize: 48, color: _divider)),
                  SizedBox(height: 12),
                  Text('אין מוצרים בקטלוג שמתחברים לפריט זה',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _sub, fontSize: 13)),
                ],
              )))
            else
              Expanded(child: ListView.separated(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: matches.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 72, color: _divider),
                itemBuilder: (ctx2, i) {
                  final p = matches[i];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      showLipskeyProductSheet(ctx2, p,
                          kLipskeyCatalog.where((x) => x.categoryHe == p.categoryHe).toList());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: const BoxDecoration(color: _surface, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: p.imageAsset != null
                              ? ClipOval(child: Image.asset(p.imageAsset!,
                                  width: 44, height: 44, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Text(p.typeEmoji, style: const TextStyle(fontSize: 20))))
                              : Text(p.typeEmoji, style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(child: Text(p.nameHe,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: _title, fontSize: 14, fontWeight: FontWeight.w600))),
                              if (p.connectionGender != null)
                                Text(_gLbl(p.connectionGender),
                                    style: TextStyle(
                                        color: _gColor(p.connectionGender),
                                        fontSize: 11, fontWeight: FontWeight.w600)),
                            ]),
                            const SizedBox(height: 2),
                            Text(p.connectionSizes.map((s) => 'DN$s').join(' · '),
                                style: const TextStyle(color: _sub, fontSize: 12)),
                          ],
                        )),
                      ]),
                    ),
                  );
                },
              )),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ]),
        ),
      ),
    );
  }
}
