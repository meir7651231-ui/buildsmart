
import 'package:buildsmart/state/prefs_persisted.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remembers the last brand the user picked on each SmartProduct card
/// (`productKey → brandName`), so reopening the card restores their choice
/// instead of always defaulting to the recommended brand. Persisted as JSON.
/// Roadmap step 7 (unified persisted selection — brand dimension).
class CardSelectionNotifier extends StateNotifier<Map<String, String>>
    with StringMapPrefsPersisted {
  CardSelectionNotifier() : super(const {}) {
    loadFromPrefs();
  }

  @override
  String get persistKey => _key;

  static const _key = 'bs.card-brand-selection.v1';



  String? brandFor(String productKey) => state[productKey];

  void setBrand(String productKey, String brandName) {
    if (state[productKey] == brandName) return;
    state = {...state, productKey: brandName};
    persistToPrefs();
  }
}

final cardSelectionProvider =
    StateNotifierProvider<CardSelectionNotifier, Map<String, String>>(
  (_) => CardSelectionNotifier(),
);
