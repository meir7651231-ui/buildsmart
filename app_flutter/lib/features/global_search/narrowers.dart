// ─────────────────────────────────────────────────────────────────────────────
// NARROWERS — pure typing-help for the OPTION-B prediction row (kGlobalSearch).
//
// Owner "option B, very high quality": the keyboard's prediction row is TYPING
// HELP, not results — the full ranked results already show IN PLACE in the panel
// ([GlobalSearchResultsView]). So the row suggests the best NEXT WORDS to narrow
// the search. PRODUCTS get the finder's own information-gain engine
// ([cardKeyboardPredictions] → [offerQuestion]); these helpers add the CROSS-
// DOMAIN half — next-words from the titles of the OTHER domains the query matches.
//
// NO-DEAD-END, PROVEN BY CONSTRUCTION: the keyboard appends a tapped word with a
// space (`"$query "` → `"$query $tok"`), and the results panel matches an entity
// title by CONTIGUOUS substring. So a cross-domain suggestion is safe ONLY if it
// is the word that IMMEDIATELY FOLLOWS the query in a matching title — then
// `"$query $tok"` is itself a substring of that title and the panel keeps ≥1
// result. [crossDomainNextTokens] offers exactly those successor words (adversarial
// swarm HIGH finding: a frequency-only picker dead-ended "אברהם"→"משה" because
// names read first-last, never reversed). Ranked by how many titles share the
// continuation (most common next word first).
//
// PURE: no widgets, no providers, nothing from lib/screens — directly unit-
// testable, in the spirit of dive_pool.dart / word_lexicon.dart.
// ─────────────────────────────────────────────────────────────────────────────
library;

/// Token separators: whitespace · comma · middle-dot · parentheses · hyphen and
/// en/em dashes. Deliberately NOT '/' '"' '.' — so numeric sizes ("1/2") and
/// Hebrew abbreviations ("ש״ת", "ח.פ.") stay ONE token instead of shredding.
final RegExp _sep = RegExp(r'[\s,·()–—-]+');

/// Punctuation stripped from a token's ENDS only (internal kept, so "ש״ת" and
/// "ח.פ" survive): period · asterisk · hash · quote · apostrophe · geresh ·
/// gershayim. Kills junk chips like "מס." · "*עם" · a dangling inch-mark.
const String _edge = '.*#"\'׳״';

String _trimEdges(String t) {
  var start = 0;
  var end = t.length;
  while (start < end && _edge.contains(t[start])) start++;
  while (end > start && _edge.contains(t[end - 1])) end--;
  return start == 0 && end == t.length ? t : t.substring(start, end);
}

/// Split [s] into lowercased word tokens, edge-punctuation trimmed and blanks
/// dropped. See [_sep] / [_edge] for the exact rules (sizes + Hebrew abbreviations
/// stay whole; leading/trailing junk is cleaned).
List<String> narrowerTokens(String s) {
  final out = <String>[];
  for (final raw in s.toLowerCase().split(_sep)) {
    final t = _trimEdges(raw);
    if (t.isNotEmpty) out.add(t);
  }
  return out;
}

/// PURE. OPTION-B next-word suggestions for [query], given the [titles] of the
/// items it currently matches (across the entity domains). Returns up to [max]
/// words, each of which IMMEDIATELY FOLLOWS the query as a contiguous run in ≥1
/// title (`"$query $tok"`), ranked by how many titles share that continuation
/// (most common next word first). Because the results panel matches by contiguous
/// substring and the keyboard appends `"$tok "`, every suggestion keeps ≥1 result
/// — it can NEVER dead-end the search. Successor words shorter than 2 GRAPHEMES
/// (astral-safe: a bare emoji is dropped) or already in the query are skipped.
/// An empty query yields nothing (the product engine supplies the opening words).
/// Deterministic + order-stable (freq desc, then token asc; keys are unique).
List<String> crossDomainNextTokens(String query, Iterable<String> titles,
    {int max = 4}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty || max <= 0) return const <String>[];
  final needle = '$q ';
  final qSet = narrowerTokens(q).toSet();
  final freq = <String, int>{};
  for (final raw in titles) {
    final title = raw.toLowerCase();
    final counted = <String>{}; // count each title at most once per successor
    var i = title.indexOf(needle);
    while (i != -1) {
      final rest = narrowerTokens(title.substring(i + needle.length));
      if (rest.isNotEmpty) {
        final tok = rest.first; // the word that immediately follows the query
        if (tok.runes.length >= 2 && !qSet.contains(tok) && counted.add(tok)) {
          freq[tok] = (freq[tok] ?? 0) + 1;
        }
      }
      i = title.indexOf(needle, i + 1);
    }
  }
  final ranked = freq.entries.toList()
    ..sort((a, b) {
      final byFreq = b.value.compareTo(a.value); // most common next word leads
      return byFreq != 0 ? byFreq : a.key.compareTo(b.key); // stable tie-break
    });
  return [for (final e in ranked.take(max)) e.key];
}

/// PURE. Merge two ordered narrower lists — [primary] leads (e.g. the product
/// engine's information-gain words), [secondary] fills (cross-domain successors)
/// — trimmed, blank-free, de-duplicated (keep the first occurrence), capped at
/// [max]. Guards a non-positive [max]. Order-preserving and deterministic.
List<String> mergeNarrowers(List<String> primary, List<String> secondary,
    {int max = 4}) {
  if (max <= 0) return const <String>[];
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
