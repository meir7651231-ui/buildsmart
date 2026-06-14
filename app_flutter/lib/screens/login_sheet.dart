// S1.1–S1.3 — the Hebrew RTL login sheet (server-connect §S1: זהות-אמת).
//
// Three steps in one bottom sheet (the persona_pod_sheet idiom — drag handle,
// rounded top, RTL, brand FilledButton):
//   phone → "שלח קוד אימות" (S1.1 verifyPhoneNumber via the AuthGateway seam)
//   code  → 6-digit entry → "אימות וכניסה" (S1.2 signInWithCredential)
//   email → email+password fallback (S1.3 signInWithEmailAndPassword)
//
// SUCCESS IS STREAM-DRIVEN: the sheet never pops itself on a returned future —
// it listens to [authStateProvider] and closes the moment a user lands. That
// single path also covers Android instant/auto verification (sign-in WITHOUT a
// typed code) for free, and avoids a double-pop race between the manual flow
// and the stream.
//
// FAILURE IS A HEBREW TOAST, never a thrown error: every flow call catches the
// neutral [AuthGatewayException] and maps its stable code through
// [hebrewAuthError]. In a Firebase-free run the gateway is null and every call
// throws `unavailable` → "שירות ההתחברות אינו זמין כרגע" (the entry row is
// hidden in that case anyway — see profile_screen).

import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Map a stable [AuthGatewayException.code] to the Hebrew the user sees.
/// Codes are FirebaseAuthException codes verbatim (the seam preserves them).
/// Pure → unit-testable.
String hebrewAuthError(String code) => switch (code) {
      'invalid-phone-number' => 'מספר הטלפון אינו תקין',
      'invalid-verification-code' => 'קוד האימות שגוי — נסה שוב',
      'invalid-verification-id' ||
      'session-expired' =>
        'תוקף הקוד פג — שלח קוד חדש',
      'too-many-requests' => 'יותר מדי ניסיונות — נסה שוב מאוחר יותר',
      'user-not-found' => 'לא נמצא חשבון עם פרטים אלה',
      'wrong-password' ||
      'invalid-credential' =>
        'אימייל או סיסמה שגויים',
      'email-already-in-use' => 'האימייל כבר רשום — התחברו במקום',
      'weak-password' => 'סיסמה חלשה (6+ תווים)',
      'invalid-email' => 'כתובת האימייל אינה תקינה',
      'user-disabled' => 'החשבון הושבת — פנה לתמיכה',
      'network-request-failed' => 'אין חיבור לרשת — נסה שוב',
      'requires-recent-login' =>
        'מטעמי אבטחה נדרשת התחברות מחדש — התחבר ונסה שוב',
      'unavailable' => 'שירות ההתחברות אינו זמין כרגע',
      _ => 'ההתחברות נכשלה — נסה שוב',
    };

/// Normalise an Israeli phone number to the E.164 shape `verifyPhoneNumber`
/// expects: `050-123 4567` → `+972501234567`. A number already carrying `+`
/// keeps its country code (any country). Returns null when the input cannot
/// be a dialable number (the sheet toasts 'מספר הטלפון אינו תקין').
/// Pure → unit-testable.
String? normalizeIlPhone(String raw) {
  final compact = raw.replaceAll(RegExp(r'[\s\-()]'), '');
  if (compact.startsWith('+')) {
    final digits = compact.substring(1);
    if (digits.length >= 11 && !digits.contains(RegExp(r'\D'))) return compact;
    return null;
  }
  if (compact.contains(RegExp(r'\D'))) return null;
  // Local format: leading 0 + 8–9 more digits (e.g. 0501234567) → +972…
  if (compact.startsWith('0') && (compact.length == 9 || compact.length == 10)) {
    return '+972${compact.substring(1)}';
  }
  return null;
}

/// Opens the login sheet (phone-OTP primary, email fallback).
Future<void> showLoginSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      // Keyboard inset — the fields stay visible while typing.
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: LoginSheet(),
      ),
    ),
  );
}

/// Which of the three panes the sheet is showing.
enum _LoginStep { phone, code, email }

class LoginSheet extends ConsumerStatefulWidget {
  const LoginSheet({super.key});

