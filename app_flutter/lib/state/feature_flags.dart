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
  static const Set<String> _forcedOnFlags =
      kEnableWordFinderDemo ? <String>{'kWordFinder'} : <String>{};

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    final loaded = list?.toSet() ?? <String>{};
    // Build-time forced flags always win — even over a returning visitor's
    // saved prefs — so the demo deploy reliably shows the feature.
    state = {...loaded, ..._forcedOnFlags};
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
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
