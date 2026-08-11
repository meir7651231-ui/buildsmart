import 'package:buildsmart/state/prefs_persisted.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SmartProducts the user is currently comparing side-by-side (foundation for
/// a future "compare 2–3 products" UI; orthogonal to step 76 saved-versions
/// which is per-product). Persisted Set<String> of productKeys, capped to
/// [maxItems] (default 4 — typical compare-3-or-4 drawer). Roadmap step 76
/// adjacent (own slot in Phase 7-ish; partial — state layer only, UI TBD).
class ComparisonSetNotifier extends StateNotifier<Set<String>>
    with StringSetPrefsPersisted {
  ComparisonSetNotifier({this.maxItems = 4}) : super(const {}) {
    loadFromPrefs();
  }

  @override
  String get persistKey => _key;
  final int maxItems;
  static const _key = 'bs.comparison-set.v1';



  bool contains(String productKey) => state.contains(productKey);

  /// Add a productKey. Returns false (and leaves state untouched) when the
  /// set is already at [maxItems] and the key isn't already in it. Idempotent
  /// for an existing key (returns true, no churn).
  bool add(String productKey) {
    if (state.contains(productKey)) return true;
    if (state.length >= maxItems) return false;
    state = {...state, productKey};
    persistToPrefs();
    return true;
  }

  void remove(String productKey) {
    if (!state.contains(productKey)) return;
    state = {...state}..remove(productKey);
    persistToPrefs();
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
    persistToPrefs();
  }
}

final comparisonSetProvider =
    StateNotifierProvider<ComparisonSetNotifier, Set<String>>(
  (_) => ComparisonSetNotifier(),
);
