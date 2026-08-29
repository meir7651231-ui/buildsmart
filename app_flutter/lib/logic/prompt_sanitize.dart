// ─────────────────────────────────────────────────────────────────────────────
// promptSafeText — defang untrusted free-text before it is interpolated into a
// Claude prompt (audit גל-5). The closed-set validators (matchRecipe/matchCategory/
// parseAssistantIntent) are the PRIMARY grounding defense; this is defense-in-depth
// for the spots where attacker-controlled text reaches a prompt:
//   • a profile `displayName` flowing into the reject-reason prompt, whose reply is
//     shown as PROSE (no closed-set after it) — the one live injection lever, so it
//     is collapsed (newlines stripped) + hard-capped short.
//   • free-text job descriptions / search queries / chat — closed-set-contained, so
//     here the cap is only a length bound (cost / context-stuffing), preserving the
//     user's text otherwise.
// ─────────────────────────────────────────────────────────────────────────────

/// Returns [raw] trimmed and capped at [maxLen] characters. When
/// [collapseWhitespace] is true, every run of whitespace (incl. newlines/tabs — a
/// prompt-injection lever) is first collapsed to a single space; use it for values
/// that legitimately have no line structure (a name). Leave it false to length-cap
/// multi-line free-text in place.
String promptSafeText(String raw,
    {int maxLen = 600, bool collapseWhitespace = false}) {
  var s = raw;
  if (collapseWhitespace) {
    s = s.replaceAll(RegExp(r'\s+'), ' ');
  }
  s = s.trim();
  return s.length <= maxLen ? s : s.substring(0, maxLen).trim();
}
