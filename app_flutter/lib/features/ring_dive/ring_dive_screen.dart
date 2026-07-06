/// RingDive (צלילת-טבעות / Pro-X-Light) — the rotary product-finder surface
/// (owner design handoff, 6/7). ONE wheel, phase-driven: `root` (the 9 search
/// styles) → `find` (one clean axis per turn over the REAL catalog) → product
/// leaves → quantity → cart. The wheel renders the CLEAN taxonomy/attribute
/// axes derived by `ring_dive_catalog` (dept·cat·type·size·angle·color·material·
/// brand) — NOT the old word-cloud. Zero engine change.
///
/// GATED on `kRingDiveFlag` (runtime) — force-enabled for a demo build via
/// `--dart-define=ENABLE_RING_DIVE=true`. OFF by default → `SizedBox.shrink()` →
/// byte-identical.
///
/// RD-B (this): the phase/state model wired to `ring_dive_catalog`
/// (rdMatching/rdOptsFor/rdFindAxes). RD-C adds the axis-switcher chip strip,
/// RD-D the qty dual-ring, RD-E compat+job, RD-F..H polish + tests. The
/// hub/breadcrumb/results/sheet/cart scaffolding is reused. See BUILD-PLAN.md.
library;

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/ring_dive/ring_dive_catalog.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart';
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Colour-name → swatch (the design's `dots` map), for the result cards.
const Map<String, Color> _dotColors = <String, Color>{
  'לבן': Color(0xFFF4F4F0),
  'שחור מט': Color(0xFF2A2A2A),
  'שחור': Color(0xFF1A1A1A),
  'פרגמון': Color(0xFFEAD9B0),
  'אפור': Color(0xFF9AA0A6),
  'ניקל מוברש': Color(0xFFC7CBCE),
  'ניקל': Color(0xFFB9C0C6),
  'כרום': Color(0xFFC6CDD3),
  'נחושת': Color(0xFFC67B3D),
  'ירוק': Color(0xFF3E8E5A),
  'כחול': Color(0xFF2C6FB0),
  'קרמיקה': Color(0xFFF4F4F0),
};

/// The 9 root search styles (emoji + label + axis key). The first 8 enter `find`
/// with that axis active; `job` is the kit flow (RD-E — a placeholder browse
/// for now).
const List<({String key, String emoji, String label})> _styles =
    <({String key, String emoji, String label})>[
  (key: 'dept', emoji: '🗂️', label: 'מחלקה'),
  (key: 'cat', emoji: '📁', label: 'קטגוריה'),
  (key: 'type', emoji: '🔧', label: 'סוג'),
  (key: 'size', emoji: '📏', label: 'גודל'),
  (key: 'angle', emoji: '📐', label: 'זווית'),
  (key: 'color', emoji: '🎨', label: 'צבע'),
  (key: 'material', emoji: '⚙️', label: 'חומר'),
  (key: 'brand', emoji: '🏷️', label: 'מותג'),
  (key: 'job', emoji: '🧩', label: 'לפי עבודה'),
];

/// The RingDive surface. Renders nothing until `kRingDiveFlag` is enabled.
class RingDiveScreen extends ConsumerStatefulWidget {
  const RingDiveScreen({super.key});

  @override
  ConsumerState<RingDiveScreen> createState() => _RingDiveScreenState();
}

class _RingDiveScreenState extends ConsumerState<RingDiveScreen> {
  /// 'root' — pick a search style · 'find' — drill the axes.
  String _mode = 'root';

  /// The chosen constraints so far, in order (the breadcrumb).
  final List<({String field, String value})> _path =
      <({String field, String value})>[];

  /// The active axis in `find` mode (the wheel shows its options).
  String? _axisField;

  /// The landed product (→ the quantity phase) and its chosen quantity.
  LipskeyCatalogProduct? _product;
  int? _qty;
  bool _added = false;

  static const List<int> _qtyOpts = <int>[
    1, 2, 3, 4, 5, 6, 8, 10, 12, 20, 50, 100, //
  ];

  /// The path as a constraint map for the derivation layer.
  RdCons get _cons =>
      <String, String>{for (final s in _path) s.field: s.value};

  void _enterStyle(String axis) {
    setState(() {
      _mode = 'find';
      _axisField = axis;
      _path.clear();
      _product = null;
      _qty = null;
      _added = false;
    });
  }

  void _dive(String field, String value) {
    setState(() {
      _path.add((field: field, value: value));
      final axes = rdFindAxes(_cons);
      _axisField = axes.isNotEmpty ? axes.first : null;
    });
  }

  void _pickProduct(LipskeyCatalogProduct p) {
    setState(() => _product = p);
  }

  void _backTo(int level) {
    setState(() {
      _path.removeRange(level, _path.length);
      _product = null;
      _qty = null;
      _added = false;
      final axes = rdFindAxes(_cons);
      _axisField = axes.isNotEmpty ? axes.first : null;
    });
  }

  void _reset() {
    setState(() {
      _mode = 'root';
      _path.clear();
      _axisField = null;
      _product = null;
      _qty = null;
      _added = false;
    });
  }

  void _clearQty() {
    setState(() {
      _qty = null;
      _added = false;
    });
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    setState(() => _added = true);
  }

  @override
  Widget build(BuildContext context) {
    final on = ref.watch(featureFlagsProvider).contains(kRingDiveFlag);
    if (!on) return const SizedBox.shrink();

    final labels = <String>[];
    final sublabels = <String>[];
    var hubHint = 'סובב · הקש לבחור';
    void Function(int)? onSelect;
    var footer = const <LipskeyCatalogProduct>[];

    if (_product != null) {
      // ── quantity / cart phase ──
      final p = _product!;
      if (_qty == null) {
        labels.addAll(_qtyOpts.map((q) => '$q'));
        sublabels.addAll(_qtyOpts.map((_) => p.nameHe));
        hubHint = 'הקש לבחור כמות';
        onSelect = (i) {
          if (i >= 0 && i < _qtyOpts.length) {
            setState(() => _qty = _qtyOpts[i]);
          }
        };
      } else {
        labels.add(p.nameHe);
        sublabels.add('כמות $_qty');
        hubHint = _added ? 'נוסף לסל ✓' : 'הוסף לסל למטה';
      }
    } else if (_mode == 'root') {
      // ── root: the 9 search styles ──
      for (final s in _styles) {
        labels.add('${s.emoji} ${s.label}');
        sublabels.add('התחל מ');
      }
      hubHint = 'בחר איך לחפש';
      onSelect = (i) {
        if (i >= 0 && i < _styles.length) _enterStyle(_styles[i].key);
      };
    } else {
      // ── find: one clean axis at a time, then product leaves ──
      final cons = _cons;
      final axes = rdFindAxes(cons);
      if (axes.isEmpty) {
        final leaves = rdMatching(cons);
        labels.addAll(leaves.map((rp) => rp.name));
        sublabels.addAll(leaves.map((_) => 'בחר מוצר'));
        hubHint = 'הקש לבחור מוצר';
        onSelect = (i) {
          if (i >= 0 && i < leaves.length) _pickProduct(leaves[i].product);
        };
      } else {
        final field = (_axisField != null && axes.contains(_axisField))
            ? _axisField!
            : axes.first;
        final opts = rdOptsFor(field, cons);
        labels.addAll(opts);
        sublabels.addAll(opts.map((_) => kRdAxisLabel[field] ?? ''));
        onSelect = (i) {
          if (i >= 0 && i < opts.length) _dive(field, opts[i]);
        };
        footer = rdMatching(cons)
            .take(10)
            .map((rp) => rp.product)
            .toList(growable: false);
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_path.isNotEmpty || _mode != 'root') _buildBreadcrumb(),
            RingDiveWheel(
              labels: labels,
              sublabels: sublabels,
              hubHint: hubHint,
              lockedCount: _path.length,
              onSelect: onSelect,
            ),
            if (_product != null && _qty != null) _cartBar(),
            if (footer.isNotEmpty) _buildResultsFooter(footer),
          ],
        ),
      ),
    );
  }

  // ── cart bar ─────────────────────────────────────────────────────────────

  Widget _cartBar() {
    if (_added) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✓ נוסף לסל',
              style: TextStyle(
                fontFamily: 'Heebo',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3E8E5A),
              ),
            ),
            Text(
              '$_qty יחידות',
              style: const TextStyle(
                fontFamily: 'Heebo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8C8578),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: _pillButton('חיפוש חדש', const Color(0xFF1B1B1A), _reset),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        width: 240,
        child: _pillButton(
          'הוסף לסל · × $_qty',
          const Color(0xFFEE6907),
          _addToCart,
        ),
      ),
    );
  }

  // ── breadcrumb ───────────────────────────────────────────────────────────

  Widget _buildBreadcrumb() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _path.length; i++)
              _crumb(_path[i].value, () => _backTo(i)),
            if (_qty != null) _crumb('× $_qty', _clearQty),
            const SizedBox(width: 6),
            _resetCrumb(),
          ],
        ),
      ),
    );
  }

  Widget _crumb(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0x1FFF7A18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: 'Heebo',
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFC4590C),
          ),
        ),
      ),
    );
  }

  Widget _resetCrumb() {
    return GestureDetector(
      onTap: _reset,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7E1D8)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          '↺ מחדש',
          style: TextStyle(
            fontFamily: 'Heebo',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF8C8578),
          ),
        ),
      ),
    );
  }

  // ── results footer + product sheet ───────────────────────────────────────

  Widget _buildResultsFooter(List<LipskeyCatalogProduct> products) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      height: 116,
      padding: const EdgeInsets.only(top: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final p in products) _productCard(p)],
        ),
      ),
    );
  }

  Widget _productCard(LipskeyCatalogProduct p) {
    return GestureDetector(
      onTap: () => _openSheet(p),
      child: Container(
        width: 132,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECE6DC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColors[p.color] ?? const Color(0xFFB7B0A5),
                    border: Border.all(color: const Color(0x24000000)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Heebo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8C8578),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Expanded(
              child: Text(
                p.nameHe,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Heebo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: Color(0xFF2A2620),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSheet(LipskeyCatalogProduct p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetCtx) => _sheetContent(sheetCtx, p),
    );
  }

  Widget _sheetContent(BuildContext sheetCtx, LipskeyCatalogProduct p) {
    final specs = <MapEntry<String, String>>[
      if (p.categoryHe.isNotEmpty) MapEntry('קטגוריה', p.categoryHe),
      if (p.color != null) MapEntry('צבע', p.color!),
      for (final e in (p.dims ?? const <String, dynamic>{}).entries)
        MapEntry(e.key, '${e.value}'),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E1D8),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColors[p.color] ?? const Color(0xFFB7B0A5),
                    border: Border.all(color: const Color(0x24000000)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  p.brand,
                  style: const TextStyle(
                    fontFamily: 'Heebo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8C8578),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              p.nameHe,
              style: const TextStyle(
                fontFamily: 'Heebo',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: Color(0xFF1B1B1A),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [for (final s in specs) _specChip(s.key, s.value)],
            ),
            const SizedBox(height: 20),
            _pillButton('הוסף להזמנה', const Color(0xFFFF7A18), () {
              Navigator.of(sheetCtx).pop();
              _pickProduct(p);
            }),
          ],
        ),
      ),
    );
  }

  Widget _specChip(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EA),
        border: Border.all(color: const Color(0xFFEBE5DB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$k · $v',
        style: const TextStyle(
          fontFamily: 'Heebo',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5A544A),
        ),
      ),
    );
  }

  Widget _pillButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Heebo',
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
