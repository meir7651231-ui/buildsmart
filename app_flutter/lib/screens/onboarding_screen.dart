import 'dart:async';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/profession_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/help_mode.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One first-run welcome slide (pure data → unit-testable).
class OnboardingSlide {
  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  /// Material icon for the slide (NOT an emoji — canvaskit can't render emoji).
  final IconData icon;
  final String title;
  final String body;
}

/// First-run welcome content. Top-level so a test can assert it stays
/// non-empty and well-formed.
const List<OnboardingSlide> kOnboardingSlides = [
  OnboardingSlide(
    icon: Icons.waving_hand_outlined,
    title: 'ברוכים הבאים ל-BuildSmart',
    body: 'הקטלוג החכם לאינסטלציה ובנייה — אלפי מוצרים, מותגים '
        'וחיבורים, במקום אחד.',
  ),
  OnboardingSlide(
    icon: Icons.search,
    title: 'מצא כל מוצר בקלות',
    body: 'התחל מהמחלקות או חפש לפי שם, מק"ט או קטגוריה — וצמצם לפי '
        'גודל, זווית וצבע. הכל בעברית פשוטה.',
  ),
  OnboardingSlide(
    icon: Icons.checklist_rtl,
    title: 'תכנן, אסוף, והזמן',
    body: 'בנה רשימת-חומרים עם "תכנון חיבור", הוסף לסל בכמות הנכונה, '
        'ושלח הזמנה — בלי לפספס אביזר.',
  ),
];

/// Decides the app's first screen from [welcomeSeenProvider]: the welcome flow
/// on a genuine first run, otherwise the home shell. Synchronous (no splash).
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(welcomeSeenProvider);
    // #1 — auth gate: on the REAL backend a signed-OUT user is NOT let into the
    // app (their writes would be silently denied by the Security Rules — the
    // same class of gap as the orders/chat sync bugs). Once auth has LOADED, a
    // null user is routed to the welcome/login flow; on sign-in this rebuilds
    // straight to HomeShell, and logout re-gates for free (we watch
    // authStateProvider). The DEMO build (useFirebaseBackend OFF) is
    // byte-identical — guest/local access is the product there — as is the whole
    // Firebase-free test suite (the flag is a compile-time const, false in tests).
    if (useFirebaseBackend) {
      final auth = ref.watch(authStateProvider);
      // A REAL (non-anonymous) sign-in IS a completed entry — open the app.
      //
      // Without this, someone who signed in through the LOGIN sheet was bounced
      // straight back to the welcome screen: the gate's last line opens only on
      // `welcomeSeen`, and that flag is hand-flipped on the REGISTRATION path
      // (`welcome_screen._finishAfterAuth`) — the login path never set it. So a
      // fresh visitor (welcomeSeen absent ⇒ false) could verify an SMS code
      // successfully and still land back on "רישום ראשוני". Anyone already
      // authenticated has, by definition, finished the opening flow.
      if (auth.user?.isRealUser ?? false) return const HomeShell();
      // NOT a real person — an anonymous catalog guest, or nobody at all.
      //
      // The owner's rule: the front door asks who you are. A guest may browse
      // the catalog, but that has to be a CHOICE made on the welcome screen,
      // not something that happens silently. Before this, the anonymous
      // bootstrap + a persisted `welcomeSeen` dropped every returning visitor
      // straight into the app with no sign-in and no way to reach one — and
      // anything they created was bound to a throwaway anonymous uid that
      // vanishes when browser storage is cleared, so their orders would quietly
      // disappear.
      //
      // `seen` still decides what the opening flow SHOWS (a returning guest is
      // not walked through onboarding again), but it can no longer stand in for
      // being signed in.
      //
      // The one way in without an account is the EXPLICIT choice made on the
      // welcome screen. Without honouring it here the guest button would loop
      // straight back to this screen — the same lock-everyone-out failure the
      // anonymous bootstrap was added to fix, so it is load-bearing, not a
      // convenience.
      if (ref.watch(guestBrowsingProvider)) return const HomeShell();
      return const _OpeningFlow();
    }
    // Demo build (no backend): guest/local access IS the product — unchanged.
    return seen ? const HomeShell() : const _OpeningFlow();
  }
}

