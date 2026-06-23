// CardKeyboardScreen — the flag-gated UNIFIED card-keyboard surface (#38, Phase 4).
//
// Wires the PURE unified engine (mergedKeys → CardVerdict) to the word-key
// keyboard. Unlike WordFinderScreen (which asks ONE axis per turn and has
// separate material/jobs/connections sub-views), the unified engine MERGES every
// axis into one key-set, so this screen is far leaner: one switch over the four
// CardVerdict cases → keys → tap. The dive shows the merged keys until it
// converges to a product, then opens the existing reach-product sheet (Phase 5).
//
// SELF-GATING: renders nothing (a zero-height SizedBox.shrink) unless
// kCardKeyboardFlag is enabled, read ONCE at mount (build-plan §1.6 — never
// per-keystroke, so a late prefs load can't swap the engine mid-dive). Lands dark
// until the owner-gated cut-over (Phase 6).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/card_keyboard/card_keyboard_flag.dart';
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show SignalSource, WordSignal, kHardSignals;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep, kPickProductQuestion, resolveWord;
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The unified engine's lexicon, built ONCE over the union dive-pool (top-level,
/// like `wordFinderLexicon`, so the build runs a single time per isolate). The
/// engine's `resolveWord` / the opening `CardAskWords` read it.
final WordLexicon cardKeyboardLexicon = buildWordLexicon(kDivePool);

/// Header prompt shown when the merged engine is asking for a merged narrowing.
/// OWNER-REVIEW.
const String kCardMergedQuestion = 'מה מתאים?';

/// The flag-gated unified card-keyboard screen. Holds the answered-step [stack];
/// everything else (what to show, what a tap means) is the pure engine's job.
class CardKeyboardScreen extends ConsumerStatefulWidget {
  const CardKeyboardScreen({
    super.key,
    this.subtype,
    this.forceLiveForTest = false,
  });

  /// Optional curated sub-type, passed straight through to [mergedKeys]. Usually
  /// null (the generic dive).
  final String? subtype;

  /// @visibleForTesting — force the self-gate ON regardless of the flag. The flag
  /// is NOT unit-seedable (read as a `late final` at mount, BEFORE the notifier's
  /// async prefs `_load` completes — the wall feature_flags.dart documents for the
  /// word-finder demo), so a behavioral test constructs the screen with this true
  /// to exercise the ON path. Default false → production is purely flag-driven.
  @visibleForTesting
  final bool forceLiveForTest;

  @override
  ConsumerState<CardKeyboardScreen> createState() => _CardKeyboardScreenState();
}

class _CardKeyboardScreenState extends ConsumerState<CardKeyboardScreen> {
  /// The answered conversation steps — the breadcrumb AND the pool filter. Each
  /// step carries a pure predicate; the live pool keeps only products for which
  /// EVERY step's predicate holds.
  final List<NewbieStep> stack = <NewbieStep>[];

  /// The flag, read ONCE at mount (build-plan §1.6's flag-race guard): a late
  /// `featureFlagsProvider` load must never swap the engine mid-dive.
  late final bool _live =
      ref.read(featureFlagsProvider).contains(kCardKeyboardFlag);

  /// @visibleForTesting — when false, reaching a [CardResolve] does NOT auto-open
  /// the product sheet (so a behavioral test need not supply the sheet's heavy
  /// Riverpod deps). Production keeps it true (the flow ends by opening the sheet).
  @visibleForTesting
  bool openSheetOnResolve = true;

  /// The live pool: base products that satisfy EVERY answered step's predicate.
  List<LipskeyCatalogProduct> get _pool {
    var pool = kDivePool;
    for (final step in stack) {
      pool = pool.where(step.predicate).toList();
    }
    return pool;
  }

  /// @visibleForTesting — the engine's verdict for the CURRENT state (the same
  /// value [build] switches on, so a test asserts on it directly).
  @visibleForTesting
  CardVerdict get verdict =>
      mergedKeys(_pool, stack, cardKeyboardLexicon, widget.subtype);

  /// @visibleForTesting — the answered breadcrumb words, in order.
  @visibleForTesting
  List<String> get crumbs => [for (final s in stack) s.crumbWord];

  /// Reconstruct a merged chip's narrowing predicate from its `(axisId, value)`
  /// DATA (build-plan §2 #19 — the step is rebuilt from data, not a captured
  /// closure over a SignalChip, so it is replay-stable). Looks up the
  /// [SignalSource] by [axisId] and applies its [SignalSource.matches] for a chip
  /// of [value]. Falls back to the word source defensively (an unknown axisId
  /// can't happen for an engine-emitted chip).
  bool Function(LipskeyCatalogProduct) _predicateFor(
    String axisId,
    String value,
  ) {
    final SignalSource src = kHardSignals.firstWhere(
      (s) => s.axisId == axisId,
      orElse: () => const WordSignal(),
    );
    final chip =
        SignalChip(axisId: axisId, value: value, displayLabel: value);
    return (p) => src.matches(p, chip);
  }

