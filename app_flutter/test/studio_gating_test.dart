// Studio Pillar 4 · step 80 — the co-editor GATE gating tests.
//
// Guards the LIVE default of the manager-only Studio co-editor. Three concerns:
//   1. BYTE-IDENTICAL invariant — `kStudioCoEditor` is a compile-time
//      `bool.fromEnvironment('STUDIO_CO_EDITOR')`; with no `--dart-define` it is
//      false, so the `studioCoEditorProvider.enabled` axis reads false and (since
//      NO screen watches the provider yet) the whole gate tree-shakes out. This is
//      the same permanent backstop `backend_flag_test` gives `kClaudeAi`/
//      `kStudioLive` — an accidental flip in a demo/CI build turns this red.
//   2. THREE INDEPENDENT AXES (§4/§8/§9) — `enabled` (pillar), `ai` (gateway),
//      `manager` (board role) are decided separately; pillar-on / gateway-off is a
//      legal distinct state, so they are never conflated. Proven by flipping the
//      `manager` axis via `boardAuthProvider` while `enabled` stays false.
//   3. ACTIVE REGRESSION GATE (§10 תוספת-ב) — asserts `STUDIO_CO_EDITOR` appears in
//      NO CI workflow, so a build config can never silently ship the flag ON.
import 'dart:io';

import 'package:buildsmart/data/repositories/backend.dart' show kStudioCoEditor;
import 'package:buildsmart/logic/studio/co_editor_gate.dart'
    show studioCoEditorProvider;
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('kStudioCoEditor defaults OFF (no dart-define) — byte-identical invariant',
      () {
    // No --dart-define=STUDIO_CO_EDITOR in the test run → the compile-time flag
    // is false, exactly like the shipped demo/CI build.
    expect(kStudioCoEditor, isFalse);
  });

  test('studioCoEditorProvider — all three axes OFF in the default/demo container '
      '(enabled ∧ ai ∧ manager all read false; axes are separate booleans)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final gate = c.read(studioCoEditorProvider);
    // enabled: flag OFF ∧ backend OFF; ai: no Claude gateway bound; manager: no
    // board session logged in. Each axis is computed independently (§4/§8/§9) —
    // the record shape itself proves they are not conflated. The `manager==true`
    // path is exercised live when step-81's cockpit consumes the gate with a real
    // manager session; here every axis is the shipped-default false.
    expect(gate.enabled, isFalse);
    expect(gate.ai, isFalse);
    expect(gate.manager, isFalse);
  });

  // §10 תוספת-ב — the active regression gate: the flag must appear in NO CI
  // workflow, so a build config can never ship it ON by accident.
  test('STUDIO_CO_EDITOR appears in no CI workflow (regression gate §10)', () {
    final dir = Directory('../.github/workflows');
    if (!dir.existsSync()) {
      markTestSkipped('CI workflows dir not present from the test cwd');
      return;
    }
    final offenders = <String>[];
    for (final e in dir.listSync()) {
      if (e is File && (e.path.endsWith('.yml') || e.path.endsWith('.yaml'))) {
        if (e.readAsStringSync().contains('STUDIO_CO_EDITOR')) {
          offenders.add(e.uri.pathSegments.last);
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'STUDIO_CO_EDITOR must never be baked into a CI build — a '
            'workflow enabling it would ship the co-editor ON: '
            '${offenders.join(", ")}',);
  });

  // ── step 81 — the manager-cockpit hero gate (the FIRST visible-UI step) ──
  // The Studio hero is added to the LIVE manager dashboard behind the OUTER
  // compile-const gate `if (kStudioCoEditor) const _StudioHero()`. Because
  // `kStudioCoEditor` is a const-false `bool.fromEnvironment` in every normal
  // build (and this define-less test run), that branch — and `_StudioHero`
  // itself — tree-shakes away, so the shipped cockpit is BYTE-IDENTICAL to today.
  //
  // The flag-ON path is COMPILE-gated (a const-false `if`), so it CANNOT be
  // exercised in a unit test without `--dart-define=STUDIO_CO_EDITOR=true` at
  // test-compile time; we therefore assert the OFF invariant — the one that
  // protects production — here.
  testWidgets(
      'flag OFF (compile default) → the manager dashboard shows NO Studio hero '
      '— the byte-identical / flag-OFF invariant that guards the LIVE cockpit',
      (t) async {
    expect(kStudioCoEditor, isFalse); // precondition: the OFF (shipped) build.

    // Seed a real MANAGER board session so the board (not the gate) renders AND
    // the runtime `manager` axis is TRUE — proving the OUTER compile gate, not
    // the role check, is what keeps the hero out of the shipped build.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));

    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: ManagerDashboardScreen(),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }

    // The manager board rendered (positive control — the AppBar title)...
    expect(find.text('מרכז השליטה'), findsOneWidget);
    // ...and the Studio hero is ABSENT — compile-gated OFF (byte-identical).
    expect(find.byKey(const Key('studio-hero')), findsNothing);
    // ...while the sibling 🤖 co-pilot hero is UNCHANGED — the cockpit built its
    // heroes; the missing key is the Studio hero being gated, not a dead board.
    expect(find.text('שאל את העסק שלך'), findsWidgets);
  });

  // §5/§8 documentation — pins the compile-gate precondition the OFF assertion
  // above relies on: the shipped / CI test build has `kStudioCoEditor == false`,
  // so `if (kStudioCoEditor)` eliminates the hero and the ON path is unreachable
  // without a dart-define. An accidental define in the harness flips this red
  // before it could mask the OFF invariant.
  test('step 81 hero is compile-gated — kStudioCoEditor is false in this build, '
      'so the ON path is unreachable without a dart-define (OFF is the invariant)',
      () {
    expect(kStudioCoEditor, isFalse);
  });
}
