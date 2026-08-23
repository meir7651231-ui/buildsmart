// C5.1 — the GRADUAL server-catalog activation gate (DORMANT · default 0%).
//
// `useServerCatalog` is the hard master on/off. This adds a STAGED rollout on top:
// even once the master is on, the server catalog activates only for a deterministic
// bucket of users (keyed by a stable id), so activation ramps 0 → … → 100% and can be
// dialled back instantly. THE MACHINE, NOT THE ACTIVATION — the real percentage is an
// owner decision (a build-time define), default 0 (nobody).

/// The rollout percentage [0..100]. Default 0 ⇒ built, OFF (nobody gets the server
/// catalog even if the master flag is on). Set via `--dart-define=SERVER_CATALOG_ROLLOUT=N`.
const int kServerCatalogRolloutPercent =
    int.fromEnvironment('SERVER_CATALOG_ROLLOUT');

/// Deterministic bucket [0..99] for a stable [key] (user/device id). A stable FNV-1a
/// hash — a given key is ALWAYS in the same bucket, so a user never flip-flops in/out
/// of the rollout between opens.
int rolloutBucket(String key) {
  var h = 0x811c9dc5;
  for (final c in key.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return h % 100;
}

/// Whether the STAGED rollout is on for [key] at [percent] (defaults to the build-time
/// [kServerCatalogRolloutPercent]). Combined with the master flag at the call site:
/// `useServerCatalog && serverCatalogRolledOut(deviceId)`.
bool serverCatalogRolledOut(String key, {int? percent}) {
  final p = percent ?? kServerCatalogRolloutPercent;
  if (p <= 0) return false;
  if (p >= 100) return true;
  return rolloutBucket(key) < p;
}
