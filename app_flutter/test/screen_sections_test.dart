// screen-management · slice-1 — the unified per-screen ORDER+HIDE model
// (screen_sections.dart). Proves: empty default is byte-identical (orderedIds ==
// defaults, nothing hidden, no prefs trace), hide is non-destructive, reorder is
// per-screen, the reconcile survives changed defaults, persistence round-trips,
// and reset leaves no trace.

import 'package:buildsmart/state/screen_sections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const home = 'home';
  const defs = ['a', 'b', 'c'];

  ScreenSectionsNotifier notifier(ProviderContainer c) =>
      c.read(screenSectionsProvider.notifier);

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('default (empty) ⇒ orderedIds == defaults, visibleIds == defaults, '
      'nothing hidden, no prefs trace (byte-identical)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = notifier(c);
    expect(n.orderedIds(home, defs), defs);
    expect(n.visibleIds(home, defs), defs);
    expect(n.isHidden(home, 'a'), isFalse);
    expect(c.read(screenSectionsProvider), isEmpty); // canonical-minimal
  });

  test('hide / show / toggle — non-destructive: order keeps the id, visible '
      'drops it; show returns to canonical-minimal', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = notifier(c);
    n.hide(home, 'b');
    expect(n.isHidden(home, 'b'), isTrue);
    expect(n.orderedIds(home, defs), defs); // still present (non-destructive)
    expect(n.visibleIds(home, defs), ['a', 'c']); // filtered from visible only
    n.toggle(home, 'b'); // -> show
    expect(n.isHidden(home, 'b'), isFalse);
    expect(n.visibleIds(home, defs), defs);
    expect(c.read(screenSectionsProvider), isEmpty); // no trace once un-hidden
  });

  test('reorder / moveUp / moveDown — ReorderableListView contract', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = notifier(c);
    n.moveDown(home, defs, 'a'); // a b c -> b a c
    expect(n.orderedIds(home, defs), ['b', 'a', 'c']);
    n.moveUp(home, defs, 'c'); // b a c -> b c a
    expect(n.orderedIds(home, defs), ['b', 'c', 'a']);
    n.reorder(home, defs, 0, 3); // move head to the end -> c a b
    expect(n.orderedIds(home, defs), ['c', 'a', 'b']);
  });

  test('per-screen isolation — customizing one screen never touches another', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = notifier(c);
    n.hide('home', 'a');
    n.moveDown('catalog', defs, 'a');
    expect(n.visibleIds('home', defs), ['b', 'c']);
    expect(n.orderedIds('home', defs), defs); // home order untouched
    expect(n.visibleIds('catalog', defs), ['b', 'a', 'c']); // reordered, none hidden
    expect(n.isHidden('catalog', 'a'), isFalse);
  });

  test('reconcile — stored order survives changed defaults (forward-compat)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = notifier(c);
    n.moveDown('s', defs, 'a'); // stored order becomes [b, a, c]
    // 'c' removed from the defaults, 'd' added: c drops, d appends, b/a survive.
    expect(n.orderedIds('s', ['b', 'a', 'd']), ['b', 'a', 'd']);
  });

  test('persist round-trip — a fresh notifier reloads the saved layout', () async {
    final c1 = ProviderContainer();
    final n1 = c1.read(screenSectionsProvider.notifier);
    n1.hide('home', 'b');
    n1.moveDown('home', defs, 'a');
    await Future<void>.delayed(const Duration(milliseconds: 20)); // flush _persist
    c1.dispose();
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    final n2 = c2.read(screenSectionsProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 20)); // let _load run
    expect(n2.isHidden('home', 'b'), isTrue);
    expect(n2.orderedIds('home', defs), ['b', 'a', 'c']);
  });

  test('resetScreen — drops all customization, leaves no prefs trace', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = notifier(c);
    n.hide('home', 'a');
    n.moveDown('home', defs, 'b');
    expect(c.read(screenSectionsProvider).containsKey('home'), isTrue);
    n.resetScreen('home');
    expect(c.read(screenSectionsProvider).containsKey('home'), isFalse);
    expect(n.orderedIds('home', defs), defs);
    expect(n.visibleIds('home', defs), defs);
  });
}
