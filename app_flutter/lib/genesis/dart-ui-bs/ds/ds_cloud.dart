// ☁️ אטום-הצבה · החוט לענן (G58 · הכרעה-31). חוצה firebase_core/auth/firestore —
// גבול-פלטפורמה מבוקר (חוק-6: הצבה, לא אטום-טהור). **דורמנטי-מלידה:**
// בלי קונפיג שהבעלים הדביק אין אתחול, אין חיבור, אין בקשה — האפליקציה ביט-זהה למקומית.
//
// מודל: `users/{uid}/state/app` — מסמך אחד, אותו JSON של `AppStore.cloudJson()`
// (בלי `settings` — מפתחות נשארים במכשיר, וגם כללי-הגישה דוחים אותם).
// המיזוג נעשה **בלקוח** דרך `AppStore.mergeJson` (מצבות-מחיקה מכובדות) — הענן לא מכריע.
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class DsCloudState {
  const DsCloudState({required this.ok, required this.note, this.uid = ''});
  final bool ok;
  final String note, uid;
}

const String kCloudApp = 'balagan-cloud';

/// קונפיג-האתר של Firebase כפי שהבעלים מדביק. חסר שדה ⇒ null (לא מנחשים).
FirebaseOptions? cloudOptions(String raw) {
  if (raw.trim().isEmpty) return null;
  try {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    String s(String k) => (j[k] ?? '').toString().trim();
    if (s('apiKey').isEmpty || s('projectId').isEmpty || s('appId').isEmpty) return null;
    return FirebaseOptions(
      apiKey: s('apiKey'),
      appId: s('appId'),
      projectId: s('projectId'),
      messagingSenderId: s('messagingSenderId'),
      authDomain: s('authDomain').isEmpty ? null : s('authDomain'),
      storageBucket: s('storageBucket').isEmpty ? null : s('storageBucket'),
    );
  } catch (_) {
    return null;
  }
}

FirebaseApp? _app;

/// אתחול פעם-אחת. קונפיג פגום/חסר ⇒ null ואפס רשת.
Future<FirebaseApp?> cloudInit(String rawConfig) async {
  final o = cloudOptions(rawConfig);
  if (o == null) return null;
  if (_app != null) return _app;
  try {
    _app = Firebase.apps.any((a) => a.name == kCloudApp)
        ? Firebase.app(kCloudApp)
        : await Firebase.initializeApp(name: kCloudApp, options: o);
    return _app;
  } catch (_) {
    return null;
  }
}

/// כניסה/הרשמה במייל+סיסמה. אותו חשבון בשני מכשירים = אותה מגירה.
Future<DsCloudState> cloudSignIn(String rawConfig, String email, String pass) async {
  final app = await cloudInit(rawConfig);
  if (app == null) return const DsCloudState(ok: false, note: 'config');
  if (email.trim().isEmpty || pass.length < 6) return const DsCloudState(ok: false, note: 'input');
  final auth = FirebaseAuth.instanceFor(app: app);
  try {
    final c = await auth.signInWithEmailAndPassword(email: email.trim(), password: pass);
    return DsCloudState(ok: true, note: 'in', uid: c.user?.uid ?? '');
  } on FirebaseAuthException catch (e) {
    if (e.code != 'user-not-found' && e.code != 'invalid-credential') return DsCloudState(ok: false, note: e.code);
    try {
      final c = await auth.createUserWithEmailAndPassword(email: email.trim(), password: pass);
      return DsCloudState(ok: true, note: 'new', uid: c.user?.uid ?? '');
    } on FirebaseAuthException catch (e2) {
      return DsCloudState(ok: false, note: e2.code);
    }
  } catch (_) {
    return const DsCloudState(ok: false, note: 'net');
  }
}

String cloudUid() {
  try {
    return _app == null ? '' : (FirebaseAuth.instanceFor(app: _app!).currentUser?.uid ?? '');
  } catch (_) {
    return '';
  }
}

Future<void> cloudSignOut() async {
  try { if (_app != null) await FirebaseAuth.instanceFor(app: _app!).signOut(); } catch (_) {}
}

DocumentReference<Map<String, dynamic>>? _docOf() {
  final uid = cloudUid();
  if (_app == null || uid.isEmpty) return null;
  return FirebaseFirestore.instanceFor(app: _app!).doc('users/$uid/state/app');
}

/// משיכה. אין חיבור/אין מסמך ⇒ null (המסך אומר, לא מזייף).
Future<String?> cloudPull() async {
  final d = _docOf();
  if (d == null) return null;
  try {
    final s = await d.get();
    if (!s.exists) return null;
    final m = Map<String, dynamic>.from(s.data() ?? const {})..remove('at');
    return jsonEncode(m);
  } catch (_) {
    return null;
  }
}

/// דחיפה. `json` = `AppStore.cloudJson()` בדיוק — מה שהכללים מתירים.
Future<bool> cloudPush(String json) async {
  final d = _docOf();
  if (d == null) return false;
  try {
    final m = Map<String, dynamic>.from(jsonDecode(json) as Map);
    m['at'] = DateTime.now().toIso8601String();
    await d.set(m);
    return true;
  } catch (_) {
    return false;
  }
}

/// האזנה: מכשיר אחר כתב ⇒ קריאה-חוזרת עם המסמך (הקורא ממזג, לא דורס).
StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? cloudWatch(void Function(String) onDoc) {
  final d = _docOf();
  if (d == null) return null;
  try {
    return d.snapshots().listen((s) {
      if (!s.exists) return;
      final m = Map<String, dynamic>.from(s.data() ?? const {})..remove('at');
      onDoc(jsonEncode(m));
    }, onError: (_) {});
  } catch (_) {
    return null;
  }
}
