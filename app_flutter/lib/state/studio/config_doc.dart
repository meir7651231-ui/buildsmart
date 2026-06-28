// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 2 — the layered config document.
//
//   • [ConfigLayer]   — one set of overrides: `global` (id→node) + `persona`
//                       (roleKey→id→node) + `structure` (reserved sub-doc for the
//                       Pillar-2 domain-builder; round-trips intact today).
//   • [ConfigVersion] — an immutable published snapshot (FULL layer, never a diff,
//                       so rollback is exact) + who/when/note.
//   • [ConfigDoc]     — `published` (live) ⊕ `draft` (owner WIP) ⊕ `history` (ring,
//                       newest-first, cap [kHistoryCap]) ⊕ `schemaVersion`.
//
// `ConfigDoc.empty` = no published/draft/history ⇒ inert (nothing flows to merge).
// `fromJson` is tolerant + runs `_migrate` (forward-compat append style, like
// home_content_order.dart:72-75): a doc with no `schemaVersion` defaults to 1, an
// unknown future schema reads what it can, persona map-of-maps casts gradually
// (never throws), and `history` is defensively capped at 30.
//
// persona is keyed by the canonical role STRING (`roleKeyOf(roleProvider)`,
// null=contractor → 'contractor'; R1-A2) — the merge (step 3) resolves against it.
// Hand-rolled JSON, no new dep (gate 60), millis ids. Canonical: studio-plan/01
// §2.4 (+ R1/R2). Inert until the store/merge consume it (kStudioFlag default-OFF).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart' show immutable, listEquals, mapEquals;

import 'config_node.dart';

/// Single source of truth for the history ring cap (used by publish/rollback/tests).
const int kHistoryCap = 30;

/// Current document schema. Bump + add a stepwise transform in [_migrate] on change.
const int kSchemaVersion = 1;

// ─── ConfigLayer ─────────────────────────────────────────────────────────────

@immutable
class ConfigLayer {
  const ConfigLayer({
    this.global = const {},
    this.persona = const {},
    this.structure = const {},
  });

  /// id → override (applies to everyone unless a persona layer overrides it).
  final Map<String, CfgNode> global;

  /// roleKey → (id → override). roleKey is the canonical role string.
  final Map<String, Map<String, CfgNode>> persona;

  /// Reserved for the Pillar-2 domain-builder (§13). Opaque here; round-trips intact
  /// so the domain layer needs no schema bump when it lands.
  final Map<String, dynamic> structure;

  static const ConfigLayer empty = ConfigLayer();

  bool get isEmpty => global.isEmpty && persona.isEmpty && structure.isEmpty;

  ConfigLayer copyWith({
    Map<String, CfgNode>? global,
    Map<String, Map<String, CfgNode>>? persona,
    Map<String, dynamic>? structure,
  }) =>
      ConfigLayer(
        global: global ?? this.global,
        persona: persona ?? this.persona,
        structure: structure ?? this.structure,
      );

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{};
    if (global.isNotEmpty) {
      j['global'] = global.map((k, v) => MapEntry(k, v.toJson()));
    }
    if (persona.isNotEmpty) {
      j['persona'] = persona.map(
        (role, m) => MapEntry(role, m.map((k, v) => MapEntry(k, v.toJson()))),
      );
    }
    if (structure.isNotEmpty) j['structure'] = structure;
    return j;
  }

  factory ConfigLayer.fromJson(Map<String, dynamic> j) => ConfigLayer(
        global: _nodeMap(j['global']),
        persona: _personaMap(j['persona']),
        structure: _asStrMap(j['structure']),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigLayer &&
          mapEquals(other.global, global) &&
          _personaEquals(other.persona, persona) &&
          mapEquals(other.structure, structure);

  @override
  int get hashCode =>
      Object.hash(global.length, persona.length, structure.length);
}

// ─── ConfigVersion ───────────────────────────────────────────────────────────

@immutable
class ConfigVersion {
  const ConfigVersion({
    required this.id,
    required this.snapshot,
    required this.publishedAtMs,
    this.note = '',
    this.byEmail = '',
  });

  final int id; // millis
  final ConfigLayer snapshot; // FULL published layer — rollback-exact (not a diff)
  final int publishedAtMs;
  final String note;
  final String byEmail;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'snapshot': snapshot.toJson(),
        'publishedAtMs': publishedAtMs,
        if (note.isNotEmpty) 'note': note,
        if (byEmail.isNotEmpty) 'byEmail': byEmail,
      };

  factory ConfigVersion.fromJson(Map<String, dynamic> j) => ConfigVersion(
        id: (j['id'] as num?)?.toInt() ?? 0,
        snapshot: ConfigLayer.fromJson(_asStrMap(j['snapshot'])),
        publishedAtMs: (j['publishedAtMs'] as num?)?.toInt() ?? 0,
        note: (j['note'] as String?) ?? '',
        byEmail: (j['byEmail'] as String?) ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigVersion &&
          other.id == id &&
          other.publishedAtMs == publishedAtMs &&
          other.note == note &&
          other.byEmail == byEmail &&
          other.snapshot == snapshot;

  @override
  int get hashCode => Object.hash(id, publishedAtMs, note, byEmail);
}

