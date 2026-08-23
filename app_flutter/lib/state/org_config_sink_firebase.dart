// ─────────────────────────────────────────────────────────────────────────────
// FirestoreOrgConfigSink — the "live for everyone" sync for the ORG CONFIG
// (the `companyJson` server lane reserved in config/org_config.dart:18 +
// state/org_config_store.dart:14). It mirrors, verbatim in shape, the proven
// Studio shared-sync (state/studio/config_sink_firebase.dart · studioConfigLive):
//
//   the OWNER runs the setup wizard  →  one owner-writable Firestore doc
//   (`orgConfigLive/current`)  →  EVERY client reads it live  →  the org config
//   the owner chose reaches all users. No Cloud Function; the `orgConfigLive`
//   rules block (owner-only write via the un-spoofable Google email) is the gate.
//
// FIREBASE-FREE-TESTABLE: all Firestore I/O goes through the [OrgConfigDocPort]
// seam, so a fake drives the whole sink in tests without initialising Firebase.
// The real adapter resolves `FirebaseFirestore.instance` LAZILY inside its
// methods (never at construction), exactly like config_sink_firebase.dart.
//
// SAFETY: every method is best-effort and NEVER throws into a UI edit — a
// permission-denied (a non-owner, who never publishes anyway) or an offline
// write is swallowed; the local prefs (org_config_store.persistOrgConfig) always
// holds the change. With the sync flag OFF the provider hands back a Noop sink ⇒
// this file is unreachable ⇒ byte-identical to today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// The canonical single doc the shared org config lives in — one field, `json`,
/// carrying `encodeOrgConfig(config)` (the same `{"v":1,…}` envelope the local
/// owner lane uses, so `decodeOrgConfig` round-trips it unchanged).
const String kOrgConfigLiveCollection = 'orgConfigLive';
const String kOrgConfigLiveDocId = 'current';
const String kOrgConfigLiveField = 'json';

/// One-document Firestore seam (read / write / remove / listen). Abstract so a
/// fake drives the sink in tests instead of a real Firestore doc (Firebase-free).
abstract class OrgConfigDocPort {
  /// Read the encoded companyJson once, or null when the doc/field is absent.
  Future<String?> read();

  /// Publish [companyJson] as the single shared doc (full set, not merge).
  Future<void> write(String companyJson);

  /// Delete the doc (a deliberate reset-to-default clears the shared config).
  Future<void> remove();

  /// Live stream of the encoded companyJson (null on a missing doc/field).
  Stream<String?> snapshots();
}

/// The REAL adapter over `orgConfigLive/current`. Resolves
/// `FirebaseFirestore.instance` LAZILY (per call, never at construction) so
/// importing this file needs no Firebase init.
class FirestoreOrgConfigDocPort implements OrgConfigDocPort {
  const FirestoreOrgConfigDocPort();

  DocumentReference<Map<String, dynamic>> get _ref => FirebaseFirestore.instance
      .collection(kOrgConfigLiveCollection)
      .doc(kOrgConfigLiveDocId);

  @override
  Future<String?> read() async =>
      (await _ref.get()).data()?[kOrgConfigLiveField] as String?;

  @override
  Future<void> write(String companyJson) =>
      _ref.set(<String, dynamic>{kOrgConfigLiveField: companyJson});

  @override
  Future<void> remove() => _ref.delete();

  @override
  Stream<String?> snapshots() =>
      _ref.snapshots().map((s) => s.data()?[kOrgConfigLiveField] as String?);
}

/// Publish the owner's chosen org config to every client — best-effort. Returns
/// `true` when the remote write succeeded, `false` when it was swallowed (a
/// non-owner / offline / no-Firebase). NEVER throws: the caller's local persist
/// is the source of truth; this is the additive "reach everyone" step.
///
/// [companyJson] is `encodeOrgConfig(config)`. An EMPTY string is a deliberate
/// reset-to-default → the doc is removed so every client falls back to
/// `kDefaultOrgConfig` on its next read.
Future<bool> publishOrgConfig(OrgConfigDocPort port, String companyJson) async {
  try {
    if (companyJson.isEmpty) {
      await port.remove();
    } else {
      await port.write(companyJson);
    }
    return true;
  } on Object catch (e) {
    // Best-effort: a non-owner (permission-denied) or offline write must never
    // throw into the wizard's "save & apply". The local prefs already holds it.
    debugPrint('publishOrgConfig (ignored, local prefs holds it): $e');
    return false;
  }
}
