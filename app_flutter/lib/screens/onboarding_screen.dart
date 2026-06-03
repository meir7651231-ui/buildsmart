import 'dart:async';

import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/profession_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/theme/tokens.dart';
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
    switch (ref.watch(startupStepProvider)) {
      case 0:
        return const WelcomeScreen();
      case 1:
        return const ProfessionScreen();
      default:
        return const OnboardingScreen();
    }
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
    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.all(BsTokens.space3),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'דלג',
                    style: TextStyle(color: BsTokens.mutedLight),
                  ),
                ),
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
                    duration: const Duration(milliseconds: 220),
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
          ],
        ),
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
