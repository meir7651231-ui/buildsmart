// TEMPORARY launch diagnostic — a small always-on chip that makes the live
// backend state VISIBLE to a non-technical tester: demo vs real server, the
// signed-in uid, the role/admin claim, and a one-tap REAL Firestore self-test
// that reports success or the exact failure code PER STEP.
//
// WHY: during go-live verification "nothing saves" can mean very different
// things — wrong (demo) build, not signed in, a rules/role denial on a specific
// collection, or a MISSING COMPOSITE INDEX (the scoped orders query throws
// `failed-precondition` with a create-index URL). The guarded background writes
// SWALLOW those failures (by design — the optimistic cache is what the user
// sees), so the ONLY way to see the real error on-device is to run the same
// operations un-guarded and print the code. This badge does exactly that:
//   1. diag/{uid} write+read   — "am I connected and does ANYTHING persist?"
//   2. users/{uid} self-write  — any signed-in user may (no role) — isolates
//                                 "connected" from "do I have a role".
//   3. orders contractor query — `where(contractorUid==uid).orderBy(ts desc)`,
//                                 the EXACT read the second device runs; a
//                                 missing index surfaces here as
//                                 failed-precondition:<create-index URL>.
//   4. orders create dry-run   — writes a real own order doc (then cleans it
//                                 up); a rules denial surfaces here as
//                                 permission-denied — THIS is the symptom when
//                                 a contractor's order never reaches the server.
//
// SAFE: every Firebase touch is guarded by [useFirebaseBackend]; on the demo
// build (and the whole Firebase-free test suite) it only renders the red "demo"
// chip and never resolves FirebaseAuth/Firestore. DELETE after go-live.
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/orders_local.dart'
    show kOrdersContractorScopeField;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseException;
import 'package:flutter/material.dart';

/// One self-test step's outcome — a pure value so the success/error MAPPING is
/// unit-testable without a live Firestore. [ok] = the step passed; [line] is the
/// single human line shown in the panel (✅/❌ + code), [code] the raw Firestore
/// error code ('' on success) so a test can assert the mapping exactly.
@immutable
class FsDiagStep {
  const FsDiagStep({required this.ok, required this.line, this.code = ''});

  final bool ok;
  final String line;
  final String code;
}

/// PURE error→line mapping for a self-test step labelled [label]. Success →
/// `✅ {label}`. A [FirebaseException] → `❌ {label}: {code}` PLUS the message
/// (which for a `failed-precondition` on a scoped query carries the
/// CREATE-INDEX URL — the single most useful thing to see on-device). Any other
/// error → `❌ {label}: {error}`. Factored out (and `@visibleForTesting`) so the
/// mapping is asserted in the Firebase-free suite — the live steps below call it.
@visibleForTesting
FsDiagStep fsDiagStepResult(String label, Object? error) {
  if (error == null) return FsDiagStep(ok: true, line: '✅ $label');
  if (error is FirebaseException) {
    final msg = error.message;
    return FsDiagStep(
      ok: false,
      code: error.code,
      line: '❌ $label: ${error.code}${msg == null ? '' : '\n$msg'}',
    );
  }
  return FsDiagStep(ok: false, line: '❌ $label: $error');
}

/// Overlay chip (place as a direct [Stack] child — it returns a [Positioned]).
class BackendDebugBadge extends StatefulWidget {
  const BackendDebugBadge({super.key});

  @override
  State<BackendDebugBadge> createState() => _BackendDebugBadgeState();
}

class _BackendDebugBadgeState extends State<BackendDebugBadge> {
  bool _open = false;
  bool _busy = false;
  String _result = '';
  String _claims = '';

  static const TextStyle _s = TextStyle(color: Colors.white, fontSize: 11);
  static const Color _panel = Color(0xE6000000); // ~90% black

  @override
  void initState() {
    super.initState();
    _refreshClaims();
  }

