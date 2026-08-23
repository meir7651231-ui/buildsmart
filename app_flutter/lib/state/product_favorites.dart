import 'package:buildsmart/features/card_keyboard/card_keyboard_flag.dart'
    show kCardKeyboardFlag;
import 'package:buildsmart/features/card_keyboard/scoped_prefs_key.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/feature_flags.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pinned ("starred") product SKUs, persisted to SharedPreferences so the live
/// ★ survives a refresh / restart.
///
/// IDENTITY SCOPING (round-2 blocker-5): when the unified finder is on, the prefs
/// key is namespaced by the active uid so a SHARED fleet tablet never bleeds
/// employee A's favorites to B. With the flag OFF (production today) [_uid] is
/// null, the key is the legacy global key, the uid is not even watched, and a
/// corrupt read no longer throws — i.e. byte-identical, just hardened.
class ProductFavoritesNotifier extends StateNotifier<Set<String>> {
  ProductFavoritesNotifier([this._uid]) : super(const {}) {
    _ready = _load();
  }

  /// The active identity for the scoped key, or null for the legacy global key.
  final String? _uid;

  static const _base = 'bs.product-favorites.v1';

  /// `true` once a mutating method (toggle) has written state. The provider is
  /// lazy, so the constructor's async `_load()` can resolve AFTER a synchronous
  /// user write and clobber it. This one-shot guard makes a late `_load()`
  /// non-destructive once the user has touched state.
  bool _userTouched = false;

  /// @visibleForTesting — completes when the constructor's async [_load] settles,
  /// so a test can deterministically await the first read.
  @visibleForTesting
  Future<void> get ready => _ready;
  late final Future<void> _ready;

  String get _key => scopedPrefsKey(_base, _uid);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    List<String>? list;
    try {
      list = prefs.getStringList(_key);
      // First scoped load with no scoped data yet → migrate the legacy global
      // list in (read-only; the global key is left intact for a clean rollback).
      if (list == null && _uid != null) list = prefs.getStringList(_base);
    } on Object catch (_) {
      list = null; // a type-corrupt key must NEVER throw an unhandled Future
    }
    if (_userTouched) return;
    if (list != null) state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    // The notifier can be disposed during this async gap (test teardown / scope
    // rebuild); reading `state` after dispose throws a StateError. Guard it — in
    // production the notifier outlives the write, so this stays a no-op there.
    if (!mounted) return;
    await prefs.setStringList(_key, state.toList());
  }

  void toggle(String sku) {
    _userTouched = true;
    if (state.contains(sku)) {
      state = {...state}..remove(sku);
    } else {
      state = {...state, sku};
    }
    _persist();
  }

  bool isFavorite(String sku) => state.contains(sku);
}

final productFavoritesProvider =
    StateNotifierProvider<ProductFavoritesNotifier, Set<String>>((ref) {
  // Scope the favorites by identity ONLY when the unified finder is on (round-2
  // blocker-5); flag-OFF keeps today's single global key → byte-identical, and the
  // uid is not even watched, so production behaviour is unchanged.
  // `.select` so this notifier REBUILDS only when the scoping actually flips
  // (flag toggled / uid changed), NOT on every equal featureFlagsProvider
  // re-emit — which would spin up a fresh notifier mid-flight and clobber a
  // just-made toggle (see state_loadrace_guards_test).
  final scoped = ref.watch(
    featureFlagsProvider.select((f) => f.contains(kCardKeyboardFlag)),
  );
  final uid = scoped ? ref.watch(currentUidProvider) : null;
  return ProductFavoritesNotifier(uid);
});
