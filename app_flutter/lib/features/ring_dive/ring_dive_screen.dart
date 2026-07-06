/// RingDive (צלילת-טבעות) — the rotary product-finder surface (owner design
/// handoff, 6/7). A NEW PRESENTATION of the SAME `card_engine` drill-down the
/// smart keyboard renders: the axis options ride a spinning knurled dial; a tap
/// on the focused option "dives" one axis deeper; after ≤6 dives the pool
/// collapses to a single product. The engine is UNCHANGED — the dial renders
/// `mergedKeys`'s verdict and feeds a chosen option back as a `NewbieStep`,
/// EXACTLY as `card_keyboard_screen` does (same pool-narrowing, same
/// `_predicateFor`, same `NewbieStep`).
///
/// GATED on `kRingDiveFlag` (runtime) — force-enabled for a demo build via
/// `--dart-define=ENABLE_RING_DIVE=true` (`kEnableRingDiveDemo`). OFF by default
/// → renders a zero-height `SizedBox.shrink()` → byte-identical to before.
///
/// PHASE 6a (this): the results footer (a live row of product cards from the
/// current pool) + the product sheet (specs + "הוסף להזמנה" that dives to it).
/// Phase 6b adds the cart/added state on resolve; Phase 7 the swap seam. See
/// BUILD-PLAN.md.
library;

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show
        CardAskWords,
        CardResolve,
        CardShowProducts,
        MergedKeys,
        SignalChip,
        mergedKeys;
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show WordSignal, sourcesFor;
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordEntry, WordLexicon, buildWordLexicon;
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The shared vocabulary — the SAME `buildWordLexicon(kDivePool)` the smart
/// keyboard's `cardKeyboardLexicon` uses (built once, pure over const catalog).
final WordLexicon _ringDiveLexicon = buildWordLexicon(kDivePool);

/// Colour-name → swatch (the prototype's `dots` map), for the result cards.
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

/// The RingDive surface. Renders nothing until `kRingDiveFlag` is enabled.
class RingDiveScreen extends ConsumerStatefulWidget {
  const RingDiveScreen({super.key});

  @override
  ConsumerState<RingDiveScreen> createState() => _RingDiveScreenState();
}

class _RingDiveScreenState extends ConsumerState<RingDiveScreen> {
  /// The answered dive steps (the breadcrumb the engine reads via emptiness).
  final List<NewbieStep> _stack = <NewbieStep>[];

  /// No curated sub-type — RingDive opens generic (the engine picks the axes).
  static const String? _subtype = null;

  /// The chosen quantity — null until the qty phase completes.
  int? _qty;

  /// Quantity options on the qty dial (the prototype's `qtyOpts`).
  static const List<int> _qtyOpts = <int>[
    1, 2, 3, 4, 5, 6, 8, 10, 12, 20, 50, 100, //
  ];

  /// The catalog narrowed by every answered step (mirrors `_ensureMemo`).
  List<LipskeyCatalogProduct> get _pool {
    var pool = kDivePool;
    for (final step in _stack) {
      pool = pool.where(step.predicate).toList();
    }
    return pool;
  }

  /// Rebuild a chip's narrowing predicate from its `(axisId, value)` DATA — the
  /// SAME replay-stable idiom as `card_keyboard_screen._predicateFor`.
  bool Function(LipskeyCatalogProduct) _predicateFor(
    String axisId,
    String value,
  ) {
    final src = sourcesFor(_subtype).firstWhere(
      (s) => s.axisId == axisId,
      orElse: () => const WordSignal(),
    );
    final chip = SignalChip(axisId: axisId, value: value, displayLabel: value);
    return (p) => src.matches(p, chip);
  }

  void _diveWord(WordEntry word) {
    setState(() {
      _stack.add(
        NewbieStep(
          axisLabel: 'התחלה',
          chipLabel: word.word,
          crumbWord: word.word,
          predicate: _predicateFor('word', word.word),
        ),
      );
    });
  }

