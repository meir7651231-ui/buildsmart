// 🃏 Card-keyboard sheet — STEP 4 of the "keyboard-becomes-the-card" fusion.
//
// Surfaces the assembled keyboard-with-tools (the step-1/2/3 [BsKeyboardHost]:
// grid ▦ + gear ⚙️ tool toggles, the no-scroll prediction row, the typed-tool
// navigation seam) on the HOME as a 'card keyboard' bottom sheet whose
// prediction row is LIVE from the word-finder engine. Behind the SAME flag
// ([kKeyboardToolStrip], default false), so when the flag is off the home is
// byte-identical (the flagged launcher spread is simply not built).
//
// LAYERING — this is a `screens`-layer file, so unlike the PURE
// `keyboard_predictions.dart` bridge it MAY import the screens/catalog code:
//   • the finder ENGINE ([offerQuestion] / [NewbieStep] / [WordLexicon] /
//     [buildWordLexicon] / [kDivePool]) — to mirror the finder's typed-query
//     narrowing exactly, and
//   • [catalogProductMatchesQuery] (catalog_screen.dart) — the SAME forgiving
//     predicate `_submitQuery` records on its `NewbieStep`.
// [predictionChips] itself stays pure and untouched: we hand it the engine's
// [NewbieQuestion] and it returns the chip labels. Nothing imports this file
// back except `smart_home_screen.dart` (the flagged launcher), so the only
// inbound edge is the home — no new dependency is forced on the engine or the
// pure bridge.
//
// HOW THE LIVE ROW MIRRORS THE FINDER (word_finder_screen.dart):
//   _submitQuery(q): clears the stack, and for a non-empty `q` pushes ONE
//     NewbieStep(axisLabel:'חיפוש', chipLabel:q, crumbWord:q,
//                predicate:(p)=>catalogProductMatchesQuery(p,q)).
//   _pool: filters `_basePool` through every step's predicate.
//   Then `offerQuestion(pool, stack, lexicon, null)` decides the next question,
//   and `offerQuestion` SKIPS its empty-stack AskWords branch precisely because
//   the stack is non-empty → it narrows instead. [cardKeyboardPredictions]
//   reproduces this: empty query → opening words (empty stack); else → filter
//   the pool + build the identical one-step stack, then `offerQuestion` →
//   `predictionChips`.

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/keyboard_predictions.dart'
    show predictionChips;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep, offerQuestion;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon, buildWordLexicon;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery;
import 'package:buildsmart/screens/keyboard_tool_actions.dart'
    show runKeyboardTool;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart' show insertAtCaret;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbTool;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart'
    show BsKeyboardHost;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// LIVE prediction-row chips for the card keyboard, mirroring the finder's
/// typed-query path (`_submitQuery` + `_pool` in word_finder_screen.dart) and
/// passing the engine's verdict through the PURE [predictionChips].
///
/// PUBLIC + TESTABLE (no widgets, no providers): given a typed [query], the
/// [pool] (normally [kDivePool]) and a [lexicon] (normally
/// `buildWordLexicon(kDivePool)`), returns up to [max] short chip labels.
///
///   • `query.trim()` empty → OPENING WORDS: `offerQuestion(pool, [], lexicon,
///     null)` returns `AskWords` (the empty-stack branch) → top lexicon words.
///   • else → NARROW: filter the pool by `catalogProductMatchesQuery(p, query)`
///     and build a one-element stack carrying the EXACT same step
///     `_submitQuery` records — `NewbieStep(axisLabel:'חיפוש', chipLabel:q,
///     crumbWord:q, predicate:(p)=>catalogProductMatchesQuery(p,q))` — so
///     `offerQuestion` skips AskWords and narrows the filtered pool.
///
/// DETERMINISTIC: same (query, pool, lexicon) in ⇒ identical list out (both the
/// pool filter and `offerQuestion`/`predictionChips` are pure).
List<String> cardKeyboardPredictions(
  String query,
  List<LipskeyCatalogProduct> pool,
  WordLexicon lexicon, {
  int max = 4,
}) {
  final q = query.trim();
  if (q.isEmpty) {
    // Empty stack → offerQuestion returns the opening AskWords.
    return predictionChips(
      offerQuestion(pool, const <NewbieStep>[], lexicon, null),
      max: max,
    );
  }
  // Mirror _submitQuery: one step whose predicate IS catalogProductMatchesQuery,
  // over a pool pre-filtered by the same predicate (matches `_pool` applying
  // every step's predicate to the base pool).
  final filtered =
      pool.where((p) => catalogProductMatchesQuery(p, q)).toList();
  final stack = <NewbieStep>[
    NewbieStep(
      axisLabel: 'חיפוש',
      chipLabel: q,
      crumbWord: q,
      predicate: (p) => catalogProductMatchesQuery(p, q),
    ),
  ];
  return predictionChips(
    offerQuestion(filtered, stack, lexicon, null),
    max: max,
  );
}

