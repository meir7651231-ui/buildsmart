// ai_interpret.dart — the AI mouth's free-text -> query interpreter (P5.60), the
// unified finder's 4th input. The user types a whole request ("אני צריך משהו אדום")
// and SUBMITS it; the dive seeds from the interpreted query. The DEFAULT is OFFLINE
// and pure (strip everyday Hebrew filler, then fold synonyms) — the contract's
// "literal-offline works" floor — and an online semantic gateway is injected OVER
// it as an [AiInterpret]. So the AI mouth never dead-ends on a missing connection;
// it just degrades to keyword extraction. PURE.

import 'package:buildsmart/features/word_finder/synonym_bridge.dart'
    show normalizeQuery;

/// Everyday Hebrew filler the user wraps a request in ("אני צריך משהו ל…") that
/// carries no product signal. Dropped before the query reaches resolveQuery, so a
/// whole sentence narrows like its keywords would. WHOLE-TOKEN only — it never
/// strips a prefix (בזווית stays intact) and keeps meaningful verbs/nouns.
const Set<String> kAiFillerWords = {
  'אני', 'צריך', 'צריכה', 'רוצה', 'משהו', 'את', 'של', 'עם', 'זה', 'כדי',
  'איזה', 'יש', 'לי', 'בבקשה', 'תביא', 'תן', 'חפש', 'מצא', 'אפשר', 'הביא',
};

/// The voice/AI seam: free text -> a query string. Async because an online gateway
/// may be remote. A test injects a fake; production defaults to [defaultAiInterpret].
typedef AiInterpret = Future<String> Function(String freeText);

/// Offline, pure interpreter: drop filler tokens, then fold synonyms. NEVER empty —
/// if every token was filler it falls back to the original (normalized) text, so
/// the dive always gets a non-empty seed.
String aiLiteralInterpret(String freeText) {
  final kept = freeText
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty && !kAiFillerWords.contains(t))
      .toList();
  final base = kept.isEmpty ? freeText : kept.join(' ');
  return normalizeQuery(base);
}

/// The production default — the offline interpreter. A semantic gateway is layered
/// over this by INJECTING a different [AiInterpret] into the screen, never by
/// editing this floor. Async to match the seam.
Future<String> defaultAiInterpret(String freeText) async =>
    aiLiteralInterpret(freeText);
