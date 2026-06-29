// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 6 — the config store (op-based draft/publish).
//
//   • [ConfigOp]    — a sealed family of single-axis edits (SetText/SetEmoji/
//                     SetHidden/SetOrder/SetStyle/SetAction). P1 OWNS the base +
//                     applyOps; Pillar-4 PRODUCES ops into the draft (R1-A3 · R2-#4).
//   • [ConfigSink]  — the persistence/sync seam (Pillar-5 swap point). v1 ships
//                     [LocalPrefsSink] (SharedPreferences, key 'bs.studio-config.v1').
//   • [ConfigStore] — `StateNotifier<ConfigDoc>`. PUBLIC API is op-based:
//                     `applyOps` (+ `undo`/`redo`), `resetDraftNode`, `discardDraft`,
//                     `publish`, `rollback`. `editDraft(id, fn)` is an INTERNAL
//                     primitive — applyOps is built on it and is the seam Pillar-4
//                     calls (NEVER editDraft directly).
//
// Immutable throughout: every mutation builds a NEW ConfigDoc via `copyWith` (never
// mutates a Map in place — else Riverpod wouldn't notify). undo/redo hold sparse
// DRAFT-LAYER snapshots (the draft is only edits → light; not heavy full-doc copies).
// publish: field-merge draft onto published → prune empties → snapshot to history
// (cap [kHistoryCap]) → clear draft → `_sink.save`. rollback is forward-only (re-publish
// an old snapshot as a NEW version, §7). `_load` decodes off-thread (`compute`, R2-#8).
//
// No consumer yet (resolvedNodeProvider arrives step 7) ⇒ an empty doc persists
// nothing new ⇒ inert / answer-equivalent under kStudioFlag OFF. Canonical:
// studio-plan/01 §2.5 + the step-6 leaf (+ R1/R2).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/config_theme.dart' show CfgTheme;
import '../auth_state.dart' show roleProvider;
import 'config_doc.dart';
import 'config_merge.dart'
    show mergeAction, mergeNodeSlices, mergeStyle, roleKeyOf;
import 'config_node.dart';
import 'edit_mode.dart' show editModeProvider;
import 'element_registry.dart' show criticalIdsProvider;

// ─── ConfigOp — the sealed edit family ───────────────────────────────────────

/// A single-axis edit targeting element [id]. `apply` returns the new node (a
/// null value CLEARS that axis → inherit). P1 owns this base; Pillar-4 produces ops.
sealed class ConfigOp {
  const ConfigOp(this.id);
  final String id;

  /// Apply this op onto [n], returning the new node (other axes preserved).
  CfgNode apply(CfgNode n);

  Map<String, dynamic> toJson();
}

final class SetText extends ConfigOp {
  const SetText(super.id, this.text);
  final String? text;
  @override
  CfgNode apply(CfgNode n) => CfgNode(
        text: text,
        emoji: n.emoji,
        hidden: n.hidden,
        order: n.order,
        style: n.style,
        action: n.action,
        extra: n.extra,
      );
  @override
  Map<String, dynamic> toJson() =>
      {'op': 'setText', 'id': id, if (text != null) 'text': text};
}

final class SetEmoji extends ConfigOp {
  const SetEmoji(super.id, this.emoji);
  final String? emoji;
  @override
  CfgNode apply(CfgNode n) => CfgNode(
        text: n.text,
        emoji: emoji,
        hidden: n.hidden,
        order: n.order,
        style: n.style,
        action: n.action,
        extra: n.extra,
      );
  @override
  Map<String, dynamic> toJson() =>
      {'op': 'setEmoji', 'id': id, if (emoji != null) 'emoji': emoji};
}

final class SetHidden extends ConfigOp {
  const SetHidden(super.id, this.hidden);
  final bool? hidden;
  @override
  CfgNode apply(CfgNode n) => CfgNode(
        text: n.text,
        emoji: n.emoji,
        hidden: hidden,
        order: n.order,
        style: n.style,
        action: n.action,
        extra: n.extra,
      );
  @override
  Map<String, dynamic> toJson() =>
      {'op': 'setHidden', 'id': id, if (hidden != null) 'hidden': hidden};
}

