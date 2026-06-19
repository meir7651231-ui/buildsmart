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
  // SEED (16) — original hand-picked brand prefixes.
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
  // OWNER-REVIEW: 17 NEW brand/series prefixes verified against the real
  // catalog bytes — each LEADS >=1 product name in the union pool, surfacing a
  // real noun behind it (e.g. בתא→ברז ×10, פיטרה→אסלה, גל/כנרת→ראש, ויגה→סוללה)
  // and the 17 collide with ZERO non-leading product nouns (only כנרת appears
  // mid-name in 2 cistern names that already key on 'מיכל', so it is harmless).
  // Reversible: delete this block to fall back to the 16-seed list. ג'נבה and
  // אנג'ל use the ASCII apostrophe U+0027 (the tokenizer does NOT split it, so
  // the whole token incl. apostrophe is the entry).
  'טרפז', // OWNER-REVIEW
  'טולדו', // OWNER-REVIEW
  'טיטוניק', // OWNER-REVIEW
  "ג'נבה", // OWNER-REVIEW (ASCII apostrophe U+0027)
  'אוסלו', // OWNER-REVIEW
  "אנג'ל", // OWNER-REVIEW (ASCII apostrophe U+0027)
  'גאלרי', // OWNER-REVIEW
  'גל', // OWNER-REVIEW
  'פלורה', // OWNER-REVIEW
  'כנרת', // OWNER-REVIEW
  'הוואי', // OWNER-REVIEW
  'אלפא', // OWNER-REVIEW
  'ויגה', // OWNER-REVIEW
  'גליל', // OWNER-REVIEW
  'דלתא', // OWNER-REVIEW
  // 'זקיף' removed (canonical audit · data-seed lens): it is the PRODUCT NOUN
  // ('זקיף אסלה', sku 121216) — not a brand prefix. Blocklisting it skipped the
  // leading token and mis-keyed that product to 'אסלה', making it unsearchable.
  'פיטרה', // OWNER-REVIEW
  'בתא', // OWNER-REVIEW
};

/// Synonym → canonical-word map.
///
/// OWNER-REVIEW: granularity / normalization. Each entry collapses a word onto
/// its canonical layman form so near-synonyms share ONE bucket (verified by
/// reading real product names). These are REVERSIBLE defaults — empty this map
/// to restore identity canonicalization. Granularity merges (one elbow / one
/// tee / one coupler / one reducer key) trade specificity for a simpler newbie
/// search; the map is a FLAT global `Map<String,String>` so a merge applies to
/// EVERY product regardless of category. NOTE: 'מחבר'→'מצמד' and 'מקטין'→'מצרה'
/// were explicitly REJECTED ('מחבר גמיש' flex-connectors and 'מקטין לחץ'
/// pressure-reducers are distinct products that must not fold in).
const Map<String, String> kWordSynonyms = <String, String>{
  // Reducer normalization (plural → singular). // OWNER-REVIEW
  'מצרות': 'מצרה', // OWNER-REVIEW
  // Tee family → one 'מסעף' key (catalog itself writes 'מסעף (טי)'). // OWNER-REVIEW
  'סעף': 'מסעף', // OWNER-REVIEW
  'טי': 'מסעף', // OWNER-REVIEW
  'הסתעפות': 'מסעף', // OWNER-REVIEW
  // Elbow → one 'ברך' key ('זווית נחושת פ.פ' IS an elbow). // OWNER-REVIEW
  'זווית': 'ברך', // OWNER-REVIEW
  // Coupler family → one 'מצמד' key (socket/connector synonyms). // OWNER-REVIEW
  'מקשר': 'מצמד', // OWNER-REVIEW
  'מופה': 'מצמד', // OWNER-REVIEW
  // Drainage-channel leak fix ('סיגמא פלוס תעלת …' → 'פלוס' otherwise). // OWNER-REVIEW
  'פלוס': 'תעלה', // OWNER-REVIEW
  // Check-valve tokenizer artifact ('אל חזור …' splits 'אל' bare). // OWNER-REVIEW
  'אל': 'אל-חזור', // OWNER-REVIEW
};

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
  // OWNER-REVIEW: 8 NEW per-category fallbacks. Every key below is a VERBATIM
  // real `categoryHe` value confirmed present in the catalog (lipskey), and its
  // value is the plain layman word. A fallback fires ONLY when a name yields no
  // meaningful token (pure brand+number) — so these only catch the brand/number
  // -only names in each category; otherwise the product keeps its own token.
  // Reversible: delete this block to fall back to the 17-seed map.
  'מושבי אסלה': 'מושב', // OWNER-REVIEW (cat exists, 26 products)
  'ידיות אחיזה': 'ידית', // OWNER-REVIEW (cat exists, 3 products)
  'סיפונים': 'סיפון', // OWNER-REVIEW (cat exists, 7 products)
  'מחלקים': 'מחלק', // OWNER-REVIEW (cat exists, 11 products)
  'ארונות מחלק': 'ארון', // OWNER-REVIEW (cat exists, 3 products)
  'צינורות גמישים': 'צינור', // OWNER-REVIEW (cat exists, 17 products)
  'מצופים': 'מצוף', // OWNER-REVIEW (cat exists, 4 products)
  'מכשירי לחץ': 'מד', // OWNER-REVIEW (cat exists, 4 products)
};
