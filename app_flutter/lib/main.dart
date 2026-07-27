import 'dart:async';

import 'package:buildsmart/config/app_brand.dart' show AppBrand;
import 'package:buildsmart/config/org_config.dart' show kOrgCompanyJson;
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/catalog_paged.dart'
    show useServerCatalog;
import 'package:buildsmart/firebase_options.dart';
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/screens/onboarding_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/company_catalog_store.dart'
    show hydrateCompanyCatalog;
import 'package:buildsmart/state/feature_flags.dart' show kAppKbOnly;
import 'package:buildsmart/state/intel/intel_bus.dart' show intelBusProvider;
import 'package:buildsmart/state/intel/screen_view.dart' show IntelRouteObserver;
import 'package:buildsmart/state/intel/session_tracker.dart'
    show sessionTrackerProvider;
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart'
    show keyboardScreenToolsProvider;
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/org_config_store.dart'
    show hydrateOrgConfig, orgConfigProvider;
import 'package:buildsmart/state/org_gates.dart' show orgTerm;
import 'package:buildsmart/state/push_routing.dart'
    show afterThisFrame, pendingPushThreadProvider, threadIdFromLaunchUrl;
import 'package:buildsmart/state/push_state.dart';
import 'package:buildsmart/state/server_catalog_auth.dart';
import 'package:buildsmart/state/studio/config_store.dart'
    show configThemeProvider;
import 'package:buildsmart/state/studio/studio_flags.dart' show kStudioFlag;
import 'package:buildsmart/state/user_profile.dart' show userProfileProvider;
import 'package:buildsmart/state/user_system_sync.dart'
    show userSystemSyncProvider;
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show combinedTextScale;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/backend_debug_badge.dart';
import 'package:buildsmart/widgets/connection_indicator.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/app_keyboard_only.dart'
    show AppKeyboardInsets, AppKeyboardOnlyLayer;
import 'package:buildsmart/widgets/studio/studio_overlay.dart';
import 'package:buildsmart/widgets/toast.dart'
    show bsMessengerKey, bsNavigatorKey, showToast;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging, RemoteMessage;
import 'package:flutter/foundation.dart'
    show
        FlutterError,
        FlutterErrorDetails,
        PlatformDispatcher,
        debugPrint,
        kDebugMode,
        kIsWeb,
        visibleForTesting;
import 'package:flutter/material.dart';
// HardwareKeyboard — so typing counts as activity for the idle auto-logout.
import 'package:flutter/services.dart' show HardwareKeyboard, KeyEvent;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S6.2 — the FCM BACKGROUND/terminated handler. MUST be top-level (the
/// Android background isolate calls it outside the widget tree — it cannot
/// live behind the PushGateway seam) and MUST carry `vm:entry-point` so AOT
/// tree-shaking keeps it. S6.3 pushes are notification-payload messages the OS
/// tray renders by itself, so there is no app work to do here yet (data-only
/// background work is a documented follow-up) — the guarded body only logs.
/// A throw here would crash the background isolate, hence the catch-all.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    debugPrint('FCM background message: ${message.messageId}');
  } on Object catch (e) {
    debugPrint('firebaseMessagingBackgroundHandler: ignored failure: $e');
  }
}

/// G4 — install the global Flutter + platform error handlers, routing each to
/// the supplied Crashlytics callbacks. Pure + `@visibleForTesting` so the wiring
/// LOGIC is asserted with plain recording closures (no real Firebase): a thrown
/// Flutter framework error and a raised platform-async error are each routed to
/// the right sink, the present-then-record order is kept, and the debug gate is
/// honored. The real call-site ([main]) passes the live `FirebaseCrashlytics`
/// methods verbatim.
///
/// CONTRACT (mirroring the FlutterFire docs):
///   • `FlutterError.onError` (framework errors) → `presentError` (keeps the
///     red error box / console dump in debug) THEN [recordFlutterError]
///     (`recordFlutterFatalError`);
///   • `PlatformDispatcher.instance.onError` (uncaught async errors) →
///     [recordError] (`recordError(..., fatal: true)`) and returns `true`.
///
/// Collection is enabled in NON-debug builds only ([isDebug] defaults to
/// `kDebugMode`), so a debug run keeps the on-device error overlay and does not
/// ship dev noise to the dashboard. This is ONLY ever called when Firebase is
/// initialised — the demo path never reaches it (see [main]'s
/// `Firebase.apps.isNotEmpty` gate).
@visibleForTesting
void installCrashlyticsHandlers({
  required void Function(bool enabled) setCollectionEnabled,
  required void Function(FlutterErrorDetails details) recordFlutterError,
  required void Function(Object error, StackTrace stack) recordError,
  bool isDebug = kDebugMode,
}) {
  // Off in debug (keep the overlay + avoid dev noise); on in release/profile.
  setCollectionEnabled(!isDebug);
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    recordError(error, stack);
    return true;
  };
}

