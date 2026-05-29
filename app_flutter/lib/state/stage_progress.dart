import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which install stages the user has marked "done", keyed `"<productKey>#<idx>"`
/// so progress is per-product. Persisted to SharedPreferences so a half-finished
/// install survives a refresh / restart. Roadmap step 31.
class StageProgressNotifier extends StateNotifier<Set<String>> {
  StageProgressNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.stage-progress.v1';

  static String keyFor(String productKey, int stageIndex) =>
      '$productKey#$stageIndex';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  bool isDone(String productKey, int stageIndex) =>
      state.contains(keyFor(productKey, stageIndex));

  void toggle(String productKey, int stageIndex) {
    final k = keyFor(productKey, stageIndex);
    state = state.contains(k)
        ? ({...state}..remove(k))
        : {...state, k};
    _persist();
  }

  /// How many of [stageCount] stages are done for [productKey].
  int doneCount(String productKey, int stageCount) {
    var n = 0;
    for (var i = 0; i < stageCount; i++) {
      if (isDone(productKey, i)) n++;
    }
    return n;
  }
}

final stageProgressProvider =
    StateNotifierProvider<StageProgressNotifier, Set<String>>(
  (_) => StageProgressNotifier(),
);

/// Pure transform for the toggle (move-in/out of the set) — unit-testable
/// without SharedPreferences.
Set<String> stageProgressNext(Set<String> current, String key) =>
    current.contains(key) ? ({...current}..remove(key)) : {...current, key};
