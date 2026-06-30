import 'dart:async';

import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/firebase_options.dart';
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/screens/onboarding_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/push_state.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/widgets/backend_debug_badge.dart';
import 'package:buildsmart/widgets/connection_indicator.dart';
import 'package:buildsmart/widgets/toast.dart' show bsMessengerKey;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
  // Benzi #4: seed the one-time ship-to-prompt flag (absent → false → prompt).
  final shipToPrompted = await loadShipToPrompted();
  runApp(
    ProviderScope(
      overrides: [
        welcomeSeenProvider.overrideWith((ref) => welcomeSeen),
        shipToPromptedProvider.overrideWith((ref) => shipToPrompted),
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

  Future<void> _expire() async {
    if (!mounted) return;
    // signOut is optimistic and a harmless no-op when already signed out.
    await ref.read(authStateProvider.notifier).signOut();
  }

  @override
  void dispose() {
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
      child: widget.child,
    );
  }
}

class BuildSmartApp extends ConsumerWidget {
  const BuildSmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // S6 — wake the push controller (providers are lazy): token registration
    // follows auth (sign-in → users/{uid}.fcmToken · refresh → re-write ·
    // sign-out → clear) and foreground pushes toast. Inert without Firebase.
    ref.watch(pushControllerProvider);
    final settings = ref.watch(appSettingsProvider);
    final catalogSettings = ref.watch(catalogSettingsProvider);
    final textScale = switch (catalogSettings.textSize) {
      CatalogTextSize.small => 0.9,
      CatalogTextSize.medium => 1.0,
      CatalogTextSize.large => 1.15,
    };
    final highContrast = catalogSettings.highContrast;
    final locale = switch (settings.lang) {
      BsLang.he => const Locale('he', 'IL'),
      BsLang.ar => const Locale('ar'),
      BsLang.en => const Locale('en', 'US'),
    };
    return MaterialApp(
      title: 'BuildSmart',
      // S6.2 — the context-free toast surface (foreground push → showGlobalToast).
      scaffoldMessengerKey: bsMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: highContrast),
      darkTheme: AppTheme.dark(highContrast: highContrast),
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
        final combined = (textScale * osScale).clamp(0.85, 1.35).toDouble();
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
              child: Stack(
                children: [
                  child ?? const SizedBox(),
                  // OWNER POLICY: the launch-diagnostic badge is dev-only — gated
                  // by kDebugMode so a release/web build shows NOTHING (see
                  // debugOverlayChildren), UNLESS the temporary FS_DIAG flag is set
                  // (release self-test for the cross-device-sync investigation).
                  ...debugOverlayChildren(isDebug: kDebugMode),
                  // ALWAYS-ON live connection pill (🟢 מחובר / 🔴 מנותק · מצב
                  // דמו) — overlays every screen. Inert on the demo/test path
                  // (connectionStatusProvider is a constant `demo` there); on
                  // the live backend it recomputes from connectivity + auth +
                  // the diag/{uid} isFromCache probe. Positioned below the debug
                  // badge in debug; owns the top in release.
                  const ConnectionIndicator(),
                  // 🃏 "keyboard on every screen" (kKbGlobal): the floating
                  // keyboard mounted ABOVE the Navigator so it floats over pushed
                  // routes too. Omitted when the flag is off → HomeShell mounts it
                  // as today (byte-identical).
                  if (kKbGlobal) const _GlobalKeyboardOverlay(),
                ],
              ),
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
class _GlobalKeyboardOverlay extends ConsumerWidget {
  const _GlobalKeyboardOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(keyboardOverlayOpenProvider)) return const SizedBox.shrink();
    return const Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(top: false, child: FloatingCardKeyboard()),
    );
  }
}
