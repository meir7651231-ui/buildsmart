import 'package:flutter/foundation.dart';

/// Pillar-3 STUDIO · step 87 — one immutable customer-intelligence record.
///
/// Mirrors `AnalyticsEvent` (`lib/state/analytics_log.dart`) and adds the intel
/// dimensions [actorKey] / [uid] / [sessionId] / [screen]. The in-memory ring
/// buffer (step 88) stores these; the pure funnel/segment logic (steps 95-96)
/// folds over them. [name] is always one of the `IntelEvents` constants, never a
/// raw literal.
///
/// PURE DATA. No Firebase, no widgets, no providers. Dormant until step 89.
///
/// ── R1-4 · [displayName] is IN-MEMORY-ONLY ───────────────────────────────
/// [displayName] is the human label (e.g. "מאיר כהן") rendered ONLY in the
/// local, on-device live feed. It is PII and it MUST NEVER be serialized,
/// batched, or forwarded to Firestore. [toWire] — the single serialization path
/// — OMITS it by construction; only the PSEUDONYMOUS [actorKey] / [uid] ever
/// leave the device (step 90). Never add [displayName] to any wire/JSON map.
@immutable
class IntelEvent {
  const IntelEvent({
    required this.name,
    required this.at,
    this.actorKey,
    this.uid,
    this.sessionId,
    this.screen,
    this.displayName,
    this.props = const <String, String>{},
  });

  /// The event name — ALWAYS an `IntelEvents` constant, never a raw literal.
  final String name;

  /// Stable PSEUDONYMOUS actor key: the uid when signed-in, else a per-install
  /// uuid (step 91). Safe to forward — it is the erasure-sweep join key.
  final String? actorKey;

  /// Firebase uid when signed-in, else null. Pseudonymous; forwarded on the wire
  /// as the erasure key (step 90) but NEVER placed in a user-visible [props]
  /// entry (step 91.3).
  final String? uid;

  /// The session this event belongs to (step 97).
  final String? sessionId;

  /// Screen / route key where the event happened (step 92).
  final String? screen;

  /// IN-MEMORY-ONLY human label for the local feed. NEVER serialized — see the
  /// class doc (R1-4). Absent from [toWire] by construction.
  final String? displayName;

  /// Scalar, non-PII properties. Keys are constrained to
  /// `IntelEvents.allowedProps[name]`; values are never raw queries / uid / PII.
  final Map<String, String> props;

  /// When the event occurred.
  final DateTime at;

  /// The ONLY serialization path — the shape step 90's batched sink would write
  /// to Firestore. It DELIBERATELY OMITS [displayName] (R1-4: PII, in-memory
  /// only) and carries only the pseudonymous [actorKey] / [uid] plus the scalar
  /// [props]. Add any new wire field HERE — and never leak [displayName].
  Map<String, Object?> toWire() => <String, Object?>{
        'name': name,
        if (actorKey != null) 'actor_key': actorKey,
        if (uid != null) 'uid': uid,
        if (sessionId != null) 'session_id': sessionId,
        if (screen != null) 'screen': screen,
        'props': props,
        'at': at.toUtc().toIso8601String(),
        // displayName is intentionally NOT serialized — R1-4.
      };
}
