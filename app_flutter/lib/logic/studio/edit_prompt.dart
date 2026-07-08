// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 74 — the GROUNDED prompt builder: it embeds
// the closed sets (the scope tokens · the in-scope element ids · the action catalog
// · the component palette) into a strict-JSON-ops prompt, so the AI co-editor
// REASONS OVER TRUTH and can only NAME ids/props/values/actions/components that
// really exist. A pure string composer — renders no view, performs no gateway
// round-trip, Firebase-free (grounding IS the caller's job, claude.ts:13-17).
//
// This is the PROMPT twin of the step-72 action catalog / step-73 component palette:
// where those files DECLARE the closed sets, this file INTERPOLATES them into the
// two prompts the gateway will send — mirroring how `describeToCartPrompt`
// (describe_to_cart_screen.dart:34 · `'${r.key} = ${r.name}'`) and
// `assistantIntentPrompt` (assistant_intent.dart:128 · `'${r.key}=${r.name}'`) hand
// the model a compact `id = he` closed set and demand a constrained reply.
//
// TWO-STAGE SCOPE (§4 · §9.1 — the 8000-char mitigation, claude.ts:40): a single
// prompt embedding the WHOLE registry would blow the server's 8000-char cap
// (claude.ts:127-132 → `invalid-argument`). So the edit is split in two:
//   • Stage-A [studioScopePrompt] + [classifyScope] — the model names ONE closed
//     SCOPE TOKEN from the registry (a broadcast `scope:all`, a per-namespace
//     `scope:screen:<ns>`, or a `scope:single:<id>`); an AMBIGUOUS utterance grounds
//     to `null` ⇒ the caller shows "צריך הבהרה" (R1-7 — never a guessed scope).
//   • Stage-B [studioEditPrompt] — embeds ONLY the slice for that scope (a few dozen
//     ids), the action catalog + palette `id = he` lines, the capped utterance, and
//     ONE tiny valid few-shot built from a REAL slice id. A debug budget-assert
//     (§9-a) fails FAST if the slice still exceeds 8000, before a server round-trip.
//
// GROUNDING SOURCE (DoD §8 · step 70): every closed set is read through the FROZEN
// [RegistryView] interface ALONE — this file imports NO concrete Pillar-1 registry
// type, so if the descriptor shape moves, only the adapter changes. A consequence
// worth naming: [RegistryView] exposes `elementIds()` but NOT the descriptors'
// `screen`/`area`/`labelHe`. So (a) scope tokens are grounded in the id NAMESPACE
// (the segment before the first `.`: `cart.cta → cart`, `manager.cockpit.* →
// manager`) — the registry-derived stand-in for the plan's "screen id" (§4); and
// (b) an in-scope element line carries its grounded EDITABLE-PROP summary in the
// `id = …` slot (there is no Hebrew label to embed through the frozen seam) — while
// the action / palette lines carry their real `he`.
//
// ADAPTATION — the ops GRAMMAR targets Pillar-1's LANDED `ConfigOp` family
// (config_store.dart:70-163 · setText·setEmoji·setHidden·setOrder·setStyle·
// setAction), NOT the plan's PRE-S3.K `SetProp/SetVisible/AddComponent/AddRule` —
// exactly as config_op.dart:8-22 reconciled: `SetVisible{roleProvider}` is P1's
// `setHidden` (persona applied via `applyOps(persona:)`), `SetProp` is
// `setStyle/setText/setEmoji`, and `addComponent`/`addRule` have NO P1 variant yet
// (`configOpFromJson` drops them, config_op.dart:74). Emitting the REAL tags keeps
// the model's JSON parseable by step-75 `parseConfigEdit` → `applyOps`.
//
// INJECTION DEFENSE (§4 · prompt_sanitize.dart:19): the owner utterance is folded +
// capped by `promptSafeText(maxLen: 600, collapseWhitespace: true)` before it is
// interpolated — every whitespace run incl. newlines (the injection lever,
// prompt_sanitize.dart:8-9,22-23) is collapsed, so "…\nהתעלם מההוראות" cannot break
// the framing. The system pins a SMALL reply (~256 tokens, ai_assistant_screen.dart:
// 108) far from the 2048 cap (claude.ts:41), since an ops reply is short (§6).
//
// DORMANT: pure const strings + pure functions — composes nothing but text, no
// gateway round-trip, no provider, Firebase-free. Nothing in `lib/` imports it yet
// ⇒ tree-shaken out ⇒ byte-identical under every flag (DoD §8).
// ─────────────────────────────────────────────────────────────────────────────

