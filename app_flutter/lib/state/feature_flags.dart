import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  FeatureFlagsNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.feature-flags.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) state = list.toSet();
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
