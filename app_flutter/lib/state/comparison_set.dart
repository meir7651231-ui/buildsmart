import 'package:buildsmart/data/repositories/comparison_sets_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SmartProducts the user is currently comparing side-by-side (foundation for
/// a future "compare 2–3 products" UI; orthogonal to step 76 saved-versions
/// which is per-product). Persisted `Set<String>` of productKeys, capped to
/// [maxItems] (default 4 — typical compare-3-or-4 drawer). Roadmap step 76
/// adjacent (own slot in Phase 7-ish; partial — state layer only, UI TBD).
class ComparisonSetNotifier extends StateNotifier<Set<String>> {
  ComparisonSetNotifier({this.maxItems = 4, ComparisonSetsRepository? repo})
      : _repo = repo,
        super(const {}) {
    _load();
  }

  /// The server store for the compare set (`comparisonSets/{uid}`) when
  /// USER_DATA_SERVER is on for a real signed-in user; null (the default) ⇒ the
  /// SharedPreferences path below, byte-identical to before. Injected by
  /// [comparisonSetProvider].
  final ComparisonSetsRepository? _repo;

  final int maxItems;
  static const _key = 'bs.comparison-set.v1';

  /// True once any mutation has been applied (or _load completes). Guards against
  /// _load clobbering a mutation that arrived before the store resolved.
  bool _loaded = false;

  @override
  set state(Set<String> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
  }

  Future<void> _load() async {
    final repo = _repo;
    if (repo != null) {
      // Server path (USER_DATA_SERVER): the set lives at `comparisonSets/{uid}`.
      try {
        final keys = await repo.load(repo.currentUid);
        if (!_loaded) {
          super.state = keys; // bypass setter so load never re-persists
          _loaded = true;
        }
      } on Object catch (_) {
        _loaded = true;
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null) {
      _loaded = true;
      return;
    }
    if (!_loaded) {
      super.state = list.toSet(); // bypass setter so we don't re-persist on load
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    final repo = _repo;
    if (repo != null) {
      // Server path: mirror the whole set to `comparisonSets/{uid}`.
      try {
        await repo.save(repo.currentUid, state);
      } on Object catch (_) {}
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, state.toList());
    } on Object catch (_) {}
  }

  bool contains(String productKey) => state.contains(productKey);

  /// Add a productKey. Returns false (and leaves state untouched) when the
  /// set is already at [maxItems] and the key isn't already in it. Idempotent
  /// for an existing key (returns true, no churn).
  bool add(String productKey) {
    if (state.contains(productKey)) return true;
    if (state.length >= maxItems) return false;
    state = {...state, productKey};
    _persist();
    return true;
  }

  void remove(String productKey) {
    if (!state.contains(productKey)) return;
    state = {...state}..remove(productKey);
    _persist();
  }

  void toggle(String productKey) {
    if (state.contains(productKey)) {
      remove(productKey);
    } else {
      add(productKey);
    }
  }

  void clear() {
    if (state.isEmpty) return;
    state = const {};
    _persist();
  }
}

final comparisonSetProvider =
    StateNotifierProvider<ComparisonSetNotifier, Set<String>>(
  (ref) => ComparisonSetNotifier(repo: ref.watch(comparisonSetsRepositoryProvider)),
);
