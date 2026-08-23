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

  test('labels (✎ rename) — setLabel overrides, empty reverts, '
      'canonical-minimal', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = notifier(c);
    expect(n.labelOf(home, 'a', 'ברירת'), 'ברירת'); // no override ⇒ default
    n.setLabel(home, 'a', 'חדש');
    expect(n.labelOf(home, 'a', 'ברירת'), 'חדש');
    // hide/order unaffected by a rename.
    expect(n.orderedIds(home, defs), defs);
    n.setLabel(home, 'a', '   '); // empty ⇒ revert to default
    expect(n.labelOf(home, 'a', 'ברירת'), 'ברירת');
    expect(c.read(screenSectionsProvider), isEmpty); // no trace once reverted
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

  // ── server-sync (screen_sections_sink_firebase.dart) — Firebase-free via a
  //    fake publish hook. Proves the manager's edit reaches "everyone" and a
  //    received snapshot adopts without echoing back to the server. ────────────
  group('server-sync — publish on edit + adopt from remote', () {
    test('every edit pushes the canonical-minimal map to the publish hook; '
        'reset pushes the empty string (⇒ shared-doc remove)', () {
      final pushed = <String>[];
      final n = ScreenSectionsNotifier(
        publish: (encoded) {
          pushed.add(encoded);
          return Future<void>.value();
        },
      );
      addTearDown(n.dispose);
      n.hide(home, 'b');
      expect(pushed, isNotEmpty);
      expect(pushed.last, contains('hidden'));
      expect(pushed.last, contains(home));
      n.resetScreen(home);
      expect(pushed.last, ''); // empty ⇒ remove the shared doc (back to defaults)
    });

    test('adoptRemote sets state from an encoded map WITHOUT re-publishing '
        '(a received snapshot never loops back to the server)', () {
      final pushed = <String>[];
      final n = ScreenSectionsNotifier(
        publish: (encoded) {
          pushed.add(encoded);
          return Future<void>.value();
        },
      );
      addTearDown(n.dispose);
      n.adoptRemote('{"home":{"hidden":["b"]}}');
      expect(n.isHidden('home', 'b'), isTrue);
      expect(n.visibleIds('home', defs), ['a', 'c']);
      expect(pushed, isEmpty); // adopt must NOT publish (no echo loop)
    });

    test('adoptRemote is tolerant — a malformed doc keeps the last-good layout',
        () {
      final n = ScreenSectionsNotifier();
      addTearDown(n.dispose);
      n.adoptRemote('{"home":{"hidden":["b"]}}');
      n.adoptRemote('}{ not json');
      expect(n.isHidden('home', 'b'), isTrue); // unchanged, never blanked
    });

    test('adoptRemote("") clears to canonical-minimal (a reset broadcast)', () {
      final n = ScreenSectionsNotifier();
      addTearDown(n.dispose);
      n.hide('home', 'b');
      n.adoptRemote('');
      expect(n.isHidden('home', 'b'), isFalse);
      expect(n.visibleIds('home', defs), defs);
    });
  });
}
