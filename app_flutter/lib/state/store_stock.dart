// 🏪 store out-of-stock set — the supplier's per-product "אזל מהמלאי" toggles.
//
// Lives in `lib/state/` (not on the store dashboard screen) so it can be read
// from the shared persona portal (`screens/persona_portal.dart` — the autoStock
// tile renders this live list) WITHOUT the portal having to import the store
// dashboard, which would create a circular import (the dashboard imports the
// portal for its 8 tiles).
//
// Persists best-effort to its own SharedPreferences key (`bs.store-oos.v1`) —
// the same pattern the orders engine + fulfillment side-car use — so the
// availability toggles survive an app restart.
//
// task #79 also adds [storeProductsProvider] here — the supplier's "הוסף
// מוצר" overlay (new products the store uploads beyond the const catalog).
// Same shared-state rationale: the store dashboard WRITES it (the מלאי-tab
// add-product sheet) and the contractor catalog/search READS it (supplier-added
// tag), so it must live in `lib/state/`, not on either screen.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kOosKey = 'bs.store-oos.v1';

class StoreOosNotifier extends StateNotifier<Set<String>> {
  StoreOosNotifier() : super(const {}) {
    unawaited(_load());
  }

  /// True once any mutation has been applied (or _load completes).
  /// Guards against _load clobbering a mutation that arrived before prefs.
  bool _loaded = false;

  // Setter does NOT persist — the mutators (markOos/markAvailable) persist
  // explicitly (the cart_lists shape), so we only flag the load-guard here.
  @override
  set state(Set<String> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kOosKey);
      if (list != null && !_loaded) {
        super.state = list.toSet(); // bypass setter so we don't re-persist on load
        _loaded = true;
      } else {
        _loaded = true;
      }
    } on Object catch (_) {
      _loaded = true; // keep empty
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kOosKey, state.toList());
    } on Object catch (_) {/* best-effort */}
  }

  void markOos(String name) {
    state = {...state, name};
    unawaited(_persist());
  }

  void markAvailable(String name) {
    state = {...state}..remove(name);
    unawaited(_persist());
  }
}

final storeOosProvider =
    StateNotifierProvider<StoreOosNotifier, Set<String>>(
  (_) => StoreOosNotifier(),
);

// ── task #79 · supplier-added products overlay ───────────────────────────────
//
// The store's "הוסף מוצר" form (מלאי tab) writes NEW products here — an
// overlay ON TOP of the const catalog, never a mutation of it. Readers:
//   • store dashboard `_stockNames` — unions [storeProductNamesProvider] so a
//     new product appears in the inventory list (and can be toggled אזל via
//     [storeOosProvider], which stays the availability set ONLY).
//   • contractor catalog/search — supplier-added items surface with the
//     [kSupplierAddedTag] badge (both-sides-see rule).
// Persisted under [kStoreProductsKey] with the `board_auth.dart` idiom
// (lazy `_load()` + `_userTouched` guard), mirroring `vacation_requests.dart`.
// SERVER-SWAP: becomes a supplier product-upload API when the backend lands.

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kStoreProductsKey = 'bs.store-products.v1';

/// The badge the contractor catalog/search shows on supplier-added products.
/// Lives here (not on a screen) so the writer and every reader share one token.
const String kSupplierAddedTag = 'נוסף ע״י הספק';