/// F2 — the App Check native attestation providers, chosen purely from the
/// compile-time [kAppCheckProd] flag. Pure + `@visibleForTesting` so the
/// SELECTION is asserted for BOTH flag values WITHOUT calling
/// `FirebaseAppCheck.instance.activate` (tests never initialise Firebase).
///
/// CONTRACT (the F2 zero-regression invariant):
///   • `prod == false` (default) → `AndroidProvider.debug` /
///     `AppleProvider.debug` — BYTE-IDENTICAL to the dev/demo attestation the
///     app shipped with;
///   • `prod == true` → `AndroidProvider.playIntegrity` /
///     `AppleProvider.appAttestWithDeviceCheckFallback` (App Attest on
///     iOS 14+/macOS 14+, DeviceCheck fallback otherwise).
///
/// READY but inert until the owner does F1 (real mobile `firebase_options`) +
/// registers the attestation keys in the Firebase console — see [kAppCheckProd].
/// The [main] call-site passes the live flag verbatim.
@visibleForTesting
({AndroidProvider android, AppleProvider apple}) appCheckProvidersFor({
  required bool prod,
}) =>
    prod
        ? (
            android: AndroidProvider.playIntegrity,
            apple: AppleProvider.appAttestWithDeviceCheckFallback,
          )
        : (android: AndroidProvider.debug, apple: AppleProvider.debug);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // S0.4 — wire Firebase (web). initializeApp must precede any Firestore/Auth
  // use; Firestore offline-persistence keeps the S2 sync cache-pattern fast.
  // This runs only in the real entrypoint (main), never in tests, so the
  // existing suite stays Firebase-free and green.
  // S0 invariant: a Firebase failure must NEVER block app start — with no
  // initialized app `Firebase.apps` stays empty, so every S2/S3 repository
  // swap (`Firebase.apps.isNotEmpty`) keeps the local seed path and the UI
  // boots normally (observed: unguarded init hung ~60s then threw on web,
  // leaving a permanent white screen).
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 8));
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
  } catch (_) {
    // non-fatal: app runs on the local repositories until Firebase is back
  }
  // S0.5 / F2 — App Check attestation. The providers are chosen purely from the
  // [kAppCheckProd] flag (see [appCheckProvidersFor]): OFF (default) keeps the
  // dev `AndroidProvider.debug` / `AppleProvider.debug` BYTE-IDENTICAL to today;
  // ON selects the production native providers (Play Integrity / App Attest +
  // DeviceCheck fallback). The ON path is READY but only takes effect once the
  // owner does F1 (real mobile firebase_options) + registers the attestation
  // keys in the Firebase console. App Check does NOT enforce client-side — this
  // `activate` only makes the SDKs ATTACH the token (G3); rejecting un-tokened
  // requests is a Firebase console toggle (owner's). So a failure here must
  // never block app start. Gated by `Firebase.apps.isNotEmpty` so the demo /
  // local-repo path skips it entirely (and the existing suite stays
  // Firebase-free); web stays SKIPPED unless a reCAPTCHA site key is supplied.
  if (Firebase.apps.isNotEmpty) {
    try {
      if (kIsWeb) {
        // Web attestation only activates when a reCAPTCHA v3 site key is
        // supplied at build time; with the default empty key the web App Check
        // path stays SKIPPED exactly as today (no behaviour change on web).
        if (kAppCheckRecaptchaSiteKey.isNotEmpty) {
          await FirebaseAppCheck.instance.activate(
            providerWeb: ReCaptchaV3Provider(kAppCheckRecaptchaSiteKey),
          );
          await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
        }
      } else {
        final providers = appCheckProvidersFor(prod: kAppCheckProd);
        await FirebaseAppCheck.instance.activate(
          androidProvider: providers.android,
          appleProvider: providers.apple,
        );
        // G3 — keep the attached App Check token fresh while the app runs (the
        // SDKs already auto-attach it to every Firestore/Functions/Storage
        // call; no per-call work). No-op-safe; only reached under live
        // Firebase + the prod providers.
        if (kAppCheckProd) {
          await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
        }
      }
    } catch (_) {
      // non-fatal: App Check enforcement is a Firebase console toggle (owner's)
    }
  }
  // GO-LIVE (server catalog) — guest anonymous auth. The seeded catalog/inventory
  // reads need a signed-in user (firestore.rules); the app browses as a GUEST, so
  // when useServerCatalog is on, sign a guest in anonymously. Gated on
  // useServerCatalog (a const-folding getter, false in the demo build) ⇒ dead code /
  // dormant today; only activates once USE_FIREBASE_BACKEND + CATALOG_BASE_URL ship.
  // A failure is non-fatal (browsing continues on the bundled catalog).
  if (useServerCatalog && Firebase.apps.isNotEmpty) {
    try {
      final auth = fb.FirebaseAuth.instance;
      await ensureAnonAuthForServerCatalog(
        hasUser: auth.currentUser != null,
        signInAnon: auth.signInAnonymously,
      );
    } on Object catch (_) {
      // non-fatal: browsing continues on the bundled catalog / local path
    }
  }
  // G4 — Crashlytics global error capture, ACTIVE ONLY when Firebase actually
  // initialised. With Firebase ABSENT (the demo / local-repo path) this whole
  // block is skipped, so `FlutterError.onError` / `PlatformDispatcher.onError`
  // stay the framework defaults and `main()` behaves byte-for-byte as before
  // (the zero-regression invariant). Collection itself is debug-gated inside
  // the helper (keep the debug error overlay; ship only release/profile).
  if (Firebase.apps.isNotEmpty) {
    final crashlytics = FirebaseCrashlytics.instance;
    installCrashlyticsHandlers(
      setCollectionEnabled: (enabled) =>
          unawaited(crashlytics.setCrashlyticsCollectionEnabled(enabled)),
      recordFlutterError: crashlytics.recordFlutterFatalError,
      recordError: (error, stack) =>
          unawaited(crashlytics.recordError(error, stack, fatal: true)),
    );
  }
  // S6.2 — register the background push handler, only when Firebase actually
  // initialised, and never on web (web background pushes belong to the hosting
  // service worker, not a Dart isolate).
  if (!kIsWeb && useFirebaseBackend) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  // Bridge step — synthesise VerifiedSpec for every Polyroll PPR product so
  // the card's compat / pair-warning / install-engine helpers cover the
  // 757-strong PPR catalog the same way they cover Lipskey.
  registerPolyrollSpecs();
  // First-run gate: seed the welcome flag from prefs before the first frame.
  final welcomeSeen = await loadWelcomeSeen();
  // …and the guest-browsing CHOICE, or a visitor who already picked "browse
  // without an account" would be asked again on every reload.
  final guestBrowsing = await loadGuestBrowsing();
  // Benzi #4: seed the one-time ship-to-prompt flag (absent → false → prompt).
  final shipToPrompted = await loadShipToPrompted();
  // Runtime-config layer hydrates FIRST (a future module gate over the catalog
  // overlay must see it; flag OFF ⇒ returns the default with zero I/O).
  final orgCfg = await hydrateOrgConfig(
    companyJson: kOrgCompanyJson.isEmpty ? null : kOrgCompanyJson,
  );
  // Import feature: the company-catalog overlay must hydrate BEFORE the first
  // resolvedCatalogProducts read — every lazy snapshot (_skuIndex ·
  // _catalogByName · _kCatalogProductCats) then sees the imported list.
  await hydrateCompanyCatalog();
  runApp(
    ProviderScope(
      overrides: [
        welcomeSeenProvider.overrideWith((ref) => welcomeSeen),
        guestBrowsingProvider.overrideWith((ref) => guestBrowsing),
        shipToPromptedProvider.overrideWith((ref) => shipToPrompted),
        orgConfigProvider.overrideWith((ref) => orgCfg),
      ],
      child: const BuildSmartApp(),
    ),
  );
}

