import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opt-in persistence for an enum-valued [StateNotifier], persisted by name in
/// SharedPreferences. It factors out the load / persist / set boilerplate that
/// was copy-pasted across the enum-mode notifiers (`card_detail_mode`,
/// `project_mode`, `profession_mode`) — see `knowledge/logic/DUPLICATION.md`.
///
/// Behaviour is byte-identical to the hand-written versions it replaces:
///   • [readPersistedEnum] = `getString(key)` → the value whose `.name` matches
///     (null when absent or unknown), so the caller keeps its current default.
///   • [persistEnum]       = `setString(key, state.name)`.
///   • [setPersisted]      = no-op when unchanged, else `state = v` then persist.
///
/// A notifier with a bespoke load (e.g. `profession_mode`, which derives an
/// initial value from onboarding) keeps its own `_load` and adopts only
/// [persistEnum] / [setPersisted]. Never force a genuine variant through the
/// mixin — that is the safety rule.
mixin EnumPrefsPersisted<T extends Enum> on StateNotifier<T> {
  /// The SharedPreferences key (was the module's `static const _key`).
  String get persistKey;

  /// The enum's `values` — used to resolve a stored name back to a constant.
  List<T> get persistValues;

  /// The stored constant (matched by `.name`), or null if absent/unknown.
  Future<T?> readPersistedEnum() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(persistKey);
    if (s == null) return null;
    for (final v in persistValues) {
      if (v.name == s) return v;
    }
    return null;
  }

  /// Persist the current [state] by its `.name`.
  Future<void> persistEnum() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(persistKey, state.name);
  }

  /// Idempotent set: a no-op when [mode] equals the current [state] (no churn,
  /// no write), otherwise updates the state and persists — identical to the
  /// hand-written `set` each notifier carried.
  void setPersisted(T mode) {
    if (state == mode) return;
    state = mode;
    persistEnum();
  }
}

/// Opt-in persistence for a `Set<String>`-valued [StateNotifier], stored as a
/// string list in SharedPreferences. Factors out the byte-identical
/// getStringList→toSet load and setStringList(toList) persist shared by the
/// UI-state set notifiers (`comparison_set`, `stage_progress`,
/// `hidden_catalog_sections`, `onboarding_progress`) — see
/// `knowledge/logic/DUPLICATION.md`. Behaviour is identical to the hand-written
/// versions: a missing list keeps the current default.
mixin StringSetPrefsPersisted on StateNotifier<Set<String>> {
  /// The SharedPreferences key (was the module's `_key`).
  String get persistKey;

  /// Load the stored list into the set; a missing value keeps the default.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(persistKey);
    if (list != null) state = list.toSet();
  }

  /// Persist the set as a string list.
  Future<void> persistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(persistKey, state.toList());
  }
}
