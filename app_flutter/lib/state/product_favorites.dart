import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductFavoritesNotifier extends StateNotifier<Set<String>> {
  ProductFavoritesNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.product-favorites.v1';

  /// `true` once a mutating method (toggle) has written state. The provider is
  /// lazy, so the constructor's async `_load()` can resolve AFTER a synchronous
  /// user write and clobber it. This one-shot guard makes a late `_load()`
  /// non-destructive once the user has touched state.
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (_userTouched) return;
    if (list != null) state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  void toggle(String sku) {
    _userTouched = true;
    if (state.contains(sku)) {
      state = {...state}..remove(sku);
    } else {
      state = {...state, sku};
    }
    _persist();
  }

  bool isFavorite(String sku) => state.contains(sku);
}

final productFavoritesProvider =
    StateNotifierProvider<ProductFavoritesNotifier, Set<String>>(
  (_) => ProductFavoritesNotifier(),
);
