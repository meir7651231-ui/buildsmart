// ─────────────────────────────────────────────────────────────────────────────
// Org-config LIVE lane — the read/subscribe half of the "wizard reaches everyone"
// feature (the write half is state/org_config_sink_firebase.dart).
//
// It subscribes to the ONE owner-writable doc (`orgConfigLive/current`) and pushes
// every remote company config into [orgConfigProvider] live — so a published edit
// on the owner's device reaches all open clients, exactly like the Studio shared
// sync adopts `studioConfigLive` (config_store.dart: `stream.listen(_adoptRemote)`).
//
// PRECEDENCE PRESERVED: the resolver stays owner → company → default. The local
// owner override (device prefs, [kOrgConfigKey]) is re-read on every adopt, so the
// OWNER keeps seeing their own choice while a fresh client (no override) sees the
// published one — the frozen precedence of [resolveOrgConfig], now fed live.
//
// DoD: [useOrgConfigLive] is false in every define-less build (and whenever
// Firebase is not initialised — so the whole test suite by construction) ⇒ the
// provider returns WITHOUT subscribing ⇒ zero I/O ⇒ byte-identical to today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/org_config.dart'
    show kOrgConfigFlag, kOrgConfigKey, kOrgConfigLive, resolveOrgConfig;
import 'package:buildsmart/state/org_config_sink_firebase.dart'
    show FirestoreOrgConfigDocPort, OrgConfigDocPort;
import 'package:buildsmart/state/org_config_store.dart' show orgConfigProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The live company lane is ON only when the system is ARMED ([kOrgConfigFlag]),
/// the live flag is set ([kOrgConfigLive]), AND Firebase actually initialised.
/// Tests never init Firebase ⇒ always false ⇒ no subscription ⇒ byte-identical.
bool get useOrgConfigLive =>
    kOrgConfigLive && kOrgConfigFlag && Firebase.apps.isNotEmpty;

/// Test seam: override with a fake [OrgConfigDocPort] to drive the adopt logic
/// Firebase-free. Live builds resolve the real Firestore adapter.
final orgConfigDocPortProvider = Provider<OrgConfigDocPort>(
  (ref) => const FirestoreOrgConfigDocPort(),
);

/// Watch this at the app root to arm the live subscription. When
/// [useOrgConfigLive] is false it returns immediately (no listener) — the
/// zero-regression path. Otherwise it adopts every remote company config into
/// [orgConfigProvider], with the local owner override still winning.
final orgConfigLiveProvider = Provider<void>((ref) {
  if (!useOrgConfigLive) return; // flag off / no Firebase ⇒ byte-identical
  final port = ref.watch(orgConfigDocPortProvider);
  final sub = port.snapshots().listen(
    (companyJson) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final owner = prefs.getString(kOrgConfigKey); // local override, if any
        ref.read(orgConfigProvider.notifier).state =
            resolveOrgConfig(ownerJson: owner, companyJson: companyJson);
      } on Object catch (e) {
        // A decode/prefs hiccup must never blank the app — the last adopted
        // config simply stands.
        debugPrint('orgConfigLive adopt (ignored): $e');
      }
    },
    onError: (Object e) =>
        debugPrint('orgConfigLive stream (ignored): $e'),
  );
  ref.onDispose(sub.cancel);
});