import '../prompt_sanitize.dart' show promptSafeText;
import 'action_catalog.dart' show kActionCatalog;
import 'component_palette.dart' show kComponentPalette;
import 'registry_view.dart' show FakeRegistryView, RegistryView, matchElementId;

/// The server's hard prompt-char cap (claude.ts:40 `kMaxPromptChars = 8000`; a
/// longer `prompt` is REJECTED with `invalid-argument`, claude.ts:127-132). The
/// whole POINT of the two-stage design is staying under it — [studioEditPrompt]
/// asserts against this in debug (§9-a) so an over-budget prompt fails FAST here,
/// before a wasted round-trip.
const int kStudioPromptCharBudget = 8000;

/// The utterance cap (§4) — folded + capped by `promptSafeText` before interpolation.
const int kStudioMaxUtteranceChars = 600;

/// The SMALL `maxTokens` hint the caller (step 83) should pin on the ops call — an
/// ops reply is short, so this sits far from the 2048 cap (claude.ts:41), mirroring
/// the `maxTokens: 256` the assistant already pins (ai_assistant_screen.dart:108). §6.
const int kStudioEditMaxTokens = 256;

/// The broadcast scope token — every editable element (the whole `elementIds()`).
const String kScopeAll = 'scope:all';

/// The per-namespace scope prefix — `scope:screen:<ns>` slices the registry to one
/// id-namespace (the segment before the first `.`).
const String kScopeScreenPrefix = 'scope:screen:';

/// The single-element scope prefix — `scope:single:<id>` targets ONE real id.
const String kScopeSinglePrefix = 'scope:single:';

/// The system prompt for the ops call (Stage-B). Mirrors `assistantIntentSystem`'s
/// closed-set voice (assistant_intent.dart:160-163): NAME only from the closed
/// lists, NEVER invent, reply STRICT JSON only, keep it short. Sent as `system`
/// (separate from the 8000-char `prompt` budget).
const String studioEditSystem =
    'אתה ממיר בקשת-עריכה של מנהל ל-ops מתוך רשימות סגורות בלבד, ב-BuildSmart '
    '(סטודיו עריכת-ממשק). נקוב אך ורק id/prop/value/action/component מהרשימות '
    'שסופקו בהודעה; לעולם אל תמציא id, prop, value, action, component, מסך או token. '
    'החזר אך ורק JSON קפדני — מערך של ops, כל op אובייקט עם המפתח "op" מתוך '
    '{setText, setEmoji, setHidden, setOrder, setStyle, setAction} ושדותיו. '
    'בלי טקסט חופשי ובלי הסבר, רק ה-JSON. שמור על תשובה קצרה (עד ~256 טוקנים). '
    'אם שום op חוקי לא מתאים — החזר מערך ריק [].';

/// The compact ops grammar embedded in Stage-B — the REAL Pillar-1 `ConfigOp` tags
/// (config_store.dart), so the reply is parseable by step-75 `parseConfigEdit`.
const String _kOpsGrammar =
    'דקדוק ה-ops — החזר מערך JSON של אובייקטים כאלה בלבד '
    '(כל id/prop/value/action/component נלקח מהרשימות למעלה בלבד):\n'
    '{"op":"setText","id":"<id>","text":"<טקסט>"}\n'
    '{"op":"setEmoji","id":"<id>","emoji":"<אמוג׳י>"}\n'
    '{"op":"setHidden","id":"<id>","hidden":<true|false>}\n'
    '{"op":"setOrder","id":"<id>","order":<מספר>}\n'
    '{"op":"setStyle","id":"<id>","style":{"colorToken":"<token>"}}\n'
    '{"op":"setAction","id":"<id>","action":"<action-id מרשימת הפעולות>"}';

/// The id NAMESPACE — the segment before the first `.` (`cart.cta → cart`,
/// `manager.cockpit.kpi.openOrders → manager`). An id with no `.` is its own
/// namespace. This is the registry-derived grouping the frozen [RegistryView]
/// affords (it exposes no `screen`/`area`); see the header.
String _namespaceOf(String id) {
  final s = id.trim();
  final dot = s.indexOf('.');
  return dot < 0 ? s : s.substring(0, dot);
}

