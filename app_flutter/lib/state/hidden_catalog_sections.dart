import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Catalog section labels the user chose to HIDE (not delete). Persisted to
/// SharedPreferences so the choice survives a refresh / app restart. Hidden
/// sections stay in the section list — they're filtered out of the chip row and
/// can be restored from "ניהול רשימות". Non-destructive.
class HiddenCatalogSectionsNotifier extends StateNotifier<Set<String>> {
  HiddenCatalogSectionsNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.hidden-catalog-sections.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  void hide(String label) {
    if (state.contains(label)) return;
    state = {...state, label};
    _persist();
  }

  void show(String label) {
    if (!state.contains(label)) return;
    state = {...state}..remove(label);
    _persist();
  }

  void toggle(String label) =>
      state.contains(label) ? show(label) : hide(label);

  bool isHidden(String label) => state.contains(label);
}

final hiddenCatalogSectionsProvider =
    StateNotifierProvider<HiddenCatalogSectionsNotifier, Set<String>>(
  (_) => HiddenCatalogSectionsNotifier(),
);
