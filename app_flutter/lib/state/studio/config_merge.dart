// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 3 — the pure merge (the zero-regression keystone).
//
// `mergeNode` resolves one element's effective override by folding the layers in
// increasing specificity:
//     identity ⊕ published.global ⊕ published.persona[roleKey]
//              ⊕ draft.global ⊕ draft.persona[roleKey]   (draft only if includeDraft)
// Most-specific non-null wins, PER AXIS. Nested `CfgStyle`/`CfgAction` are merged
// FIELD-BY-FIELD (R1-A2-merge · R2-#5): a draft that sets only `fontScale` keeps the
// published `colorToken` instead of clobbering the whole style.
//
// persona is keyed by the canonical role STRING via [roleKeyOf] — `null`/empty =
// contractor → 'contractor' (R1-A2 · R2-#4: never a raw `null` key, never `BoardRole`).
// `criticalIds` is INJECTED (not imported) to keep this function pure + cycle-free
// (the seed arrives at step 26); a critical id can never resolve to hidden.
//
// PURE: imports only the value-objects + the doc — NO Flutter/widgets — so it is
// trivially testable and is THE proof that every wrapper is identity-equivalent when
// the doc is empty (⇒ kStudioFlag OFF ⇒ zero-regression). Canonical: studio-plan/01
// §1 + §2.1 (+ R1/R2).
// ─────────────────────────────────────────────────────────────────────────────

import 'config_doc.dart';
import 'config_node.dart';

/// Canonical persona key. `roleProvider` is `String?` with `null`/'' = contractor;
/// every read/write keys persona by this string, never by a raw `null`/`BoardRole`.
String roleKeyOf(String? role) =>
    (role == null || role.isEmpty) ? 'contractor' : role;

/// The resolved override for [id] under [roleKey]. Empty doc ⇒ `CfgNode.identity`
/// (no override) — the load-bearing zero-regression contract.
CfgNode mergeNode(
  String id,
  ConfigDoc doc,
  String roleKey, {
  bool includeDraft = false,
  Set<String> criticalIds = const {},
}) {
  // Least → most specific. Draft layers participate only when previewing (owner).
  final draftPersona = includeDraft ? doc.draft.persona[roleKey] : null;
  CfgNode out = CfgNode.identity;
  out = _overlay(out, doc.published.global[id]);
  out = _overlay(out, doc.published.persona[roleKey]?[id]);
  if (includeDraft) {
    out = _overlay(out, doc.draft.global[id]);
    out = _overlay(out, draftPersona?[id]);
  }

  // Critical/immutable elements can never be hidden (defence-in-depth; the inspector
  // + publish-validator enforce the same — steps 26/27). Clear `hidden` if set.
  if (out.hidden != null && criticalIds.contains(id)) {
    out = CfgNode(
      text: out.text,
      emoji: out.emoji,
      order: out.order,
      style: out.style,
      action: out.action,
      extra: out.extra,
    );
  }
  return out;
}

/// Overlay [over] onto [base] — per-axis, most-specific (over) wins; nested
/// style/action merged field-by-field; `extra` unioned (later layer wins a key).
CfgNode _overlay(CfgNode base, CfgNode? over) {
  if (over == null || over.isEmpty) return base;
  return CfgNode(
    text: over.text ?? base.text,
    emoji: over.emoji ?? base.emoji,
    hidden: over.hidden ?? base.hidden,
    order: over.order ?? base.order,
    style: mergeStyle(base.style, over.style),
    action: mergeAction(base.action, over.action),
    extra: base.extra.isEmpty && over.extra.isEmpty
        ? const {}
        : {...base.extra, ...over.extra},
  );
}

/// Field-by-field style merge (R1/R2): an over that sets one sub-axis keeps the
/// rest from base. (The old "style as one unit" overwrite is cancelled.)
CfgStyle? mergeStyle(CfgStyle? base, CfgStyle? over) {
  if (over == null) return base;
  if (base == null) return over;
  return CfgStyle(
    colorToken: over.colorToken ?? base.colorToken,
    bgToken: over.bgToken ?? base.bgToken,
    fontScale: over.fontScale ?? base.fontScale,
    weightToken: over.weightToken ?? base.weightToken,
    sizeToken: over.sizeToken ?? base.sizeToken,
    pad: over.pad ?? base.pad,
  );
}

/// Field-by-field action merge: over's `kind` wins (it IS the new action); args are
/// unioned so a partial arg-override keeps the rest.
CfgAction? mergeAction(CfgAction? base, CfgAction? over) {
  if (over == null) return base;
  if (base == null) return over;
  return CfgAction(
    kind: over.kind,
    args: base.args.isEmpty && over.args.isEmpty
        ? const {}
        : {...base.args, ...over.args},
  );
}
