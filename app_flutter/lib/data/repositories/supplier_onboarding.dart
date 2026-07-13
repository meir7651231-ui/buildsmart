// SUPPLIER ONBOARDING (SPEC-catalog-to-server · C4 — self-onboarding pipeline).
//
// The pure logic behind the supplier form (`trade_builder/product_authoring_screen`,
// dormant behind kTradeImportFlag): validate a draft (C4.2), auto-suggest facets from
// the name by REUSING the catalog's own name-parse getters (C4.3), and turn a draft
// into the two docs a submit writes — the catalog product AND its store inventory
// (C4.4). Price/stock live ONLY in the inventory doc (R1-6), never the product doc.
//
// GATING: pure + referenced only by the gated form + tests → tree-shakes out of OFF.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/store_inventory.dart'
    show InventoryItem;

/// One supplier's submission — the catalog fields + the store's price/stock. `dims`
/// is a raw map (numeric values stay numbers). `price`/`stock` null ⇒ no inventory row.
class SupplierDraft {
  const SupplierDraft({
    required this.storeId,
    required this.sku,
    required this.nameHe,
    required this.categoryHe,
    this.nameEn = '',
    this.categoryEn = '',
    this.categoryEmoji = '📦',
    this.brand = '',
    this.color,
    this.dims,
    this.imageFile,
    this.price,
    this.stock,
    this.updatedAt = '',
  });

  final String storeId;
  final String sku;
  final String nameHe;
  final String categoryHe;
  final String nameEn;
  final String categoryEn;
  final String categoryEmoji;
  final String brand;
  final String? color;
  final Map<String, dynamic>? dims;
  final String? imageFile;
  final num? price;
  final int? stock;
  final String updatedAt;

  /// The draft as a catalog product (for `toDoc` + the name-parse getters).
  LipskeyCatalogProduct toProduct() => LipskeyCatalogProduct(
        sku: sku,
        nameHe: nameHe,
        nameEn: nameEn,
        categoryHe: categoryHe,
        categoryEn: categoryEn,
        categoryEmoji: categoryEmoji,
        page: 0,
        color: color,
        dims: dims,
        imageFile: imageFile,
        brand: brand.isEmpty ? 'ליפסקי' : brand,
      );
}

/// C4.3 — facets auto-derived from the draft's name/dims, by REUSING the catalog's
/// own getters (no new parser). A form pre-fills these; the supplier can override.
class FacetSuggestion {
  const FacetSuggestion({this.type, this.gender, this.method, this.sizes = const []});
  final String? type;
  final String? gender;
  final String? method;
  final List<String> sizes;
}

FacetSuggestion suggestFacets(SupplierDraft draft) {
  final p = draft.toProduct();
  return FacetSuggestion(
    type: p.productType,
    gender: p.connectionGender,
    method: p.connectionMethod,
    sizes: p.connectionSizes,
  );
}

/// C4.2 — validation result. [ok] gates the submit; [warnings] are non-blocking (e.g.
/// a duplicate SKU = an UPDATE, not an error).
class DraftValidation {
  const DraftValidation(this.errors, this.warnings);
  final List<String> errors;
  final List<String> warnings;
  bool get ok => errors.isEmpty;
}

/// C4.2 — validate a draft: required fields, non-negative price/stock, numeric dims,
/// and a duplicate-SKU WARNING (already in [existingSkus] ⇒ this submit updates it).
DraftValidation validateDraft(SupplierDraft d, Set<String> existingSkus) {
  final errors = <String>[];
  final warnings = <String>[];
  if (d.sku.trim().isEmpty) errors.add('מק"ט חובה');
  if (d.nameHe.trim().isEmpty) errors.add('שם (עברית) חובה');
  if (d.categoryHe.trim().isEmpty) errors.add('קטגוריה חובה');
  if (d.storeId.trim().isEmpty) errors.add('מזהה-חנות חובה');
  if (d.price != null && d.price! < 0) errors.add('מחיר לא יכול להיות שלילי');
  if (d.stock != null && d.stock! < 0) errors.add('מלאי לא יכול להיות שלילי');
  // dims values must be numbers or numeric strings (a form field mistyped as text).
  for (final e in (d.dims ?? const <String, dynamic>{}).entries) {
    final v = e.value;
    if (v is! num && (v is! String || num.tryParse(v) == null)) {
      // A descriptive dim (e.g. 'תיאור') is fine; only flag keys that look numeric.
      if (e.key == 'מידה' || e.key == 'קוטר' || e.key == 'אורך') {
        errors.add('מידה "${e.key}" חייבת להיות מספר');
      }
    }
  }
  if (existingSkus.contains(d.sku.trim())) {
    warnings.add('מק"ט ${d.sku} כבר קיים — ההעלאה תעדכן אותו');
  }
  return DraftValidation(errors, warnings);
}

/// C4.4 — the product doc a submit writes to `catalogProducts` (reuses `toDoc`; price
/// is NEVER here — R1-6).
Map<String, dynamic> draftToProductDoc(
  SupplierDraft d,
  FirebaseAuthoredProductsRepository repo,
) =>
    repo.toDoc(d.toProduct());

/// C4.4 — the inventory row a submit writes to `inventory` (null when no price given).
/// This is the store-layer half the product-only authoring never had.
InventoryItem? draftToInventory(SupplierDraft d) => d.price == null
    ? null
    : InventoryItem(
        storeId: d.storeId,
        sku: d.sku.trim(),
        price: d.price!,
        stock: d.stock ?? 0,
        updatedAt: d.updatedAt,
      );