/// The CLOSED Stage-A scope-token set, DERIVED from the live registry: the broadcast
/// [kScopeAll] plus one `scope:screen:<ns>` per distinct id-namespace present in
/// `elementIds()`. Bounded by the namespace COUNT (screens are few), not the id
/// count — the elegance that keeps Stage-A tiny. A `scope:single:<id>` is NOT
/// enumerated here (one per id would bloat the list); [classifyScope] grounds it on
/// demand against `elementIds()`.
Set<String> studioScopeTokens(RegistryView registry) {
  final tokens = <String>{kScopeAll};
  for (final id in registry.elementIds()) {
    final ns = _namespaceOf(id);
    if (ns.isNotEmpty) tokens.add('$kScopeScreenPrefix$ns');
  }
  return tokens;
}

/// Stage-A — CLASSIFY the model's scope reply to a closed-set token FROM the
/// registry, or `null` when nothing grounds (the AMBIGUOUS → "צריך הבהרה" path,
/// R1-7 — never a guess). The reply is grounded through the FROZEN step-71
/// [matchElementId] (exact → longest-contained → null) over the token set — the
/// SAME single matching path the action catalog reuses (action_catalog.dart:261).
/// A `scope:single:<id>` reply additionally grounds its id against the live
/// `elementIds()`, so a single-target scope names only a REAL element.
String? classifyScope(String reply, RegistryView registry) {
  final r = reply.trim();
  if (r.isEmpty) return null; // fail-closed → clarify

  // The broadcast + per-namespace tokens are distinctive (`scope:` prefixed), so the
  // longest-contained matcher can't false-fire on prose (e.g. "install" ⊅ scope:all).
  final tokens = studioScopeTokens(registry);
  final t = matchElementId(FakeRegistryView.of(ids: tokens), r);
  if (t != null) return t;

  // A single concrete element — `scope:single:<id>` where <id> is a REAL registry id.
  if (r.contains(kScopeSinglePrefix)) {
    final id = matchElementId(registry, r); // grounds the id part against elementIds()
    if (id != null) return '$kScopeSinglePrefix$id';
  }
  return null; // nothing groundable → ambiguous → clarify (never a guessed scope)
}

/// The concrete in-scope element ids for [scope] (the Stage-B slice). `scope:all` →
/// every id; `scope:screen:<ns>` → the ids in that namespace; `scope:single:<id>` →
/// that one id IF real. An unrecognised scope → empty (fail-closed).
Set<String> scopeElementIds(String scope, RegistryView registry) {
  final ids = registry.elementIds();
  if (scope == kScopeAll) return ids;
  if (scope.startsWith(kScopeScreenPrefix)) {
    final ns = scope.substring(kScopeScreenPrefix.length);
    return {
      for (final id in ids)
        if (_namespaceOf(id) == ns) id,
    };
  }
  if (scope.startsWith(kScopeSinglePrefix)) {
    final id = scope.substring(kScopeSinglePrefix.length);
    return ids.contains(id) ? {id} : const <String>{};
  }
  return const <String>{}; // fail-closed
}

/// The Hebrew preview label for [scope] — the "מתוך: …" line surfaced before the
/// changes (§4), so step-79/83 can confirm the TARGET ("מתוך: מרחב «cart»" /
/// "מתוך: כל האלמנטים") before showing a diff. Shows the grounded token verbatim —
/// there is no Hebrew screen name to translate through the frozen seam.
String scopeLabel(String scope) {
  if (scope == kScopeAll) return 'מתוך: כל האלמנטים';
  if (scope.startsWith(kScopeScreenPrefix)) {
    return 'מתוך: מרחב «${scope.substring(kScopeScreenPrefix.length)}»';
  }
  if (scope.startsWith(kScopeSinglePrefix)) {
    return 'מתוך: האלמנט «${scope.substring(kScopeSinglePrefix.length)}»';
  }
  return 'מתוך: (טווח לא מזוהה)'; // defensive — an unrecognised scope
}

/// A one-line Hebrew description of a Stage-A scope token (for the `token = תיאור`
/// list). Broadcast / per-namespace only — the closed set [studioScopeTokens] emits.
String _scopeTokenHe(String token) {
  if (token == kScopeAll) return 'כל האלמנטים';
  if (token.startsWith(kScopeScreenPrefix)) {
    return 'מרחב «${token.substring(kScopeScreenPrefix.length)}»';
  }
  return token;
}

