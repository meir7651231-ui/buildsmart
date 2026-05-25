import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductFavoritesNotifier extends StateNotifier<Set<String>> {
  ProductFavoritesNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.product-favorites.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  void toggle(String sku) {
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