/// OWNER POLICY: developer/diagnostic-only overlays mounted on top of the app
/// shell. The launch-diagnostic [BackendDebugBadge] is a NON-FUNCTIONAL UI in a
/// shipped build (the App Store rejects visible debug UI), so it is gated to
/// debug builds only. In release/profile (and `flutter build web --release`)
/// [isDebug] is `kDebugMode == false`, so this returns an empty list and the
/// shipped build shows NOTHING. The widget itself is kept for dev use.
///
/// TEMPORARY [fsDiag] override (cross-device-sync investigation): when the
/// `FS_DIAG` build flag is set, the badge is ALSO mounted in a release/profile
/// build, so a tester on the real signed APK can run the Firestore self-test and
/// see the exact denial that a guarded background write swallows. Default OFF →
/// the shipped build is BYTE-IDENTICAL (debug-only). Remove with the badge.
///
/// Pure + `@visibleForTesting` so the gate is asserted directly for all flag
/// combinations without flipping the `kDebugMode` const at runtime.
@visibleForTesting
List<Widget> debugOverlayChildren({
  required bool isDebug,
  bool fsDiag = kFsDiag,
}) =>
    (isDebug || fsDiag) ? const [BackendDebugBadge()] : const [];

/// P3 — auto-logout after pointer inactivity (`sessionTimeout`). GATED to the
/// real backend: when [useFirebaseBackend] is OFF (the demo build AND the whole
/// Firebase-free test suite) this is a PURE pass-through — no [Listener], no
/// [Timer] — so behavior is byte-identical and every widget test is unaffected.
/// On the backend it signs the user out after [timeout] of inactivity so an
/// unattended session on a shared device falls back to the login gate. The timer
/// is cancelled on dispose and re-armed on every interaction.
/// Makes `users/{uid}` exist for EVERY real sign-in — the door the approval gate
/// was leaking through.
///
/// Registration is all-by-approval, and that is enforced by
/// `permitAction`, which blocks a user whose status is `pending`. But it blocks
/// on the STATUS, and a user with no `users/{uid}` document at all has no
/// status: the check falls straight through to the role's permissions, and
/// `bsRoleFrom` hands a signed-in user with no server role the default
/// contractor role. So "no document" did not mean "not approved yet" — it meant
/// APPROVED.
///
/// And the document was only ever created in one place: the welcome screen's
/// registration button (`_finishAfterAuth`). Anyone who signed in through the
/// login sheet instead — the "🔐 התחברות לחשבון" row in the profile — got a real
/// Firebase identity, no document, and therefore walked past the gate.
///
/// Listening here closes that by construction: every path that produces a real
/// user ends up in `authStateChanges`, so there is no door left to forget.
/// `ensureUser` is create-if-absent, so a returning user's server-assigned
/// status/role/store is never touched and calling this on every sign-in — next
/// to the registration call that already does it — is harmless.
///
/// Guests are skipped inside `onRegisteredLogin`: an anonymous catalog browser
/// is not a user record.
class _UserDocSync extends ConsumerWidget {
  const _UserDocSync({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthSnapshot>(authStateProvider, (prev, next) {
      final user = next.user;
      if (user == null || !user.isRealUser) return;
      if (prev?.user?.uid == user.uid && (prev?.user?.isRealUser ?? false)) {
        return; // same person as a moment ago — nothing new to ensure
      }
      unawaited(
        ref.read(userSystemSyncProvider).onRegisteredLogin(
              uid: user.uid,
              profile: ref.read(userProfileProvider),
              isAnonymous: user.isAnonymous,
              now: DateTime.now(),
            ),
      );
    });
    return child;
  }
}

class _AutoLogout extends ConsumerStatefulWidget {
  const _AutoLogout({required this.timeout, required this.child});

