import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/firebase_options.dart';
import 'package:buildsmart/screens/onboarding_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/push_state.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/widgets/toast.dart' show bsMessengerKey;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging, RemoteMessage;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // S0.4 — wire Firebase (web). initializeApp must precede any Firestore/Auth
  // use; Firestore offline-persistence keeps the S2 sync cache-pattern fast.
  // This runs only in the real entrypoint (main), never in tests, so the
  // existing suite stays Firebase-free and green.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  // S0.5 — App Check (debug attestation for dev). Web reCAPTCHA + prod
  // attestation (Play Integrity / DeviceCheck) are wired once the keys are
  // registered in the console; App Check does not enforce until S5.7, so a
  // failure here must never block app start.
  if (!kIsWeb) {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } catch (_) {
      // non-fatal until S5 enforcement
    }
  }
  // S6.2 — register the background push handler, only when Firebase actually
  // initialised, and never on web (web background pushes belong to the hosting
  // service worker, not a Dart isolate).
  if (!kIsWeb && Firebase.apps.isNotEmpty) {
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
          data: mq.copyWith(textScaler: TextScaler.linear(combined)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox(),
          ),
        );
      },
      home: const OnboardingGate(),
    );
  }
}
