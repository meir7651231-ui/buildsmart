import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-product brand-selection counts. Each time the user picks a brand on a
/// SmartProduct card, the count for that (productKey, brandName) pair goes up
/// by 1. A future "smart default" can use `favouriteFor(productKey)` to pre-
/// select the most-used brand. Roadmap step 51 (state layer only; wiring TBD).
class BrandHistoryNotifier extends StateNotifier<Map<String, Map<String, int>>> {
  BrandHistoryNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.brand-history.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      state = m.map((k, v) => MapEntry(
            k,
            (v as Map<String, dynamic>)
                .map((bk, bv) => MapEntry(bk, (bv as num).toInt())),
          ));
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  void record(String productKey, String brandName) {
    final current = Map<String, Map<String, int>>.from(state);
    final brands = Map<String, int>.from(current[productKey] ?? const {});
    brands[brandName] = (brands[brandName] ?? 0) + 1;
    current[productKey] = brands;
    state = current;
    _persist();
  }

  String? favouriteFor(String productKey) {
    final brands = state[productKey];
    if (brands == null || brands.isEmpty) return null;
    final entries = brands.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value); // most-picked first
        return cmp != 0 ? cmp : a.key.compareTo(b.key); // tiebreak alpha
      });
    return entries.first.key;
  }

  Map<String, int> countsFor(String productKey) =>
      Map<String, int>.from(state[productKey] ?? const {});

  int get totalPicks =>
      state.values.fold(0, (s, m) => s + m.values.fold<int>(0, (a, b) => a + b));
}

final brandHistoryProvider =
    StateNotifierProvider<BrandHistoryNotifier, Map<String, Map<String, int>>>(
  (_) => BrandHistoryNotifier(),
);
