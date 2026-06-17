/// Pure word-extraction primitives for the product finder (בית/מאתר).
///
/// STEP 2 of the word-finder swarm — the build-time WORD LEXICON's lower
/// layer. A PURE library (no Flutter widgets, no Riverpod providers), mirroring
/// the purity of `dive_pool.dart` (STEP 1), `narrow_axis.dart` (STEP 0) and
/// `catalog_lens.dart`. Importing it pulls in zero UI.
///
/// WHY THIS EXISTS:
///   A non-technical user searches by a single plain word ("ברז", "ברך",
///   "צינור"). To map products → words we take the FIRST MEANINGFUL TOKEN of
///   each product's `nameHe`. But many Lipskey names lead with a BRAND/series
///   prefix ("דיור ראש מקלחת…", "קיסר ברז…", "אקווה סט…") — keying on that
///   would scatter products under meaningless marketing names instead of the
///   thing they are. So we:
///     1. skip a leading brand-prefix token (`kBrandPrefixBlocklist`),
///     2. skip pure-number/size tokens (`250`, `1/2"`, `DN40`),
///     3. optionally canonicalize synonyms (`kWordSynonyms`, EMPTY pending
///        owner sign-off),
///     4. and when nothing meaningful survives, fall back to a per-category
///        layman word (`kCategoryFallbackWord`).
///
/// The token splitter mirrors `narrow_axis.wordOptions` so the finder shares
/// one tokenizer idiom; only the policy (blocklist / fallback) lives here.
library;

/// Splits a Hebrew product name into candidate word tokens. SAME character
/// class as `narrow_axis.wordOptions` (`[\s()"׳/×,.+-]`), so the two stay in
/// lock-step. A token survives only if it is a "real word": ≥2 chars AND
/// digit-free — which drops sizes (`250`, `40`), fractions (`1/2"`), and codes
/// (`DN40`) the way `wordOptions` already does.
List<String> _realWordTokens(String name) => name
    .split(RegExp(r'[\s()"׳/×,.+\-]+'))
    .where((w) => w.length >= 2 && !RegExp(r'\d').hasMatch(w))
    .toList();

/// The first "meaningful" token of [nameHe]: the first real word (≥2 chars,
/// digit-free) that is NOT in [blocklist]. Brand-prefix words in [blocklist]
/// are skipped so the meaningful noun behind them wins (e.g. "דיור ראש
/// מקלחת…" → 'ראש', "קיסר ברז…" → 'ברז'). Returns `null` when no token
/// qualifies (e.g. a name that is all brand + numbers) — the caller then
/// applies the category fallback.
String? firstMeaningfulToken(String nameHe, Set<String> blocklist) {
  for (final t in _realWordTokens(nameHe)) {
    if (!blocklist.contains(t)) return t;
  }
  return null;
}

/// Collapses a [token] onto its canonical form via [synonyms]; pass-through
/// when no mapping exists. With the EMPTY default `kWordSynonyms` this is the
/// identity — see the OWNER-REVIEW note there.
String canonicalizeWord(String token, Map<String, String> synonyms) =>
    synonyms[token] ?? token;

/// SEED list of brand / series prefixes that lead a product name but carry no
/// search meaning ("דיור ראש מקלחת" is a *shower head*, not a "דיור"). Skipping
/// them lets the real noun become the lexicon key.
///
/// OWNER-REVIEW: this seed is intentionally partial — names in the catalog also
/// lead with brands NOT listed here (e.g. טולדו, טרפז, תבור, קונקורד already
/// seen in `מערכות אמבטיה`). The category fallback (`kCategoryFallbackWord`)
/// catches those, but the owner should finalize the authoritative brand set.
const Set<String> kBrandPrefixBlocklist = {
  'דיור',
  'אקווה',
  'סיגמא',
  'איביזה',
  'רותם',
  'קיסר',
  'טרפלקס',
  'פולו',
  'נוגה',
  'מלודי',
  'לונה',
  'גרנדה',
  'תמר',
  'הדר',
  'קורל',
  'קונקורד',
};

/// Synonym → canonical-word map. EMPTY by default.
///
/// OWNER-REVIEW: whether to collapse near-synonyms (e.g. 'זווית' → 'ברך',
/// 'מזלף' → 'מקלח') is an owner product decision. Do NOT add entries without
/// sign-off — collapsing changes which products share a word bucket.
const Map<String, String> kWordSynonyms = <String, String>{};

/// categoryHe → simple layman word, used when a product's first meaningful
/// token is unavailable (all brand + numbers) so the lexicon never loses it.
/// Keys are VERBATIM real `categoryHe` values from the catalog; values are the
/// plain word a non-technical user would type.
///
/// OWNER-REVIEW: this is a SEED of obvious cases (taps, shower heads, sprays,
/// systems, spouts, water-points) drawn from real category names. The owner
/// should review/extend coverage; categories without an entry simply fall
/// through (the product keeps whatever first token it has).
const Map<String, String> kCategoryFallbackWord = <String, String>{
  // Faucet families — names often lead with a brand (קיסר/דיור…) → 'ברז'.
  'ברזי כיור': 'ברז',
  'ברזי מטבח': 'ברז',
  'ברזי אמבטיה': 'ברז',
  'ברזי מקלחת': 'ברז',
  'ברזי קיר': 'ברז',
  'ברזי ניל': 'ברז',
  'ברזי מעבר': 'ברז',
  'ברזי דלי': 'ברז',
  'ברזי גן': 'ברז',
  // Shower / bath fixtures.
  'ראשי מקלחת': 'ראש',
  'מזלפי יד': 'מזלף',
  'זרועות דוש': 'זרוע',
  'מערכות שטיפה': 'מערכת',
  'מערכות אמבטיה': 'מערכת',
  'ערכות רחצה': 'סט',
  // Spouts & water-points (lead with 'דיור').
  'דיורים ופיות': 'פיה',
  'נקודות מים': 'נקודה',
};
