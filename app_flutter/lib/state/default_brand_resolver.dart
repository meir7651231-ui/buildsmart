import 'package:buildsmart/data/smart_tree.dart';

/// Resolves the default brand index for a SmartProduct card on open.
///
/// Precedence (first hit wins):
///   1. **Last-saved selection** for THIS product (`cardSelection`).
///   2. **Most-used brand** across all sessions for THIS product
///      (`brandHistoryFav`).
///   3. The product's **recommended** brand (`sp.recBrand`).
///   4. Index `0` if nothing matches and there's no recommended brand.
///
/// Pure — caller passes the names already read from providers. Roadmap step 51.
int resolveDefaultBrandIndex({
  required SmartProduct sp,
  required String? cardSelection,
  required String? brandHistoryFav,
}) {
  // Step 1: the user's explicit last pick for this product.
  if (cardSelection != null) {
    final i = sp.brands.indexWhere((b) => b.name == cardSelection);
    if (i >= 0) return i;
  }
  // Step 2: the user's most-used brand across sessions.
  if (brandHistoryFav != null) {
    final i = sp.brands.indexWhere((b) => b.name == brandHistoryFav);
    if (i >= 0) return i;
  }
  // Step 3: the product's recommended brand.
  final ri = sp.brands.indexWhere((b) => b.rec);
  return ri >= 0 ? ri : 0;
}
