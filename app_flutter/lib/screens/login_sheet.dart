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

import 'dart:async';

import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/feature_flags.dart' show kEmailPasswordAuth;
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
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
      // P2 — account-enumeration: user-not-found is folded into the SAME generic
      // credential error as a wrong password, so the sign-in form can't be used
      // to probe which emails are registered. (The full server-side fix is the
      // Firebase console "Email Enumeration Protection" toggle — owner action;
      // this is client defense-in-depth that helps even without it.)
      'user-not-found' ||
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
  // P2 — optional full name captured on the "צור חשבון" path (mirrored to the
  // local profile → users/{uid}.displayName by the welcome flow's post-auth step).
  final TextEditingController _name = TextEditingController();

  _LoginStep _step = _LoginStep.phone;
  bool _busy = false;

  /// server-gate-auth — within the email pane, toggles between sign-in (false,
  /// the default — today's "כניסה עם אימייל") and CREATE-account (true, the new
  /// "צור חשבון" → `createUserWithEmailPassword`). Ephemeral UI state.
  bool _emailCreateMode = false;
  // #3 — true while a "צור חשבון" is in flight, so the auth-stream listener shows
  // the email-verification notice (a verification mail was sent best-effort by
  // createUserWithEmailPassword) instead of the generic sign-in toast.
  bool _justCreated = false;
  // Latches the one-time success toast+pop in the auth listener, so a later
  // user→null→user transition on the same sheet can't re-toast / double-pop.
  bool _popped = false;
  // P2 — show/hide the password (the eye toggle in the email pane). Ephemeral.
  bool _showPassword = false;
  // P2 — when the current SMS code was sent, for the resend cooldown + the
  // code-validity (expiry) pre-check. Timestamp-driven (no Timer) so the OTP
  // widget tests' pumpAndSettle keep settling.
  DateTime? _otpSentAt;
  static const int _kResendCooldownSecs = 30;
  static const int _kCodeValiditySecs = 120;

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
    _name.dispose();
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
        _otpSentAt = DateTime.now(); // P2 — start the resend cooldown / expiry
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

  /// P2 — resend the SMS code, but enforce a [_kResendCooldownSecs] cooldown so
  /// a user can't hammer the (rate-limited, billable) send. Within the window it
  /// toasts the precise remaining seconds instead of re-sending.
  void _onResendTapped() {
    final sentAt = _otpSentAt;
    if (sentAt != null) {
      final remaining =
          _kResendCooldownSecs - DateTime.now().difference(sentAt).inSeconds;
      if (remaining > 0) {
        showToast(context, 'אפשר לשלוח קוד חדש בעוד $remaining שניות');
        return;
      }
    }
    unawaited(_sendOtp(resend: true));
  }

  Future<void> _confirmCode() async {
    final code = _code.text.trim();
    final verificationId = _verificationId;
    if (verificationId == null || !RegExp(r'^\d{6}$').hasMatch(code)) {
      showToast(context, 'הזן את הקוד בן 6 הספרות שקיבלת ב-SMS');
      return;
    }
    // P2 — expiry pre-check: skip the round-trip if the code is already past its
    // validity window (the server also returns session-expired as a backstop).
    final sentAt = _otpSentAt;
    if (sentAt != null &&
        DateTime.now().difference(sentAt).inSeconds > _kCodeValiditySecs) {
      showToast(context, 'תוקף הקוד פג — שלח קוד חדש');
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
    // LOCK 2 of 2 — the two calls that actually hand a password to Firebase are
    // guarded here, not only where the button is drawn. A UI-only gate is
    // undone by anyone who later adds another entry point; these two lines are
    // the ones that matter.
    if (!kEmailPasswordAuth) return;
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      showToast(context, 'הזן אימייל וסיסמה');
      return;
    }
    if (!validEmail(email)) {
      showToast(context, 'כתובת האימייל אינה תקינה');
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
    if (!kEmailPasswordAuth) return; // LOCK 2 of 2 — see [_emailLogin]
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      showToast(context, 'הזן אימייל וסיסמה');
      return;
    }
    if (!validEmail(email)) {
      showToast(context, 'כתובת האימייל אינה תקינה');
      return;
    }
    // P2 — client-side length pre-check (Firebase's floor is 6) so the user gets
    // instant feedback without a round-trip; the server weak-password error is
    // still mapped as a backstop.
    if (password.length < 6) {
      showToast(context, 'הסיסמה חייבת לפחות 6 תווים');
      return;
    }
    setState(() {
      _busy = true;
      _justCreated = true; // #3 — show the verification notice on success
    });
    try {
      await ref
          .read(authStateProvider.notifier)
          .createUserWithEmailPassword(email, password);
      // P2 — capture the optional name into the local profile so the app knows
      // the user; the welcome flow's post-auth step mirrors it to
      // users/{uid}.displayName (read by computeCredit / the push sender name).
      final name = _name.text.trim();
      if (name.isNotEmpty) {
        ref.read(userProfileProvider.notifier).register(
              name: name,
              contact: ref.read(userProfileProvider).contact,
            );
      }
      if (mounted) setState(() => _busy = false);
    } on AuthGatewayException catch (e) {
      _justCreated = false;
      _fail(hebrewAuthError(e.code));
    } on Object catch (_) {
      _justCreated = false;
      _fail(hebrewAuthError('unknown'));
    }
  }

  /// "שכחתי סיסמה" — send a reset email. The SAME neutral success toast shows
  /// whether or not the email is registered (no account enumeration — a
  /// `user-not-found` is folded into success); only real failures
  /// (invalid-email / network / too-many) surface in Hebrew. Needs an email.
  Future<void> _resetPassword() async {
    if (!kEmailPasswordAuth) return; // no passwords ⇒ nothing to reset
    final email = _email.text.trim();
    if (email.isEmpty) {
      showToast(context, 'הזן אימייל לאיפוס הסיסמה');
      return;
    }
    if (!validEmail(email)) {
      showToast(context, 'כתובת האימייל אינה תקינה');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authStateProvider.notifier).resetPassword(email);
    } on AuthGatewayException catch (e) {
      if (e.code != 'user-not-found') {
        _fail(hebrewAuthError(e.code));
        return;
      }
    } on Object catch (_) {
      _fail(hebrewAuthError('unknown'));
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    showToast(context, 'אם קיים חשבון — נשלח אליו מייל לאיפוס הסיסמה');
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
      // The transition we close on is GUEST-OR-NOBODY → A REAL PERSON.
      //
      // This used to read `next.user != null && prev?.user == null`, which was
      // correct only while a signed-out visitor really had no Firebase user.
      // Since the server-catalog bootstrap signs every visitor in ANONYMOUSLY
      // before the first frame (main.dart → ensureAnonAuthForServerCatalog),
      // `prev.user` is never null, so a successful OTP moved anonUser → phoneUser
      // and this predicate NEVER fired: no toast, no pop, and the awaiting
      // `_enterViaAuth` never ran `_finishAfterAuth()`. The user typed a valid
      // code, the spinner stopped, and the sheet just sat there.
      final becameReal = next.user?.isRealUser ?? false;
      final wasReal = prev?.user?.isRealUser ?? false;
      if (becameReal && !wasReal && !_popped) {
        _popped = true; // one-shot — never re-toast / double-pop this sheet
        // #3 — a fresh account was just sent a verification email (best-effort,
        // by createUserWithEmailPassword); prompt the user to confirm it rather
        // than the generic sign-in toast.
        showToast(
          context,
          _justCreated
              ? '✓ החשבון נוצר — שלחנו מייל אימות לכתובת, אַשרו אותו'
              : 'התחברת בהצלחה ✓',
        );
        _justCreated = false;
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
            CfgText(
              'login_sheet.t01',
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
                _LoginStep.code => 'הקוד נשלח אל $_sentTo · תקף לכ-2 דקות',
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
              // LOCK 3 of 3 — the one that makes the pane ABSENT rather than
              // merely unreachable. Locks 1 and 2 mean no code path can set
              // [_step] to `email`, but dart2js cannot prove that (it is runtime
              // state), so `_emailPane` and every string in it still shipped in
              // the bundle. With this const branch the compiler folds the arm
              // away, the method becomes unreferenced, and it is tree-shaken out
              // — verified by searching the deployed main.dart.js. It also means
              // a future edit that somehow reaches this state renders the phone
              // pane instead of a working password form.
              _LoginStep.email =>
                kEmailPasswordAuth ? _emailPane() : _phonePane(),
            },
          ],
        ),
      ),
    );
  }

  /// Sign in with Google — for ANY user, not only the owner.
  ///
  /// The mechanism existed already, but every entry point to it was the
  /// owner/manager one (`_managerGoogleLogin`, gated on an email allowlist), so
  /// a normal person had no Google door at all. With email+password closed that
  /// left exactly one way in — an SMS message, which costs money per send and
  /// depends on a carrier region policy that has already blocked this project
  /// once. This restores the second door the decision assumed was there.
  ///
  /// No allowlist and no role granted: this only proves identity. The account
  /// still lands `pending` like every other registration, because `_UserDocSync`
  /// (main.dart) ensures the record on any real sign-in.
  Future<void> _googleLogin() async {
    setState(() => _busy = true);
    try {
      final user =
          await ref.read(authStateProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      setState(() => _busy = false);
      // A null user is the person closing the Google chooser — not a failure,
      // so it must not toast an error at them.
      if (user == null) return;
      // Success lands on authStateChanges → the ref.listen below pops the sheet.
    } on AuthGatewayException catch (e) {
      _fail(hebrewAuthError(e.code));
    } on Object catch (_) {
      _fail('כניסת Google נכשלה — נסה שוב');
    }
  }

  List<Widget> _phonePane() => [
        // Google first: it is one tap, costs nothing to send, and works where
        // SMS delivery does not.
        if (ref.read(authGatewayProvider) != null) ...[
          OutlinedButton.icon(
            onPressed: _busy ? null : _googleLogin,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('המשך עם Google'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: BsTokens.inkLight,
              side: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space2,
                ),
                child: CfgText(
                  'login_sheet.t06',
                  'או בקוד ל-SMS',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 13,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        _field(
          controller: _phone,
          hint: 'מספר טלפון נייד',
          icon: Icons.phone_iphone,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          textInputAction: TextInputAction.done,
          onSubmitted: _sendOtp,
        ),
        const SizedBox(height: BsTokens.space3),
        _primaryButton(label: 'שלח קוד אימות', onPressed: _sendOtp),
        const SizedBox(height: BsTokens.space2),
        // LOCK 1 of 2 — the only way into the email pane from this sheet. With
        // [kEmailPasswordAuth] off the button is not built at all, so [_step]
        // can never become [_LoginStep.email].
        if (kEmailPasswordAuth)
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() => _step = _LoginStep.email),
            child: CfgText(
              'login_sheet.t02',
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
          autofillHints: const [AutofillHints.oneTimeCode],
          textInputAction: TextInputAction.done,
          onSubmitted: _confirmCode,
        ),
        const SizedBox(height: BsTokens.space3),
        _primaryButton(label: 'אימות וכניסה', onPressed: _confirmCode),
        const SizedBox(height: BsTokens.space2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _busy ? null : _onResendTapped,
              child: CfgText(
                'login_sheet.t03',
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
              child: CfgText(
                'login_sheet.t04',
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
        // P2 — on the create path, capture an optional full name up front.
        if (_emailCreateMode) ...[
          _field(
            controller: _name,
            hint: 'שם מלא (לא חובה)',
            icon: Icons.person_outline,
            ltr: false, // a Hebrew name stays RTL
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        _field(
          controller: _email,
          hint: 'אימייל',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: BsTokens.space3),
        _field(
          controller: _password,
          hint: _emailCreateMode ? 'סיסמה (6+ תווים)' : 'סיסמה',
          icon: Icons.lock_outline,
          obscure: !_showPassword,
          autofillHints: _emailCreateMode
              ? const [AutofillHints.newPassword]
              : const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: () => _emailCreateMode ? _emailCreate() : _emailLogin(),
          // P2 — show/hide eye toggle.
          suffix: IconButton(
            onPressed:
                _busy ? null : () => setState(() => _showPassword = !_showPassword),
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFFBBBBBB),
              size: 20,
            ),
            tooltip: _showPassword ? 'הסתר סיסמה' : 'הצג סיסמה',
          ),
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
        // "שכחתי סיסמה" — only in sign-in mode (a create flow has no password to
        // reset yet). Sends a reset email via _resetPassword (no enumeration).
        if (!_emailCreateMode)
          TextButton(
            onPressed: _busy ? null : _resetPassword,
            child: CfgText(
              'login_sheet.t05',
              'שכחתי סיסמה',
              style: TextStyle(
                color: BsTokens.mutedLight,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() => _step = _LoginStep.phone),
          child: CfgText(
            'login_sheet.t06',
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
    Widget? suffix,
    // LTR by default (digits/email/latin); pass false for a Hebrew NAME field so
    // it stays RTL. autofillHints/textInputAction/onSubmitted wire OS autofill +
    // the keyboard's next/go action to the pane's primary action.
    bool ltr = true,
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      enabled: !_busy,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      textAlign: TextAlign.right,
      textDirection: ltr ? TextDirection.ltr : null,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
      style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: const TextStyle(color: BsTokens.mutedLight),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
        suffixIcon: suffix,
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