  /// Push an answered step, recompute, and — if the engine now RESOLVEs — open
  /// the reach-product sheet (the flow's terminus, Phase 5).
  void _pushStep(NewbieStep step) {
    setState(() => stack.add(step));
    final v = verdict;
    if (v is CardResolve && openSheetOnResolve) {
      showLipskeyProductSheet(context, v.product, v.siblings);
    }
  }

  /// Pop the last answered step (the back affordance). A no-op on an empty stack.
  void _popStep() {
    if (stack.isEmpty) return;
    setState(stack.removeLast);
  }

  /// @visibleForTesting — drive [_popStep] directly (the back control is hidden
  /// at an empty stack, so a "pop at empty is a safe no-op" test needs this).
  @visibleForTesting
  void popStepForTest() => _popStep();

  /// Map a [CardVerdict] to the word-key list the keyboard renders.
  ///  • [CardAskWords]    → one 'word' key per opening word.
  ///  • [MergedKeys]      → one key per merged chip; payload carries the chip's
  ///    axisId+value (the narrowing data) so the tap rebuilds the step from data.
  ///  • [CardShowProducts]→ one product key per distinct card (payload = its sku).
  ///  • [CardResolve]     → no keys (the sheet is opened on resolve).
  List<WordKey> _keysFor(CardVerdict v) => switch (v) {
        CardAskWords(:final words) => [
            for (final e in words) WordKey(e.word, payload: 'word'),
          ],
        MergedKeys(:final chips) => [
            for (final c in chips)
              WordKey(c.displayLabel, payload: 'chip|${c.axisId}|${c.value}'),
          ],
        CardShowProducts(:final products) => [
            for (final p in products) WordKey(quickLabel(p), payload: p.sku),
          ],
        CardResolve() => const <WordKey>[],
      };

  /// Header prompt for the current verdict (empty for resolve).
  String _headerFor(CardVerdict v) => switch (v) {
        CardAskWords() => 'מה אתה מחפש?',
        MergedKeys() => kCardMergedQuestion,
        CardShowProducts() => kPickProductQuestion,
        CardResolve() => '',
      };

  /// Handle a tapped word key, dispatched by its [WordKey.payload]:
  ///  • `'word'`        — seed the pool with the products the word names;
  ///  • `'chip|axis|v'` — narrow by the tapped merged chip (rebuild the predicate
  ///    from the axisId+value data);
  ///  • otherwise       — a PRODUCT key whose payload is the product's sku → open
  ///    the reach-product sheet (resolved by sku, never the non-unique label).
  void _onWordTap(WordKey key) {
    final payload = key.payload;

    if (payload == 'word') {
      final skuSet = <String>{
        for (final p in resolveWord(key.label, cardKeyboardLexicon)) p.sku,
      };
      _pushStep(NewbieStep(
        axisLabel: 'דגם',
        chipLabel: key.label,
        crumbWord: key.label,
        predicate: (p) => skuSet.contains(p.sku),
      ));
      return;
    }

    if (payload is String && payload.startsWith('chip|')) {
      final parts = payload.split('|');
      final axisId = parts[1];
      // value may (in principle) contain a '|'; re-join the remainder so the
      // predicate keys on the exact chip value.
      final value = parts.sublist(2).join('|');
      final src = kHardSignals.firstWhere(
        (s) => s.axisId == axisId,
        orElse: () => const WordSignal(),
      );
      _pushStep(NewbieStep(
        axisLabel: src.axisName,
        chipLabel: value,
        crumbWord: value,
        predicate: _predicateFor(axisId, value),
      ));
      return;
    }

    // A product key (payload = sku) → resolve within the current ShowProducts
    // list and open the existing sheet (same sku-keyed add-path, no new route).
    final v = verdict;
    if (v is! CardShowProducts) return; // defensive — state moved under us
    LipskeyCatalogProduct? picked;
    for (final p in v.products) {
      if (p.sku == payload) {
        picked = p;
        break;
      }
    }
    if (picked != null && openSheetOnResolve) {
      showLipskeyProductSheet(context, picked, v.products);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SELF-GATE: dark unless the flag is on (read once at mount). A behavioral
    // test forces the ON path via [widget.forceLiveForTest] (the flag isn't
    // unit-seedable).
    if (!_live && !widget.forceLiveForTest) return const SizedBox.shrink();

    final v = verdict;
    final keys = _keysFor(v);
    final header = _headerFor(v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BsTokens.space2, 0, BsTokens.space2, 0),
          child: Row(
            children: [
              if (stack.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'חזרה',
                  onPressed: _popStep,
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    header,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        if (keys.isNotEmpty)
          WordKeyboard(words: keys, onWordTap: _onWordTap),
      ],
    );
  }
}
