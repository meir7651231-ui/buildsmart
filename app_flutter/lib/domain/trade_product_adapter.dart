// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 35 — the zero-regression
// linchpin (§1.4). The screens read `LipskeyCatalogProduct`; we do NOT rewrite them.
//
// `tradeProductFromLegacy` builds the data-driven [TradeProduct] from a legacy
// product (used by the plumbing seed generator, step 36); `.toLegacy()` reconstructs
// the exact [LipskeyCatalogProduct] the screens render. The pair is a FAITHFUL
// INVERSE: `dims` is kept 1:1 (render parity), and the legacy-only fields
// (color / the category strings / brand / the singular image fields) are stashed in
// `attributes` under reserved `__` keys (a new trade never uses them; the legacy
// render ignores `attributes`). Plumbing products ARE the seed, so == / rendering /
// `connectionSizes` are unchanged. No live consumer yet ⇒ zero regression.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/domain/trade_schema.dart';

// Reserved attribute keys for the legacy-only fields (keeps `dims` clean / 1:1).
const String kLegacyColorAttr = '__color';
const String kLegacyCategoryHeAttr = '__categoryHe';
const String kLegacyCategoryEnAttr = '__categoryEn';
const String kLegacyCategoryEmojiAttr = '__categoryEmoji';
const String kLegacyBrandAttr = '__brand';
const String kLegacyImageFileAttr = '__imageFile';
const String kLegacySpecImageFileAttr = '__specImageFile';

/// Build the data-driven [TradeProduct] from a legacy [LipskeyCatalogProduct].
/// `dims` is preserved 1:1; the legacy-only fields are stashed in `attributes` so
/// [TradeProductLegacy.toLegacy] reconstructs the product byte-for-byte.
///
/// When [categoryId] is supplied (e.g. the plumbing seed resolves it from the
/// catalog tree so it points at a real [TradeCategory]) it is used verbatim;
/// otherwise the legacy-derived `'$tradeId.${p.categoryHe}'` is kept. `toLegacy`
/// reconstructs `categoryHe` from the stashed attribute, not from `categoryId`,
/// so the round-trip stays byte-faithful regardless of this argument.
TradeProduct tradeProductFromLegacy(
  LipskeyCatalogProduct p, {
  String tradeId = 'plumbing',
  String? categoryId,
}) =>
    TradeProduct(
      id: p.sku,
      tradeId: tradeId,
      categoryId: categoryId ?? '$tradeId.${p.categoryHe}',
      brandId: p.brand,
      nameHe: p.nameHe,
      nameEn: p.nameEn,
      attributes: {
        if (p.color != null) kLegacyColorAttr: p.color!,
        kLegacyCategoryHeAttr: p.categoryHe,
        kLegacyCategoryEnAttr: p.categoryEn,
        kLegacyCategoryEmojiAttr: p.categoryEmoji,
        kLegacyBrandAttr: p.brand,
        if (p.imageFile != null) kLegacyImageFileAttr: p.imageFile!,
        if (p.specImageFile != null) kLegacySpecImageFileAttr: p.specImageFile!,
      },
      dims: p.dims ?? const {},
      imageFiles: p.imageFiles ?? const [],
      specImageFiles: p.specImageFiles ?? const [],
      qtyPack: p.qtyPack,
      qtyPallet: p.qtyPallet,
      page: p.page,
    );

extension TradeProductLegacy on TradeProduct {
  /// Reconstruct the legacy [LipskeyCatalogProduct] the screens render. For a product
  /// built by [tradeProductFromLegacy] this is byte-for-byte the original.
  LipskeyCatalogProduct toLegacy() => LipskeyCatalogProduct(
        sku: id,
        nameHe: nameHe,
        nameEn: nameEn,
        color: attributes[kLegacyColorAttr],
        qtyPack: qtyPack,
        qtyPallet: qtyPallet,
        categoryHe: attributes[kLegacyCategoryHeAttr] ?? '',
        categoryEn: attributes[kLegacyCategoryEnAttr] ?? '',
        categoryEmoji: attributes[kLegacyCategoryEmojiAttr] ?? '',
        page: page,
        dims: dims.isEmpty ? null : dims,
        imageFile: attributes[kLegacyImageFileAttr],
        imageFiles: imageFiles.isEmpty ? null : imageFiles,
        specImageFile: attributes[kLegacySpecImageFileAttr],
        specImageFiles: specImageFiles.isEmpty ? null : specImageFiles,
        brand: attributes[kLegacyBrandAttr] ?? 'ליפסקי',
      );
}