final class SetOrder extends ConfigOp {
  const SetOrder(super.id, this.order);
  final int? order;
  @override
  CfgNode apply(CfgNode n) => CfgNode(
        text: n.text,
        emoji: n.emoji,
        hidden: n.hidden,
        order: order,
        style: n.style,
        action: n.action,
        extra: n.extra,
      );
  @override
  Map<String, dynamic> toJson() =>
      {'op': 'setOrder', 'id': id, if (order != null) 'order': order};
}

final class SetStyle extends ConfigOp {
  const SetStyle(super.id, this.style);
  final CfgStyle? style;
  @override
  CfgNode apply(CfgNode n) => CfgNode(
        text: n.text,
        emoji: n.emoji,
        hidden: n.hidden,
        order: n.order,
        style: style,
        action: n.action,
        extra: n.extra,
      );
  @override
  Map<String, dynamic> toJson() =>
      {'op': 'setStyle', 'id': id, if (style != null) 'style': style!.toJson()};
}

final class SetAction extends ConfigOp {
  const SetAction(super.id, this.action);
  final CfgAction? action;
  @override
  CfgNode apply(CfgNode n) => CfgNode(
        text: n.text,
        emoji: n.emoji,
        hidden: n.hidden,
        order: n.order,
        style: n.style,
        action: action,
        extra: n.extra,
      );
  @override
  Map<String, dynamic> toJson() => {
        'op': 'setAction',
        'id': id,
        if (action != null) 'action': action!.toJson(),
      };
}

// ─── ConfigSink — persistence/sync seam (Pillar-5 swaps this) ─────────────────

abstract class ConfigSink {
  Future<void> save(ConfigDoc doc);

  /// Loaded doc, or null when nothing is persisted yet.
  Future<ConfigDoc?> load();

  /// Optional live stream (Pillar-5 server push). Null for the local sink.
  Stream<ConfigDoc>? watch() => null;
}

/// Default local sink — SharedPreferences, decode off-thread (R2-#8). Mirrors the
/// `catalog_settings.dart` load/persist idiom (try/on Object catch, never throws).
class LocalPrefsSink implements ConfigSink {
  static const _key = 'bs.studio-config.v1';

  @override
  Future<void> save(ConfigDoc doc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (doc.isEmpty) {
        await prefs.remove(_key); // empty ⇒ store nothing (stays inert)
        return;
      }
      await prefs.setString(_key, jsonEncode(doc.toJson()));
    } on Object catch (_) {
      // best-effort persist; never throw out of a UI edit.
    }
  }

  @override
  Future<ConfigDoc?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final map = await compute(_decodeJsonMap, raw); // off-thread cold-start
      return ConfigDoc.fromJson(map);
    } on Object catch (_) {
      return null; // corrupt → fall back to empty/last-good (R2 error-recovery)
    }
  }

  @override
  Stream<ConfigDoc>? watch() => null;
}

/// Top-level so it can run in a `compute` isolate (R2-#8: keep cold-start off the
/// UI thread at 10K ids).
Map<String, dynamic> _decodeJsonMap(String raw) {
  final d = jsonDecode(raw);
  return d is Map ? d.map((k, v) => MapEntry(k.toString(), v)) : const {};
}

// ─── ConfigStore ─────────────────────────────────────────────────────────────

class ConfigStore extends StateNotifier<ConfigDoc> {
  ConfigStore(this._sink) : super(ConfigDoc.empty) {
    _load();
  }

