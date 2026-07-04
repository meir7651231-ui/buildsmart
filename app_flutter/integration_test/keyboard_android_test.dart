// Drives the REAL FloatingCardKeyboard through a full interactive journey on a
// GENUINE Android emulator (in CI — local emulation is blocked on the dev box by
// missing hardware virtualization). A GREEN run proves, on real Android, that the
// WHOLE keyboard works — not just that it paints:
//   (1) it RENDERS (the tools strip toggles),
//   (2) TYPING Hebrew letters builds the query and recomputes the live row,
//   (3) the home-tools layer shows the tools (מחלקות),
//   (4) tapping a tool NAVIGATES the screen underneath while the keyboard keeps
//       FLOATING (the owner's keep-floating model), and
//   (5) the ⚙ gear drills a BRANCH in place (children appear, no nav).
// Every step also captures an on-device screenshot (uploaded as a CI artifact) so
// the whole keyboard-on-Android is VISIBLE, step by step — not just asserted.
//
// Hermetic: the panel is self-contained (ProviderScope + mocked SharedPreferences
// + the bundled kDivePool catalogue), so the SAME behaviour proven deterministically
// in the VM test test/screens/floating_card_keyboard_test.dart runs on real hardware.
//
// IMPORTANT — the OPENING LAYER differs by screen size. In the 800x600 VM surface
// the keyboard opens on the LETTERS; on a real phone-sized emulator it opens on the
// HOME-TOOLS layer (מחלקות visible, letters hidden). So this test does NOT assume
// which layer is up: `_reveal` toggles the ▦ grid (which flips letters<->home-tools)
// up to twice until the target it needs is on screen. That keeps every step robust
// to the real device's opening state instead of hard-coding the VM's.
//
// One state per test (not one long walk): Android screenshots require a single
// convertFlutterSurfaceToImage() per test (it asserts on a second call and only
// reverts at tearDown), so each step is its own testWidgets that re-pumps the panel.
//
// Hardware BACK is deliberately NOT asserted here — it is verified deterministically
// in the VM test test/screens/android_back_test.dart (which drives the exact
// `popRoute` platform message the OS sends and asserts the keyboard closes). We do
// not re-assert it on-device because the SAME simulated `popRoute` that passes in the
// VM binding flakes under this one: IntegrationTestWidgetsFlutterBinding extends
// LiveTestWidgetsFlutterBinding (real wall-clock + real engine), while the VM uses
// AutomatedTestWidgetsFlutterBinding (deterministic FakeAsync). `didPopRoute` is
// async and only unmounts the keyboard on a follow-up frame after it flips
// keyboardOverlayOpenProvider; that settles deterministically under FakeAsync but
// races real-time frame scheduling under the live binding, so the assertion can catch
// the pre-close frame. It is a harness-timing artifact, NOT app behavior: in the real
// app BACK closes the keyboard (it lives in a sibling Overlay, never a pushed route,
// so on a home tab bsNavigatorKey.canPop()==false and didPopRoute falls through to
// _close()). The regular taps + text entry exercised HERE do not go through that async
// chain, so they are robust on-device. Run via `flutter drive` + test_driver/…dart.