  final BsSessionTimeout timeout;
  final Widget child;

  @override
  ConsumerState<_AutoLogout> createState() => _AutoLogoutState();
}

class _AutoLogoutState extends ConsumerState<_AutoLogout> {
  Timer? _timer;

  Duration get _idleLimit => switch (widget.timeout) {
        BsSessionTimeout.m5 => const Duration(minutes: 5),
        BsSessionTimeout.m15 => const Duration(minutes: 15),
        BsSessionTimeout.m30 => const Duration(minutes: 30),
        BsSessionTimeout.m60 => const Duration(minutes: 60),
      };

  @override
  void initState() {
    super.initState();
    _arm();
    // Typing is activity. Without this a user writing a long note or chat
    // message for the whole idle window was signed out MID-SENTENCE and lost
    // everything still held in the TextEditingControllers — the pointer
    // listener below never sees a keystroke. Global (not a Focus subtree) so it
    // counts wherever the caret is; returns false so the event still reaches
    // whatever was going to handle it.
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  bool _onKey(KeyEvent _) {
    _arm();
    return false; // never consume — this only observes
  }

  @override
  void didUpdateWidget(_AutoLogout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeout != widget.timeout) _arm();
  }

  /// (Re)start the idle countdown. Inert off the backend (demo/tests).
  void _arm() {
    _timer?.cancel();
    if (!useFirebaseBackend) return;
    _timer = Timer(_idleLimit, _expire);
  }

