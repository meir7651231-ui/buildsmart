/// Feature-flag name for the UNIFIED "card-keyboard" engine (#38).
///
/// The runtime gate for the parallel merged-prediction engine
/// ([card_engine.dart]). Mirrors [kWordFinderFlag] exactly: a screen that drives
/// the unified engine self-gates on this name via
/// `ref.watch(featureFlagsProvider).contains(kCardKeyboardFlag)`, read ONCE at
/// mount (not per-keystroke — see the build plan §1.6, the flag-race guard).
///
/// OFF by default (no operator `enable`, no test seed) → the unified engine is
/// never reached and the live word_finder is byte-identical. The owner-gated
/// cut-over (build plan Phase 6) is what eventually turns it on.
const String kCardKeyboardFlag = 'kCardKeyboard';
