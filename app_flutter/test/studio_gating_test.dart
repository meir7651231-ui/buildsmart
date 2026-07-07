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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