import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Pumps the REAL FloatingCardKeyboard in the same hermetic RTL shell the VM test
  // uses: the panel is mounted only while keyboardOverlayOpenProvider is true (seeded
  // true), so a tool/close that flips it false actually removes the panel. Returns the
  // container for provider reads (e.g. the navigated tab).
  Future<ProviderContainer> pumpPanel(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [keyboardOverlayOpenProvider.overrideWith((_) => true)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final open = ref.watch(keyboardOverlayOpenProvider);
                  return Stack(
                    children: [
                      const Center(child: Text('screen-underneath')),
                      if (open)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: FloatingCardKeyboard(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  // The opening layer differs by screen size (letters in the VM, home-tools on a real
  // phone), and the ▦ grid toggle flips between letters and the home-tools layer. So to
  // reach [target] we tap the grid toggle up to [taps] times until it appears — 0 taps
  // if it is already up. Returns whether the target is on screen. `.first` targets the
  // strip toggle (the departments tile also draws a grid icon once the layer opens).
  Future<bool> reveal(WidgetTester tester, Finder target, {int taps = 2}) async {
    for (var i = 0; i <= taps; i++) {
      if (target.evaluate().isNotEmpty) return true;
      if (i < taps) {
        await tester.tap(find.byIcon(Icons.grid_view).first);
        await tester.pumpAndSettle();
      }
    }
    return target.evaluate().isNotEmpty;
  }

  // Best-effort on-device screenshot: convert the surface (Android-only; no-op
  // elsewhere), pump a frame, capture. Guarded — a headless swiftshader GPU can no-op
  // the conversion, and a missing shot must NEVER fail the assertion that precedes it.
  Future<void> shot(WidgetTester tester, String name) async {
    try {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    } on Object catch (_) {
      // Screenshot is best-effort; the preceding expect() is the proof.
    }
  }

  testWidgets('01 · the keyboard renders on real Android (strip toggles)',
      (tester) async {
    await pumpPanel(tester);

    // The keyboard-with-tools mounted (FloatingCardKeyboard forces it visible). The
    // strip toggles (▦ grid + ⚙ gear) are present on EVERY layer, so they are the
    // layer-independent proof the keyboard rendered + is interactive.
    expect(find.byType(BsKeyboard), findsOneWidget,
        reason: 'the KB_GLOBAL floating keyboard renders on the Android emulator');
    expect(find.byIcon(Icons.grid_view), findsWidgets,
        reason: 'the ▦ tool-grid toggle renders in the strip');
    expect(find.byIcon(Icons.settings), findsWidgets,
        reason: 'the ⚙ tool toggle renders in the strip');

    await shot(tester, '01-keyboard-rendered');
  });

  testWidgets('02 · typing Hebrew letters builds the query on real Android',
      (tester) async {
    await pumpPanel(tester);

    // Make sure the LETTERS are up (on a phone the keyboard may open on the tools
    // layer), then tap ב · ר · ז. Each insert recomputes the live prediction row; the
    // typed text shows inside the strip, so a "ברז" substring can only be the query.
    expect(await reveal(tester, find.text('ב')), isTrue,
        reason: 'the Hebrew letter layer is reachable on Android');
    await tester.tap(find.text('ב'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ר'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ז'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ברז'), findsWidgets,
        reason: 'the typed letters registered in the strip on Android');
    expect(find.byType(BsKeyboard), findsOneWidget,
        reason: 'the live recompute ran without crashing on Android');

    await shot(tester, '02-typed-barz');
  });

  testWidgets('03 · the home-tools layer shows the tools on real Android',
      (tester) async {
    await pumpPanel(tester);

    // Reveal the home-tools layer (already up on a phone; one ▦ tap away on the VM).
    // The first home tool tile (מחלקות) renders as Text.
    expect(await reveal(tester, find.text('מחלקות')), isTrue,
        reason: 'the ▦ home-tools layer is reachable on Android');
    expect(find.text('מחלקות'), findsWidgets,
        reason: 'the home-tools layer shows its tools on Android');

    await shot(tester, '03-tools-open');
  });

  testWidgets(
      '04 · tapping a tool navigates underneath, keyboard keeps floating (Android)',
      (tester) async {
    final container = await pumpPanel(tester);
    expect(container.read(mainTabProvider), 0, reason: 'starts on tab 0');

    // Reveal the home tools and tap the מחלקות LEAF.
    expect(await reveal(tester, find.text('מחלקות')), isTrue,
        reason: 'the מחלקות tool is reachable on Android');
    await tester.tap(find.text('מחלקות').first);
    await tester.pumpAndSettle();

    // Owner keep-floating model: the LEAF routes the screen underneath (departments
    // → tab 1) but the keyboard stays open and mounted over the swapped screen.
    expect(container.read(mainTabProvider), 1,
        reason: 'the מחלקות leaf routed the home to the departments tab on Android');
    expect(container.read(keyboardOverlayOpenProvider), isTrue,
        reason: 'a leaf tap must NOT close the floating keyboard');
    expect(find.byType(BsKeyboard), findsOneWidget,
        reason: 'the keyboard keeps floating over the swapped screen');

    await shot(tester, '04-navigated-floating');
  });

  testWidgets('05 · the ⚙ gear drills a branch in place on real Android',
      (tester) async {
    final container = await pumpPanel(tester);
    final tabBefore = container.read(mainTabProvider);

    // Open the kbd-tools layer (⚙ gear), revealing the תפריט branch tile.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('תפריט'), findsOneWidget,
        reason: 'the ⚙ gear opened the kbd tools (תפריט is a branch)');

    // Tapping the BRANCH morphs the tool view in place to its children — the AI hub
    // (בינה) + settings (הגדרות) tiles — with NO navigation and NO close.
    await tester.tap(find.text('תפריט'));
    await tester.pumpAndSettle();

    expect(find.text('בינה'), findsOneWidget,
        reason: 'the branch morphed to its AI-hub child tile on Android');
    expect(find.text('הגדרות'), findsOneWidget,
        reason: 'the branch morphed to its settings child tile on Android');
    expect(container.read(mainTabProvider), tabBefore,
        reason: 'morphing a branch does not navigate');
    expect(container.read(keyboardOverlayOpenProvider), isTrue,
        reason: 'morphing a branch keeps the overlay open');

    await shot(tester, '05-branch-drilled');
  });
}
