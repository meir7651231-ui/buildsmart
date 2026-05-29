import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Product+brand configurations the user saved as a favourite / template,
/// keyed `"<productKey>#<brandName>"`. Persisted so saved configs survive a
/// refresh. Roadmap step 47.
class SavedConfigsNotifier extends StateNotifier<Set<String>> {
  SavedConfigsNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.saved-configs.v1';

  static String keyFor(String productKey, String brandName) =>
      '$productKey#$brandName';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
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
  (_) => SavedConfigsNotifier(),
);