  @override
  ConsumerState<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends ConsumerState<LoginSheet> {
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  _LoginStep _step = _LoginStep.phone;
  bool _busy = false;

  /// server-gate-auth — within the email pane, toggles between sign-in (false,
  /// the default — today's "כניסה עם אימייל") and CREATE-account (true, the new
  /// "צור חשבון" → `createUserWithEmailPassword`). Ephemeral UI state.
  bool _emailCreateMode = false;

  /// The verificationId [AuthGateway.sendOtp] resolved with — consumed by the
  /// code step. Null until a code was sent.
  String? _verificationId;

  /// The E.164 number the code went to (shown on the code step).
  String _sentTo = '';

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // ── flow actions (every failure → Hebrew toast, never a throw) ─────────────

  Future<void> _sendOtp({bool resend = false}) async {
    final phone = normalizeIlPhone(_phone.text);
    if (phone == null) {
      showToast(context, 'מספר הטלפון אינו תקין');
      return;
    }
    setState(() => _busy = true);
    try {
      final id = await ref.read(authStateProvider.notifier).sendOtp(phone);
      if (!mounted) return;
      setState(() {
        _verificationId = id;
        _sentTo = phone;
        _step = _LoginStep.code;
        _busy = false;
      });
      showToast(
        context,
        resend ? 'קוד חדש נשלח ב-SMS 📱' : 'קוד אימות נשלח ב-SMS 📱',
      );
    } on AuthGatewayException catch (e) {
      _fail(hebrewAuthError(e.code));
    } on Object catch (_) {
      _fail(hebrewAuthError('unknown'));
    }
  }

  Future<void> _confirmCode() async {
    final code = _code.text.trim();
    final verificationId = _verificationId;
    if (code.length < 6 || verificationId == null) {
      showToast(context, 'הזן את הקוד בן 6 הספרות שקיבלת ב-SMS');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .signInWithSmsCode(verificationId, code);
      // Success lands on authStateChanges → the ref.listen below pops us.
      if (mounted) setState(() => _busy = false);
    } on AuthGatewayException catch (e) {
      _fail(hebrewAuthError(e.code));
    } on Object catch (_) {
      _fail(hebrewAuthError('unknown'));
    }
  }

  Future<void> _emailLogin() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      showToast(context, 'הזן אימייל וסיסמה');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .signInWithEmailPassword(email, password);
      if (mounted) setState(() => _busy = false);
    } on AuthGatewayException catch (e) {
      _fail(hebrewAuthError(e.code));
    } on Object catch (_) {
      _fail(hebrewAuthError('unknown'));
    }
  }

  /// server-gate-auth — CREATE a REAL Firebase account ("צור חשבון"). Success
  /// lands on the auth stream (the ref.listen below pops the sheet), exactly
  /// like sign-in; the honest errors (`email-already-in-use` / `weak-password`)
  /// are Hebrew-toasted.
  Future<void> _emailCreate() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      showToast(context, 'הזן אימייל וסיסמה');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .createUserWithEmailPassword(email, password);
      if (mounted) setState(() => _busy = false);
    } on AuthGatewayException catch (e) {
      _fail(hebrewAuthError(e.code));
    } on Object catch (_) {
      _fail(hebrewAuthError('unknown'));
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _busy = false);
    showToast(context, message);
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // THE close path: a user landed (typed code, email, or Android
    // auto-verification) → toast + pop. Toast BEFORE pop so the root
    // ScaffoldMessenger is resolved from a still-mounted context.
    ref.listen<AuthSnapshot>(authStateProvider, (prev, next) {
      if (next.user != null && prev?.user == null) {
        showToast(context, 'התחברת בהצלחה ✓');
        Navigator.of(context).maybePop();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space3,
        BsTokens.space4,
        BsTokens.space5,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D8D8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space3),
            const Text(
              '🔐 התחברות לחשבון',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              switch (_step) {
                _LoginStep.phone => 'נשלח לך קוד אימות חד-פעמי ב-SMS',
                _LoginStep.code => 'הקוד נשלח אל $_sentTo',
                _LoginStep.email => _emailCreateMode
                    ? 'יצירת חשבון חדש עם אימייל וסיסמה'
                    : 'כניסה עם אימייל וסיסמה',
              },
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: BsTokens.space4),
            ...switch (_step) {
              _LoginStep.phone => _phonePane(),
              _LoginStep.code => _codePane(),
              _LoginStep.email => _emailPane(),
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _phonePane() => [
        _field(
          controller: _phone,
          hint: 'מספר טלפון נייד',
          icon: Icons.phone_iphone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: BsTokens.space3),
        _primaryButton(label: 'שלח קוד אימות', onPressed: _sendOtp),
        const SizedBox(height: BsTokens.space2),
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() => _step = _LoginStep.email),
          child: const Text(
            'כניסה עם אימייל וסיסמה',
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ];

  List<Widget> _codePane() => [
        _field(
          controller: _code,
          hint: 'קוד בן 6 ספרות',
          icon: Icons.sms_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: BsTokens.space3),
        _primaryButton(label: 'אימות וכניסה', onPressed: _confirmCode),
        const SizedBox(height: BsTokens.space2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _busy ? null : () => _sendOtp(resend: true),
              child: const Text(
                'שליחת קוד חדש',
                style: TextStyle(
                  color: BsTokens.mutedLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _code.clear();
                        _step = _LoginStep.phone;
                      }),
              child: const Text(
                'החלפת מספר',
                style: TextStyle(
                  color: BsTokens.mutedLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ];

  List<Widget> _emailPane() => [
        _field(
          controller: _email,
          hint: 'אימייל',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: BsTokens.space3),
        _field(
          controller: _password,
          hint: _emailCreateMode ? 'סיסמה (6+ תווים)' : 'סיסמה',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: BsTokens.space3),
        // server-gate-auth — the primary action follows the mode: sign-in
        // (today's "כניסה עם אימייל") or CREATE a real Firebase account.
        _primaryButton(
          label: _emailCreateMode ? 'צור חשבון' : 'כניסה עם אימייל',
          onPressed: _emailCreateMode ? _emailCreate : _emailLogin,
        ),
        const SizedBox(height: BsTokens.space2),
        // server-gate-auth — flip between sign-in and create-account in place.
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() => _emailCreateMode = !_emailCreateMode),
          child: Text(
            _emailCreateMode
                ? 'כבר יש לי חשבון — כניסה'
                : 'אין לי חשבון — צור חשבון',
            style: const TextStyle(
              color: BsTokens.brandDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() => _step = _LoginStep.phone),
          child: const Text(
            'חזרה לכניסה עם טלפון',
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ];

  /// Brand FilledButton (the pod-sheet idiom) with the loading state: while
  /// [_busy] the button is disabled and shows a small white spinner.
  Widget _primaryButton({
    required String label,
    required Future<void> Function() onPressed,
  }) {
    return FilledButton(
      onPressed: _busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: BsTokens.brand,
        disabledBackgroundColor: const Color(0xFFF3D8C4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        ),
      ),
      child: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
    );
  }

  /// One input — right-aligned under ambient RTL, LTR entry for digits/Latin
  /// (the profile_screen contact-field idiom).
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      enabled: !_busy,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
      style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: const TextStyle(color: BsTokens.mutedLight),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BsTokens.brand, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space4,
        ),
      ),
    );
  }
}