  void _diveChip(SignalChip chip) {
    setState(() {
      _stack.add(
        NewbieStep(
          axisLabel: chip.axisName ?? '',
          chipLabel: chip.displayLabel,
          crumbWord: chip.displayLabel,
          predicate: _predicateFor(chip.axisId, chip.value),
        ),
      );
    });
  }

  void _diveProduct(LipskeyCatalogProduct product) {
    setState(() {
      _stack.add(
        NewbieStep(
          axisLabel: 'מוצר',
          chipLabel: product.nameHe,
          crumbWord: product.nameHe,
          predicate: (p) => p.sku == product.sku,
        ),
      );
    });
  }

  /// Go back to a dive level — drop the step at [level] and everything deeper.
  void _backTo(int level) {
    setState(() {
      _stack.removeRange(level, _stack.length);
      _qty = null;
    });
  }

  void _reset() {
    setState(() {
      _stack.clear();
      _qty = null;
    });
  }

  void _clearQty() {
    setState(() {
      _qty = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final on = ref.watch(featureFlagsProvider).contains(kRingDiveFlag);
    if (!on) return const SizedBox.shrink();

    final pool = _pool;
    final verdict = mergedKeys(pool, _stack, _ringDiveLexicon, _subtype);
    final labels = <String>[];
    final sublabels = <String>[];
    var hubHint = 'סובב · הקש לבחור';
    var resolved = false;
    void Function(int)? onSelect;

    switch (verdict) {
      case CardAskWords(words: final words):
        labels.addAll(words.map((w) => w.word));
        sublabels.addAll(words.map((_) => 'מה צריך?'));
        onSelect = (i) {
          if (i >= 0 && i < words.length) _diveWord(words[i]);
        };
      case MergedKeys(chips: final chips):
        labels.addAll(chips.map((c) => c.displayLabel));
        sublabels.addAll(chips.map((c) => c.axisName ?? ''));
        onSelect = (i) {
          if (i >= 0 && i < chips.length) _diveChip(chips[i]);
        };
      case CardShowProducts(products: final products):
        labels.addAll(products.map((p) => p.nameHe));
        sublabels.addAll(products.map((_) => 'בחר מוצר'));
        onSelect = (i) {
          if (i >= 0 && i < products.length) _diveProduct(products[i]);
        };
      case CardResolve(product: final product):
        resolved = true;
        if (_qty == null) {
          // Quantity phase — the rim becomes qty numbers, the hub the product.
          labels.addAll(_qtyOpts.map((q) => '$q'));
          sublabels.addAll(_qtyOpts.map((_) => product.nameHe));
          hubHint = 'הקש לבחור כמות';
          onSelect = (i) {
            if (i >= 0 && i < _qtyOpts.length) {
              setState(() {
                _qty = _qtyOpts[i];
              });
            }
          };
        } else {
          // Chosen — a landed confirmation (Phase 6b = add-to-cart).
          labels.add(product.nameHe);
          sublabels.add('× $_qty נבחרו');
          hubHint = 'נבחרה כמות';
        }
    }

    // The results footer previews the current pool while still narrowing.
    final footer =
        resolved ? const <LipskeyCatalogProduct>[] : pool.take(10).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_stack.isNotEmpty || _qty != null) _buildBreadcrumb(),
            RingDiveWheel(
              labels: labels,
              sublabels: sublabels,
              hubHint: hubHint,
              lockedCount: _stack.length,
              onSelect: onSelect,
            ),
            if (footer.isNotEmpty) _buildResultsFooter(footer),
          ],
        ),
      ),
    );
  }

  // ── breadcrumb ─────────────────────────────────────────────────────────────

  Widget _buildBreadcrumb() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _stack.length; i++)
              _crumb(_stack[i].crumbWord, () => _backTo(i)),
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
              _diveProduct(p);
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
