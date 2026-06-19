// WordFinderHome — the unified "one keyboard, two modes" entry.
//
// FINAL seam of the word-finder swarm: a single flag-gated host that puts the
// NEWBIE cascade ([WordFinderScreen] — word → narrow → product) and the QUICK
// re-order pad ([QuickPadScreen] — fast quantity keys for most-used products)
// behind ONE entry with a MANUAL toggle between them.
//
// SCOPE — manual, not auto. Auto-adaptation between the two modes (e.g. show
// the quick pad once the user has favorites, fall back to the cascade for a
// blank-slate user) is intentionally OUT of scope: it is an owner design
// decision. A MANUAL toggle is the safe default — the user is always in
// control of which surface they see, and the default lands on the cascade
// (newbie-first, per 'מתחילים פשוט-לכולם').
//
// SELF-GATING: like its children ([WordFinderScreen] / [QuickPadScreen]) and
// `SmartSuggestionStrip`, this host renders nothing (a zero-height
// `SizedBox.shrink`) unless `kWordFinderFlag` is enabled. It is safe to land
// dark; wiring it into a real navigation seam is a SEPARATE later step.
//
// LAYOUT: Directionality.rtl > Column([ toggle row, Expanded(IndexedStack) ]).
// The toggle row is two PLAIN-TEXT segment keys (NO Material icons) — the
// active one drawn with the brand accent. Each child screen brings its own
// Directionality + Material/Scaffold; we wrap the body in [Expanded] so
// [QuickPadScreen]'s Scaffold (which needs bounded height) and
// [WordFinderScreen]'s Spacer-bearing Column both lay out cleanly inside the
// host Column.
//
// STATE PRESERVATION: the body is an [IndexedStack] (not a switch that returns
// one child), so BOTH child screens stay mounted across a toggle and keep their
// in-progress State — the cascade's answered-step stack / typed query and the
// quick pad's per-item quantities survive switching modes and switching back,
// instead of resetting each time the user flips the toggle.

import 'package:buildsmart/features/word_finder/quick_pad_screen.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/features/word_finder/word_finder_screen.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which surface the host is currently showing.
///
/// [cascade] = the newbie product-finder ([WordFinderScreen]); [quickPad] = the
/// quick re-order pad ([QuickPadScreen]). The default is [cascade]
/// (newbie-first).
enum _Mode { cascade, quickPad }

/// The flag-gated, two-mode word-finder host with a manual toggle.
///
/// Holds the active [_Mode] as widget state and swaps the body between the two
/// child screens. Switching is driven ONLY from this host's toggle row (and
/// from the quick pad's own `מצב רגיל` utility key, which calls back into the
/// host to return to the cascade); the cascade screen has no switch affordance
/// of its own.
class WordFinderHome extends ConsumerStatefulWidget {
  const WordFinderHome({super.key});

  @override
  ConsumerState<WordFinderHome> createState() => _WordFinderHomeState();
}

class _WordFinderHomeState extends ConsumerState<WordFinderHome> {
  /// The active surface. Defaults to the newbie cascade ('מתחילים פשוט-לכולם').
  _Mode _mode = _Mode.cascade;

  // OWNER-REVIEW copy — segment labels. Plain Hebrew text, no icons.
  static const String _cascadeLabel = 'מצא לי'; // OWNER-REVIEW (was 'חפש לי')
  static const String _quickPadLabel = 'המהיר שלי'; // OWNER-REVIEW

  void _setMode(_Mode mode) {
    if (_mode == mode) return; // no churn
    setState(() => _mode = mode);
  }

  /// One plain-text segment key. NO Material icon: it is a [BsKey] over a
  /// [KbKey] of [KeyKind.letter], which [BsKey] draws as plain text (see
  /// `BsKey._iconFor` → null for `KeyKind.letter`). The `active` segment gets
  /// the brand accent fill (`isAccent: true`).
  ///
  /// A11Y: the active state is colour-only on the key face, so a [Semantics]
  /// wrapper carries `selected:` for a screen reader — it announces "selected"
  /// on the active segment of this two-way toggle (mirrors a SegmentedButton's
  /// per-segment selected semantics). `container: false` lets it merge with the
  /// [BsKey]'s own `button: true` Semantics rather than splitting the node.
  Widget _segment(String label, _Mode mode) {
    return Expanded(
      child: Semantics(
        selected: _mode == mode,
        container: false,
        child: BsKey(
          // KeyKind.letter → rendered as plain text, no icon.
          model: KbKey(label),
          isAccent: _mode == mode,
          onTap: () => _setMode(mode),
        ),
      ),
    );
  }

  /// The two child surfaces, kept side-by-side in an [IndexedStack] so BOTH
  /// stay mounted across a toggle and PRESERVE their in-progress State (the
  /// cascade's answered-step stack / typed query; the pad's per-item
  /// quantities). Only the [_mode]-selected child is shown; the other is laid
  /// out (zero-size) but retained, so flipping the toggle back finds it exactly
  /// as the user left it instead of rebuilt from scratch.
  ///
  /// Each child self-gates and brings its own Directionality + Material/Scaffold,
  /// so nesting is fine; the build wraps the whole stack in [Expanded]. Child
  /// order is fixed ([cascade, quickPad]) and matches [_Mode.index], so the
  /// selected index is the enum's own index.
  Widget _body() {
    return IndexedStack(
      index: _mode.index,
      sizing: StackFit.expand,
      children: [
        // [_Mode.cascade] (index 0). No onSwitchMode param — the cascade has no
        // switch affordance of its own; switching is driven only from the host
        // toggle (+ the pad's callback below).
        const WordFinderScreen(),
        // [_Mode.quickPad] (index 1). The pad's `מצב רגיל` utility key flips back
        // to the cascade via this callback.
        QuickPadScreen(onSwitchMode: () => _setMode(_Mode.cascade)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // SELF-GATE first — render nothing unless the flag is on. Mirrors the
    // `word_finder_screen.dart` / `quick_pad_screen.dart`
    // `.contains(flag) → SizedBox.shrink` idiom.
    final on = ref.watch(featureFlagsProvider).contains(kWordFinderFlag);
    if (!on) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Toggle row: two plain-text segments, active one accented ──────
          Material(
            color: BsTokens.surfaceMid,
            child: Padding(
              padding: const EdgeInsets.all(BsTokens.space1),
              child: Row(
                children: [
                  _segment(_cascadeLabel, _Mode.cascade),
                  const SizedBox(width: BsTokens.space1),
                  _segment(_quickPadLabel, _Mode.quickPad),
                ],
              ),
            ),
          ),

          // ── Active surface — wrapped in Expanded so the child's own
          //    Scaffold/Spacer-bearing Column gets bounded height. ───────────
          Expanded(child: _body()),
        ],
      ),
    );
  }
}
