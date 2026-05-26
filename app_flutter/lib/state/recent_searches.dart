import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Max recent searches kept (newest first).
const int kMaxRecentSearches = 8;

/// Pure: return [current] with [query] moved/inserted to the front,
/// de-duplicated and capped to [max] (newest first). Empty/blank queries are
/// ignored. Never mutates [current].
List<String> addRecentSearch(List<String> current, String query,
    {int max = kMaxRecentSearches,}) {
  final q = query.trim();
  if (q.isEmpty) return List<String>.from(current);
  final list = List<String>.from(current)
    ..remove(q)
    ..insert(0, q);
  if (list.length > max) list.removeRange(max, list.length);
  return list;
}

/// Recent search queries, newest first, persisted across launches.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super(const []) {
    _load();
  }

  static const _key = 'bs.recent-searches.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) state = list;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  void add(String query) {
    state = addRecentSearch(state, query);
    _persist();
  }

  void remove(String query) {
    state = [...state]..remove(query);
    _persist();
  }

  void clear() {
    state = const [];
    _persist();
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
  (_) => RecentSearchesNotifier(),
);