  final ConfigSink _sink;
  final List<ConfigLayer> _undo = [];
  final List<ConfigLayer> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  Future<void> _load() async {
    final loaded = await _sink.load();
    // Adopt the persisted doc ONLY if no edit raced ahead of the async load
    // (pristine: still the empty seed, nothing on the undo stack) — else a draft
    // made during the load window would be silently clobbered (lost update).
    if (loaded != null && mounted && state == ConfigDoc.empty && _undo.isEmpty) {
      state = loaded;
    }
  }

  // ── PUBLIC op-based API (the seam Pillar-4 uses) ──

  /// Apply a batch of edits to the draft as ONE undoable step (R1-A3).
  void applyOps(List<ConfigOp> ops, {String? persona}) {
    if (ops.isEmpty) return;
    var d = state.draft;
    for (final op in ops) {
      d = _withNode(d, op.id, op.apply(_nodeIn(d, op.id, persona)), persona);
    }
    if (d == state.draft) return; // no-op batch — no phantom undo frame / notify
    _undo.add(state.draft); // sparse draft snapshot (light)
    _redo.clear();
    state = state.copyWith(draft: d);
    _save();
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(state.draft);
    state = state.copyWith(draft: _undo.removeLast());
    _save();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(state.draft);
    state = state.copyWith(draft: _redo.removeLast());
    _save();
  }

  /// Reset one id's draft override back to inherit (does not affect undo of others).
  void resetDraftNode(String id, {String? persona}) {
    _undo.add(state.draft);
    _redo.clear();
    state = state.copyWith(
      draft: _withNode(state.draft, id, CfgNode.identity, persona),
    );
    _save();
  }

  /// Drop all draft edits (published stays live).
  void discardDraft() {
    if (state.draft.isEmpty) return;
    _undo.add(state.draft);
    _redo.clear();
    state = state.copyWith(draft: ConfigLayer.empty);
    _save();
  }

  /// A strictly-increasing version id (the rollback key): never collides even on a
  /// same-millisecond publish or a caller relying on the default `nowMs`.
  int _nextVersionId(int nowMs) {
    final last = state.history.isEmpty ? 0 : state.history.first.id;
    return nowMs > last ? nowMs : last + 1;
  }

  /// Promote the draft to live: field-merge onto published, prune empties, snapshot
  /// the new published to history (cap), clear draft. byEmail feeds the audit (#84).
  bool publish({
    String note = '',
    String byEmail = '',
    int nowMs = 0,
    Set<String> criticalIds = const {},
  }) {
    if (state.draft.isEmpty) return false; // nothing to publish — no spurious version
    // Publish-validator (#26): strip any hide/reroute of a critical id BEFORE it goes
    // live (the merge already neutralizes it at resolve — this keeps `published` clean
    // too). What remains is the legal part of the draft.
    final cleanDraft = _sanitizeCritical(state.draft, criticalIds);
    if (cleanDraft.isEmpty) return false; // the draft was ONLY illegal critical edits
    final vid = _nextVersionId(nowMs);
    final newPublished = _promote(state.published, cleanDraft);
    final version = ConfigVersion(
      id: vid,
      snapshot: newPublished,
      publishedAtMs: nowMs,
      note: note,
      byEmail: byEmail,
    );
    state = ConfigDoc(
      published: newPublished,
      draft: ConfigLayer.empty,
      history: [version, ...state.history].take(kHistoryCap).toList(),
      schemaVersion: state.schemaVersion,
    );
    _undo.clear();
    _redo.clear();
    _save();
    return true;
  }

  /// The critical ids whose DRAFT illegally hides or reroutes them (global or any
  /// persona) — the publish-validator's report, for an inline owner warning (#26).
  Set<String> criticalViolations(Set<String> criticalIds) {
    final out = <String>{};
    for (final id in criticalIds) {
      if (_violates(state.draft.global[id])) out.add(id);
      for (final layer in state.draft.persona.values) {
        if (_violates(layer[id])) out.add(id);
      }
    }
    return out;
  }

  static bool _violates(CfgNode? n) =>
      n != null && (n.hidden != null || n.action != null);

