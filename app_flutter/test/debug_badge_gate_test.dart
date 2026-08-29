// B1 (owner policy): no visible non-functional/debug UI in a shipped build —
// the App Store rejects it. The launch-diagnostic BackendDebugBadge is kept in
// code for dev, but is mounted ONLY in debug builds via kDebugMode. These
// guards pin that: the release branch contributes NOTHING, and the live app
// shell mounts the badge exactly when kDebugMode is true.
//
// The gate is a pure `debugOverlayChildren({required bool isDebug})` so we can
// assert BOTH flag values without flipping the kDebugMode const at runtime.
// MUTATION-VERIFY: change the gate to `isDebug ? const [] : ...` (or
// `isDebug: !kDebugMode`) → the release-absent / dev-present expectations turn
// RED; restoring the gate is GREEN.
import 'package:buildsmart/main.dart';
import 'package:buildsmart/widgets/backend_debug_badge.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('B1 — BackendDebugBadge is gated to debug builds', () {
    test('release branch (isDebug:false) mounts NOTHING', () {
      // A release / profile / web-release build has kDebugMode == false.
      expect(debugOverlayChildren(isDebug: false), isEmpty);
    });

    test('debug branch (isDebug:true) keeps the badge for dev', () {
      final overlays = debugOverlayChildren(isDebug: true);
      expect(overlays, hasLength(1));
      expect(overlays.single, isA<BackendDebugBadge>());
    });

    testWidgets('the live app shell mounts the badge iff kDebugMode', (t) async {
      await t.pumpWidget(const ProviderScope(child: BuildSmartApp()));
      await t.pumpAndSettle();
      // Ties the pure gate to the real wiring: present in debug test runs,
      // absent once shipped. (No tap on it — it sits behind the shell.)
      expect(
        find.byType(BackendDebugBadge),
        kDebugMode ? findsOneWidget : findsNothing,
      );
    });
  });
}
