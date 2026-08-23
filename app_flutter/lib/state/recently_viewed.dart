import 'package:buildsmart/features/card_keyboard/card_keyboard_flag.dart'
    show kCardKeyboardFlag;
import 'package:buildsmart/features/card_keyboard/scoped_prefs_key.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/feature_flags.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Most-recently-viewed product SKUs, newest first, de-duplicated and capped.
/// Persisted to SharedPreferences so history survives a refresh / restart.
/// Roadmap step 66.
///
/// IDENTITY SCOPING (round-2 blocker-5): when the unified finder is on, the prefs
/// key is namespaced by the active uid so a SHARED fleet tablet never bleeds
/// employee A's history to B. With the flag OFF (production today) [_uid] is null,
/// the key is the legacy global key, the uid is not even watched, and a corrupt
/// read no longer throws — i.e. byte-identical, just hardened.
class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  RecentlyViewedNotifier([this._uid]) : super(const []) {
    _ready = _load();
  }

  /// The active identity for the scoped key, or null for the legacy global key.
  final String? _uid;

  static const _base = 'bs.recently-viewed.v1';
  static const cap = 20;

  bool _userTouched = false;

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
      // list in (read-only; the global key is left intact for a clean rollback).
      if (list == null && _uid != null) list = prefs.getStringList(_base);
    } on Object catch (_) {
      list = null; // a type-corrupt key must NEVER throw an unhandled Future
    }
    if (_userTouched) return;
    if (list != null) state = List.unmodifiable(list);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  /// Record [sku] as just-viewed: move it to the front, drop any earlier copy,
  /// and trim to [cap]. No-op for an empty sku.
  void touch(String? sku) {
    if (sku == null || sku.isEmpty) return;
    _userTouched = true;
    final next = [sku, ...state.where((s) => s != sku)];
    state = List.unmodifiable(
        next.length > cap ? next.sublist(0, cap) : next);
    _persist();
  }

  void clear() {
    _userTouched = true;
    if (state.isEmpty) return;
    state = const [];
    _persist();
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<String>>((ref) {
  // Scope the history by identity ONLY when the unified finder is on (round-2
  // blocker-5); flag-OFF keeps today's single global key → byte-identical, and the
  // uid is not even watched, so production behaviour is unchanged.
  final scoped = ref.watch(featureFlagsProvider).contains(kCardKeyboardFlag);
  final uid = scoped ? ref.watch(currentUidProvider) : null;
  return RecentlyViewedNotifier(uid);
});

/// Pure list transform extracted for unit-testing the move-to-front + cap
/// invariant without touching SharedPreferences.
List<String> recentlyViewedNext(List<String> current, String sku,
    {int cap = RecentlyViewedNotifier.cap}) {
  if (sku.isEmpty) return current;
  final next = [sku, ...current.where((s) => s != sku)];
  return next.length > cap ? next.sublist(0, cap) : next;
}
