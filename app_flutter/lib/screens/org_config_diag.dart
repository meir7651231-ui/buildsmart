// ─────────────────────────────────────────────────────────────────────────────
// Org-config sync DIAGNOSTIC — a live, on-device check of why (or whether) the
// setup-wizard publish reaches the server. Surfaced by a button in the wizard.
//
// It answers, in order, the exact chain that must ALL hold for a change to reach
// other users:
//   1. Firebase actually initialised on this build.
//   2. ORG_CONFIG + ORG_CONFIG_LIVE armed (useOrgConfigLive) — else publish is
//      never even called (the "נשמר ופעיל" note = this being false).
//   3. Signed in, and as the OWNER email (the ONLY writer the rules allow).
//   4. A REAL round-trip: write the config, then force a SERVER read and confirm
//      it actually landed — because with offline persistence `set()` returns
//      success on the LOCAL write even when the server later rejects it (the
//      "נשמר ופורסם but the doc is 404" trap).
//
// Best-effort — never throws; returns human-readable lines.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/org_config.dart'
    show kOrgConfigFlag, kOrgConfigLive;
import 'package:buildsmart/data/board_accounts_local.dart' show kOwnerEmails;
import 'package:buildsmart/state/org_config_live.dart'
    show canPublishOrgConfig, useOrgConfigLive;
import 'package:buildsmart/state/org_config_sink_firebase.dart'
    show kOrgConfigLiveCollection, kOrgConfigLiveDocId, kOrgConfigLiveField;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Runs the live sync diagnostic and returns report lines. [configJson] is the
/// current config (`encodeOrgConfig(draft)`) — the round-trip step publishes it,
/// so a green result also means the change is now actually live for everyone.
Future<List<String>> runOrgConfigDiagnostic(String configJson) async {
  final out = <String>[];

  final fbUp = Firebase.apps.isNotEmpty;
  out.add(fbUp ? '✅ Firebase מאותחל' : '❌ Firebase לא מאותחל בכלל');
  out.add('${kOrgConfigFlag ? '✅' : '❌'} דגל ORG_CONFIG (חמוש)');
  out.add('${kOrgConfigLive ? '✅' : '❌'} דגל ORG_CONFIG_LIVE');
  out.add(canPublishOrgConfig
      ? '✅ פרסום מופעל — "שמור" יפרסם לשרת'
      : '❌ פרסום כבוי — ORG_CONFIG לא חמוש');
  out.add(useOrgConfigLive
      ? '✅ מנוי-חי פעיל — תקבל שינויים מאחרים חי'
      : '⚠️ מנוי-חי כבוי — לא תקבל שינויי-אחרים חי (build ללא ORG_CONFIG_LIVE)');

  String? email;
  try {
    email = FirebaseAuth.instance.currentUser?.email;
  } on Object catch (_) {/* Firebase-free / not signed in */}
  out.add((email == null || email.isEmpty)
      ? '❌ לא מחובר (אין email) — התחבר עם גוגל'
      : 'מחובר כ: $email');
  final isOwner =
      email != null && kOwnerEmails.contains(email.trim().toLowerCase());
  out.add(isOwner
      ? '✅ בעלים — מורשה לפרסם'
      : '❌ לא בעלים — השרת ידחה את הכתיבה');

  if (!fbUp) {
    out.add('— בדיקת-שרת דולגה (אין Firebase) —');
    return out;
  }

  // The real proof: write, then FORCE a server read and confirm it landed.
  try {
    final ref = FirebaseFirestore.instance
        .collection(kOrgConfigLiveCollection)
        .doc(kOrgConfigLiveDocId);
    await ref.set(<String, dynamic>{kOrgConfigLiveField: configJson});
    final snap = await ref.get(const GetOptions(source: Source.server));
    final landed =
        snap.exists && snap.data()?[kOrgConfigLiveField] == configJson;
    out.add(landed
        ? '✅ הכתיבה הגיעה לשרת ואומתה — פעיל אצל כולם עכשיו'
        : '❌ הכתיבה לא נמצאה בשרת — נדחתה בשקט (בדוק בעלים/הרשאות)');
  } on Object catch (e) {
    out.add('❌ כתיבה/קריאה מהשרת נכשלה: $e');
  }
  return out;
}
