// 🧰⋈📦 EQUIPMENT ⋈ EMPLOYER-STOCK JOIN (Wave E2, task #112) — the PURE,
// VM-safe (no widgets, no Firebase, no Riverpod) join that answers, for one
// equipment-checklist label, "does the EMPLOYER (contractor) currently stock
// this, and where?". Consumed by `worker_equipment_checklist_sheet.dart` to
// render a per-row availability chip from the worker's READ-ONLY projection of
// the employer's stock (`employerStockProvider` → `List<EmployerStockItem>`).
//
// HONESTY (אין-המצאות, the PARKED join-key decision in _waveE2-contracts.md):
// the equipment `KitItem.label` (e.g. 'סרט טפלון (PTFE)') and a stock item name
// (e.g. 'סרט טפלון') are NOT identical strings. We annotate a line as available
// ONLY on a normalized WHOLE-TOKEN correspondence — exact equality, or one
// side's token-sequence appearing as a contiguous run of WHOLE tokens inside
// the other (with the contained side carrying ≥2 tokens). A lone generic token
// (מפתח/שקע/עט) never matches by containment, and a token-based match can never
// fire on a mid-word fragment or a substring that spans the normalized space —
// so no match is ever fabricated. No stock, no correspondence, or only a
// single-token non-equal overlap → `StockAvailability.unknown`, which the sheet
// renders as the honest 'זמינות לא ידועה'. A curated explicit mapping table is
// a possible later refinement; today the match is purely token-normalized.

import 'package:buildsmart/state/employer_stock.dart';

/// Where the employer currently holds a piece of equipment, as the worker's
/// checklist surfaces it. [warehouse] / [site] mirror [EmployerStockItem.location]
/// (`'warehouse'` / `'site'`); [unknown] is the HONEST default — no stock, no
/// match, or a match too weak to assert (never a fabricated correspondence).
enum StockAvailability { warehouse, site, unknown }

/// Normalize one side of the join: trim, lower-case, and collapse every run of
/// whitespace AND punctuation (anything that is not a letter/digit, across
/// scripts incl. Hebrew via Unicode-aware classes) into a single space, then
/// trim again. So 'סרט טפלון (PTFE)' and '  סרט   טפלון – ptfe ' both reduce to
/// a clean space-separated core, and 'Wrench, 1/2"' → 'wrench 1 2'. Punctuation
/// becomes a separator (not a deletion) so adjacent words never fuse.
String _normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

/// Split a normalized string into its whitespace-separated tokens. An empty
/// normalized string yields an empty list (no tokens → never matches).
List<String> _tokens(String normalized) =>
    normalized.isEmpty ? const [] : normalized.split(' ');

/// True iff [needle]'s token-sequence appears as a CONTIGUOUS run inside
/// [haystack]'s token-sequence (whole-token alignment — no mid-word or
/// cross-space substring is possible because we compare whole tokens). An empty
/// [needle] never matches. A single-token [needle] is intentionally NOT matched
/// here (callers handle single-token correspondence via exact equality only) —
/// this is what keeps a generic short stock token (מפתח/שקע/עט) from
/// fabricating availability against a longer label that merely contains it.
bool _isContiguousSubsequence(List<String> needle, List<String> haystack) {
  if (needle.length < 2 || needle.length > haystack.length) return false;
  final last = haystack.length - needle.length;
  outer:
  for (var i = 0; i <= last; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}

/// Map a stock item's raw [EmployerStockItem.location] to the enum. Anything
/// other than the canonical `'warehouse'` is treated as on-site (the stock map
/// only ever holds `'warehouse'`/`'site'`; an unexpected value is surfaced as
/// `site` rather than silently dropped to `unknown`, since the item DOES exist).
StockAvailability _locationToAvailability(String location) =>
    location == 'warehouse'
        ? StockAvailability.warehouse
        : StockAvailability.site;

/// PURE join (the E2 cross-file contract, frozen — unit-tested by E2b):
/// resolve one [equipmentLabel] against the employer's [stock]. Matching is
/// WHOLE-TOKEN aware (both sides are normalized then split on space) — a stock
/// item matches the label iff:
///   • the normalized name EQUALS the normalized label (exact, any token
///     count), OR
///   • the name has ≥2 tokens AND its token-sequence is a contiguous
///     sub-sequence of the label's tokens, OR
///   • the label has ≥2 tokens AND its token-sequence is a contiguous
///     sub-sequence of the name's tokens.
/// A SINGLE-token name/label matches ONLY by exact equality — so a generic
/// short stock token (מפתח/שקע/עט) never fabricates availability merely by
/// sitting inside a longer label, and (token-based) no mid-word or
/// cross-space substring can ever match. Otherwise — empty stock or no
/// token-aligned correspondence — returns [StockAvailability.unknown]. NEVER
/// fabricates a correspondence. First match wins in the given (already
/// deterministic, warehouse-first) stock order.
StockAvailability availabilityFor(
  String equipmentLabel,
  List<EmployerStockItem> stock,
) {
  final label = _normalize(equipmentLabel);
  // No usable label → nothing to honestly match against.
  if (label.isEmpty) return StockAvailability.unknown;
  final labelTokens = _tokens(label);

  for (final item in stock) {
    final name = _normalize(item.name);
    if (name.isEmpty) continue;
    final nameTokens = _tokens(name);

    // Honest match: exact normalized equality, OR a whole-token contiguous
    // sub-sequence in either direction (the ≥2-token guard lives in
    // _isContiguousSubsequence, so a lone generic token cannot fabricate a
    // hit). The label may carry extra qualifiers like '(PTFE)'/'12"' that the
    // stock name omits, or vice-versa — those survive as a token subsequence.
    final hit = name == label ||
        _isContiguousSubsequence(nameTokens, labelTokens) ||
        _isContiguousSubsequence(labelTokens, nameTokens);
    if (hit) return _locationToAvailability(item.location);
  }
  return StockAvailability.unknown;
}

/// Optional convenience for the sheet: annotate a list of [labels] against the
/// employer's [stock] in one pass, preserving input order. Each entry pairs the
/// ORIGINAL (un-normalized) label with its [availabilityFor] result.
List<({String label, StockAvailability availability})> annotate(
  List<String> labels,
  List<EmployerStockItem> stock,
) =>
    [
      for (final label in labels)
        (label: label, availability: availabilityFor(label, stock)),
    ];