  /// [draft] with every critical id's `hidden`/`action` override removed (global +
  /// persona). A node emptied by the strip is dropped. Pure; returns a NEW layer.
  ConfigLayer _sanitizeCritical(ConfigLayer draft, Set<String> criticalIds) {
    if (criticalIds.isEmpty) return draft;
    var out = draft;
    for (final id in criticalIds) {
      if (_violates(out.global[id])) {
        out = _withNode(out, id, _stripGuard(out.global[id]!), null);
      }
      for (final persona in out.persona.keys.toList()) {
        final n = out.persona[persona]?[id];
        if (_violates(n)) out = _withNode(out, id, _stripGuard(n!), persona);
      }
    }
    return out;
  }

  static CfgNode _stripGuard(CfgNode n) => CfgNode(
        text: n.text,
        emoji: n.emoji,
        order: n.order,
        style: n.style,
        extra: n.extra,
      );

  /// Forward-only rollback: re-publish an old version's snapshot as a NEW version
  /// (never destroys history). Returns false if the version id is unknown.
  bool rollback(int versionId, {String byEmail = '', int nowMs = 0}) {
    final v = state.history.where((x) => x.id == versionId).firstOrNull;
    if (v == null) return false;
    final vid = _nextVersionId(nowMs);
    final version = ConfigVersion(
      id: vid,
      snapshot: v.snapshot,
      publishedAtMs: nowMs,
      note: 'שחזור גרסה ${v.id}',
      byEmail: byEmail,
    );
    state = ConfigDoc(
      published: v.snapshot,
      draft: ConfigLayer.empty,
      history: [version, ...state.history].take(kHistoryCap).toList(),
      schemaVersion: state.schemaVersion,
    );
    _undo.clear();
    _redo.clear();
    _save();
    return true;
  }

  // ── internal primitive (NOT the public seam) ──

  /// The single-node draft edit primitive. `applyOps` is built on this; Pillar-4
  /// must go through `applyOps`, never here (R1-A3).
  void editDraft(String id, CfgNode Function(CfgNode) fn, {String? persona}) {
    final next = fn(_nodeIn(state.draft, id, persona));
    final d = _withNode(state.draft, id, next, persona);
    if (d == state.draft) return; // no-op edit — no phantom undo frame / notify
    _undo.add(state.draft);
    _redo.clear();
    state = state.copyWith(draft: d);
    _save();
  }

  /// Stage an app-theme override into the draft (step 24). Lives in the global
  /// structure layer (not a node); publish promotes it like any draft.
  void setThemeDraft(CfgTheme theme) {
    final next =
        state.draft.copyWith(structure: {...state.draft.structure, 'theme': theme.toJson()});
    if (next == state.draft) return; // no-op
    _undo.add(state.draft);
    _redo.clear();
    state = state.copyWith(draft: next);
    _save();
  }

  CfgNode _nodeIn(ConfigLayer d, String id, String? persona) => persona == null
      ? (d.global[id] ?? CfgNode.identity)
      : (d.persona[persona]?[id] ?? CfgNode.identity);

  void _save() => _sink.save(state);
}

// ─── pure layer helpers ──────────────────────────────────────────────────────

/// Return [d] with [id]'s node set to [next] (or removed when [next] is empty),
/// in the global layer or the given [persona] layer. Always a NEW layer.
ConfigLayer _withNode(ConfigLayer d, String id, CfgNode next, String? persona) {
  if (persona == null) {
    final g = {...d.global};
    if (next.isEmpty) {
      g.remove(id);
    } else {
      g[id] = next;
    }
    return d.copyWith(global: g);
  }
  final p = {...d.persona};
  final inner = {...(p[persona] ?? const {})};
  if (next.isEmpty) {
    inner.remove(id);
  } else {
    inner[id] = next;
  }
  if (inner.isEmpty) {
    p.remove(persona);
  } else {
    p[persona] = inner;
  }
  return d.copyWith(persona: p);
}

