// Gate-120 (GATE_REGISTRY · Studio Pillar-3 · "analytics-PII") — the PRIVACY
// capstone of the customer-intelligence layer. Mirrors gate_118 / gate_119's shape
// (a plain source/data scan run at TEST time, not just a fake) and REGISTERS the
// invariant that seals Pillar-3: the intel layer forwards ONLY pseudonymous,
// non-PII keys — no email / phone / personal-name / raw-query key, and NO
// `displayName`, ever reaches a wire / `toWire` / Firestore path.
//
// It scans the REAL intel sources (lib/state/intel/ + lib/logic/intel/) and asserts:
//   (a) the SERIALIZATION surface (IntelEvent.toWire + the Firestore `.set` writers
//       in intel_sink.dart) emits ONLY keys in the pseudonymous ALLOWLIST — a closed
//       set, so ANY new wire key trips the gate and forces review;
//   (b) NO map-key / prop-key anywhere in the intel layer LOOKS LIKE PII (the
//       `_looksLikePii` denylist — email / phone / display_name / full_name /
//       address / raw-query / credential shapes);
//   (c) the `displayName` literal (R1-4 canary) NEVER appears as a quoted wire key
//       anywhere in the intel layer — it is IN-MEMORY-ONLY, omitted from toWire by
//       construction;
//   (d) anti-vacuous — a planted `email` / `full_name` / `user_query` /
//       `displayName` key DOES fire the detector, while the legit pseudonymous keys
//       (`name` / `actor_key` / `q_hash` / `session_id` …) do NOT.
//
// Reconciliation (live-code truth): the plan's allowlist enumerates the EVENT +
// PRESENCE keys (actor_key / uid / screen / last_beat / expire_at / name / props /
// at / session_id); the anon→uid STITCH doc additionally writes the pseudonymous
// `anonKeys` array (a list of anon uuids — NOT PII), so it is allow-listed here too.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The intel source roots the gate scans (CWD is the package root under
/// `flutter test`).
const List<String> kIntelDirs = <String>[
  'lib/state/intel',
  'lib/logic/intel',
];

/// The two files that carry the SERIALIZATION surface — the map-key literals that
/// actually reach Firestore: `IntelEvent.toWire()` + the `FirestoreActorStitchWriter`
/// / `FirestorePresenceWriter` `.set(<String, Object?>{…})` maps. These are the ONLY
/// places a wire key is minted, so the closed-set (a) check scans exactly them.
const List<String> kSerializationFiles = <String>[
  'lib/state/intel/intel_event.dart',
  'lib/state/intel/intel_sink.dart',
];

/// The pseudonymous wire-key ALLOWLIST — the COMPLETE closed set the intel layer is
/// allowed to forward. Every entry is pseudonymous / scalar / non-PII: an event
/// `name`, the `actor_key` / `uid` join keys, a `screen` label, the `props`
/// container, timestamps (`at` / `last_beat` / `expire_at`), the `session_id`, and
/// the stitch `anonKeys` array. Anything OUTSIDE this set → the gate fails (new key
/// forces a privacy review); anything that LOOKS like PII → the denylist fails.
const Set<String> kIntelWireKeyAllowlist = <String>{
  'name', 'actor_key', 'uid', 'session_id', 'screen', 'props', 'at',
  'anonKeys', 'last_beat', 'expire_at',
};

/// Tokens that mark a key as carrying real-world PII — the analytics-#120 denylist.
/// Deliberately the LONG personal-name FORMS (display_name / full_name / first/last),
/// so the legitimate bare `name` (the EVENT name) + the `props` container do NOT
/// trip it. Fires on the planted `email` / `full_name` / `user_query` /
/// `displayName`; pinned anti-vacuously below. Matched with underscores stripped, so
/// `full_name` and `fullname` both normalize onto `fullname`.
const List<String> kPiiKeyTokens = <String>[
  // contact
  'email', 'phone', 'mobile', 'contact', 'whatsapp',
  // personal name forms (NOT bare 'name')
  'displayname', 'fullname', 'firstname', 'lastname', 'surname',
  // postal / location
  'address', 'street', 'zipcode', 'postal', 'latitude', 'longitude', 'geohash',
  // government / credential
  'ssn', 'passport', 'nationalid', 'password', 'secret', 'otp',
  // raw free-text query (the taxonomy forwards only q_len / q_hash, never this)
  'query', 'searchtext',
];

/// True when [key] carries a PII token (case-insensitive, underscores stripped from
/// BOTH sides so `full_name`↔`fullname` match). The proven `_isForbidden` substring
/// idiom from studio_action_catalog_test / gate_119.
bool _looksLikePii(String key) {
  final k = key.toLowerCase().replaceAll('_', '');
  return kPiiKeyTokens.any((t) => k.contains(t.replaceAll('_', '')));
}

/// Every quoted MAP-KEY literal (`'key':`) in [source] — the wire/prop keys. The
/// closing-quote-then-colon shape excludes in-string colons (a `debugPrint('X: …')`)
/// and unquoted named args (`merge: true`), so it captures exactly Dart map keys.
Set<String> _mapKeyLiterals(String source) {
  final keyRe = RegExp(r"'([a-zA-Z_][a-zA-Z0-9_]*)'\s*:");
  return keyRe.allMatches(source).map((m) => m.group(1)!).toSet();
}

String _read(String p) => File(p).readAsStringSync();

