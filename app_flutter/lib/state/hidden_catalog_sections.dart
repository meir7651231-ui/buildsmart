import 'package:buildsmart/state/prefs_persisted.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catalog section labels the user chose to HIDE (not delete). Persisted to
/// SharedPreferences so the choice survives a refresh / app restart. Hidden
/// sections stay in the section list — they're filtered out of the chip row and
/// can be restored from "ניהול רשימות". Non-destructive.
class HiddenCatalogSectionsNotifier extends StateNotifier<Set<String>>
    with StringSetPrefsPersisted {
  HiddenCatalogSectionsNotifier() : super(const {}) {
    loadFromPrefs();
  }

  @override
  String get persistKey => _key;

  static const _key = 'bs.hidden-catalog-sections.v1';



  void hide(String label) {
    if (state.contains(label)) return;
    state = {...state, label};
    persistToPrefs();
  }

  void show(String label) {
    if (!state.contains(label)) return;
    state = {...state}..remove(label);
    persistToPrefs();
  }

  void toggle(String label) =>
      state.contains(label) ? show(label) : hide(label);

  bool isHidden(String label) => state.contains(label);
}

final hiddenCatalogSectionsProvider =
    StateNotifierProvider<HiddenCatalogSectionsNotifier, Set<String>>(
  (_) => HiddenCatalogSectionsNotifier(),
);
