// TEMPORARY launch diagnostic — a small always-on chip that makes the live
// backend state VISIBLE to a non-technical tester: demo vs real server, the
// signed-in uid, the role/admin claim, and a one-tap REAL Firestore write+read
// round-trip that reports success or the exact failure code.
//
// WHY: during go-live verification "nothing saves" can mean three very
// different things — wrong (demo) build, not signed in, or a rules/role denial.
// This badge tells them apart at a glance instead of guessing blind.
//
// SAFE: every Firebase touch is guarded by [useFirebaseBackend]; on the demo
// build (and the whole Firebase-free test suite) it only renders the red "demo"
// chip and never resolves FirebaseAuth/Firestore. DELETE after go-live.
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseException;
import 'package:flutter/material.dart';

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

  Future<void> _testServer() async {
    setState(() {
      _busy = true;
      _result = 'בודק…';
    });
    try {
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
      // Self-write to users/{uid}: allowed for ANY signed-in user by the S5
      // rules (no role needed), so this isolates "connected + persists" from
      // the separate "do I have a role" question. Read back FROM THE SERVER.
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await doc.set(
        {'diagPing': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      final snap = await doc.get(const GetOptions(source: Source.server));
      final ok = snap.exists && snap.data()?['diagPing'] != null;
      await _refreshClaims();
      if (!mounted) return;
      setState(() {
        _result = ok
            ? '✅ מחובר! נכתב ונקרא מהשרת בהצלחה.\nuid ${user.uid.substring(0, 6)}… — הנתונים נשמרים.'
            : '⚠️ הכתיבה עברה אך לא אומתה — נסה שוב.';
        _busy = false;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _result = '❌ נכשל: ${e.code}\n${e.message ?? ''}';
        _busy = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _result = '❌ שגיאה: $e';
        _busy = false;
      });
    }
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
        alignment: Alignment.topRight,
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