/// One supplier-added product — the catalog-schema subset the form collects
/// (name + SKU + category, mirroring `LipskeyCatalogProduct`'s
/// sku/nameHe/categoryHe/categoryEmoji axes).
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.createdTs,
    this.categoryEmoji = '🆕',
  });

  final String id;

  /// Hebrew display name (the `nameHe` axis) — also the key the inventory
  /// list and [storeOosProvider] toggle by.
  final String name;

  /// Supplier-entered SKU — [StoreProductsNotifier.add] dup-guards it
  /// (case-insensitive).
  final String sku;

  /// Hebrew category title — one of the `kCatalogCats` titles
  /// (`data/catalog.dart`), picked in the add-product form.
  final String category;

  /// The category's emoji (straight off the picked `kCatalogCats` section).
  final String categoryEmoji;

  final DateTime createdTs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'category': category,
        'categoryEmoji': categoryEmoji,
        'createdTs': createdTs.toIso8601String(),
      };

  /// Defensive decode — a malformed entry is dropped, never crashes the load.
  static StoreProduct? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    final sku = raw['sku'];
    final category = raw['category'];
    final created = DateTime.tryParse('${raw['createdTs']}');
    if (id is! String ||
        name is! String ||
        sku is! String ||
        category is! String ||
        created == null) {
      return null;
    }
    return StoreProduct(
      id: id,
      name: name,
      sku: sku,
      category: category,
      categoryEmoji:
          raw['categoryEmoji'] is String ? raw['categoryEmoji'] as String : '🆕',
      createdTs: created,
    );
  }
}

class StoreProductsNotifier extends StateNotifier<List<StoreProduct>> {
  StoreProductsNotifier() : super(const []) {
    unawaited(_load());
  }

  /// One-shot guard (the board_auth idiom): once an add/remove has written
  /// state, a late `_load()` becomes non-destructive.
  bool _userTouched = false;

  /// Monotonic id suffix — on web DateTime precision is ~1ms, so two rapid
  /// adds could collide on a timestamp-only id (remove would then hit BOTH).
  int _seq = 0;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kStoreProductsKey);
      if (raw == null || _userTouched) return;
      final list = jsonDecode(raw) as List;
      if (_userTouched) return;
      state = [
        for (final e in list)
          if (StoreProduct.tryFromJson(e) case final p?) p,
      ];
    } on Object catch (_) {
      // Corrupt or unavailable storage — keep the empty overlay.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kStoreProductsKey,
        jsonEncode([for (final p in state) p.toJson()]),
      );
    } on Object catch (_) {/* best-effort */}
  }

  /// True when [sku] is already used by an overlay product (case-insensitive,
  /// trimmed) — the add-product form's live duplicate check.
  bool skuTaken(String sku) {
    final s = sku.trim().toLowerCase();
    return state.any((p) => p.sku.toLowerCase() == s);
  }

  /// True when [name] is already an overlay product name (trimmed).
  bool nameTaken(String name) {
    final n = name.trim();
    return state.any((p) => p.name == n);
  }

  /// STORE write — add a new product from the "הוסף מוצר" form. Returns the
  /// created product, or null when a field is empty after trimming or the
  /// name/SKU duplicates an existing overlay product (the form shows the
  /// matching error — never a silent fake-add).
  StoreProduct? add({
    required String name,
    required String sku,
    required String category,
    String categoryEmoji = '🆕',
  }) {
    final n = name.trim();
    final s = sku.trim();
    final c = category.trim();
    if (n.isEmpty || s.isEmpty || c.isEmpty) return null;
    if (nameTaken(n) || skuTaken(s)) return null;
    _userTouched = true;
    _seq++;
    final p = StoreProduct(
      id: 'sp-${DateTime.now().microsecondsSinceEpoch}-$_seq',
      name: n,
      sku: s,
      category: c,
      categoryEmoji: categoryEmoji,
      createdTs: DateTime.now(),
    );
    state = [...state, p];
    unawaited(_persist());
    return p;
  }

  /// STORE write — remove an overlay product (only supplier-added products
  /// are removable; the const catalog is untouchable by design).
  void remove(String id) {
    _userTouched = true;
    state = [for (final p in state) if (p.id != id) p];
    unawaited(_persist());
  }
}

/// The supplier-added products overlay — the store dashboard writes (add /
/// remove), the inventory list + contractor catalog/search read.
final storeProductsProvider =
    StateNotifierProvider<StoreProductsNotifier, List<StoreProduct>>(
  (_) => StoreProductsNotifier(),
);

/// Just the names, in insertion order — the store dashboard unions this into
/// `_stockNames` so supplier-added products join the inventory list (and the
/// אזל toggle keys by the same name).
final storeProductNamesProvider = Provider<List<String>>(
  (ref) => [for (final p in ref.watch(storeProductsProvider)) p.name],
);
