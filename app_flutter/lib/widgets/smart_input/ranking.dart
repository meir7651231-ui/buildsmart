import 'package:buildsmart/widgets/smart_input/models.dart';

/// Frequency at/above which a candidate is treated as "popular" and floated to
/// the front of the list (product rule #1).
const int kPopularThreshold = 3;

/// Pure ordering + capping of suggestion [candidates] per the product rules:
///
/// 1. a candidate whose `text` has frequency `>= kPopularThreshold` (3) in
///    [frequencies] is *popular* and sorts to the FRONT (ties broken by higher
///    frequency first);
/// 2. then by text-match strength against [query]: `startsWith(query)` beats
///    `contains(query)` beats no-match;
/// 3. up to [recentCap] of the most-recent picks (those present in [recent],
///    recent-first) are guaranteed included even if they would fall past the
///    cap;
/// 4. the final list is de-duplicated by `text` and truncated to [cap]; the
///    first surviving item is returned with `isPrimary == true`, the rest
///    `false`.
///
/// Never mutates its inputs. [Suggestion] has no `copyWith`, so primary-marking
/// rebuilds via `Suggestion(c.text, label: c.label, isPrimary: ...)`.
List<Suggestion> rankSuggestions(
  List<Suggestion> candidates, {
  String query = '',
  List<String> recent = const [],
  Map<String, int> frequencies = const {},
  int recentCap = 2,
  int cap = 6,
}) {
  if (cap <= 0 || candidates.isEmpty) return const [];

  // De-duplicate by `text`, first occurrence wins (preserves source order as
  // the stable baseline before the rank sort below).
  final byText = <String, Suggestion>{};
  for (final c in candidates) {
    byText.putIfAbsent(c.text, () => c);
  }
  final unique = byText.values.toList();

  final q = query.trim().toLowerCase();

  int freqOf(Suggestion s) => frequencies[s.text] ?? 0;
  bool isPopular(Suggestion s) => freqOf(s) >= kPopularThreshold;

  // 2 = startsWith, 1 = contains, 0 = no-match (or blank query).
  int matchStrength(Suggestion s) {
    if (q.isEmpty) return 0;
    final t = s.text.toLowerCase();
    if (t.startsWith(q)) return 2;
    if (t.contains(q)) return 1;
    return 0;
  }

  // Stable rank sort: popular-first, then higher frequency, then match
  // strength. We keep original index as the final tiebreaker so the sort is
  // deterministic and stable.
  final indexed = <MapEntry<int, Suggestion>>[
    for (var i = 0; i < unique.length; i++) MapEntry(i, unique[i]),
  ];
  indexed.sort((a, b) {
    final sa = a.value, sb = b.value;
    final pa = isPopular(sa), pb = isPopular(sb);
    if (pa != pb) return pa ? -1 : 1; // popular to the front
    if (pa && pb) {
      final f = freqOf(sb).compareTo(freqOf(sa)); // higher frequency first
      if (f != 0) return f;
    }
    final m = matchStrength(sb).compareTo(matchStrength(sa)); // stronger first
    if (m != 0) return m;
    return a.key.compareTo(b.key); // stable
  });
  final ranked = [for (final e in indexed) e.value];

  // Guaranteed-recent: up to [recentCap] items whose text is in [recent],
  // taken recent-first, that actually exist among the candidates.
  final guaranteed = <Suggestion>[];
  final guaranteedTexts = <String>{};
  for (final t in recent) {
    if (guaranteed.length >= recentCap) break;
    final s = byText[t];
    if (s != null && guaranteedTexts.add(t)) guaranteed.add(s);
  }

  // Compose: guaranteed picks first (so they survive the cap), then the ranked
  // remainder, skipping any text already placed. Truncate to [cap].
  final out = <Suggestion>[];
  final seen = <String>{};
  void push(Suggestion s) {
    if (out.length >= cap) return;
    if (seen.add(s.text)) out.add(s);
  }

  for (final s in guaranteed) {
    push(s);
  }
  for (final s in ranked) {
    if (out.length >= cap) break;
    push(s);
  }

  // First item is primary, the rest are not.
  return [
    for (var i = 0; i < out.length; i++)
      Suggestion(out[i].text, label: out[i].label, isPrimary: i == 0),
  ];
}