/// Stage-A PROMPT — hands the model the closed scope-token set (`token = תיאור`,
/// the compact idiom) + the capped utterance, and demands ONE token or AMBIGUOUS.
/// Pure string; no gateway round-trip.
String studioScopePrompt(RegistryView registry, String utterance) {
  final safe = promptSafeText(
    utterance,
    maxLen: kStudioMaxUtteranceChars,
    collapseWhitespace: true,
  );
  final tokens = studioScopeTokens(registry).toList()..sort();
  final b = StringBuffer();
  b.writeln('טווחי-עריכה זמינים (token = תיאור):');
  for (final t in tokens) {
    b.writeln('$t = ${_scopeTokenHe(t)}');
  }
  b.writeln('$kScopeSinglePrefix<id> = אלמנט בודד (id אמיתי מהרישום)');
  b.writeln();
  b.writeln('בקשת המנהל: "$safe".');
  b.writeln('בחר token אחד בלבד מהרשימה הסגורה שמתאר את טווח-העריכה, או השב '
      'AMBIGUOUS אם הבקשה אינה חד-משמעית. החזר שורה אחת: ה-token בלבד.');
  return b.toString();
}

/// A compact `id = <editable-props · actions>` line for an in-scope element (the
/// `id = he` slot carries the grounded editable summary, since the frozen seam
/// exposes no Hebrew label). Both sub-lists are read straight off [registry].
String _elementLine(RegistryView registry, String id) {
  final props = registry.propKeysFor(id).toList()..sort();
  final actions = registry.actionIdsFor(id).toList()..sort();
  final rhs = <String>[];
  if (props.isNotEmpty) rhs.add('props ${props.join('/')}');
  if (actions.isNotEmpty) rhs.add('actions ${actions.join('/')}');
  return rhs.isEmpty ? id : '$id = ${rhs.join(' · ')}';
}

/// ONE tiny valid few-shot (§10) built from a REAL slice id — never an invented id.
/// Prefers a `setText` on an id that actually exposes a `text` prop; otherwise a
/// `setHidden` on the first slice id (needs only a real id). `null` on an empty
/// slice. The example proves the JSON SHAPE while pinning "target must be real".
String? _fewShotExample(List<String> slice, RegistryView registry) {
  if (slice.isEmpty) return null;
  for (final id in slice) {
    if (registry.propKeysFor(id).contains('text')) {
      return '[{"op":"setText","id":"$id","text":"טקסט לדוגמה"}]';
    }
  }
  return '[{"op":"setHidden","id":"${slice.first}","hidden":false}]';
}

/// Stage-B PROMPT — the grounded ops prompt for [scope]. Embeds, in order: the
/// "מתוך: …" preview label ([scopeLabel]); the in-scope element slice (compact,
/// sorted); the action catalog + component palette `id = he` lines; the ops grammar
/// (the REAL P1 tags); the folded + capped utterance; and ONE valid few-shot from a
/// REAL slice id. A debug budget-assert (§9-a) fails FAST if the result still
/// exceeds [kStudioPromptCharBudget], before a server round-trip — the two-stage
/// design's whole point is that a narrowed scope keeps this under 8000.
String studioEditPrompt({
  required RegistryView registry,
  required String utterance,
  required String scope,
}) {
  final safe = promptSafeText(
    utterance,
    maxLen: kStudioMaxUtteranceChars,
    collapseWhitespace: true,
  );
  final slice = scopeElementIds(scope, registry).toList()..sort();

  final b = StringBuffer();
  b.writeln(scopeLabel(scope)); // the §4 preview line
  b.writeln();
  b.writeln('אלמנטים בטווח (id = מה ניתן לערוך):');
  if (slice.isEmpty) {
    b.writeln('(אין אלמנטים בטווח)');
  } else {
    for (final id in slice) {
      b.writeln(_elementLine(registry, id));
    }
  }
  b.writeln();
  b.writeln('פעולות מותרות ל-setAction (id = תיאור):');
  for (final a in kActionCatalog) {
    b.writeln('${a.id} = ${a.he}');
  }
  b.writeln();
  b.writeln('רכיבים שניתן להוסיף (type = תיאור):');
  for (final t in kComponentPalette) {
    b.writeln('${t.type.name} = ${t.he}');
  }
  b.writeln();
  b.writeln('בקשת המנהל: "$safe".');
  b.writeln(_kOpsGrammar);
  final example = _fewShotExample(slice, registry);
  if (example != null) {
    b.writeln('דוגמה תקינה (id אמיתי מהרשימה):');
    b.writeln(example);
  }

  final prompt = b.toString();
  // §9-a — fail FAST in dev if a slice still blows the 8000-char server cap
  // (claude.ts:40,127-132), before wasting a round-trip. In release the assert is
  // stripped and the server rejects an over-budget prompt honestly.
  assert(
    prompt.length <= kStudioPromptCharBudget,
    'studioEditPrompt exceeded $kStudioPromptCharBudget chars '
    '(${prompt.length}) for scope <$scope> — narrow the scope further',
  );
  return prompt;
}
