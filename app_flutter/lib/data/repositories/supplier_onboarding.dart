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
    this.barcode,
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

  /// C3.6 — the scannable barcode (EAN/UPC). Optional; the scanner resolves it to a
  /// [sku] via [resolveBarcodeToSku]. Written into the product doc (not the model).
  final String? barcode;
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
) {
  final doc = repo.toDoc(d.toProduct());
  // C3.6 — the barcode rides on the doc (the bundled model has no such field);
  // guarded, so a product without one round-trips unchanged.
  if (d.barcode != null && d.barcode!.isNotEmpty) doc['barcode'] = d.barcode;
  return doc;
}

/// C3.6 — resolve a scanned BARCODE to its sku, by looking through catalog product
/// docs (which carry the optional `barcode` field). Null when no product matches —
/// the scanner then falls back to treating the scan as a raw sku. This replaces the
/// scan→sku-direct path with scan→barcode→sku.
String? resolveBarcodeToSku(
  String barcode,
  Iterable<Map<String, dynamic>> productDocs,
) {
  final b = barcode.trim();
  if (b.isEmpty) return null;
  for (final doc in productDocs) {
    if (doc['barcode'] == b) return doc['sku'] as String?;
  }
  return null;
}

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

/// C4.5 — parse a supplier CSV/Excel export (a header row + data rows) into
/// [SupplierDraft]s for the bulk importer (the dormant Trade Builder, kTradeImport).
/// Minimal RFC-ish CSV: comma-separated, optional `"quoted, fields"`. The header maps
/// column → field (English or Hebrew names accepted); unknown columns are ignored;
/// a row with no sku is skipped. Every row is stamped with [storeId].
List<SupplierDraft> parseCsvToDrafts(String csv, {required String storeId}) {
  final lines = csv
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .toList();
  if (lines.length < 2) return const <SupplierDraft>[];
  final header = [for (final h in _splitCsvLine(lines.first)) h.trim()];
  final out = <SupplierDraft>[];
  for (final line in lines.skip(1)) {
    final cells = _splitCsvLine(line);
    final row = <String, String>{};
    for (var i = 0; i < header.length && i < cells.length; i++) {
      row[header[i]] = cells[i].trim();
    }
    String pick(List<String> names) {
      for (final n in names) {
        final v = row[n];
        if (v != null && v.isNotEmpty) return v;
      }
      return '';
    }

    final sku = pick(['sku', 'מק"ט', 'מקט', 'barcode-sku']);
    if (sku.isEmpty) continue;
    final barcode = pick(['barcode', 'ברקוד']);
    out.add(SupplierDraft(
      storeId: storeId,
      sku: sku,
      nameHe: pick(['nameHe', 'שם', 'name']),
      categoryHe: pick(['categoryHe', 'קטגוריה', 'category']),
      barcode: barcode.isEmpty ? null : barcode,
      price: num.tryParse(pick(['price', 'מחיר'])),
      stock: int.tryParse(pick(['stock', 'מלאי'])),
    ));
  }
  return out;
}

/// Split ONE CSV line, honouring `"quoted, fields"` (a comma inside quotes is data).
List<String> _splitCsvLine(String line) {
  final out = <String>[];
  final sb = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      inQuotes = !inQuotes;
    } else if (c == ',' && !inQuotes) {
      out.add(sb.toString());
      sb.clear();
    } else {
      sb.write(c);
    }
  }
  out.add(sb.toString());
  return out;
}
