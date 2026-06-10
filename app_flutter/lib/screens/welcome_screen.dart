import 'dart:async';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/login_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First-run registration — ported from the prototype's `screen-welcome`
/// (`index.html`) in the "hero sheet" look: a tall orange gradient hero with a
/// glassy logo badge up top, and a white sheet that lifts over it carrying the
/// form — existing-customer login, full name + contact (saved locally, no
/// server), or "continue as demo". On continue → the profession step.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key, this.boardRole});

  /// task #65 · role-gate mode: when set, this SAME screen — pixel- and
  /// string-identical (the user's hard rule: רק בקוד, לא בעיצוב ולא בטקסטים)
  /// — acts as the login gate of a role board: the name field is read as שם
  /// המשתמש, the contact field as the board code, the demo button enters a
  /// demo board session, and a successful login simply flips
  /// [boardAuthProvider] — the gated board (or the role-picker's gate route)
  /// rebuilds into the board in place, so no navigation happens here.
  final BoardRole? boardRole;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _contact = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(_onChanged);
    _contact.addListener(_onChanged);
  }

  /// task #65 · role-gate mode only: a well-formed code that
  /// [BoardAuthNotifier.login] rejected — keeps the existing field-error UI
  /// up until the input is edited again. Never set in the contractor flow.
  bool _codeRejected = false;

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
    super.dispose();
  }

  void _advance() => ref.read(startupStepProvider.notifier).state = 1;

  /// task #65 · role-gate mode: try the seeded board credentials (name field
  /// = שם משתמש, contact field = code). Success flips [boardAuthProvider] and
  /// the gated parent rebuilds into the board — no navigation here. Failure
  /// surfaces the existing field-error UI (no new strings).
  void _boardLogin(BoardRole role) {
    final ok = ref
        .read(boardAuthProvider.notifier)
        .login(role, _name.text, _contact.text);
    if (!ok) setState(() => _codeRejected = true);
  }

  void _register() {
    final role = widget.boardRole;
    if (role != null) {
      _boardLogin(role);
      return;
    }
    ref
        .read(userProfileProvider.notifier)
        .register(name: _name.text, contact: _contact.text);
    // Live backend (flag ON): name/contact are saved locally, then the user
    // authenticates (phone-OTP) — without auth the _firebase repos hit the
    // deny-all Rules and nothing persists. Demo (flag OFF): straight to the
    // profession step, exactly as before.
    if (useFirebaseBackend) {
      unawaited(_enterViaAuth());
      return;
    }
    _advance();
  }

  void _demo() {
    final role = widget.boardRole;
    if (role != null) {
      // Role-gate mode: the demo affordance enters a demo board session —
      // the contractor profile / startup flow is never touched.
      ref.read(boardAuthProvider.notifier).enterDemo(role);
      return;
    }
    ref.read(userProfileProvider.notifier).continueAsDemo();
    _advance();
  }

  void _existingLogin() {
    // Board role-gate mode FIRST: "כניסה ללקוח קיים" IS the login attempt —
    // the seeded username+code check (#65), independent of the Firebase flag.
    final role = widget.boardRole;
    if (role != null) {
      _boardLogin(role);
      return;
    }
    // Contractor flow — live backend (flag ON): route to the Firebase
    // phone-OTP login sheet; on success we enter the app. Demo (flag OFF):
    // existing customer skips the trade step and enters straight in.
    if (useFirebaseBackend) {
      unawaited(_enterViaAuth());
      return;
    }
    ref.read(userProfileProvider.notifier).continueAsDemo();
    ref.read(welcomeSeenProvider.notifier).state = true;
    unawaited(persistWelcomeSeen());
  }

  /// Live-backend entry: open the Firebase login sheet (phone-OTP / email), and
  /// once [authStateProvider] reports a signed-in user, mirror the identity
  /// fields to `users/{uid}` (rules-safe merge) and enter the app. A cancelled
  /// sheet (still signed-out) leaves the user on the welcome screen to retry.
  Future<void> _enterViaAuth() async {
    await showLoginSheet(context);
    if (!mounted) return;
    final auth = ref.read(authStateProvider);
    if (!auth.signedIn) return; // cancelled — stay on welcome
    final uid = auth.user?.uid;
    final writer = ref.read(usersProfileWriterProvider);
    if (uid != null && writer != null) {
      final p = ref.read(userProfileProvider);
      // Best-effort identity mirror (merge); never blocks entry.
      unawaited(
        writer.set(uid, {
          if (p.name.isNotEmpty) 'displayName': p.name,
          if (p.contact.isNotEmpty) 'phone': p.contact,
        }).catchError((Object _) {}),
      );
    }
    ref.read(welcomeSeenProvider.notifier).state = true;
    unawaited(persistWelcomeSeen());
  }

  @override
  Widget build(BuildContext context) {
    // task #64: format gate — the contact must look like an Israeli mobile
    // (05XXXXXXXX) or an email before the CTA unlocks. Format only;
    // uniqueness checks are deferred to the Firebase backend.
    // task #65 · role-gate mode: the SAME field carries the 4-digit board
    // code instead, and a code login() rejected stays invalid until edited —
    // same widgets, same labels, same error UI (zero visual/text change).
    final contactOk = widget.boardRole == null
        ? validIsraeliMobile(_contact.text) || validEmail(_contact.text)
        : _validBoardCode(_contact.text) && !_codeRejected;
    final valid = registrationValid(_name.text, _contact.text) && contactOk;
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
                    const Text(
                      'BuildSmart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space2),
                    const Text(
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
                      HelpTarget(
                        title: 'כניסה ללקוח קיים',
                        body: 'מיועד למי שכבר נרשם — כניסה ישירה פנימה. כרגע '
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
                          onPressed: _existingLogin,
                          child: const Text(
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
                            child: Text(
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
                      const Text(
                        'רישום ראשוני',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          color: BsTokens.inkLight,
                        ),
                      ),
                      const SizedBox(height: BsTokens.space1),
                      const Text(
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
                            _field(_name, 'שם מלא', Icons.person_outline),
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
                          errorText: _contact.text.trim().isEmpty || contactOk
                              ? null
                              : 'מספר נייד או אימייל לא תקינים',
                        ),
                      ),
                      const SizedBox(height: BsTokens.space5),
                      HelpTarget(
                        title: 'אישור והמשך',
                        body: 'מסיים את ההרשמה, שומר את הפרטים, וממשיך לבחירת '
                            'המקצוע. נפעל רק כשהשדות תקינים.',
                        child: _primaryButton(
                          onPressed: valid ? _register : null,
                        ),
                      ),
                      const SizedBox(height: BsTokens.space2),
                      HelpTarget(
                        title: 'המשך ללא רישום (דוגמה)',
                        body: 'נכנסים כאורח-דמו בלי לשמור פרטים — לסיור מהיר '
                            'באפליקציה. אפשר להירשם מאוחר יותר מההגדרות.',
                        child: TextButton(
                          onPressed: _demo,
                          child: const Text(
                            'המשך ללא רישום (דוגמה)',
                            style: TextStyle(
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
                          const Text(
                            'בהרשמה אתה מאשר את ',
                            style: TextStyle(
                              color: Color(0xFFB3B3B3),
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              LegalScreen.route(initialTab: LegalTab.terms),
                            ),
                            child: const Text(
                              'תנאי השימוש',
                              style: TextStyle(
                                color: BsTokens.brandDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(
                            ' ואת ',
                            style: TextStyle(
                              color: Color(0xFFB3B3B3),
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              LegalScreen.route(initialTab: LegalTab.privacy),
                            ),
                            child: const Text(
                              'מדיניות הפרטיות',
                              style: TextStyle(
                                color: BsTokens.brandDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(
                            ' של BuildSmart',
                            style: TextStyle(
                              color: Color(0xFFB3B3B3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
  Widget _primaryButton({required VoidCallback? onPressed}) {
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
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: BsTokens.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 20, color: Colors.white),
                SizedBox(width: BsTokens.space2),
                Text(
                  'אישור והמשך',
                  style: TextStyle(
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
  }) {
    final ok = c.text.trim().isNotEmpty && errorText == null;
    return TextField(
      controller: c,
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
