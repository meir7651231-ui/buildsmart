/// PURE material axis for the word-finder (the "ציר-חומר" entry).
///
/// THE PROBLEM IT SOLVES:
///   The finder narrows by NOUN → size → colour, but has NO MATERIAL dimension.
///   The owner asked "where are all the copper fittings?" / "where's ניפל?".
///   A product's MATERIAL (נחושת, PPR, פקס…) is encoded informally inside its
///   `nameHe`/`categoryHe` text, never as a structured field. This library reads
///   that text and answers three questions, all PURELY:
///     • what material is a product? ([materialOf])
///     • which materials actually appear in a pool? ([materialsInPool])
///     • which products are of a given material? ([productsOfMaterial])
///   The screen uses these to add a material-FIRST entry that then reuses the
///   ENTIRE existing word→size→colour cascade unchanged.
///
/// DETECTION MODEL:
///   A product's material is the FIRST [kMaterials] key whose ANY detection term
///   is a substring of `'<nameHe> <categoryHe>'`. The key order is therefore both
///   the precedence order (a product matching two materials takes the earlier
///   key) AND the display order the UI offers. כרום is a FINISH, not a material,
///   so it is intentionally absent; PVC/מולטיגול carry zero products in the pool,
///   so they are omitted too. HDPE was ADDED 19/6 (120 products) — the #14 scout
///   searched 'PE'/'פוליאתילן' and missed the 'HDPE'-token category.
///
/// PURITY: imports NO Flutter widgets and builds NO UI — a plain transform over
/// const data and product fields. Deterministic: same input ⇒ same output, no
/// clock, no randomness, no I/O. (Like every other word-finder data library it
/// is exercised under `flutter_test` only because [LipskeyCatalogProduct] pulls
/// the Flutter chain transitively; the logic here is pure.)
library;

import 'package:buildsmart/data/lipskey_catalog.dart';

/// ORDERED material → detection terms. Key order is BOTH the match precedence
/// (a product is assigned the FIRST key whose any term hits) AND the display
/// order the material chip-row offers. A product's material = the first key any
/// of whose terms is a substring of `'<nameHe> <categoryHe>'`.
///
/// OWNER-REVIEW seed (label + terms + order are all owner-tunable):
///   • 'נחושת' folds copper AND brass (פליז) — the owner asked for "copper
///     fittings" as one bucket; split into two keys if they should differ.
///   • 'רב-שכבתי' is listed BEFORE 'פקס' so a multilayer pipe is not mis-bucketed
///     by an incidental PEX token; both spellings (spaced / hyphenated) are
///     detected.
///   • finishes (כרום) and zero-product materials (PVC/מולטיגול) are deliberately
///     omitted; HDPE was added 19/6 — the #14 scout missed its 120 products by
///     searching 'PE' rather than the 'HDPE' token in 'מחברי HDPE'.
const Map<String, List<String>> kMaterials = <String, List<String>>{
  'נחושת': ['נחושת', 'פליז'], // OWNER-REVIEW
  'PPR': ['PPR'], // OWNER-REVIEW
  'HDPE': ['HDPE', 'פוליאתילן'], // OWNER-REVIEW — 120 products ('מחברי HDPE'); the #14 scout searched 'PE' and missed the 'HDPE' token
  'רב-שכבתי': ['רב שכבתי', 'רב-שכבתי'], // OWNER-REVIEW
  'פקס': ['פקסגול', 'פקס', 'PEX'], // OWNER-REVIEW
  'נירוסטה': ['נירוסטה'], // OWNER-REVIEW
  'פלדה': ['פלדה'], // OWNER-REVIEW
};

/// Whole-CATEGORY material overrides — for categories whose products are
/// uniformly one material but do NOT say so in their text (e.g. chrome/nickel-
/// plated brass taps that read as neither 'נחושת' nor 'פליז'). Consulted by
/// [materialOf] ONLY as a fallback AFTER the [kMaterials] term heuristic, so it
/// can ADD a classification but can never change an existing one. Keyed by EXACT
/// `categoryHe`.
///
/// OWNER-REVIEW: produced 2026-06-19 by the donned classify+verify swarm (#24),
/// which mapped a category here ONLY when confident the WHOLE category is that
/// material; brass folds into 'נחושת' (copper+brass), matching the original
/// "where are all the copper fittings?" intent. Add/trim entries freely.
const Map<String, String> kCategoryMaterial = <String, String>{
  'ברזי ניל': 'נחושת', // brass-bodied (nickel/chrome-plated) taps
  'ברזי מעבר': 'נחושת',
  'ברזי קיר': 'נחושת',
  'ברזי כיור': 'נחושת',
  'מחלקים': 'נחושת', // brass manifolds
  'נקודות מים': 'נחושת', // brass rough-in water points (#24 re-run batch)
};

/// The material of [p]: the FIRST [kMaterials] key whose any term is a substring
/// of the `'<nameHe> <categoryHe>'` text (so [kMaterials] order is the precedence);
/// else the [kCategoryMaterial] whole-category override for its `categoryHe`; else
/// null. PURE & deterministic.
String? materialOf(LipskeyCatalogProduct p) {
  final haystack = '${p.nameHe} ${p.categoryHe}';
  for (final entry in kMaterials.entries) {
    for (final term in entry.value) {
      if (haystack.contains(term)) return entry.key;
    }
  }
  return kCategoryMaterial[p.categoryHe];
}

/// Like [materialOf] but, when the name/category text heuristic finds nothing,
/// falls back to the product's declared `dims['חומר']` (mapped through
/// [kMaterials]) BEFORE the category override — recovering the ~64 dims-only
/// materials (e.g. copper press fittings whose name omits 'נחושת'). The
/// UNIFIED-finder material axis uses THIS; the LIVE word_finder keeps calling
/// [materialOf] verbatim, so the live material axis stays byte-identical.
/// Precedence text > dims > category. PURE & deterministic.
String? materialOfEnriched(LipskeyCatalogProduct p) {
  final haystack = '${p.nameHe} ${p.categoryHe}';
  for (final entry in kMaterials.entries) {
    for (final term in entry.value) {
      if (haystack.contains(term)) return entry.key;
    }
  }
  final dim = p.dims?['חומר'];
  if (dim is String && dim.isNotEmpty) {
    for (final entry in kMaterials.entries) {
      if (entry.key == dim || entry.value.any(dim.contains)) {
        return entry.key;
      }
    }
  }
  return kCategoryMaterial[p.categoryHe];
}

/// The [kMaterials] keys (IN [kMaterials] ORDER) that have at least one product
/// in [pool]. The order is preserved so the UI can offer the materials in the
/// owner's display order; a material with zero products in the pool is omitted.
/// PURE & deterministic.
List<String> materialsInPool(List<LipskeyCatalogProduct> pool) {
  return [
    for (final material in kMaterials.keys)
      if (pool.any((p) => materialOf(p) == material)) material,
  ];
}

/// Every product in [pool] whose [materialOf] equals [material], in pool order.
/// PURE & deterministic.
List<LipskeyCatalogProduct> productsOfMaterial(
  List<LipskeyCatalogProduct> pool,
  String material,
) =>
    pool.where((p) => materialOf(p) == material).toList();