void main() {
  group('gate-120 · (a) serialization surface is a CLOSED pseudonymous key-set', () {
    test('every wire key in toWire + the Firestore writers is in the allowlist', () {
      final wireKeys = <String>{};
      for (final f in kSerializationFiles) {
        expect(File(f).existsSync(), isTrue,
            reason: '$f missing — gate scan is moot');
        wireKeys.addAll(_mapKeyLiterals(_read(f)));
      }
      // NON-VACUOUS: the serialization surface must actually carry keys (a broken
      // scan that finds none is itself a failure — the gate would prove nothing).
      expect(wireKeys, isNotEmpty,
          reason: 'gate-120 found no wire keys — the scan pattern is broken');
      // The exact live surface (2026-07): the 7 toWire keys + anonKeys + the 2
      // presence timestamps. A drift in EITHER direction forces this test's review.
      expect(wireKeys,
          containsAll(<String>{'name', 'actor_key', 'uid', 'props', 'at'}),
          reason: 'the known toWire keys vanished — the scan pattern drifted');
      for (final key in wireKeys) {
        expect(kIntelWireKeyAllowlist.contains(key), isTrue,
            reason: 'analytics-#120 leak: wire key <$key> is NOT an allow-listed '
                'pseudonymous key — a new forwarded field needs a privacy review');
      }
    });
  });

  group('gate-120 · (b) no intel map-key / prop-key looks like PII', () {
    test(
        'NO quoted map-key anywhere in lib/state/intel + lib/logic/intel trips the '
        'PII denylist', () {
      final allKeys = <String>{};
      final scanned = <String>[];
      for (final dir in kIntelDirs) {
        final d = Directory(dir);
        expect(d.existsSync(), isTrue, reason: '$dir missing — gate scan is moot');
        for (final f in d.listSync(recursive: true)) {
          if (f is! File || !f.path.endsWith('.dart')) continue;
          scanned.add(f.path);
          allKeys.addAll(_mapKeyLiterals(f.readAsStringSync()));
        }
      }
      // NON-VACUOUS: we actually scanned files and found keys.
      expect(scanned, isNotEmpty, reason: 'no intel .dart files scanned');
      expect(allKeys, isNotEmpty, reason: 'no intel map-keys found — scan is broken');
      for (final key in allKeys) {
        expect(_looksLikePii(key), isFalse,
            reason: 'analytics-#120 leak: intel key <$key> looks like PII');
      }
    });

    test('the allowed prop-key taxonomy (intel_events.dart) carries no PII key', () {
      // The per-event ALLOWED prop keys (allowedProps) are the OTHER key surface the
      // call-sites may forward. Every quoted snake_case token in that registry (event
      // names + prop keys) must be non-PII — the taxonomy forwards q_len / q_hash,
      // never a raw query.
      const taxonomy = 'lib/state/intel/intel_events.dart';
      expect(File(taxonomy).existsSync(), isTrue);
      final tokens = RegExp("'([a-z][a-z0-9_]*)'")
          .allMatches(_read(taxonomy))
          .map((m) => m.group(1)!)
          .toSet();
      expect(tokens, isNotEmpty, reason: 'no taxonomy tokens found — scan is broken');
      // sanity: the real prop keys are present (non-vacuous).
      expect(tokens, containsAll(<String>{'q_len', 'q_hash', 'actor_kind'}));
      for (final t in tokens) {
        expect(_looksLikePii(t), isFalse,
            reason: 'analytics-#120 leak: taxonomy token <$t> looks like PII');
      }
    });
  });

  group('gate-120 · (c) displayName never reaches the wire (R1-4)', () {
    test("the quoted 'displayName' literal is ABSENT from the entire intel layer", () {
      // displayName is IN-MEMORY-ONLY (intel_event.dart R1-4) — a wire key MUST be a
      // quoted string, so a serialized displayName could ONLY appear as 'displayName'.
      // Its total absence proves toWire/the writers never forward it.
      final offenders = <String>[];
      for (final dir in kIntelDirs) {
        for (final f in Directory(dir).listSync(recursive: true)) {
          if (f is! File || !f.path.endsWith('.dart')) continue;
          if (f.readAsStringSync().contains("'displayName'")) offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty,
          reason: "R1-4 breach: 'displayName' appears as a quoted wire key in "
              '$offenders — it must be IN-MEMORY-ONLY, never serialized');
    });
  });

  group('gate-120 · (d) anti-vacuous — the PII detector is not a no-op', () {
    test('the detector FIRES on planted PII keys', () {
      for (final planted in const <String>[
        'email', // THE planted sample (§4 · mandatory)
        'full_name',
        'user_query', // a raw-query key (§4 · mandatory)
        'displayName',
        'phone',
        'home_address',
        'last_name',
        'password',
      ]) {
        expect(_looksLikePii(planted), isTrue,
            reason: 'detector MISSED a PII key <$planted> — gate-120 would be vacuous');
      }
    });

    test('the detector does NOT fire on the legit pseudonymous keys', () {
      for (final ok in const <String>[
        'name', // the EVENT name — not a person's name
        'actor_key', 'uid', 'session_id', 'screen', 'props', 'at',
        'anonKeys', 'last_beat', 'expire_at',
        'q_len', 'q_hash', 'actor_kind', 'sku', 'item_count', 'dur_s', 'reason',
      ]) {
        expect(_looksLikePii(ok), isFalse,
            reason: '<$ok> is a legit pseudonymous key but was flagged as PII');
      }
    });
  });
}