/// The first-run opening flow — walks welcome/register → profession →
/// onboarding slides (ported from the prototype's `showScreen` sequence),
/// driven by [startupStepProvider]. The last slide completes it (→ home).
class _OpeningFlow extends ConsumerWidget {
  const _OpeningFlow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(startupStepProvider);
    final child = switch (step) {
      0 => const WelcomeScreen(),
      1 => const ProfessionScreen(),
      _ => const OnboardingScreen(),
    };
    // The whole opening flow lives on ONE route (the steps are provider
    // state, not pushed routes), so an unguarded system/browser back would
    // pop the only route and throw the user out of the app mid-registration.
    // Intercept it: past the first step, back walks one step back
    // (slides → profession → welcome); only on the welcome step does back
    // actually leave. Side routes (ComingSoonScreen, the replayable tour)
    // are their own routes and pop normally, untouched by this guard.
    return PopScope<Object?>(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(startupStepProvider.notifier).state = step - 1;
      },
      child: child,
    );
  }
}

/// Opens the intro slides as a replayable tour — e.g. from the 💡 button in
/// the home app-bar. Unlike the first-run flow, finishing just closes the
/// route (it does NOT touch [welcomeSeenProvider]).
Future<void> showIntroTour(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const OnboardingScreen(isTour: true),
    ),
  );
}

/// First-run welcome flow: swipeable slides + skip / next / get-started.
/// In the first-run flow (`isTour: false`) completing/skipping flips
/// [welcomeSeenProvider] (→ home) and persists it. As a replayable tour
/// (`isTour: true`) it simply pops the route.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.isTour = false});

  /// Replayable tour (pop on finish) vs the first-run flow (flip the gate).
  final bool isTour;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    // As a replayable tour, finishing just closes the route.
    if (widget.isTour) {
      Navigator.of(context).pop();
      return;
    }
    // First-run flow: flip the gate synchronously (instant → home), persist in
    // the background.
    ref.read(welcomeSeenProvider.notifier).state = true;
    unawaited(persistWelcomeSeen());
    // Rewind the opening step so a later sign-out re-opens the flow at the
    // welcome/login screen (step 0), not the leftover slides (step 2) — which
    // would loop "בואו נתחיל". Harmless on a fresh first run (already 0).
    ref.read(startupStepProvider.notifier).state = 0;
  }

  void _next() {
    if (_page >= kOnboardingSlides.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == kOnboardingSlides.length - 1;
    final showHelp = !widget.isTour;
    final helpMode = showHelp && ref.watch(helpModeProvider);
    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      body: Column(
        children: [
          if (helpMode) const HelpModeBanner(),
          Expanded(
            child: SafeArea(
              child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(BsTokens.space3),
              child: Row(
                children: [
                  HelpTarget(
                    title: 'דלג',
                    body: 'מדלג על שקופיות ההיכרות ועובר ישר לאפליקציה.',
                    child: TextButton(
                      onPressed: _finish,
                      child: CfgText(
                        'onboarding_screen.skip',
                        'דלג',
                        style: TextStyle(color: BsTokens.mutedLight),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (showHelp) const HelpToggleButton(),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: kOnboardingSlides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) =>
                    _SlideView(slide: kOnboardingSlides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < kOnboardingSlides.length; i++)
                  AnimatedContainer(
                    duration: ref.read(catalogSettingsProvider).reducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? BsTokens.brand
                          : const Color(0xFFD6D6D6),
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(BsTokens.space5),
              child: SizedBox(
                width: double.infinity,
                child: HelpTarget(
                  title: 'הבא / בואו נתחיל',
                  body: 'עובר לשקופית הבאה; בשקופית האחרונה ("בואו נתחיל") '
                      'מסיים את ההיכרות ופותח את האפליקציה.',
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: BsTokens.brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: BsTokens.space4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusCard),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      isLast ? 'בואו נתחיל' : 'הבא',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }
}

/// A single centered slide: brand-tinted icon disc + title + body.
class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BsTokens.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: const BoxDecoration(
              color: Color(0x1AFF7A18), // brand @ ~10%
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 60, color: BsTokens.brand),
          ),
          const SizedBox(height: BsTokens.space6),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: BsTokens.inkLight,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: BsTokens.mutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
