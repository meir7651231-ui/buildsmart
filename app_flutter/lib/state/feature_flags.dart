import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// True iff the build passed `--dart-define=ENABLE_WORD_FINDER=true` (the
/// buildsmart-il.com demo build). A top-level build-time const — the SAME idiom
/// as `kUseFirebaseBackendFlag` in `data/repositories/backend.dart`, which ships
/// via this mechanism in production. NOTE: `flutter test` does NOT forward
/// --dart-define to library consts (the repo drives such ON branches
/// explicitly), so the ON path is not unit-testable here; `flutter build web`
/// DOES forward it — that is what the deploy uses.
const bool kEnableWordFinderDemo =
    bool.fromEnvironment('ENABLE_WORD_FINDER');

/// True iff the build passed `--dart-define=ENABLE_CARD_KEYBOARD=true` — the
/// A/B demo build for the unified card-keyboard (#38). SAME idiom as
/// [kEnableWordFinderDemo]: default false → 'kCardKeyboard' stays off → the new
/// 'מקלדת חכמה' catalog pill never renders → byte-identical. The live deploy
/// workflows do NOT pass it (the cut-over stays owner-gated); a demo build (or
/// _app_cardkeyboard_demo.dart) flips it to A/B the new finder beside the old.
const bool kEnableCardKeyboardDemo =
    bool.fromEnvironment('ENABLE_CARD_KEYBOARD');

/// Runtime tier name for the עדכונים LIVE-MIRROR keyboard (plan Q4). The floating
/// keyboard's mirror branch is guarded by `kKbLiveMirror ||
/// featureFlagsProvider.isOn(kKbLiveMirrorFlag)`, so the orchestrator can stage
/// the feature ON for a demo WITHOUT a rebuild — `ref.read(
/// featureFlagsProvider.notifier).enable(kKbLiveMirrorFlag)` — exactly like the
/// 'kWordFinder' demo tier. Default OFF (the flag is absent from the persisted
/// set and is not in [FeatureFlagsNotifier._forcedOnFlags]), so a normal build is
/// byte-identical; the compile-time `kKbLiveMirror` const is the other, also-OFF,
/// path. Naming it here keeps callers from stringly-typing the flag.
const String kKbLiveMirrorFlag = 'kKbLiveMirror';

// ── No-Code Studio master gate (studio plan, steps 4–5) ──────────────────────
// The Studio's runtime flag-name is `kStudioFlagName` ('kStudio', in
// `state/studio/studio_flags.dart`), with the compile-time twin `kStudioFlag`
// (`bool.fromEnvironment('STUDIO')`). Like [kKbLiveMirrorFlag], 'kStudio' is
// INTENTIONALLY absent from [FeatureFlagsNotifier._forcedOnFlags] below — the only
// runtime path is the owner-staged `enable('kStudio')`, so a normal build stays
// default-OFF / answer-equivalent. (studio_flags_test pins it absent from a fresh
// notifier.) OWNER-REVIEW: the Studio is owner-gated — never force-enable 'kStudio'.

/// Feature-flag infrastructure (ROADMAP step 10).
///
/// A persisted `Set<String>` of *enabled* flag names. The set survives a refresh
/// / app restart via SharedPreferences (`bs.feature-flags.v1`). Mirrors the
/// `HiddenCatalogSectionsNotifier` pattern: async `_load()` in the ctor and
/// `_persist()` after each mutation. Mutations are idempotent — no state churn
/// (and no extra `_persist`) when the flag is already in the desired state.
///
/// Intent: lets us toggle a new-vs-old card path (and any future A/B surface)
/// safely without touching consumer code — call `isOn('<flag>')` at the branch
/// point.
class FeatureFlagsNotifier extends StateNotifier<Set<String>> {
  FeatureFlagsNotifier() : super(_forcedOnFlags) {
    _load();
  }

  static const _key = 'bs.feature-flags.v1';

  /// Flags FORCE-ENABLED at build time, for scoped demo deploys. Empty by
  /// default, so a normal build (the app, Android, the real site) is
  /// byte-identical — flags stay prefs-driven and default-off. The
  /// buildsmart-il.com web build (firebase-hosting.yml) passes
  /// `--dart-define=ENABLE_WORD_FINDER=true` → [kEnableWordFinderDemo] is true →
  /// 'kWordFinder' (== kWordFinderFlag) turns ON, so the 'מאתר חכם' demo is
  /// visible THERE ONLY. Reversible: drop the dart-define → back to default-off.
  // OWNER-REVIEW: build-time demo enablement of the word-finder.
  //
  // The two A/B DEMO surfaces (word-finder + card-keyboard #38), each behind its
  // own dart-define. [kKbLiveMirrorFlag] ('kKbLiveMirror') is intentionally NOT
  // force-enabled here even under a demo define (plan Q4):
  // its compile-time twin is the separate `kKbLiveMirror` const
  // (== bool.fromEnvironment('KB_LIVE_MIRROR'), in
  // widgets/smart_input/keyboard/bs_keyboard_host.dart), and the live-mirror
  // guard is `kKbLiveMirror || featureFlags.isOn(kKbLiveMirrorFlag)`. So the
  // two OFF-by-default paths stay distinct: the compile-only const (its own
  // dart-define) and the runtime tier reached SOLELY via a no-rebuild
  // `enable(kKbLiveMirrorFlag)`. Adding it to this set would conflate the two
  // and break the default-OFF assumption that
  // test/screens/keyboard_updates_deriver_test.dart relies on.
  static const Set<String> _forcedOnFlags = <String>{
    if (kEnableWordFinderDemo) 'kWordFinder',
    if (kEnableCardKeyboardDemo) 'kCardKeyboard',
  };

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final list = prefs.getStringList(_key);
    final loaded = list?.toSet() ?? <String>{};
    // Build-time forced flags always win — even over a returning visitor's
    // saved prefs — so the demo deploy reliably shows the feature.
    final next = {...loaded, ..._forcedOnFlags};
    // Emit ONLY on a real content change. `state = {...}` always makes a fresh
    // Set identity; when the content is unchanged (e.g. empty→empty) Riverpod
    // still sees a "change" and rebuilds every dependent provider. That
    // spuriously recreated productFavoritesProvider mid-flight and clobbered a
    // just-toggled SKU (the load-race the guard tests assert against). No-op
    // when equal → no needless rebuild.
    if (setEquals(next, state)) return;
    state = next;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await prefs.setStringList(_key, state.toList());
  }

  bool isOn(String flag) => state.contains(flag);

  void enable(String flag) {
    if (state.contains(flag)) return; // idempotent
    state = {...state, flag};
    _persist();
  }

  void disable(String flag) {
    if (!state.contains(flag)) return; // idempotent
    state = {...state}..remove(flag);
    _persist();
  }

  void toggle(String flag) =>
      state.contains(flag) ? disable(flag) : enable(flag);
}

final featureFlagsProvider =
    StateNotifierProvider<FeatureFlagsNotifier, Set<String>>(
  (_) => FeatureFlagsNotifier(),
);
