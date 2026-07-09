// ─────────────────────────────────────────────────────────────────────────────
// NARROWERS — pure typing-help for the OPTION-B prediction row (kGlobalSearch).
//
// Owner "option B": the keyboard's prediction row is TYPING HELP, not results —
// the full ranked results already show IN PLACE in the panel
// ([GlobalSearchResultsView]). So the row suggests the best NEXT WORDS to narrow
// the search, the way a keyboard's suggestion strip is meant to.
//
// PRODUCTS get the finder's own guided engine ([cardKeyboardPredictions] →
// [offerQuestion]) — information-gain-scored, the MOST-DECISIVE next words, not a
// dumb substring match. These helpers add the CROSS-DOMAIN half: next-tokens
// drawn from the titles of the OTHER domains the query currently matches
// (tasks · customers · chats · screens · orders · notifications), and merge the
// two ordered lists into one row.
//
// GUARANTEE: every token these return appears in ≥1 title the query CURRENTLY
// matches, so appending it can NEVER dead-end the search (zero results). And a
// token common to EVERY matching title doesn't narrow, so it is dropped — only
// tokens that actually split the set are offered. Deterministic: same inputs ⇒
// identical output (safe for golden/property tests).
//
// PURE: no widgets, no providers, nothing from lib/screens — directly unit-
// testable, in the spirit of dive_pool.dart / word_lexicon.dart.
// ─────────────────────────────────────────────────────────────────────────────
library;

/// Split [s] into lowercased word tokens on whitespace + common Hebrew/spec name
/// separators (comma · middle-dot · parentheses). Sizes like "1/2" stay ONE token
/// (no split on '/'), so a meaningful spec is never shredded into digits.
List<String> narrowerTokens(String s) => s
    .toLowerCase()
    .split(RegExp(r'[\s,·()]+'))
    .where((t) => t.isNotEmpty)
    .toList();

/// PURE. Given the current [query] and the [titles] of the items it currently
/// matches (across ANY domain), return up to [max] NEXT-TOKEN narrowers: words
/// that appear in those titles but are NOT yet in the query, ranked by how many
/// of the matching titles contain them (the most common next word first — the
/// "salesperson" suggestion). A token present in EVERY matching title does not
/// narrow, so it is skipped whenever more than one title matches — only tokens
/// that actually split the set are offered. Because every token comes FROM a
/// matching title, appending it always leaves ≥1 result (never a dead-end).
/// Tokens shorter than 2 chars are dropped as noise. Deterministic + order-stable
/// (ties broken alphabetically).
List<String> crossDomainNextTokens(String query, Iterable<String> titles,
    {int max = 4}) {
  final titleList = titles.toList();
  final qSet = narrowerTokens(query).toSet();
  final freq = <String, int>{};
  for (final title in titleList) {
    final counted = <String>{};
    for (final tok in narrowerTokens(title)) {
      if (tok.length < 2) continue; // single-char noise
      if (qSet.contains(tok)) continue; // already typed
      if (!counted.add(tok)) continue; // count each title at most once per token
      freq[tok] = (freq[tok] ?? 0) + 1;
    }
  }
  final total = titleList.length;
  final ranked = freq.entries
      // Must NARROW: a token in every matching title (freq == total) keeps the
      // whole set — useless as a narrower. Keep all when there's a single match.
      .where((e) => total <= 1 || e.value < total)
      .toList()
    ..sort((a, b) {
      final byFreq = b.value.compareTo(a.value); // most common next word leads
      return byFreq != 0 ? byFreq : a.key.compareTo(b.key); // stable tie-break
    });
  return [for (final e in ranked.take(max)) e.key];
}

/// PURE. Merge two ordered narrower lists — [primary] leads (e.g. the product
/// engine's information-gain words), [secondary] fills (cross-domain next-tokens)
/// — trimmed, blank-free, de-duplicated (keep the first occurrence), capped at
/// [max]. Order-preserving and deterministic.
List<String> mergeNarrowers(List<String> primary, List<String> secondary,
    {int max = 4}) {
  final seen = <String>{};
  final out = <String>[];
  for (final s in primary.followedBy(secondary)) {
    final t = s.trim();
    if (t.isEmpty || !seen.add(t)) continue;
    out.add(t);
    if (out.length >= max) break;
  }
  return out;
}
