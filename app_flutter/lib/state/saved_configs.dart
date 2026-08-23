import 'package:buildsmart/features/card_keyboard/card_keyboard_flag.dart'
    show kCardKeyboardFlag;
import 'package:buildsmart/features/card_keyboard/scoped_prefs_key.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/feature_flags.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Product+brand configurations the user saved as a favourite / template,
/// keyed `"<productKey>#<brandName>"`. Persisted so saved configs survive a
/// refresh. Roadmap step 47.
///
/// IDENTITY SCOPING (round-2 blocker-5): when the unified finder is on, the prefs
/// key is namespaced by the active uid so a SHARED fleet tablet never bleeds
/// employee A's saved configs to B. With the flag OFF (production today) [_uid]
/// is null, the key is the legacy global key, the uid is not even watched, and a
/// corrupt read no longer throws — i.e. byte-identical, just hardened.
class SavedConfigsNotifier extends StateNotifier<Set<String>> {
  SavedConfigsNotifier([this._uid]) : super(const {}) {
    _ready = _load();
  }

  /// The active identity for the scoped key, or null for the legacy global key.
  final String? _uid;

  static const _base = 'bs.saved-configs.v1';

  static String keyFor(String productKey, String brandName) =>
      '$productKey#$brandName';

  /// @visibleForTesting — completes when the constructor's async [_load] settles,
  /// so a test can deterministically await the first read.
  @visibleForTesting
  Future<void> get ready => _ready;
  late final Future<void> _ready;

  String get _key => scopedPrefsKey(_base, _uid);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? list;
    try {
      list = prefs.getStringList(_key);
      // First scoped load with no scoped data yet → migrate the legacy global
      // set in (read-only; the global key is left intact for a clean rollback).
      if (list == null && _uid != null) list = prefs.getStringList(_base);
    } on Object catch (_) {
      list = null; // a type-corrupt key must NEVER throw an unhandled Future
    }
    if (list != null) state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  bool isSaved(String productKey, String brandName) =>
      state.contains(keyFor(productKey, brandName));

  void toggle(String productKey, String brandName) {
    final k = keyFor(productKey, brandName);
    state = state.contains(k) ? ({...state}..remove(k)) : {...state, k};
    _persist();
  }
}

final savedConfigsProvider =
    StateNotifierProvider<SavedConfigsNotifier, Set<String>>(
  (ref) {
    // Scope the saved configs by identity ONLY when the unified finder is on
    // (round-2 blocker-5); flag-OFF keeps today's single global key →
    // byte-identical, and the uid is not even watched, so production behaviour is
    // unchanged.
    final scoped = ref.watch(featureFlagsProvider).contains(kCardKeyboardFlag);
    final uid = scoped ? ref.watch(currentUidProvider) : null;
    return SavedConfigsNotifier(uid);
  },
);