// ─── ConfigDoc ───────────────────────────────────────────────────────────────

@immutable
class ConfigDoc {
  const ConfigDoc({
    this.published = ConfigLayer.empty,
    this.draft = ConfigLayer.empty,
    this.history = const [],
    this.schemaVersion = kSchemaVersion,
  });

  final ConfigLayer published; // live, every user
  final ConfigLayer draft; // owner work-in-progress (not live)
  final List<ConfigVersion> history; // newest first, cap kHistoryCap
  final int schemaVersion;

  /// The inert document — nothing published/drafted ⇒ merge yields the identity.
  static const ConfigDoc empty = ConfigDoc();

  bool get isEmpty => published.isEmpty && draft.isEmpty && history.isEmpty;

  /// How many draft overrides exist — drives the "טיוטה" badge (step 17) without
  /// a recompute.
  int get draftNodeCount =>
      draft.global.length +
      draft.persona.values.fold<int>(0, (s, m) => s + m.length);

  ConfigDoc copyWith({
    ConfigLayer? published,
    ConfigLayer? draft,
    List<ConfigVersion>? history,
    int? schemaVersion,
  }) =>
      ConfigDoc(
        published: published ?? this.published,
        draft: draft ?? this.draft,
        history: history ?? this.history,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{'schemaVersion': schemaVersion};
    if (!published.isEmpty) j['published'] = published.toJson();
    if (!draft.isEmpty) j['draft'] = draft.toJson();
    if (history.isNotEmpty) {
      j['history'] = history.map((v) => v.toJson()).toList();
    }
    return j;
  }

  factory ConfigDoc.fromJson(Map<String, dynamic> j) {
    final m = _migrate(j);
    final rawHistory = (m['history'] as List?) ?? const [];
    return ConfigDoc(
      published: ConfigLayer.fromJson(_asStrMap(m['published'])),
      draft: ConfigLayer.fromJson(_asStrMap(m['draft'])),
      history: rawHistory
          .whereType<Map>()
          .map((e) => ConfigVersion.fromJson(_asStrMap(e)))
          .take(kHistoryCap) // defensive cap even if a stored doc over-ran
          .toList(growable: false),
      schemaVersion: (m['schemaVersion'] as num?)?.toInt() ?? kSchemaVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigDoc &&
          other.published == published &&
          other.draft == draft &&
          other.schemaVersion == schemaVersion &&
          listEquals(other.history, history);

  @override
  int get hashCode =>
      Object.hash(published, draft, history.length, schemaVersion);
}

// ─── migration + tolerant casts ──────────────────────────────────────────────

/// Forward-compat migration. A doc with no `schemaVersion` is treated as v1; an
/// unknown future schema reads what it can (no throw). When [kSchemaVersion] bumps,
/// add stepwise transforms here (v1→v2→…), append-only like home_content_order.
Map<String, dynamic> _migrate(Map<String, dynamic> j) {
  final from = (j['schemaVersion'] as num?)?.toInt() ?? 1;
  // v1 is the only schema today — no structural transform required yet.
  // (Stepwise upgrades go here as the schema evolves; we never drop unknown keys.)
  if (from == kSchemaVersion) return j;
  return j;
}

Map<String, CfgNode> _nodeMap(Object? raw) {
  if (raw is! Map) return const {};
  final out = <String, CfgNode>{};
  raw.forEach((k, v) {
    if (v is Map) out[k.toString()] = CfgNode.fromJson(_asStrMap(v));
  });
  return out;
}

Map<String, Map<String, CfgNode>> _personaMap(Object? raw) {
  if (raw is! Map) return const {};
  final out = <String, Map<String, CfgNode>>{};
  raw.forEach((role, m) {
    if (m is Map) out[role.toString()] = _nodeMap(m);
  });
  return out;
}

Map<String, dynamic> _asStrMap(Object? raw) =>
    raw is Map ? raw.map((k, v) => MapEntry(k.toString(), v)) : const {};

bool _personaEquals(
  Map<String, Map<String, CfgNode>> a,
  Map<String, Map<String, CfgNode>> b,
) {
  if (a.length != b.length) return false;
  for (final k in a.keys) {
    final bm = b[k];
    if (bm == null || !mapEquals(a[k], bm)) return false;
  }
  return true;
}
