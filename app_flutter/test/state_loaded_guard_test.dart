// State-notifier hardening gate — the load-clobber guard (`bool _loaded`).
//
// THE BUG (just fixed across the persisting engines): a StateNotifier that
// overrides `set state` to AUTO-PERSIST, and seeds itself from an async
// `_load()` that writes `super.state = …` after an `await`, can have its load
// CLOBBER a mutation that arrived before SharedPreferences resolved. The fix is
// a `bool _loaded` latch: the `set state` override flips it, and `_load` only
// applies the persisted value `if (!_loaded)`.
//
// THE GATE: scan every lib/state/*.dart at test time (real File reads — NOT
// reflection). A file is a "clobber-prone persisting notifier" when its source
// BOTH:
//   • overrides the setter — contains `set state(`  (this is what creates the
//     persist-on-assign hazard; a notifier that never overrides `set state`
//     re-persists nothing from `_load`, so it carries no clobber race), AND
//   • persists            — contains `SharedPreferences`.
// Every such file MUST also contain `bool _loaded`. If a future persisting
// notifier ships the `set state` + SharedPreferences pair WITHOUT the latch,
// this test goes red.
//
// Why `set state(` (not merely a `_load(` method): a sweep of the tree shows
// MANY notifiers that hold `SharedPreferences` + a `_load()` method but do NOT
// override `set state` (e.g. app_settings, ab_experiments) — they assign via
// the plain public setter and have no load-clobber race of this shape, so they
// correctly DON'T carry the latch. The `set state` override is the exact,
// observed signal that separates the 12 guarded engines from those — using it
// keeps the gate green today while still locking the invariant for the future.
//
// Modeled on regression_gate_test.dart (dart:io File reads, Directory.listSync,
// an offenders list, expect(..., isEmpty, reason: …)).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every persisting notifier that overrides `set state` carries '
      'the `bool _loaded` load-clobber guard', () {
    // Tests run with the package root as cwd, so this resolves to
    // app_flutter/lib/state (same convention as regression_gate_test.dart).
    final dir = Directory('lib/state');
    expect(dir.existsSync(), isTrue,
        reason: 'lib/state must exist (run from the app_flutter package root)');

    final stateFiles = [
      for (final e in dir.listSync())
        if (e is File && e.path.endsWith('.dart')) e,
    ];
    expect(stateFiles.length, greaterThan(20),
        reason: 'sanity — lib/state should hold many notifiers');

    final offenders = <String>[];
    var guarded = 0;
    for (final f in stateFiles) {
      final src = f.readAsStringSync();
      final persists = src.contains('SharedPreferences');
      final overridesSetter = src.contains('set state(');
      if (!persists || !overridesSetter) continue; // not clobber-prone
      if (src.contains('bool _loaded')) {
        guarded++;
      } else {
        offenders.add(f.uri.pathSegments.last);
      }
    }

    // The fix is already in place across the engines, so at least a handful of
    // files must match the guarded pattern — this also proves the gate's
    // predicate actually selects files (a no-match scan would pass vacuously).
    expect(guarded, greaterThan(0),
        reason: 'the gate must actually be exercising guarded notifiers');

    expect(offenders, isEmpty,
        reason: 'these persisting notifiers override `set state` but are '
            'MISSING the `bool _loaded` load-clobber guard — an async _load '
            'can clobber a pre-load mutation:\n  ${offenders.join("\n  ")}');
  });
}