/// Opens the card-keyboard bottom sheet from the home. Matches the app's
/// modal-sheet idiom (white background, top-rounded 20, `isScrollControlled`
/// so the full keyboard fits above the inset). The sheet captures the home's
/// [context]/[ref] so a tapped tool can close the sheet and THEN navigate on
/// the home's (still-mounted) navigator.
Future<void> openCardKeyboardSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CardKeyboardSheet(homeContext: context, homeRef: ref),
  );
}

/// The sheet body: a read-only field driven by the custom keyboard, with a LIVE
/// prediction row recomputed from the field text on every change. Self-contained
/// and crash-safe: the controller/focus are owned here; [homeContext]/[homeRef]
/// stay valid because the home stays mounted UNDER the sheet.
class _CardKeyboardSheet extends ConsumerStatefulWidget {
  const _CardKeyboardSheet({required this.homeContext, required this.homeRef});

  /// The home's BuildContext — used to navigate AFTER the sheet pops (its own
  /// context is defunct once popped, so tool navigation runs on this one).
  final BuildContext homeContext;

  /// The home's WidgetRef — the state-provider tools ([runKeyboardTool]) read/
  /// write providers through it; valid while the home is mounted under the sheet.
  final WidgetRef homeRef;

  @override
  ConsumerState<_CardKeyboardSheet> createState() => _CardKeyboardSheetState();
}

class _CardKeyboardSheetState extends ConsumerState<_CardKeyboardSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  /// Lexicon built ONCE from the dive pool (pure + deterministic); reused for
  /// every keystroke's recompute so we never rebuild it per change.
  late final WordLexicon _lexicon;

  /// The current prediction-row chips (LIVE: recomputed from `_controller.text`).
  late List<String> _preds;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focus = FocusNode();
    _lexicon = buildWordLexicon(kDivePool);
    _preds = cardKeyboardPredictions('', kDivePool, _lexicon);
    _controller.addListener(_recompute);
  }

  /// Recompute the prediction row from the field text. Cheap (pure pool filter +
  /// engine verdict); guarded by `mounted` so a late listener tick after dispose
  /// can never `setState` on a defunct element.
  void _recompute() {
    if (!mounted) return;
    final next = cardKeyboardPredictions(_controller.text, kDivePool, _lexicon);
    setState(() => _preds = next);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_recompute)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Append a tapped chip (+ a trailing space) at the caret to narrow further;
  /// the controller listener then recomputes the row. [insertAtCaret] leaves the
  /// caret collapsed after the inserted text (and appends when no selection).
  void _onPrediction(String chip) {
    insertAtCaret(_controller, '$chip ');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle (matches the app's grab-pill affordance).
          Padding(
            padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x33000000),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Read-only query field — the custom keyboard drives it, so the OS
          // keyboard never appears. RTL for Hebrew product words.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
              vertical: BsTokens.space2,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              readOnly: true,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'מה לחפש?',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          // The assembled keyboard-with-tools, fed the LIVE finder chips.
          BsKeyboardHost(
            controller: _controller,
            focusNode: _focus,
            // 'done' — close the sheet (the field text is the search seed).
            onSend: () => Navigator.of(context).pop(),
            showToolStrip: true,
            predictions: _preds,
            onPrediction: _onPrediction,
            // Close the sheet FIRST, then navigate on the home's navigator/ref
            // (this sheet's own context is defunct after the pop).
            onTool: (KbTool t) {
              Navigator.of(context).pop();
              runKeyboardTool(widget.homeRef, widget.homeContext, t);
            },
          ),
        ],
      ),
    );
  }
}
