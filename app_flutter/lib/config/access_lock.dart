// ─────────────────────────────────────────────────────────────────────────────
// Access lock — the owner-set password gate. The owner types a password in the
// setup wizard (manager screen); it is stored ONLY as a SHA-256 hash on
// [OrgConfig.accessPasswordHash], published to the public `orgConfigLive/current`
// doc, and [AccessLockGate] blocks the app until the password is entered.
//
// UNIVERSAL by design: the gate reads the hash straight from the PUBLIC config
// doc over plain HTTPS ([fetchAccessPasswordHash]) — no Firebase SDK, no backend
// flags — so the lock engages on EVERY build (store · web · tester), not only the
// backend-connected one. The org-config-live provider is a live-update bonus on
// builds that have it; the fetch is the floor that works everywhere.
//
// This is an ACCESS gate (the owner shares one password with the people they
// approve) — NOT per-user auth (that is the filtered-auth system). The hash lives
// in a public-read doc, so it keeps the literal password off the wire but a
// determined attacker who reads the client can still bypass a client-side gate.
//
// DoD: [kAccessLock] ships OFF (every define-less build) ⇒ [AccessLockGate]
// returns its child unwrapped ⇒ byte-identical to today.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert' show jsonDecode, utf8;

import 'package:buildsmart/config/org_config.dart' show decodeOrgConfig;
import 'package:crypto/crypto.dart' show sha256;
import 'package:http/http.dart' as http;

/// The arming flag — `--dart-define=ACCESS_LOCK=true` turns the gate on. OFF
/// (default) ⇒ the gate is a passthrough and the whole lock screen tree-shakes.
const bool kAccessLock = bool.fromEnvironment('ACCESS_LOCK');

/// Persisted local-unlock key: whoever entered the right password on THIS device
/// is remembered so they are not re-prompted every launch. Namespaced by the
/// hash so rotating the password re-locks everyone.
const String kAccessUnlockedKey = 'bs.access-unlocked.v1';

/// Last hash seen from the server, cached so a later OFFLINE launch still knows a
/// lock is in force (fail-closed for a device that has connected once).
const String kAccessCachedHashKey = 'bs.access-cached-hash.v1';

/// The PUBLIC config doc (public-read rule) over the Firestore REST API — the one
/// URL every build can GET with no auth and no SDK. Project `buildsmart-b0b78`.
const String kAccessConfigDocUrl =
    'https://firestore.googleapis.com/v1/projects/buildsmart-b0b78/databases/(default)/documents/orgConfigLive/current';

/// Hash a plaintext access password → hex SHA-256, the ONLY form ever persisted.
/// A blank/whitespace password hashes to '' — the "no lock" sentinel. A fixed app
/// salt namespaces the digest (adds no secrecy — it is in the source — but keeps
/// these off a bare-SHA rainbow table).
String hashAccessPassword(String plain) {
  final p = plain.trim();
  if (p.isEmpty) return '';
  return sha256.convert(utf8.encode('bs.access.v1 $p')).toString();
}

/// True when [entered] unlocks the gate guarding [storedHash]. Empty stored hash
/// = "no lock" (any input passes — the gate never engages).
bool accessPasswordMatches(String storedHash, String entered) {
  if (storedHash.isEmpty) return true;
  return hashAccessPassword(entered) == storedHash;
}

/// Fetch the owner's access-password hash straight from the PUBLIC config doc,
/// independent of Firebase/backend flags — so the gate works on every build.
/// Returns '' when no lock is set (doc/field absent), the hash when set, or null
/// when it cannot be determined (network/parse error → the caller uses its cache).
Future<String?> fetchAccessPasswordHash() async {
  try {
    final res = await http
        .get(Uri.parse(kAccessConfigDocUrl))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode == 404) return ''; // no doc → no lock
    if (res.statusCode != 200) return null; // could not determine
    final root = jsonDecode(res.body);
    if (root is! Map) return null;
    final fields = root['fields'];
    final jsonField = fields is Map ? fields['json'] : null;
    final encoded =
        jsonField is Map ? jsonField['stringValue'] as String? : null;
    if (encoded == null) return ''; // doc exists but carries no config → no lock
    return decodeOrgConfig(encoded)?.accessPasswordHash ?? '';
  } on Object {
    return null; // network/timeout/parse → let the caller fall back to its cache
  }
}