  void _bump(PointerEvent _) => _arm();

  /// Idle limit reached — end the session and make it STICK.
  ///
  /// `signOut()` alone was not enough: the server-catalog bootstrap signs every
  /// visitor back in anonymously before the first frame, and with `welcomeSeen`
  /// still persisted the gate routed that guest straight back to the home shell.
  /// The sign-out was therefore invisible the moment the page reloaded. Clearing
  /// the welcome flag re-arms [OnboardingGate], so the idle user lands on the
  /// welcome/login screen and has to sign in again — the owner's choice.
  ///
  /// GUESTS ARE NEVER EXPIRED: an anonymous visitor has no session to end, and
  /// expiring them would eject a harmless browser to a login screen for doing
  /// nothing wrong. `_expire` therefore no-ops unless a REAL user is signed in.
  Future<void> _expire() async {
    if (!mounted) return;
    final user = ref.read(authStateProvider).user;
    if (!(user?.isRealUser ?? false)) return; // guest / signed out — nothing to do
    await ref.read(authStateProvider.notifier).signOut();
    if (!mounted) return;
    ref.read(welcomeSeenProvider.notifier).state = false;
    unawaited(clearWelcomeSeen());
    // Also drop any guest choice — an expired session must land on the login
    // screen, not quietly continue as an anonymous browser.
    ref.read(guestBrowsingProvider.notifier).state = false;
    unawaited(clearGuestBrowsing());
    if (!mounted) return;
    // Say WHY the screen changed — otherwise the app silently teleports to the
    // welcome screen and reads as a crash.
    showToast(context, 'נותקת עקב חוסר פעילות — יש להתחבר מחדש');
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!useFirebaseBackend) return widget.child; // pure pass-through
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _bump,
      onPointerMove: _bump,
      onPointerSignal: _bump,
      // On web a moving mouse emits HOVER, not move — without this, a user
      // actively reading and moving the cursor counted as idle.
      onPointerHover: _bump,
      child: widget.child,
    );
  }
}

/// Step 92 — the ONE app-global navigator observer (the single addition to
/// `MaterialApp.navigatorObservers`, empty until now). A stable top-level
/// singleton so the Navigator's observer list never changes identity across
/// [BuildSmartApp] rebuilds. It turns every *named* route push/pop into a
/// `screen_view` centrally — no screen has to emit (~3 edits, not 270). Bound to
/// the bus once, read-only, in [BuildSmartApp.build]; every current app route is
/// unnamed so it is inert on the demo path (the tab listener carries the 4 tabs).
final intelRouteObserver = IntelRouteObserver();

