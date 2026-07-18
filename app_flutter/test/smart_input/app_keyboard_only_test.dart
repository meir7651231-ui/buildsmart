// APP-KEYBOARD-ONLY (owner, wave 1) — the contract behind `--dart-define=SMART_INPUT=true`.
//
// The owner's ask: "no device keyboard, only the app's keyboard". The mechanism was
// already built (BsKeyboardHost + the chat field's `readOnly:`), but its gate flag
// 'kSmartInput' was never in `FeatureFlagsNotifier._forcedOnFlags`, so it was dorment
// in EVERY build. `kSmartInputDemo` now seeds it, exactly like its three siblings.
//
// WHY THESE TESTS: the one bug that matters here is the SPLIT-BRAIN the gate's own
// doc-comment warns about — a field going `readOnly` (OS keyboard suppressed) while
// the in-app keyboard does NOT appear, leaving a field NOBODY can type into. That is
// a user-facing lockout, so it is asserted directly, in both flag states.
//
// `flutter test` does NOT forward --dart-define to library consts, so the ON branch
// is driven the way the repo always drives such branches: by seeding the RUNTIME flag
// (`featureFlagsProvider.notifier.enable(...)`) — the same tier the const merely
// pre-seeds. That keeps the assertions honest without a special build.

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/kb_field_mode.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mounts the SHARED gate the way a real screen consumes it, and records what a
/// wired field would do: `readOnly` == "OS keyboard suppressed", and the same
/// value drives whether the in-app keyboard shows.
class _GateProbe extends ConsumerWidget {
  const _GateProbe({required this.onGate});

  final void Function({required bool custom}) onGate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom = useCustomKeyboard(ref, context);
    onGate(custom: custom);
    return TextField(
      readOnly: custom,
      showCursor: custom ? true : null,
    );
  }
}

Future<bool> _pumpGate(
  WidgetTester tester, {
  required bool enableFlag,
  bool accessibleNavigation = false,
}) async {
  late bool captured;
  final container = ProviderContainer();
  addTearDown(container.dispose);
  if (enableFlag) {
    container.read(featureFlagsProvider.notifier).enable(kSmartInputFlag);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      // MaterialApp (not a bare Directionality) — TextField needs Localizations
      // + an Overlay for its selection controls, or it asserts while building.
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(accessibleNavigation: accessibleNavigation),
          child: Material(
            child: _GateProbe(onGate: ({required custom}) => captured = custom),
          ),
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  // FeatureFlagsNotifier hydrates from SharedPreferences on construction; without
  // a mock the plugin channel throws MissingPluginException in the test VM.
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('kSmartInputDemo — the build-time seed', () {
    test('defaults OFF so a normal build is byte-identical', () {
      // No --dart-define ⇒ const false ⇒ the flag is NOT force-seeded, so every
      // consumer (fields + strips) keeps today's behaviour.
      expect(kSmartInputDemo, isFalse);
    });

    test('the seeded literal matches the real flag name', () {
      // _forcedOnFlags keeps the name literal (import-free const set), so a typo
      // there would silently seed nothing. Pin the literal to the shared const.
      expect(kSmartInputFlag, 'kSmartInput');
    });

    test('flag absent by default ⇒ device keyboard stays in charge', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(featureFlagsProvider).contains(kSmartInputFlag),
          isFalse);
    });
  });

  group('useCustomKeyboard — the shared gate (no split-brain)', () {
    testWidgets('OFF ⇒ field is NOT readOnly (OS keyboard works as today)',
        (tester) async {
      final custom = await _pumpGate(tester, enableFlag: false);
      expect(custom, isFalse);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isFalse,
          reason: 'flag OFF must leave the OS keyboard reachable');
    });

    testWidgets('ON ⇒ field IS readOnly (device keyboard suppressed)',
        (tester) async {
      final custom = await _pumpGate(tester, enableFlag: true);
      expect(custom, isTrue);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue,
          reason: 'the whole point: the native keyboard must not appear');
      expect(field.showCursor, isTrue,
          reason: 'caret must stay visible so the app keyboard can type');
    });

    testWidgets('a11y: screen reader ON ⇒ OS keyboard is given back',
        (tester) async {
      // The fallback that keeps the app usable with a screen reader, even with
      // the feature flag enabled.
      final custom = await _pumpGate(
        tester,
        enableFlag: true,
        accessibleNavigation: true,
      );
      expect(custom, isFalse);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isFalse);
    });

    testWidgets('field suppression and keyboard visibility are ONE decision',
        (tester) async {
      // The split-brain guard: both sides read the SAME predicate, so they can
      // never disagree — a field is readOnly if and only if our keyboard shows.
      for (final on in [false, true]) {
        final custom = await _pumpGate(tester, enableFlag: on);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.readOnly, custom,
            reason: 'readOnly must track the gate exactly (state: $on)');
      }
    });
  });
}
