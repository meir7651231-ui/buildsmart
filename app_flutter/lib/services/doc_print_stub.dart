// SERVER-SWAP — native/VM stub for the document print seam (#106/#107). No
// package:web here, so the file compiles on every non-web target (and on the
// flutter-test VM). Wire a real platform printer / server-side PDF filing here
// when going native; the contract (Future<bool>, false = unavailable) stays
// byte-identical.

/// Native/VM: no printer wired yet — honest false (the caller shows
/// 'הדפסה זמינה בדפדפן'), never a pretend success.
Future<bool> printDocument({required String title, required String html}) =>
    Future<bool>.value(false);
