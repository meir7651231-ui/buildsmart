// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · the FAMILY + TYPE taxonomy (owner §1 · against fragmentation).
// PURE. Reuses the finder stack — ZERO new grouping, ZERO invented patches:
//   • FAMILY (the open section, layer 2) = groupOf(p) — the 12 human-curated
//     category groups (word_finder/category_groups.dart): חיבורים ומחברים ·
//     ברזים ושסתומים · צינורות · ניקוז וסיפונים · …
//   • TYPE (the rail tile, layer 3) = the product's canonical TYPE word — the
//     first meaningful name token (word_extraction.firstMeaningfulToken, brand
//     prefix skipped), folded through the finder's alias map (synonym_bridge.
//     kQuerySynonyms: מרפק→ברך, materials, …). So ברך/מרפק collapse to ONE tile,
//     no page/pack in the key. Category fallback when the name has no token.
//
// GATING (byte-identical-off): pure, no `kCatalogConfig` branch; reachable only
// through the gated dive screen ⇒ tree-shaken from a default (OFF) build.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/category_groups.dart' show groupOf;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOfEnriched;
import 'package:buildsmart/features/word_finder/material_taxonomy.dart'
    show canonicalMaterial;
import 'package:buildsmart/features/word_finder/synonym_bridge.dart'
    show kQuerySynonyms;
import 'package:buildsmart/features/word_finder/word_extraction.dart'
    show
        canonicalizeWord,
        firstMeaningfulToken,
        kBrandPrefixBlocklist,
        kCategoryFallbackWord,
        kWordSynonyms;

/// BOTH of the finder's existing normalization maps, applied to the TYPE word
/// (owner: "apply the existing normalization maps"). [kWordSynonyms] is the
/// word_extraction canonicalizer's own map (זווית→ברך, plural→singular מצרות→מצרה,
/// tee-family→מסעף, coupler-family→מצמד); [kQuerySynonyms] is the query-bridge's
/// (מרפק→ברך + material aliases). Merged so a type word folds through EVERY owner-
/// approved synonym, so ברך/מרפק/זווית — and singular/plural — collapse to ONE tile.
/// No overlap between the two key sets, so the merge order is immaterial.
const Map<String, String> _kTypeSynonyms = {...kWordSynonyms, ...kQuerySynonyms};

/// The FAMILY (open section · layer 2) of [p] — its owner-curated category group
/// ([groupOf]; 'אחר' for an unmapped category). TOTAL — never empty.
String familyGroupOf(LipskeyCatalogProduct p) => groupOf(p);

/// The TYPE word (rail tile · layer 3) of [p] — the canonical head noun a layman
/// says ("ברך", "צינור", "ברז"): the first meaningful name token folded through BOTH
/// finder alias maps ([_kTypeSynonyms] — זווית→ברך, מרפק→ברך, plural→singular …), or
/// the category fallback word when the name yields no token, or the raw category as a
/// last resort. TOTAL.
String typeWordOf(LipskeyCatalogProduct p) {
  final token = firstMeaningfulToken(p.nameHe, kBrandPrefixBlocklist);
  final base = (token != null && token.isNotEmpty)
      ? token
      : (kCategoryFallbackWord[p.categoryHe] ?? p.categoryHe);
  final canon = canonicalizeWord(base, _kTypeSynonyms);
  return canon.isEmpty ? p.categoryHe : canon;
}

/// The TILE identity — the [typeWordOf] within its [familyGroupOf] (a type word can
/// appear in more than one family, e.g. צינור under both ניקוז and מקלחת). This is
/// the SINGLE key the rail collapses to AND the card's wheels aggregate over, so
/// the two never disagree (owner: rail = types, card = variations, one peer-key).
String typeKeyOf(LipskeyCatalogProduct p) =>
    '${familyGroupOf(p)} ${typeWordOf(p)}';


/// The products in [universe] that share [p]'s [typeKeyOf] — the card's VARIANT
/// family (every size/angle/… of the same type). The card resolves the centre image
/// + name against this set as the selection changes, so a drag swaps the photo.
List<LipskeyCatalogProduct> typeGroupOf(
  LipskeyCatalogProduct p,
  List<LipskeyCatalogProduct> universe,
) {
  final key = typeKeyOf(p);
  return [
    for (final m in universe)
      if (typeKeyOf(m) == key) m,
  ];
}

/// The canonical MATERIAL of [p] (PPR · HDPE · נחושת · …) via the finder's
/// material lexicon, or `''` when none is detected. The SINGLE derivation the
/// browse rail groups by AND the config card scopes to, so a material tile and
/// its card agree (owner: "לפי הכותרת" — filter to the current material).
String materialOf(LipskeyCatalogProduct p) {
  final m = materialOfEnriched(p);
  return m == null ? '' : canonicalMaterial(m);
}
