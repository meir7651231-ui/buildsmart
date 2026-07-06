/// RingDive (צלילת-טבעות) — the rotary product-finder surface (owner design
/// handoff, 6/7). A NEW PRESENTATION of the SAME `card_engine` drill-down the
/// smart keyboard renders: the axis options ride a spinning knurled dial; a tap
/// on the focused option "dives" one axis deeper; after ≤6 dives the pool
/// collapses to a single product. The engine is UNCHANGED — the dial only
/// renders `mergedKeys`'s verdict and feeds a chosen option back as a
/// `NewbieStep`, EXACTLY as `card_keyboard_screen` does (same pool-narrowing,
/// same `_predicateFor`, same `NewbieStep`).
///
/// GATED on `kRingDiveFlag` (runtime) — force-enabled for a demo build via
/// `--dart-define=ENABLE_RING_DIVE=true` (`kEnableRingDiveDemo`). OFF by default
/// → renders a zero-height `SizedBox.shrink()` → byte-identical to before.
///
/// PHASE 4 (this): the engine is wired. The wheel shows REAL catalog options —
/// the opening plain-words (`CardAskWords`), then merged axis chips
/// (`MergedKeys`), then the scan list (`CardShowProducts`), landing on one
/// product (`CardResolve`). Tapping the focused option dives. Phase 5 adds the
/// breadcrumb/back + the quantity phase on resolve; Phase 6 the results footer +
/// product sheet + cart; Phase 7 the swap seam. See BUILD-PLAN.md.
library;

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show
        CardAskWords,
        CardResolve,
        CardShowProducts,
        CardVerdict,
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

/// The RingDive surface. Renders nothing until `kRingDiveFlag` is enabled.
class RingDiveScreen extends ConsumerStatefulWidget {
  const RingDiveScreen({super.key});

  @override
  ConsumerState<RingDiveScreen> createState() => _RingDiveScreenState();
}

class _RingDiveScreenState extends ConsumerState<RingDiveScreen> {
  /// The answered dive steps (the breadcrumb the engine reads via emptiness).
  /// A local field, exactly like `card_keyboard_screen`'s `stack`.
  final List<NewbieStep> _stack = <NewbieStep>[];

  /// No curated sub-type — RingDive opens generic (the engine picks the axes).
  static const String? _subtype = null;

  /// The chosen quantity — null until the qty phase completes. Non-null → the
  /// dive has landed and the wheel shows the qty confirmation (Phase 6 = cart).
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

  CardVerdict get _verdict =>
      mergedKeys(_pool, _stack, _ringDiveLexicon, _subtype);

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

  /// Go back to a dive level — drop the step at [level] and everything deeper
  /// (mirrors the prototype's `backTo`). Tapping breadcrumb i lands here.
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

    final labels = <String>[];
    final sublabels = <String>[];
    var hubHint = 'סובב · הקש לבחור';
    void Function(int)? onSelect;

    switch (_verdict) {
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
          // Chosen — a landed confirmation (Phase 6 = add-to-cart).
          labels.add(product.nameHe);
          sublabels.add('× $_qty נבחרו');
          hubHint = 'נוסף';
        }
    }

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
          ],
        ),
      ),
    );
  }

  /// The breadcrumb trail — one pill per answered step (tap to go back to that
  /// level) + a "↺ מחדש" reset. Scrolls horizontally once the trail is long.
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
}