class BuildSmartApp extends ConsumerWidget {
  const BuildSmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // S6 — wake the push controller (providers are lazy): token registration
    // follows auth (sign-in → users/{uid}.fcmToken · refresh → re-write ·
    // sign-out → clear) and foreground pushes toast. Inert without Firebase.
    ref.watch(pushControllerProvider);
    // The web arm of the same tap. When no tab is open the service worker
    // cannot postMessage into a page that does not exist, so it launches one
    // with `?thread=` in the url; this is where that is picked up. Read ONCE
    // from `Uri.base` — it is the launch url, not a stream — and parked in the
    // same place the mobile tap parks it, so `ChatsScreen` has a single thing to
    // consume regardless of which platform the notification came from.
    // Off web, `Uri.base` is a file uri with no query, so this is a no-op.
    final launchThread = threadIdFromLaunchUrl(Uri.base.toString());
    if (launchThread != null &&
        ref.read(pendingPushThreadProvider) != launchThread) {
      // Assign outside the build phase: writing to a provider during build is
      // the release-only crash pattern already fixed once in this codebase.
      afterThisFrame(
        () => ref.read(pendingPushThreadProvider.notifier).state = launchThread,
      );
    }
    // Step 92 — hand the app-global route observer its bus, ONCE (idempotent).
    // `ref.read` (never watch): a stable-singleton hand-off, so this creates NO
    // rebuild dependency and the tracking stays byte-neutral for the 4 tabs.
    intelRouteObserver.bind(ref.read(intelBusProvider));
    // Step 97 — construct the session tracker ONCE (read-only, like the bind
    // above): its ctor registers the app's ONE app-lifecycle observer + runs the
    // always-on LOCAL session (session_start/end → the bus). Off-backend /
    // non-customer the presence heartbeat inside it is inert (the double-gate) —
    // zero timer, zero Firestore on the demo/test path.
    ref.read(sessionTrackerProvider);
    final settings = ref.watch(appSettingsProvider);
    final catalogSettings = ref.watch(catalogSettingsProvider);
    final textScale = switch (catalogSettings.textSize) {
      CatalogTextSize.small => 0.9,
      CatalogTextSize.medium => 1.0,
      CatalogTextSize.large => 1.15,
    };
    final highContrast = catalogSettings.highContrast;
    // No-Code Studio app theme — inert (CfgTheme.fallback = BsTokens) until the
    // owner publishes a theme override; then the whole app reflects it live.
    final cfgTheme = ref.watch(configThemeProvider);
    final locale = switch (settings.lang) {
      BsLang.he => const Locale('he', 'IL'),
      BsLang.ar => const Locale('ar'),
      BsLang.en => const Locale('en', 'US'),
    };
    return MaterialApp(
      title: orgTerm(ref, 'brand.name', AppBrand.name),
      // S6.2 — the context-free toast surface (foreground push → showGlobalToast).
      scaffoldMessengerKey: bsMessengerKey,
      // Root navigator key — lets the app-global floating keyboard (kKbGlobal)
      // AND the Studio chrome (kStudioFlag — the STUDIO/preview build's board
      // selector in [StudioOverlay]) push routes / open sheets from above the
      // Navigator. GATED on the two compile consts so it tree-shakes when both are
      // off, exactly like every other kKbGlobal touchpoint: with [kKbGlobal] AND
      // [kStudioFlag] const-false dart2js folds this ternary to `null` (= the
      // default keyless root Navigator, the pre-monster behaviour), restoring
      // provable byte-identity on the LIVE app. Only the ASSIGNMENT is gated;
      // `bsNavigatorKey`'s top-level declaration in toast.dart stays unconditional
      // (an inert `final` global until something reads it).
      navigatorKey: (kKbGlobal || kStudioFlag) ? bsNavigatorKey : null,
      // Step 92 — the ONE navigator observer (empty list until now): emits
      // `screen_view` automatically on every named route push/pop, read-only.
      navigatorObservers: [intelRouteObserver],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: highContrast, cfg: cfgTheme),
      darkTheme: AppTheme.dark(highContrast: highContrast, cfg: cfgTheme),
      themeMode:
          settings.theme == BsTheme.dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('ar'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // Respect the OS Dynamic-Type setting (previously discarded) folded with
        // the in-app size preference, clamped so RTL layouts stay intact.
        final osScale = mq.textScaler.scale(100) / 100;
        // Fold in the owner's CfgTheme font-scale (#studio) — 1.0 by default ⇒ no
        // change until the owner moves the theme-editor slider (round-2 fix).
        final combined = combinedTextScale(textScale, osScale, cfgTheme.fontScale);
        // App-content stack, built once so it can be conditionally wrapped for
        // focus traversal below. Carries BOTH the No-Code Studio overlay (live)
        // and the global keyboard overlay (kKbGlobal).
        Widget appContent = Stack(
          children: [
            // ⌨️ APP-KEYBOARD-ONLY: the app's screens inset for OUR keyboard the
            // same way they already inset for the device one, so a docked
            // keyboard never covers the field being typed into. Wraps the
            // Navigator ONLY — the keyboard layer below stays pinned to the real
            // bottom, so it can never inset itself. Flag-gated → OFF identical.
            if (kAppKbOnly)
              AppKeyboardInsets(child: child ?? const SizedBox())
            else
              child ?? const SizedBox(),
            // OWNER POLICY: the launch-diagnostic badge is dev-only — gated by
            // kDebugMode so a release/web build shows NOTHING (see
            // debugOverlayChildren), UNLESS the temporary FS_DIAG flag is set
            // (release self-test for the cross-device-sync investigation).
            ...debugOverlayChildren(isDebug: kDebugMode),
            // ALWAYS-ON live connection pill (🟢 מחובר / 🔴 מנותק · מצב דמו) —
            // overlays every screen. Inert on the demo/test path.
            const ConnectionIndicator(),
            // No-Code Studio edit-mode overlay — inert (SizedBox.shrink) unless
            // the owner has the Studio ACTIVE and is in edit-mode; same
            // always-mounted-inert pattern as ConnectionIndicator.
            const StudioOverlay(),
            // 🃏 "keyboard on every screen" (kKbGlobal): the floating keyboard
            // mounted ABOVE the Navigator so it floats over pushed routes too.
            // Omitted when the flag is off → HomeShell mounts it as today
            // (byte-identical).
            //
            // Hosted in its OWN Overlay: this subtree is a Stack SIBLING of the
            // app's Navigator, so on its own it has NO Overlay ancestor. Its
            // interactive widgets — the FAB's Tooltip (shown on web mouse-hover),
            // the keyboard's text-selection handles/magnifier, any dropdown —
            // call Overlay.of() and would otherwise throw "No Overlay widget
            // found" and freeze the screen (the crash the flag-ON cut-over hit).
            // Positioned.fill + a single non-opaque initial entry: pointer events
            // fall through the transparent regions to the app below (the screen
            // stays independent & interactive — keyboard-is-navigation-OS), while
            // route pushes keep going through the root bsNavigatorKey.
            if (kKbGlobal)
              Positioned.fill(
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) => const _GlobalKeyboardOverlay(),
                    ),
                  ],
                ),
              ),
            // ⌨️ APP-KEYBOARD-ONLY (kAppKbOnly): the keyboard that answers for
            // EVERY field, mounted here — above the Navigator — so it also
            // covers fields inside pushed routes, dialogs and bottom sheets,
            // which is where most of the app's forms actually live.
            //
            // Hosted in its OWN Overlay for the same reason the floating
            // keyboard above is: this subtree is a Stack SIBLING of the app's
            // Navigator and so has no Overlay ancestor of its own, and anything
            // inside that calls Overlay.of() would throw and freeze the screen.
            // Omitted entirely when the flag is off → byte-identical.
            if (kAppKbOnly)
              Positioned.fill(
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) => const AppKeyboardOnlyLayer(),
                    ),
                  ],
                ),
              ),
          ],
        );
        // KB_GLOBAL focus-traversal robustness (flag-gated → flag-OFF
        // byte-identical): WidgetOrderTraversalPolicy sorts by widget-tree order
        // (no geometry) and sidesteps a caught "RenderBox was not laid out" that
        // the default ReadingOrderTraversalPolicy throws for the overlay + the
        // app's many autofocus fields. Only under the flag, so flag-OFF identical.
        if (kKbGlobal) {
          appContent = FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: appContent,
          );
        }
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(combined),
            // P3 — reduce-motion, app-wide: when on, Flutter shortens/removes
            // implicit animations everywhere (page transitions, switches,
            // AnimatedFoo) — the standard a11y signal. (The catalog flip already
            // honors reducedMotion separately; this generalises it.)
            disableAnimations: catalogSettings.reducedMotion,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            // P3 — auto-logout after inactivity (sessionTimeout). Inert off the
            // backend (demo + tests) — see _AutoLogout — so this is byte-identical
            // there; on the real backend it returns an idle session to the login
            // gate.
            child: _AutoLogout(
              timeout: settings.sessionTimeout,
              // Compile-gated like every other user-system touchpoint: with
              // kUserSystem const-false the wrapper and its provider tree-shake
              // away and the tree is byte-identical.
              child: kUserSystem
                  ? _UserDocSync(child: appContent)
                  : appContent,
            ),
          ),
        );
      },
      home: const OnboardingGate(),
    );
  }
}

