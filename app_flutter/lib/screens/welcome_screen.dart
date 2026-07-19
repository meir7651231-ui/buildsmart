import 'dart:async';

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/login_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/role_requests.dart' show submitRoleRequest;
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/state/user_system_sync.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First-run registration — ported from the prototype's `screen-welcome`
/// (`index.html`) in the "hero sheet" look: a tall orange gradient hero with a
/// glassy logo badge up top, and a white sheet that lifts over it carrying the
/// form — existing-customer login, full name + contact (saved locally, no
/// server), or "continue as demo". On continue → the profession step.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key, this.boardRole});

  /// task #65 + cluster #85א · role-gate mode: when set, this screen acts as
  /// the login gate of a role board. 'כניסה ללקוח קיים' is the PRIMARY path:
  /// tapping it reveals (inline, same card style) שם משתמש + קוד fields and a
  /// 'כניסה' button; the registration form is contractor-only and hidden
  /// here, and 'מצב דמו' enters a demo board session. A successful login
  /// simply flips [boardAuthProvider] — the gated board (or the role-picker's
  /// gate route) rebuilds into the board in place, so no navigation happens.
  final BoardRole? boardRole;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _contact = TextEditingController();

  /// server-gate-auth — the registration PASSWORD, used ONLY when the backend
  /// flag is ON and the contact is an email: the welcome CTA then mints a REAL
  /// Firebase account (`createUserWithEmailPassword`) instead of writing a
  /// local-only profile. The field is not built (and never read) when the flag
  /// is OFF, so the demo flow stays byte-identical.
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(_onChanged);
    _contact.addListener(_onChanged);
    _password.addListener(_onChanged);
  }

  /// task #65 + #85א · role-gate mode only: a well-formed code that
  /// [BoardAuthNotifier.login] rejected — shows 'שם משתמש או קוד לא נכונים'
  /// under the code field until the input is edited again. Never set in the
  /// contractor flow.
  bool _codeRejected = false;

  /// Cluster #85א · role-gate mode only: whether the inline existing-customer
  /// login form (שם משתמש + קוד + 'כניסה') is revealed — tapping
  /// 'כניסה ללקוח קיים' toggles it. Never set in the contractor flow.
  /// Ephemeral UI state on purpose — not persisted.
  bool _loginRevealed = false;

  /// True while a flag-ON async entry (register / existing-login) is in flight,
  /// so the CTAs are disabled and a double-tap can't fire two concurrent
  /// create / login-sheet flows. Ephemeral.
  bool _busy = false;

  void _onChanged() => setState(() => _codeRejected = false);

  /// task #65 · role-gate mode: FORMAT check for the 4-digit board code —
  /// spaces/dashes stripped, mirroring the validators in
  /// `logic/input_validators.dart` (lives here because this gate is the only
  /// caller; real existence checks stay in [BoardAuthNotifier.login]).
  static bool _validBoardCode(String input) {
    final digits = input.replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^\d{4}$').hasMatch(digits);
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _password.dispose();
    super.dispose();
  }

  void _advance() => ref.read(startupStepProvider.notifier).state = 1;

  /// task #65 + #85א · role-gate mode: try the seeded board credentials
  /// (the שם משתמש + קוד fields of the revealed login form). Success flips
  /// [boardAuthProvider] and the gated parent rebuilds into the board — no
  /// navigation here. Failure shows 'שם משתמש או קוד לא נכונים' under the
  /// code field via the errorText slot.
  void _boardLogin(BoardRole role) {
    final ok = ref
        .read(boardAuthProvider.notifier)
        .login(role, _name.text, _contact.text);
    if (!ok) setState(() => _codeRejected = true);
  }

  void _register() {
    // Contractor flow only — in role mode (cluster #85א) the registration
    // form is not built; board login goes through [_boardLogin].
    //
    // server-gate-auth — live backend (flag ON): the welcome CTA must mint a
    // REAL Firebase account, never a local-only "registered" profile (the gap a
    // device test exposed). So flag-ON routes to [_registerViaAuth] and does
    // NOT call `user_profile.register` here. Demo (flag OFF): the verbatim
    // local register + advance to the profession step, byte-identical.
    if (useFirebaseBackend) {
      if (_busy) return; // a flow is already in flight — ignore the double-tap
      setState(() => _busy = true);
      unawaited(
        _registerViaAuth().whenComplete(() {
          if (mounted) setState(() => _busy = false);
        }),
      );
      return;
    }
    ref
        .read(userProfileProvider.notifier)
        .register(name: _name.text.trim(), contact: _contact.text.trim());
    _advance();
  }

  /// server-gate-auth (flag ON only) — mint a REAL account for a NEW user from
  /// the welcome form. The contact field accepts a phone OR an email:
  ///   • EMAIL → create the account directly with the typed password
  ///     (`createUserWithEmailPassword`); honest errors (`email-already-in-use`
  ///     / `weak-password`) are Hebrew-toasted and the user stays on welcome.
  ///   • PHONE → route to the login sheet's phone-OTP (which mints the account
  ///     on first verify; the password field is email-only).
  /// Either way, ONLY a real signed-in user advances — then the identity is
  /// mirrored to `users/{uid}` and the app entered (see [_finishAfterAuth]).
  Future<void> _registerViaAuth() async {
    final contact = _contact.text.trim();
    final password = _password.text;
    if (validEmail(contact)) {
      // Mirror the typed name locally so the post-auth users/{uid} write and
      // the profile chip carry it (the account itself is the real Firebase
      // identity — this is the on-device display copy, like the login flow).
      ref
          .read(userProfileProvider.notifier)
          .register(name: _name.text, contact: contact);
      try {
        await ref
            .read(authStateProvider.notifier)
            .createUserWithEmailPassword(contact, password);
      } on AuthGatewayException catch (e) {
        if (mounted) showToast(context, hebrewAuthError(e.code));
        return;
      } on Object catch (_) {
        if (mounted) showToast(context, hebrewAuthError('unknown'));
        return;
      }
      if (!mounted) return;
      // The account now exists (createUser signed us in at the FirebaseAuth
      // level). The authStateProvider STREAM may not have propagated to the
      // snapshot yet, so do NOT gate on `signedIn` — that race left a freshly
      // registered email user stuck on welcome. Advance unconditionally;
      // _finishAfterAuth reads the uid from the gateway's currentUser when the
      // snapshot still lags.
      _finishAfterAuth();
      return;
    }
    // Phone contact (or non-email): the account is minted by phone-OTP in the
    // login sheet. Mirror the name first so the post-auth write carries it.
    ref
        .read(userProfileProvider.notifier)
        .register(name: _name.text, contact: contact);
    await _enterViaAuth();
  }

  void _demo() {
    final role = widget.boardRole;
    if (role != null) {
      // מנהל = חשבון הבעלים: אין כניסת דמו (גם הגנה אם נקרא בטעות) — "אין לו דמו".
      if (role == BoardRole.manager) return;
      // Role-gate mode: the demo affordance enters a demo board session —
      // the contractor profile / startup flow is never touched.
      ref.read(boardAuthProvider.notifier).enterDemo(role);
      return;
    }
    ref.read(userProfileProvider.notifier).continueAsDemo();
    _advance();
  }

  Future<void> _existingLogin() async {
    // Board role-gate FIRST (#65): in role mode 'כניסה ללקוח קיים' is the
    // seeded username+code login (the revealed inline form normally handles
    // it — this path is a safety net), independent of the Firebase flag.
    final role = widget.boardRole;
    if (role != null) {
      _boardLogin(role);
      return;
    }
    // Contractor flow — live backend (flag ON): route to the Firebase
    // phone-OTP login sheet; on success we enter the app.
    if (useFirebaseBackend) {
      if (_busy) return; // a flow is already in flight — ignore the double-tap
      setState(() => _busy = true);
      unawaited(
        _enterViaAuth().whenComplete(() {
          if (mounted) setState(() => _busy = false);
        }),
      );
      return;
    }
    // Demo (flag OFF) — #19 honesty: there is no login server yet (tickets
    // #23/#27), so say so BEFORE entering as a demo guest. For App Store review
    // (kHideUnderConstruction) the self-declared "אין שרת … (דוגמה)" wording is
    // SOFTENED to a neutral guest-entry confirmation (Apple rejects apps that
    // present themselves as demos / missing a backend); the underlying guest
    // flow is identical, and flipping the flag restores the honest disclosure.
    final ok = await confirmDestructive(
      context,
      title: 'כניסה ללקוח קיים',
      message: kHideUnderConstruction
          ? 'נכנסים כאורח כדי לעיין באפליקציה.'
          : 'עדיין אין שרת התחברות — נכנסים כאורח (דוגמה).',
      confirmLabel: 'המשך כאורח',
      confirmColor: BsTokens.brandDark,
    );
    if (!ok || !mounted) return;
    ref.read(userProfileProvider.notifier).continueAsDemo();
    ref.read(welcomeSeenProvider.notifier).state = true;
    unawaited(persistWelcomeSeen());
  }

  /// Live-backend entry: open the Firebase login sheet (phone-OTP / email /
  /// create-account), and once [authStateProvider] reports a signed-in user,
  /// finish via [_finishAfterAuth]. A cancelled sheet (still signed-out) leaves
  /// the user on the welcome screen to retry.
  Future<void> _enterViaAuth() async {
    await showLoginSheet(context);
    if (!mounted) return;
    if (!ref.read(authStateProvider).signedIn) return; // cancelled — stay
    _finishAfterAuth();
  }

  /// server-gate-auth — the shared post-auth step both entry paths run once a
  /// REAL user has signed in: mirror the identity fields to `users/{uid}`
  /// (rules-safe merge — empties skipped, never clobbers role/fcmToken) and
  /// flip the welcome-seen gate so the app opens.
  void _finishAfterAuth() {
    // Prefer the snapshot uid; fall back to the gateway's currentUser when the
    // auth stream hasn't propagated yet (the direct email-create path, where
    // createUser set FirebaseAuth.currentUser synchronously but the snapshot
    // stream event is still queued).
    final uid = ref.read(authStateProvider).user?.uid ??
        ref.read(authGatewayProvider)?.currentUser?.uid;
    final writer = ref.read(usersProfileWriterProvider);
    // U0.3 (user-system) — DORMANT behind [kUserSystem]: on a REGISTERED login,
    // ensure the unified users/{uid} record exists (born status=pending,
    // all-by-approval) and refresh lastSeen. This registered-entry path is never
    // reached by an anonymous catalog guest, so the sync is non-anonymous here.
    // Const-false in every normal build → this whole block tree-shakes → the
    // shipped welcome flow is BYTE-IDENTICAL to today (the `if (kIntelLive)`
    // consent-modal call-site pattern).
    //
    // ⚠️ ORDER IS LOAD-BEARING — this MUST be enqueued BEFORE the legacy mirror
    // below, and it is the whole reason the two blocks are in this order.
    // Both write the SAME users/{uid} doc through `set(merge:true)`, and the SDK
    // preserves enqueue order, so whichever fires first CREATES the document:
    //   • mirror first (the old order) → the doc is created with NO `status`
    //     key, which firestore.rules ALLOWS on create
    //     (`request.resource.data.get('status','pending') == 'pending'` defaults
    //     when the key is absent). `ensureUser` then becomes an UPDATE that ADDS
    //     `status`, and the users update rule FREEZES `status` → permission-
    //     denied, swallowed by guardWrite. The doc is left status-less forever,
    //     `BsUser.fromWire(null)` decodes it as `pending`, and EVERY registered
    //     user is shown "ממתין לאישור מנהל" with all permissions denied.
    //   • ensureUser first (this order) → the doc is CREATED carrying
    //     `status: 'pending'` (legal on create), and the mirror's later merge
    //     touches only display fields, so the update rule passes.
    // This was deterministic, not a race: the mirror used to be ~10 statements
    // earlier in the same synchronous block.
    if (kUserSystem && uid != null) {
      unawaited(
        ref
            .read(userSystemSyncProvider)
            .onRegisteredLogin(
              uid: uid,
              profile: ref.read(userProfileProvider),
              isAnonymous: false,
              now: DateTime.now(),
            )
            .catchError((Object _) {}),
      );
      // U2.4 — file the roleRequest that seeds the U4 admin-approval queue: every
      // registration stays pending until an admin approves it (all-by-approval,
      // decision #1). The welcome flow is the contractor registration; store/
      // courier requests arrive via their own onboarding. submitRoleRequest
      // self-handles a signed-out / write failure (returns false, never throws).
      unawaited(submitRoleRequest(ref, 'contractor').then<void>((_) {}));
    }
    if (uid != null && writer != null) {
      final p = ref.read(userProfileProvider);
      // Best-effort identity mirror (merge); never blocks entry. The contact is
      // EITHER a phone OR an email (the email-create flow stores the email in
      // `contact`), so route it to the matching field — never write an email
      // into `phone` (the field users_lookup.uidByPhone queries).
      // Runs AFTER the user-system create above — see the ordering note there.
      unawaited(
        writer.set(uid, {
          if (p.name.isNotEmpty) 'displayName': p.name,
          if (validIsraeliMobile(p.contact)) 'phone': p.contact,
          if (validEmail(p.contact)) 'email': p.contact,
          if (p.profession.isNotEmpty) 'profession': p.profession,
          if (p.address.isNotEmpty) 'address': p.address,
          if (p.businessId.isNotEmpty) 'businessId': p.businessId,
        }).catchError((Object _) {}),
      );
    }
    ref.read(welcomeSeenProvider.notifier).state = true;
    unawaited(persistWelcomeSeen());
  }

  /// Manager (OWNER) gate — secure login is "כניסה עם Google" ONLY (no demo, no
  /// seed code). After a Google sign-in whose email is on the owner allowlist
  /// ([isOwnerEmail]) we grant the manager board; any other account is rejected.
  /// When Firebase is unavailable the Google button is replaced by an honest
  /// "needs a connection" message.
  List<Widget> _managerGoogleChildren() {
    final canGoogle = ref.read(authGatewayProvider) != null;
    return [
      const CfgText(
        'welcome_screen.mgr_login_title',
        'כניסת מנהל המערכת',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 19,
          color: BsTokens.inkLight,
        ),
      ),
      const SizedBox(height: BsTokens.space1),
      const CfgText(
        'welcome_screen.mgr_login_subtitle',
        'חשבון הבעלים — כניסה מאובטחת עם חשבון Google.',
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
      ),
      const SizedBox(height: BsTokens.space4),
      if (canGoogle)
        HelpTarget(
          title: 'כניסה עם Google',
          body: 'נכנסים עם חשבון ה-Google של הבעלים. גוגל מאמתת את הזהות '
              '(כולל אימות דו-שלבי אם מוגדר) — לא נשמרת סיסמה במכשיר.',
          child: FilledButton.icon(
            onPressed: _busy ? null : _managerGoogleLogin,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login_rounded),
            label: const CfgText(
              'welcome_screen.mgr_continue_google',
              'המשך עם Google',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: BsTokens.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: BsTokens.space4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        )
      else
        Container(
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D6),
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
          child: const CfgText(
            'welcome_screen.mgr_needs_connection',
            'כניסת מנהל דורשת חיבור לאינטרנט. נסה שוב כשיש חיבור.',
            style: TextStyle(color: Color(0xFF8A6D00), fontSize: 13),
          ),
        ),
    ];
  }

  /// Manager (OWNER) Google sign-in flow: sign in with Google → verify the email
  /// is on the owner allowlist → grant the manager board. A non-owner account is
  /// signed out with an honest message (never silently admits a stranger).
  Future<void> _managerGoogleLogin() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final user =
          await ref.read(authStateProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      if (user == null) return; // user cancelled the Google chooser
      if (!isOwnerEmail(user.email)) {
        await ref.read(authStateProvider.notifier).signOut();
        if (mounted) {
          showToast(context, 'רק חשבון הבעלים יכול להיכנס כמנהל המערכת');
        }
        return;
      }
      ref.read(boardAuthProvider.notifier).loginManagerViaGoogle(
            uid: user.uid,
            displayName: user.displayName ?? 'מנהל המערכת',
          );
      // OWNER bypass: when this runs from the opening-flow welcome (not only the
      // in-app role picker), the OnboardingGate must route to HomeShell — mark the
      // welcome seen so a freshly-signed-in owner is not bounced back into the
      // _OpeningFlow loop (auth.user != null + seen ⇒ HomeShell).
      ref.read(welcomeSeenProvider.notifier).state = true;
      unawaited(persistWelcomeSeen());
    } on AuthGatewayException catch (e) {
      if (mounted) showToast(context, hebrewAuthError(e.code));
    } on Object catch (_) {
      if (mounted) showToast(context, 'כניסת Google נכשלה — נסה שוב');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Cluster #85א · role-gate mode sheet: 'כניסה ללקוח קיים' is the PRIMARY
  /// login path — tapping it reveals (inline, same card style) the שם משתמש
  /// + קוד fields and a 'כניסה' button that checks the seeded credentials
  /// via [BoardAuthNotifier.login]. The registration form is contractor-only
  /// and never built here; 'מצב דמו' enters an honest demo board session.
  List<Widget> _boardLoginChildren(BoardRole role) {
    final codeFormatOk = _validBoardCode(_contact.text);
    final loginValid = _name.text.trim().isNotEmpty && codeFormatOk;
    return [
      // Manager (OWNER): the secure path is "כניסה עם Google" (owner-email). On
      // web — where Google sign-in isn't configured yet — a seeded code-login
      // (admin/5555) is ALSO offered so the owner can reach the manager board.
      // DEMO-GRADE (a compiled code); revert to Google-only before real production.
      if (role == BoardRole.manager) ...[
        ..._managerGoogleChildren(),
        const SizedBox(height: BsTokens.space5),
        const Divider(height: 1),
        const SizedBox(height: BsTokens.space4),
        const CfgText(
          'welcome_screen.mgr_or_code_login',
          'או כניסה עם קוד (demo)',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space3),
      ],
      HelpTarget(
        title: 'כניסה ללקוח קיים',
        body: 'הדרך הראשית להיכנס ללוח — לחיצה פותחת את שדות שם המשתמש '
            'והקוד שקיבלת.',
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: BsTokens.brandDark,
            side: const BorderSide(
              color: BsTokens.brand,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: BsTokens.space4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => setState(() => _loginRevealed = !_loginRevealed),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CfgText(
                'welcome_screen.board_existing_login_btn',
                'כניסה ללקוח קיים',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              Icon(
                _loginRevealed
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 22,
              ),
            ],
          ),
        ),
      ),
      if (_loginRevealed) ...[
        const SizedBox(height: BsTokens.space4),
        HelpTarget(
          title: 'שם משתמש',
          body: 'שם המשתמש שהוגדר לך בלוח — באנגלית, בלי הבדל בין אותיות '
              'גדולות לקטנות.',
          child: _field(
            _name,
            'שם משתמש',
            Icons.person_outline,
            // Board username is latin (see HelpTarget body) — render LTR.
            ltr: true,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        HelpTarget(
          title: 'קוד כניסה',
          body: 'קוד בן 4 ספרות שקיבלת יחד עם שם המשתמש — רווחים ומקפים '
              'מותרים.',
          child: _field(
            _contact,
            'קוד',
            Icons.key_outlined,
            keyboardType: TextInputType.number,
            ltr: true,
            textInputAction: TextInputAction.done,
            errorText: _codeRejected
                ? 'שם משתמש או קוד לא נכונים'
                : _contact.text.trim().isEmpty || codeFormatOk
                    ? null
                    : 'קוד בן 4 ספרות',
          ),
        ),
        const SizedBox(height: BsTokens.space5),
        HelpTarget(
          title: 'כניסה',
          body: 'בודק את שם המשתמש והקוד מול החשבונות הקיימים ונכנס ללוח. '
              'נפעל רק כששני השדות מלאים והקוד בן 4 ספרות.',
          child: _primaryButton(
            onPressed: loginValid ? () => _boardLogin(role) : null,
            label: 'כניסה',
            icon: Icons.login_rounded,
          ),
        ),
      ],
      // מנהל = חשבון הבעלים: אין כניסת דמו (דרישת מוצר — "אין לו דמו"). שאר
      // הלוחות שומרים על מצב הדמו לסיור מהיר.
      if (role != BoardRole.manager) ...[
        const SizedBox(height: BsTokens.space2),
        HelpTarget(
          title: 'מצב דמו',
          body: 'כניסה ללוח בלי חשבון — לסיור מהיר עם נתוני דוגמה בלבד.',
          child: TextButton(
            onPressed: _demo,
            child: const CfgText(
              'welcome_screen.board_demo_mode',
              'מצב דמו',
              style: TextStyle(
                color: BsTokens.mutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    // task #64: format gate — the contact must look like an Israeli mobile
    // (05XXXXXXXX) or an email before the CTA unlocks. Format only;
    // uniqueness checks are deferred to the Firebase backend. Contractor
    // flow only — role mode (cluster #85א) builds its own login sheet via
    // [_boardLoginChildren] and never reads these.
    final contactOk =
        validIsraeliMobile(_contact.text) || validEmail(_contact.text);
    // server-gate-auth — flag ON + an EMAIL contact mints a real account from
    // the welcome CTA, so a 6+ char password is required before it unlocks. A
    // PHONE contact routes to OTP (no password), and flag OFF never reads it —
    // so the demo CTA gate is byte-identical.
    final needsPassword =
        useFirebaseBackend && validEmail(_contact.text);
    final passwordOk = !needsPassword || _password.text.length >= 6;
    final valid =
        registrationValid(_name.text, _contact.text) && contactOk && passwordOk;
    final media = MediaQuery.of(context);
    final heroHeight = media.size.height * 0.4;
    return Scaffold(
      // White scaffold so any gap below the lifted sheet reads as one
      // continuous white surface.
      backgroundColor: BsTokens.cardLight,
      body: HelpModeScaffold(
        child: Stack(
          children: [
            SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: media.size.height),
          child: Column(
            children: [
              // ===== Brand hero (orange gradient) =====
              Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: heroHeight),
                padding: EdgeInsets.fromLTRB(
                  BsTokens.space5,
                  media.padding.top + 56,
                  BsTokens.space5,
                  56,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8A2B), BsTokens.brandDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: const Icon(
                        Icons.engineering_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space4),
                    const CfgText(
                      'welcome.hero.title',
                      'BuildSmart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space2),
                    const CfgText(
                      'welcome.hero.tagline',
                      'מהשרטוט עד האתר — בלי לשכוח כלום',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // ===== White sheet (lifts over the hero, rounded top) =====
              Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    BsTokens.space5,
                    BsTokens.space5,
                    BsTokens.space5,
                    BsTokens.space4,
                  ),
                  decoration: const BoxDecoration(
                    color: BsTokens.cardLight,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cluster #85א — role mode: the sheet IS the
                      // existing-customer login (registration is
                      // contractor-only). Contractor children below are
                      // unchanged.
                      if (widget.boardRole != null)
                        ..._boardLoginChildren(widget.boardRole!)
                      else ...[
                      // OWNER bypass (server-gate-auth): on the LIVE backend the
                      // owner/manager signs in with Google RIGHT HERE. Without it
                      // the manager Google login was only reachable from inside
                      // HomeShell — which is unreachable while signed-out, since the
                      // OnboardingGate forces _OpeningFlow until auth.user != null
                      // (the circular dead-end a device test hit). isOwnerEmail is
                      // enforced server-side in _managerGoogleLogin. Hidden on the
                      // demo build (no Firebase) — byte-identical there.
                      if (useFirebaseBackend) ...[
                        HelpTarget(
                          title: 'כניסה עם Google (בעלים/מנהל)',
                          body: 'בעל המערכת נכנס עם חשבון ה-Google שלו — הדרך '
                              'המהירה להיכנס מחובר. רק חשבון הבעלים מורשה.',
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: BsTokens.brand,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: BsTokens.space4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _busy ? null : _managerGoogleLogin,
                            child: const CfgText(
                              'welcome_screen.owner_google_login',
                              'כניסה עם Google (בעלים)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: BsTokens.space4),
                      ],
                      HelpTarget(
                        title: 'כניסה ללקוח קיים',
                        // server-gate-auth — flag ON: a real login sheet opens
                        // (טלפון/אימייל). Flag OFF: the verbatim guest wording.
                        body: useFirebaseBackend
                            ? 'מיועד למי שכבר נרשם — נפתח חלון התחברות עם '
                                'טלפון או אימייל.'
                            : 'מיועד למי שכבר נרשם — כניסה ישירה פנימה. כרגע '
                                'אין שרת התחברות, כך שבפועל זה נכנס כאורח.',
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: BsTokens.brandDark,
                            side: const BorderSide(
                              color: BsTokens.brand,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: BsTokens.space4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _busy ? null : _existingLogin,
                          child: const CfgText(
                            'welcome_screen.existing_login_btn',
                            'כניסה ללקוח קיים',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: BsTokens.space4),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFECECEC),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: BsTokens.space3,
                            ),
                            child: CfgText(
                              'welcome.signup.divider',
                              'או הירשם',
                              style: TextStyle(
                                color: BsTokens.mutedLight,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFECECEC),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: BsTokens.space4),
                      const CfgText(
                        'welcome.signup.heading',
                        'רישום ראשוני',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          color: BsTokens.inkLight,
                        ),
                      ),
                      const SizedBox(height: BsTokens.space1),
                      const CfgText(
                        'welcome.signup.subtitle',
                        'מלא את הפרטים — סימן ✓ יופיע כשהשדות תקינים',
                        style: TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: BsTokens.space4),
                      HelpTarget(
                        title: 'שם מלא',
                        body: 'השם שיוצג בפרופיל ובהזמנות. שדה זה פחות קריטי — '
                            'הזיהוי בפועל הוא לפי טלפון/מייל.',
                        child:
                            _field(
                              _name,
                              'שם מלא',
                              Icons.person_outline,
                              autofillHints: const [AutofillHints.name],
                              textInputAction: TextInputAction.next,
                            ),
                      ),
                      const SizedBox(height: BsTokens.space3),
                      HelpTarget(
                        title: 'טלפון או אימייל',
                        body: 'פרטי הקשר שמזהים אותך כלקוח — לפיהם תזוהה '
                            'בכניסה הבאה. כאן מקלידים מספר טלפון או כתובת מייל.',
                        child: _field(
                          _contact,
                          'טלפון או אימייל',
                          Icons.alternate_email,
                          ltr: true,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: needsPassword
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onSubmitted:
                              needsPassword ? null : (valid ? _register : null),
                          errorText: _contact.text.trim().isEmpty || contactOk
                              ? null
                              : 'מספר נייד או אימייל לא תקינים',
                        ),
                      ),
                      // server-gate-auth — flag ON + an email contact: a real
                      // Firebase account is minted here, so collect a password.
                      // Not built when the flag is OFF (demo byte-identical) or
                      // for a phone contact (that account is minted by OTP).
                      if (needsPassword) ...[
                        const SizedBox(height: BsTokens.space3),
                        HelpTarget(
                          title: 'סיסמה',
                          body: 'בוחרים סיסמה (6 תווים ומעלה) ליצירת החשבון. '
                              'איתה תוכלו להתחבר בכל מכשיר.',
                          child: _field(
                            _password,
                            'סיסמה (6+ תווים)',
                            Icons.lock_outline,
                            obscure: true,
                            ltr: true,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            onSubmitted: valid ? _register : null,
                            errorText: _password.text.isEmpty ||
                                    _password.text.length >= 6
                                ? null
                                : 'סיסמה חלשה (6+ תווים)',
                          ),
                        ),
                      ],
                      const SizedBox(height: BsTokens.space5),
                      HelpTarget(
                        title: 'אישור והמשך',
                        body: 'מסיים את ההרשמה, שומר את הפרטים, וממשיך לבחירת '
                            'המקצוע. נפעל רק כשהשדות תקינים.',
                        child: _primaryButton(
                          onPressed: (valid && !_busy) ? _register : null,
                        ),
                      ),
                      const SizedBox(height: BsTokens.space2),
                      HelpTarget(
                        title: 'המשך ללא רישום (דוגמה)',
                        body: 'נכנסים כאורח-דמו בלי לשמור פרטים — לסיור מהיר '
                            'באפליקציה. אפשר להירשם מאוחר יותר מההגדרות.',
                        child: TextButton(
                          onPressed: _demo,
                          // server-gate-auth — flag ON: this is the ONLY way in
                          // without a real Firebase account, so it is labelled
                          // HONESTLY as a demo (local data — never impersonating
                          // a real account). Flag OFF: the verbatim wording.
                          child: Text(
                            useFirebaseBackend
                                ? 'מצב דמו — נתונים מקומיים'
                                : 'המשך ללא רישום (דוגמה)',
                            style: const TextStyle(
                              color: BsTokens.mutedLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: BsTokens.space2),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const CfgText(
                            'welcome_screen.terms_prefix',
                            'בהרשמה אתה מאשר את ',
                            style: TextStyle(
                              color: BsTokens.mutedLight,
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              LegalScreen.route(initialTab: LegalTab.terms),
                            ),
                            child: const CfgText(
                              'welcome_screen.terms_of_use',
                              'תנאי השימוש',
                              style: TextStyle(
                                color: BsTokens.brandDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const CfgText(
                            'welcome_screen.terms_and',
                            ' ואת ',
                            style: TextStyle(
                              color: BsTokens.mutedLight,
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              LegalScreen.route(initialTab: LegalTab.privacy),
                            ),
                            child: const CfgText(
                              'welcome_screen.privacy_policy',
                              'מדיניות הפרטיות',
                              style: TextStyle(
                                color: BsTokens.brandDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const CfgText(
                            'welcome_screen.terms_suffix',
                            ' של BuildSmart',
                            style: TextStyle(
                              color: BsTokens.mutedLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      ], // end contractor-only sheet (cluster #85א)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
          ),
          const Positioned(
            top: 4,
            left: 4,
            child: SafeArea(
              child: HelpToggleButton(color: Colors.white),
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// Brand gradient CTA with a soft orange glow — the "refined" primary action.
  /// [label]/[icon] default to the contractor registration CTA; the board
  /// login (cluster #85א) passes 'כניסה'. Rendering is unchanged for the
  /// defaults.
  Widget _primaryButton({
    required VoidCallback? onPressed,
    String label = 'אישור והמשך',
    IconData icon = Icons.check_rounded,
  }) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [BsTokens.brand, BsTokens.brandDark],
              )
            : null,
        color: enabled ? null : const Color(0xFFF3D8C4),
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? const [
                BoxShadow(
                  color: Color(0x59FF7A18),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: BsTokens.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: BsTokens.space2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    String? errorText,
    TextInputType? keyboardType,
    bool obscure = false,
    // LTR for digits/email/latin (phone, code, password); the default (RTL,
    // inherited) keeps a Hebrew NAME field right-to-left. Mirrors login_sheet's
    // _field, which forces ltr on its (all-latin) inputs.
    bool ltr = false,
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
  }) {
    final ok = c.text.trim().isNotEmpty && errorText == null;
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      obscureText: obscure,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
      textAlign: TextAlign.right,
      textDirection: ltr ? TextDirection.ltr : null,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
        suffixIcon: ok
            ? const Icon(Icons.check_circle, color: Color(0xFF1F8A4C))
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BsTokens.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BsTokens.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BsTokens.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space4,
        ),
      ),
    );
  }
}