/// Field-merge draft onto published, pruning empties — the published-promotion.
ConfigLayer _promote(ConfigLayer pub, ConfigLayer draft) {
  final g = {...pub.global};
  draft.global.forEach((id, dn) {
    final merged = _overlayNode(g[id], dn);
    if (merged.isEmpty) {
      g.remove(id);
    } else {
      g[id] = merged;
    }
  });
  final p = {
    for (final e in pub.persona.entries) e.key: {...e.value},
  };
  draft.persona.forEach((role, m) {
    final inner = {...(p[role] ?? const {})};
    m.forEach((id, dn) {
      final merged = _overlayNode(inner[id], dn);
      if (merged.isEmpty) {
        inner.remove(id);
      } else {
        inner[id] = merged;
      }
    });
    if (inner.isEmpty) {
      p.remove(role);
    } else {
      p[role] = inner;
    }
  });
  return ConfigLayer(
    global: g,
    persona: p,
    structure: {...pub.structure, ...draft.structure}, // promote theme etc.
  );
}

CfgNode _overlayNode(CfgNode? base, CfgNode over) {
  if (base == null) return over;
  return CfgNode(
    text: over.text ?? base.text,
    emoji: over.emoji ?? base.emoji,
    hidden: over.hidden ?? base.hidden,
    order: over.order ?? base.order,
    style: mergeStyle(base.style, over.style),
    action: mergeAction(base.action, over.action),
    extra: {...base.extra, ...over.extra},
  );
}

// ─── providers ───────────────────────────────────────────────────────────────

/// The persistence/sync seam — Pillar-5 overrides this with a Firestore sink.
final configSinkProvider = Provider<ConfigSink>((ref) => LocalPrefsSink());

final configStoreProvider =
    StateNotifierProvider<ConfigStore, ConfigDoc>((ref) {
  return ConfigStore(ref.watch(configSinkProvider));
});

/// The effective [CfgNode] for [id] under the viewer's persona, including the
/// owner's unpublished draft WHILE previewing. R2-#1: watches ONLY this id's four
/// layer slices (via `.select`), so an edit/publish touching a DIFFERENT id never
/// rebuilds this provider. Empty doc + not previewing ⇒ `CfgNode.identity` ⇒ every
/// wrapper renders its verbatim fallback (the zero-regression root). `autoDispose`
/// frees ids no widget is watching (memory at 100k+ ids, §11).
final resolvedNodeProvider =
    Provider.autoDispose.family<CfgNode, String>((ref, id) {
  final roleKey = roleKeyOf(ref.watch(roleProvider));
  final includeDraft =
      ref.watch(editModeProvider.select((s) => s.previewDraft));
  return mergeNodeSlices(
    id,
    publishedGlobal:
        ref.watch(configStoreProvider.select((d) => d.published.global[id])),
    publishedPersona: ref.watch(
      configStoreProvider.select((d) => d.published.persona[roleKey]?[id]),
    ),
    draftGlobal:
        ref.watch(configStoreProvider.select((d) => d.draft.global[id])),
    draftPersona: ref.watch(
      configStoreProvider.select((d) => d.draft.persona[roleKey]?[id]),
    ),
    includeDraft: includeDraft,
    criticalIds: ref.watch(criticalIdsProvider),
  );
});

/// The effective app theme — the owner's draft theme (live preview) over the
/// published theme, else the inert defaults. doc-empty ⇒ CfgTheme.fallback ⇒ the
/// app is byte-identical (zero-regression). main.dart injects this into AppTheme.
final configThemeProvider = Provider<CfgTheme>((ref) {
  final draftTheme =
      ref.watch(configStoreProvider.select((d) => d.draft.structure['theme']));
  final pubTheme = ref.watch(
    configStoreProvider.select((d) => d.published.structure['theme']),
  );
  final m = draftTheme ?? pubTheme;
  return m is Map
      ? CfgTheme.fromJson(Map<String, dynamic>.from(m))
      : CfgTheme.fallback;
});