/// App-global mount for the floating keyboard ("keyboard on every screen",
/// [kKbGlobal]). Lives in [BuildSmartApp]'s builder Stack — ABOVE the Navigator —
/// so the keyboard floats over pushed full-screen routes too, not only the
/// HomeShell tabs. Watches [keyboardOverlayOpenProvider] itself (only THIS
/// rebuilds on open/close, not the whole MaterialApp); renders nothing when
/// closed. Uses a bottom [Align] (not [Positioned]) so it is a valid
/// non-positioned Stack child. Added to the tree only when [kKbGlobal] is on (the
/// collection-if in the builder tree-shakes it away otherwise → flag-OFF identity).
/// The HomeShell bottom-nav bar height (home_shell.dart `_BottomNav` SizedBox).
/// OWNER FIX: the global keyboard overlay lives ABOVE the Navigator, so its
/// SafeArea clears the OS inset but NOT the HomeShell nav tabs — the FAB sat too
/// low and the open keyboard covered the בית/מחלקות/עדכונים/חנות tabs. Lifting the
/// FAB + keyboard by this much clears the nav so it stays visible + tappable.
const double _kHomeNavHeight = 58;

class _GlobalKeyboardOverlay extends ConsumerWidget {
  const _GlobalKeyboardOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OWNER FIX (nav-clearance, REACTIVE): lift by the HomeShell nav height ONLY
    // when NO route is pushed above HomeShell — a pushed full-screen route (e.g.
    // משימות) has no bottom nav, so lifting there would leave a gap that shows the
    // screen content BELOW the keyboard. Watch the screen-tools stack so this
    // rebuilds on route push/pop; read canPop() fresh for the current depth.
    ref.watch(keyboardScreenToolsProvider);
    final routePushed = bsNavigatorKey.currentState?.canPop() ?? false;
    final navOffset = routePushed ? 0.0 : _kHomeNavHeight;

    // Closed -> a global open-FAB (mirrors the home FAB but above the Navigator,
    // so it is reachable on EVERY route). Open -> the floating keyboard itself.
    if (!ref.watch(keyboardOverlayOpenProvider)) {
      return Align(
        alignment: AlignmentDirectional.bottomStart,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, navOffset + 16),
            child: FloatingActionButton(
              heroTag: 'keyboard-fab-global',
              onPressed: () =>
                  ref.read(keyboardOverlayOpenProvider.notifier).state = true,
              backgroundColor: BsTokens.brand,
              foregroundColor: Colors.white,
              tooltip: 'מקלדת חכמה',
              child: const Icon(Icons.keyboard),
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: navOffset),
          child: const FloatingCardKeyboard(),
        ),
      ),
    );
  }
}
