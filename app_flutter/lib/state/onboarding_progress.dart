import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding progress — a persisted `Set<String>` of *hint ids the user has
/// already seen* (and therefore shouldn't see again). Foundation for any future
/// onboarding overlay / first-time tooltip surface.
///
/// Mirrors the `FeatureFlagsNotifier` persistence pattern: async `_load()` in
/// the ctor and `_persist()` after each mutation. Mutations are idempotent —
/// no state churn (and no extra `_persist`) when the hint is already in the
/// desired state.
///
/// Persisted under `'bs.onboarding-progress.v1'` via SharedPreferences
/// `setStringList`/`getStringList`, so it survives a refresh / app restart.
class OnboardingProgressNotifier extends StateNotifier<Set<String>> {
  OnboardingProgressNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.onboarding-progress.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  /// Whether the user has already seen [hintId].
  bool hasSeen(String hintId) => state.contains(hintId);

  /// Idempotent: mark a hint as seen. No state churn if already seen.
  void markSeen(String hintId) {
    if (state.contains(hintId)) return; // idempotent
    state = {...state, hintId};
    _persist();
  }

  /// Has the user seen ALL of the given [hintIds]? Useful for "are we done
  /// onboarding the card?" gates. Vacuously true on an empty iterable.
  bool seenAll(Iterable<String> hintIds) {
    for (final id in hintIds) {
      if (!state.contains(id)) return false;
    }
    return true;
  }

  /// Reset (for debug / "show me the tour again" affordance).
  void reset() {
    if (state.isEmpty) return; // idempotent
    state = const {};
    _persist();
  }
}

final onboardingProgressProvider =
    StateNotifierProvider<OnboardingProgressNotifier, Set<String>>(
  (_) => OnboardingProgressNotifier(),
);
