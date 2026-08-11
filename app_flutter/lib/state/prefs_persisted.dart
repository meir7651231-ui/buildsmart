import 'dart:convert';

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

/// Opt-in persistence for a `Map<String, String>`-valued [StateNotifier], stored
/// as a JSON object. Factors out the byte-identical tolerant load + jsonEncode
/// persist shared by `ab_experiments` and `card_selection` — see
/// `knowledge/logic/DUPLICATION.md`.
mixin StringMapPrefsPersisted on StateNotifier<Map<String, String>> {
  String get persistKey;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(persistKey);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        state = m.map((k, v) => MapEntry(k, v as String));
      } on Object catch (_) {
        // corrupt/legacy payload — keep default state
      }
    }
  }

  Future<void> persistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(persistKey, jsonEncode(state));
  }
}

/// Opt-in persistence for a `List<E>`-valued [StateNotifier] of json-encodable
/// records, stored as a JSON array. Factors out the tolerant list load +
/// `jsonEncode(state.map(toJson))` persist shared by `card_versions` and
/// `draft_quote` — see `knowledge/logic/DUPLICATION.md`. The per-element codec
/// is injected (each module keeps its own `fromJson`/`toJson`).
mixin JsonListPrefsPersisted<E> on StateNotifier<List<E>> {
  String get persistKey;
  E decodeElement(Map<String, dynamic> json);
  Map<String, dynamic> encodeElement(E element);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(persistKey);
    if (raw != null) {
      try {
        state = (jsonDecode(raw) as List)
            .map((e) => decodeElement(e as Map<String, dynamic>))
            .toList();
      } on Object catch (_) {
        // corrupt/legacy payload — keep default state
      }
    }
  }

  Future<void> persistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        persistKey, jsonEncode(state.map(encodeElement).toList()));
  }
}

/// Opt-in for a persisting [StateNotifier] whose `set state` override
/// auto-persists AND must guard against an async `_load` clobbering a mutation
/// that arrived before SharedPreferences resolved (the `bool _loaded` latch —
/// see `test/state_loaded_guard_test.dart` and hard-case #6 in DUPLICATION.md).
///
/// The setter (`_loaded=true; super.state; persistState()`) and the latch live
/// here once; each engine keeps its own [persistState] and calls [seedIfUnloaded]
/// / [markLoaded] from its bespoke `_load`. Behaviour is identical to the
/// hand-written invariant it replaces.
mixin PersistOnWrite<T> on StateNotifier<T> {
  bool _loaded = false;

  /// The engine's own persist (was its `_persist`).
  Future<void> persistState();

  @override
  set state(T value) {
    _loaded = true; // a mutation happened — block any pending _load
    super.state = value;
    persistState();
  }

  /// Apply a persisted [value] only if no mutation has arrived yet, then latch.
  /// (Bypasses the setter so loading does not re-persist.) Identical to the
  /// hand-written `if (!_loaded) { super.state = value; } _loaded = true;`.
  void seedIfUnloaded(T value) {
    if (!_loaded) super.state = value;
    _loaded = true;
  }

  /// Latch as loaded without seeding (the empty / corrupt `_load` paths).
  void markLoaded() => _loaded = true;
}
