// ─────────────────────────────────────────────────────────────────────────────
// FirestoreConfigSink — the "live for everyone" persistence/sync sink for the
// Studio config store (the Pillar-5 swap point named in config_store.dart:7).
//
// It mirrors the owner's PUBLISHED config to ONE owner-writable Firestore doc
// (`studioConfigLive/current`) that every client reads live. A published edit on
// the owner's device therefore reaches all users; a draft keystroke does NOT
// (only `published` is synced — the draft is per-device WIP). This is the
// SELF-CONTAINED shared path (gated by `useStudioSharedSync`): it needs only the
// `studioConfigLive` rules block (owner-only write) + the owner's Google sign-in,
// NO Cloud Function — distinct from the heavier pointer/shard pipeline
// (studio_config_firebase.dart), which stays the future hardened option.
//
// FIREBASE-FREE-TESTABLE: all Firestore I/O goes through the [ConfigDocPort]
// seam (the `RemoteCollectionSource` idiom), so a fake drives the whole sink in
// tests without initialising Firebase. The real adapter resolves
// `FirebaseFirestore.instance` LAZILY inside its methods (never at construction),
// exactly like `authored_products_firebase.dart`.
//
// SAFETY: every method is best-effort and NEVER throws out of a UI edit (the
// [LocalPrefsSink] cache always holds the change) — a permission-denied (a
// non-owner, who never publishes anyway) or an offline write is swallowed. With
// the flag OFF the whole file is unreachable (the provider returns
// [LocalPrefsSink]) ⇒ byte-identical to today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'config_doc.dart';
import 'config_store.dart' show ConfigSink, LocalPrefsSink;

/// The canonical single doc the shared published config lives in.
const String kStudioLiveCollection = 'studioConfigLive';
const String kStudioLiveDocId = 'current';

/// One-document Firestore seam (get / set / delete / listen). Abstract so a fake
/// drives the sink in tests instead of a real Firestore doc (Firebase-free).
abstract class ConfigDocPort {
  /// Read the doc's data once, or null when it does not exist.
  Future<Map<String, dynamic>?> read();

  /// Overwrite the doc with [data] (full set, not merge).
  Future<void> write(Map<String, dynamic> data);

  /// Delete the doc (used when the published layer resets to empty).
  Future<void> remove();

  /// Live stream of the doc's data (null on a missing doc).
  Stream<Map<String, dynamic>?> snapshots();
}

/// The REAL adapter over `studioConfigLive/current`. Resolves
/// `FirebaseFirestore.instance` LAZILY (per call, never at construction) so
/// importing this file needs no Firebase init.
class FirestoreConfigDocPort implements ConfigDocPort {
  const FirestoreConfigDocPort();

  DocumentReference<Map<String, dynamic>> get _ref => FirebaseFirestore.instance
      .collection(kStudioLiveCollection)
      .doc(kStudioLiveDocId);

  @override
  Future<Map<String, dynamic>?> read() async => (await _ref.get()).data();

  @override
  Future<void> write(Map<String, dynamic> data) => _ref.set(data);

  @override
  Future<void> remove() => _ref.delete();

  @override
  Stream<Map<String, dynamic>?> snapshots() =>
      _ref.snapshots().map((s) => s.data());
}

/// The shared-sync [ConfigSink]. Wraps a [ConfigDocPort] (the remote) + a local
/// [ConfigSink] cache (the offline mirror — [LocalPrefsSink] by default, which
/// also keeps the owner's draft/history per-device).
class FirestoreConfigSink implements ConfigSink {
  FirestoreConfigSink(this._port, {ConfigSink? cache})
      : _cache = cache ?? LocalPrefsSink();

  /// The live-wired sink used by the provider (real Firestore + prefs cache).
  factory FirestoreConfigSink.live() =>
      FirestoreConfigSink(const FirestoreConfigDocPort());

  final ConfigDocPort _port;
  final ConfigSink _cache;

  /// The `published` layer we last know is on the server. Lets [save] SKIP the
  /// remote write on a draft-only change (published unchanged) — a draft
  /// keystroke must never hit Firestore. `null` = unknown ⇒ the first publish
  /// always writes.
  ConfigLayer? _lastPublished;

  /// The shared projection: ONLY `published` (+ schema) — NEVER the draft
  /// (per-device WIP) or history (the owner's local rollback ring, kept off the
  /// shared doc so it stays small and well under Firestore's 1 MiB doc cap).
  Map<String, dynamic> _sharedView(ConfigDoc doc) =>
      ConfigDoc(published: doc.published, schemaVersion: doc.schemaVersion)
          .toJson();

  @override
  Future<void> save(ConfigDoc doc) async {
    // Always mirror the FULL doc (published + draft + history) to the local
    // cache first, so the owner's WIP + an offline view survive a reload —
    // byte-identical to the local-only path.
    await _cache.save(doc);
    // Only touch the shared doc when the PUBLISHED layer actually CHANGED
    // (publish / rollback / reset) — a draft edit leaves `published` untouched
    // and must not write to Firestore.
    final prev = _lastPublished;
    if (prev != null && prev == doc.published) return; // no publish change → skip
    // Never-synced + still-empty published (a first DRAFT keystroke before any
    // publish) is a no-op for the remote: there is nothing to publish, and a
    // remove() here could delete another device's live doc. Just remember the
    // empty baseline so the next draft edits also skip.
    if (prev == null && doc.published.isEmpty) {
      _lastPublished = doc.published;
      return;
    }
    _lastPublished = doc.published;
    try {
      if (doc.published.isEmpty) {
        await _port.remove(); // a deliberate reset-to-baseline clears the doc
      } else {
        await _port.write(_sharedView(doc));
      }
    } on Object catch (e) {
      // Best-effort: a non-owner (permission-denied) or offline write must never
      // throw into the UI. Reset the cursor so the next publish retries.
      _lastPublished = null;
      debugPrint('FirestoreConfigSink.save (ignored, local cache holds it): $e');
    }
  }

  @override
  Future<ConfigDoc?> load() async {
    try {
      final data = await _port.read();
      if (data != null) {
        final remote = ConfigDoc.fromJson(data);
        _lastPublished = remote.published;
        // Overlay the owner's LOCAL draft + rollback history (the per-device WIP)
        // onto the shared published layer.
        final cached = await _cache.load();
        return ConfigDoc(
          published: remote.published,
          draft: cached?.draft ?? ConfigLayer.empty,
          history: cached?.history ?? const [],
          schemaVersion: remote.schemaVersion,
        );
      }
    } on Object catch (e) {
      debugPrint('FirestoreConfigSink.load (fall back to cache): $e');
    }
    return _cache.load(); // offline / empty remote / denied → last-good local
  }

  @override
  Stream<ConfigDoc>? watch() => _port.snapshots().map((data) {
        if (data == null) return ConfigDoc.empty;
        final remote = ConfigDoc.fromJson(data);
        _lastPublished = remote.published;
        return remote;
      }).handleError((Object e) {
        // A permission/transport error must never surface to the store; the last
        // adopted published layer simply stands (never blanks the app).
        debugPrint('FirestoreConfigSink.watch (ignored): $e');
      });
}
