// Studio Pillar 3 · step 92 — automatic `screen_view` via RouteObserver + shell
// tab listener. This is the FIRST ACTIVE instrumentation, so the bars are strict
// (§8 DoD):
//   1. a tab switch (drive `mainTabProvider`) emits EXACTLY ONE screen_view with
//      the right `screen` key AND `prev`;
//   2. the SAME tab again — or a rebuild — does NOT double-fire (`prev==next`
//      guard + `ref.listen` fires only on change);
//   3. a NAMED route push emits exactly one screen_view (unnamed app routes stay
//      inert — zero demo-path change);
//   4. the SAME route pushed twice (push→pop→push) does NOT double-fire (the
//      observer's consecutive-dedupe + the bus §9 min-interval throttle);
//   5. tracking causes ZERO rebuild of the tab UI (a probe that watches
//      `mainTabProvider` is unchanged across a track) — read-only;
//   6. GREP-style guard (mirrors intel_bus_test): the screen_view seam subscribes
//      to NOTHING — no `ref.watch` / `.watch(` in its CODE (comments stripped).
//   7. the pure key maps (§6 single source) are correct.
import 'dart:io';

import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/intel/intel_bus.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:buildsmart/state/intel/screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal stand-in for the shell: it registers the SAME read-only tab
/// listener the live shell registers (`listenTabScreenView`) and nothing else.
class _TabHarness extends ConsumerWidget {
  const _TabHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenTabScreenView(ref); // the exact call home_shell.dart:~90 makes
    return const SizedBox();
  }
}

/// A tiny app whose home button pushes a NAMED route (unnamed app routes are
/// inert). The `back` button on the pushed route pops back to the shell.
Widget _routeHarness(IntelRouteObserver observer) => MaterialApp(
      navigatorObservers: [observer],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'ai_hub'),
                  builder: (_) => Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('back'),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );

Iterable<IntelEvent> _views(ProviderContainer c) =>
    c.read(intelLogProvider).where((e) => e.name == IntelEvents.screenView);

void main() {
  group('screen keys (§6 single source)', () {
    test('screenKeyForTab maps the 4 bottom-nav tabs; out-of-range is safe', () {
      expect(screenKeyForTab(0), 'home');
      expect(screenKeyForTab(1), 'departments');
      expect(screenKeyForTab(2), 'updates');
      expect(screenKeyForTab(3), 'store');
      expect(screenKeyForTab(9), 'tab_9');
    });

    test('screenKeyForRoute: name→key, null/root/empty→null', () {
      expect(screenKeyForRoute('ai_hub'), 'ai_hub');
      expect(screenKeyForRoute('/settings'), 'settings');
      expect(screenKeyForRoute(null), isNull);
      expect(screenKeyForRoute('/'), isNull); // the app root folds to null
      expect(screenKeyForRoute(''), isNull);
    });

    test('the emitted prop keys are within the screen_view allow-list (§4)', () {
      expect(
        IntelEvents.allowedProps[IntelEvents.screenView],
        containsAll(<String>['screen', 'prev']),
      );
    });
  });

  testWidgets(
    'a tab switch emits EXACTLY ONE screen_view with screen + prev',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TabHarness(),
        ),
      );
      expect(_views(container), isEmpty); // no emit on initial mount

      // 0 (home) → 2 (updates)
      container.read(mainTabProvider.notifier).state = 2;
      await tester.pump();

      final views = _views(container).toList();
      expect(views, hasLength(1));
      expect(views.single.props['screen'], 'updates');
      expect(views.single.props['prev'], 'home');
    },
  );

  testWidgets(
    'the same tab again (and a rebuild) does NOT double-fire',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TabHarness(),
        ),
      );

      container.read(mainTabProvider.notifier).state = 1; // one switch
      await tester.pump();
      // Re-assert the SAME value — StateProvider won't notify (identical), and
      // the `prev==next` guard would drop it anyway.
      container.read(mainTabProvider.notifier).state = 1;
      await tester.pump();
      // Force extra rebuilds — `ref.listen` re-registers but fires only on a
      // CHANGE, so it must not re-emit.
      await tester.pump();
      await tester.pump();

      expect(_views(container), hasLength(1));
    },
  );

  testWidgets('a NAMED route push emits exactly one screen_view', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final observer = IntelRouteObserver()..bind(container.read(intelBusProvider));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _routeHarness(observer),
      ),
    );
    expect(_views(container), isEmpty); // the unnamed root ('/') does not emit

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final views = _views(container).toList();
    expect(views, hasLength(1));
    expect(views.single.props['screen'], 'ai_hub');
    expect(views.single.props.containsKey('prev'), isFalse); // first nav
  });

  testWidgets(
    'the same route push→pop→push does NOT double-fire (dedupe + throttle)',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final observer = IntelRouteObserver()
        ..bind(container.read(intelBusProvider));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _routeHarness(observer),
        ),
      );

      await tester.tap(find.text('go')); // push ai_hub → emit 1
      await tester.pumpAndSettle();
      await tester.tap(find.text('back')); // pop back to the shell (no emit)
      await tester.pumpAndSettle();
      await tester.tap(find.text('go')); // re-push within 1s → throttled
      await tester.pumpAndSettle();

      expect(_views(container), hasLength(1)); // exactly once despite two pushes
    },
  );

  testWidgets(
    'tracking causes ZERO rebuild of the tab UI (read-only)',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var builds = 0;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              builds++;
              // Stand-in for the 4 tabs: watches the tab-UI provider like the
              // shell (home_shell.dart:69). A track must NOT rebuild it.
              ref.watch(mainTabProvider);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(builds, 1);

      // Exactly what the observer / listener call.
      container.read(intelBusProvider).track(
        IntelEvents.screenView,
        props: const <String, String>{'screen': 'ai_hub'},
      );
      await tester.pump();

      expect(builds, 1, reason: 'tracking is byte-neutral for the tab UI');
      // Anti-vacuous: the track really ran (the event landed in the log).
      expect(_views(container), hasLength(1));
    },
  );

  test(
    'the screen_view seam subscribes to NOTHING — no watch in its CODE (§8)',
    () {
      // Mirrors intel_bus_test's grep guard, but strips comment lines first so
      // the PROSE that explains why we DON'T watch cannot false-positive.
      // (cwd == package root under `flutter test`.)
      final src = File('lib/state/intel/screen_view.dart').readAsStringSync();
      final code = src
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      // Anti-vacuous: prove we read the right file + it IS the read-only seam.
      expect(code.contains('class IntelRouteObserver'), isTrue);
      expect(code.contains('ref.listen'), isTrue); // the tab seam LISTENS
      expect(code.contains('ref.read('), isTrue); // and READS the bus
      expect(
        code.contains('ref.watch'),
        isFalse,
        reason: 'the screen_view seam must never subscribe (§4)',
      );
      expect(
        code.contains('.watch('),
        isFalse,
        reason: 'no reactive subscription in the observer/listener (§8 DoD)',
      );
    },
  );

  test('an unbound observer is inert (never throws, never emits)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final observer = IntelRouteObserver(); // no bind()
    final route = MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ai_hub'),
      builder: (_) => const SizedBox(),
    );
    expect(() => observer.didPush(route, null), returnsNormally);
    expect(container.read(intelLogProvider), isEmpty);
  });
}