  Future<void> _refreshClaims() async {
    if (!useFirebaseBackend) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _claims = '');
        return;
      }
      final token = await user.getIdTokenResult(true);
      final c = token.claims ?? const <String, dynamic>{};
      final role = c['role'] ?? c['roles'] ?? '—';
      if (mounted) {
        setState(() => _claims = 'role=$role · admin=${c['admin'] == true}');
      }
    } on Object catch (e) {
      if (mounted) setState(() => _claims = 'claims error: $e');
    }
  }

  /// Run one self-test [step] (an un-guarded Firestore op), returning its pure
  /// outcome line via [fsDiagStepResult]. A throw is CAUGHT here (the diagnostic
  /// must surface, not crash) and mapped — exactly the failure a guarded
  /// background write would have swallowed.
  Future<FsDiagStep> _runStep(String label, Future<void> Function() step) async {
    try {
      await step();
      return fsDiagStepResult(label, null);
    } on Object catch (e) {
      return fsDiagStepResult(label, e);
    }
  }

  Future<void> _testServer() async {
    setState(() {
      _busy = true;
      _result = 'בודק…';
    });
    if (!useFirebaseBackend) {
      setState(() {
        _result = '🔴 זו גרסת דמו — אין כאן חיבור לשרת. פתח את כתובת-הבדיקה.';
        _busy = false;
      });
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _result = '⚠️ אתה לא מחובר. התחבר קודם (אימייל/טלפון) ואז נסה שוב.';
        _busy = false;
      });
      return;
    }
    final uid = user.uid;
    final db = FirebaseFirestore.instance;
    final steps = <FsDiagStep>[];

    // STEP 1 — diag/{uid}: write a doc + read it back FROM THE SERVER. The
    // owner-asked baseline "is the device connected and does ANYTHING persist?".
    steps.add(await _runStep('1 כתיבה/קריאה diag', () async {
      final ref = db.collection('diag').doc(uid);
      await ref.set(
        {'ping': FieldValue.serverTimestamp(), 'uid': uid},
        SetOptions(merge: true),
      );
      final snap = await ref.get(const GetOptions(source: Source.server));
      if (!(snap.exists && snap.data()?['ping'] != null)) {
        throw FirebaseException(
          plugin: 'diag',
          code: 'verify-failed',
          message: 'diag doc write not confirmed by a server read',
        );
      }
    }));

    // STEP 2 — users/{uid} self-write: every signed-in user may (no role), so a
    // failure here means "not connected", isolating it from "no role".
    steps.add(await _runStep('2 כתיבת users/{uid}', () async {
      await db.collection('users').doc(uid).set(
        {'diagPing': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }));

    // STEP 3 — the EXACT contractor read the SECOND device runs:
    // where(contractorUid==uid).orderBy(ts desc) limit 1. A missing composite
    // index surfaces here as failed-precondition + the create-index URL.
    steps.add(await _runStep('3 שאילתת ההזמנות שלי', () async {
      await db
          .collection('orders')
          .where(kOrdersContractorScopeField, isEqualTo: uid)
          .orderBy('ts', descending: true)
          .limit(1)
          .get(const GetOptions(source: Source.server));
    }));

    // STEP 4 — orders CREATE dry-run: a REAL own order at the flow head, then
    // cleaned up. A rules denial surfaces here as permission-denied — the smoking
    // gun when a contractor's placed order never reaches Firestore.
    // ⚠️ UNIQUE id per run (millisecond timestamp): so the `set` is ALWAYS a
    // fresh CREATE, never an UPDATE. A fixed `BS-diag-$uid` re-ran on a 2nd+ probe
    // hit an already-existing doc ⇒ the op became an UPDATE ⇒ the orders UPDATE
    // rule demands a role ⇒ a role-less contractor got a FALSE permission-denied
    // (a diagnostic artifact — orders genuinely create fine; the cleanup delete
    // below is best-effort, so a stale doc never makes the next run an update).
    final probeId = 'BS-diag-$uid-${DateTime.now().millisecondsSinceEpoch}';
    steps.add(await _runStep('4 יצירת הזמנה (בדיקה)', () async {
      final ref = db.collection('orders').doc(probeId);
      await ref.set({
        'contractorId': 'אבחון',
        'contractorUid': uid,
        'siteAddress': 'אבחון',
        'items': 0,
        'sum': 0,
        'stage': 'new',
        'ts': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      // Best-effort cleanup (delete is manager-only by rules; ignore failure —
      // the create already proved the point, and a 0₪ 'אבחון' doc is harmless).
      try {
        await ref.delete();
      } on Object catch (_) {/* manager-only delete — leave the probe doc */}
    }));

    await _refreshClaims();
    if (!mounted) return;
    final allOk = steps.every((s) => s.ok);
    final header = allOk
        ? '✅ הכול עבר! ההזמנות יסונכרנו בין המכשירים.\nuid ${uid.substring(0, 6)}…'
        : '❌ נמצאה תקלה — הצעד שנכשל מראה את הקוד המדויק:';
    setState(() {
      _result = '$header\n${steps.map((s) => s.line).join('\n')}';
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fb = useFirebaseBackend;
    final initialized = Firebase.apps.isNotEmpty;
    final uid =
        fb && initialized ? FirebaseAuth.instance.currentUser?.uid : null;
    final modeColor = fb ? const Color(0xFF1F8A4C) : const Color(0xFFC62828);
    final modeText = fb ? '🟢 שרת' : '🔴 דמו';
    final who = uid == null ? 'אורח' : 'מחובר ${uid.substring(0, 6)}…';

    return Positioned(
      top: MediaQuery.of(context).padding.top + 4,
      left: 8,
      right: 8,
      child: Align(
        // topCenter — under RTL the visual right is the BuildSmart logo (the
        // role-picker entry); a topRight badge sat exactly on it and swallowed
        // its taps (caught by widget_test 'BS dial opens 5 personas').
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _open = !_open);
                if (_open) _refreshClaims();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: modeColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 6),
                  ],
                ),
                child: Text(
                  '$modeText · $who  ${_open ? '▲' : '▼'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (_open)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Firebase מאותחל: ${initialized ? 'כן ✓' : 'לא ✗'}',
                        style: _s),
                    Text('דגל שרת (USE_FIREBASE_BACKEND): $fb', style: _s),
                    Text('uid: ${uid ?? '—'}', style: _s),
                    Text(_claims.isEmpty ? 'claims: —' : _claims, style: _s),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _testServer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A18),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_busy ? 'בודק…' : '🔌 בדוק חיבור לשרת'),
                      ),
                    ),
                    if (_result.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(_result, style: _s),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
