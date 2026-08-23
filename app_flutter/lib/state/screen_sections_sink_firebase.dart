// ─────────────────────────────────────────────────────────────────────────────
// FirestoreScreenSectionsSink — the "live for everyone" sync for SCREEN
// MANAGEMENT (state/screen_sections.dart: the per-screen section ORDER + HIDE +
// rename map the manager edits under "ניהול מסכים"). It mirrors, verbatim in
// shape, the proven org-config shared-sync (state/org_config_sink_firebase.dart ·
// orgConfigLive):
//
//   the MANAGER edits the screen layout  →  one owner-writable Firestore doc
//   (`screenSectionsLive/current`)  →  EVERY client reads it live  →  the screen
//   layout the manager chose reaches all users. No Cloud Function; the
//   `screenSectionsLive` rules block (owner-only write via the un-spoofable
//   Google email) is the gate. This is what closes "ניהול מסך משפיע רק עליי".
//
// FIREBASE-FREE-TESTABLE: all Firestore I/O goes through the [ScreenSectionsDocPort]
// seam, so a fake drives the whole sink in tests without initialising Firebase.
// The real adapter resolves `FirebaseFirestore.instance` LAZILY inside its
// methods (never at construction), exactly like org_config_sink_firebase.dart.
//
// SAFETY: every method is best-effort and NEVER throws into a UI edit — a
// permission-denied (a non-owner, who never publishes anyway) or an offline
// write is swallowed; the local prefs (screen_sections `_persistLocal`) always
// holds the change. With [useScreenSectionsLive] OFF the notifier is handed a
// null publisher ⇒ this file is unreachable ⇒ byte-identical to today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart' show debugPrint;

/// Arm the screen-management shared sync: OFF in every define-less build (so the
/// whole test suite by construction) ⇒ the notifier gets a null publisher and no
/// subscription is armed ⇒ zero I/O ⇒ byte-identical to today. Turn ON with
/// `--dart-define=SCREEN_SECTIONS_LIVE=true` (mirrors ORG_CONFIG_LIVE).
const bool kScreenSectionsLive =
    bool.fromEnvironment('SCREEN_SECTIONS_LIVE');

/// The canonical single doc the shared screen layout lives in — one field,
/// `json`, carrying the encoded `{screenId: {order,hidden,labels}}` map (the same
/// envelope the local prefs lane uses, so the notifier round-trips it unchanged).
const String kScreenSectionsLiveCollection = 'screenSectionsLive';
const String kScreenSectionsLiveDocId = 'current';
const String kScreenSectionsLiveField = 'json';

/// The live lane is ON only when armed ([kScreenSectionsLive]) AND Firebase
/// actually initialised. Tests never init Firebase ⇒ always false ⇒ no
/// subscription / no publisher ⇒ byte-identical.
bool get useScreenSectionsLive =>
    kScreenSectionsLive && Firebase.apps.isNotEmpty;

/// The manager may PUBLISH under the exact same condition — the server rules
/// still gate the WRITE to the owner (a non-owner is denied and swallowed).
bool get canPublishScreenSections =>
    kScreenSectionsLive && Firebase.apps.isNotEmpty;

/// One-document Firestore seam (read / write / remove / listen). Abstract so a
/// fake drives the sink in tests instead of a real Firestore doc (Firebase-free).
abstract class ScreenSectionsDocPort {
  /// Read the encoded map once, or null when the doc/field is absent.
  Future<String?> read();

  /// Publish [json] as the single shared doc (full set, not merge).
  Future<void> write(String json);

  /// Delete the doc (a deliberate reset-to-default clears the shared layout).
  Future<void> remove();

  /// Live stream of the encoded map (null on a missing doc/field).
  Stream<String?> snapshots();
}

/// The REAL adapter over `screenSectionsLive/current`. Resolves
/// `FirebaseFirestore.instance` LAZILY (per call, never at construction) so
/// importing this file needs no Firebase init.
class FirestoreScreenSectionsDocPort implements ScreenSectionsDocPort {
  const FirestoreScreenSectionsDocPort();

  DocumentReference<Map<String, dynamic>> get _ref => FirebaseFirestore.instance
      .collection(kScreenSectionsLiveCollection)
      .doc(kScreenSectionsLiveDocId);

  @override
  Future<String?> read() async =>
      (await _ref.get()).data()?[kScreenSectionsLiveField] as String?;

  @override
  Future<void> write(String json) =>
      _ref.set(<String, dynamic>{kScreenSectionsLiveField: json});

  @override
  Future<void> remove() => _ref.delete();

  @override
  Stream<String?> snapshots() =>
      _ref.snapshots().map((s) => s.data()?[kScreenSectionsLiveField] as String?);
}

/// Publish the manager's chosen screen layout to every client — best-effort.
/// Returns `true` when the remote write succeeded, `false` when it was swallowed
/// (a non-owner / offline / no-Firebase). NEVER throws: the notifier's local
/// prefs is the source of truth; this is the additive "reach everyone" step.
///
/// An EMPTY string is a deliberate reset-to-default → the doc is removed so every
/// client falls back to its own canonical defaults on the next read.
Future<bool> publishScreenSections(
    ScreenSectionsDocPort port, String json) async {
  try {
    if (json.isEmpty) {
      await port.remove();
    } else {
      await port.write(json);
    }
    return true;
  } on Object catch (e) {
    // Best-effort: a non-owner (permission-denied) or offline write must never
    // throw into a manager edit. The local prefs already holds it.
    debugPrint('publishScreenSections (ignored, local prefs holds it): $e');
    return false;
  }
}
