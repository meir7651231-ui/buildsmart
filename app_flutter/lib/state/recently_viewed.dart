import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Most-recently-viewed product SKUs, newest first, de-duplicated and capped.
/// Persisted to SharedPreferences so history survives a refresh / restart.
/// Roadmap step 66.
class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  RecentlyViewedNotifier() : super(const []) {
    _load();
  }

  static const _key = 'bs.recently-viewed.v1';
  static const cap = 20;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
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
    final next = [sku, ...state.where((s) => s != sku)];
    state = List.unmodifiable(
        next.length > cap ? next.sublist(0, cap) : next);
    _persist();
  }

  void clear() {
    if (state.isEmpty) return;
    state = const [];
    _persist();
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<String>>(
  (_) => RecentlyViewedNotifier(),
);

/// Pure list transform extracted for unit-testing the move-to-front + cap
/// invariant without touching SharedPreferences.
List<String> recentlyViewedNext(List<String> current, String sku,
    {int cap = RecentlyViewedNotifier.cap}) {
  if (sku.isEmpty) return current;
  final next = [sku, ...current.where((s) => s != sku)];
  return next.length > cap ? next.sublist(0, cap) : next;
}
