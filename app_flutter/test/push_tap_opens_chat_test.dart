// A tapped chat notification must open its conversation — also when the app is
// ALREADY running.
//
// The contractor's `ChatsScreen` is an always-mounted `IndexedStack` child of
// the home shell. It used to look for the parked thread id only with a one-shot
// read inside `build`, and nothing rebuilds that screen when the id is parked,
// so for a signed-in user (warm tap, late cold-launch message, web `?thread=`
// launch) the tap opened the app and no conversation; the chat then opened by
// itself at the next unrelated rebuild. These tests pump the real screen.
//
// The second half: the web launch url keeps `?thread=` for the whole session
// and was re-read on every root rebuild, so once the screen really listens, an
// unlatched read would re-open the same chat on every settings change.
import 'dart:async';

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:buildsmart/state/push_routing.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/widgets/toast.dart' show bsMessengerKey;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A seed conversation the contractor can see (`lib/data/chat_seeds.dart`).
const _thread = 'th-contractor-store';

Future<void> _settle(WidgetTester t) async {
  // Bounded settle (the sys_chat_test idiom — the list animates).
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
}

Future<ProviderContainer> _pumpChats(
  WidgetTester t, {
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  await t.binding.setSurfaceSize(const Size(600, 1400));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        scaffoldMessengerKey: bsMessengerKey,
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: ChatsScreen()),
        ),
      ),
    ),
  );
  await _settle(t);
  return ProviderScope.containerOf(t.element(find.byType(ChatsScreen, skipOffstage: false)));
}

bool _chatIsOpen(WidgetTester t) =>
    t.state<NavigatorState>(find.byType(Navigator)).canPop();

void main() {
  group('ChatsScreen consumes a tapped notification', () {
    testWidgets('WARM: the id is parked while the screen is already mounted',
        (t) async {
      final c = await _pumpChats(t);
      expect(_chatIsOpen(t), isFalse);

      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);

      expect(c.read(pendingPushThreadProvider), isNull,
          reason: 'the parked id must be consumed without waiting for an '
              'unrelated rebuild');
      expect(_chatIsOpen(t), isTrue, reason: 'the conversation is pushed');
      expect(t.takeException(), isNull);
    });

    testWidgets('ARRIVAL: the id was parked before the screen existed',
        (t) async {
      final c = await _pumpChats(
        t,
        overrides: [pendingPushThreadProvider.overrideWith((_) => _thread)],
      );

      expect(t.takeException(), isNull,
          reason: 'consuming must not write a provider during build');
      expect(c.read(pendingPushThreadProvider), isNull);
      expect(_chatIsOpen(t), isTrue);
    });

    testWidgets('a SECOND tap on the same conversation re-opens it', (t) async {
      final c = await _pumpChats(t);
      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      t.state<NavigatorState>(find.byType(Navigator)).pop();
      await _settle(t);
      expect(_chatIsOpen(t), isFalse);

      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(_chatIsOpen(t), isTrue);
      expect(c.read(pendingPushThreadProvider), isNull);
    });

    testWidgets(
        'a thread that never shows up ends in an honest toast, not in silence',
        (t) async {
      final c = await _pumpChats(t);
      c.read(pendingPushThreadProvider.notifier).state = 'no-such-thread';
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), isNull);
      expect(_chatIsOpen(t), isFalse);
      expect(find.text('השיחה לא נמצאה'), findsNothing, reason: 'still waiting');

      await t.pump(const Duration(seconds: 8));
      await t.pump();
      expect(find.text('השיחה לא נמצאה'), findsOneWidget);
      expect(_chatIsOpen(t), isFalse);
      expect(t.takeException(), isNull);
      await t.pump(const Duration(seconds: 6)); // let the toast run out
    });

    testWidgets(
        'the conversation is not loaded yet (cold / web launch): the tap '
        'waits and opens it when the thread list arrives', (t) async {
      final c = await _pumpChats(t);
      final engine = c.read(chatEngineProvider.notifier);
      // The live backend starts EMPTY until the first server snapshot.
      // ignore: invalid_use_of_protected_member
      engine.state = const [];
      await _settle(t);

      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(_chatIsOpen(t), isFalse);

      engine.resetToSeed(); // the snapshot lands
      await _settle(t);
      expect(_chatIsOpen(t), isTrue,
          reason: 'the tap must survive a slow first snapshot');

      await t.pump(const Duration(seconds: 9));
      expect(find.text('השיחה לא נמצאה'), findsNothing,
          reason: 'opened — the give-up toast must not fire');
    });

    testWidgets('a second notification for the conversation already open '
        'does not stack the same page twice', (t) async {
      final c = await _pumpChats(t);
      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), isNull);

      final nav = t.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await _settle(t);
      expect(nav.canPop(), isFalse, reason: 'exactly one chat page was pushed');
    });

    testWidgets(
        'with a role board on top, the BOARD opens the conversation — not '
        'the contractor list underneath', (t) async {
      final c = await _pumpChats(t);
      final nav = t.state<NavigatorState>(find.byType(Navigator));
      unawaited(nav.push(MaterialPageRoute<void>(
        builder: (_) => const Directionality(
          textDirection: TextDirection.rtl,
          child: ChatsScreen(persona: BsRole.store, audience: 'store'),
        ),
      )));
      await _settle(t);

      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), isNull);

      final page = t.widget(find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_ChatPage'));
      // ignore: avoid_dynamic_calls
      expect((page as dynamic).view.persona, BsRole.store);
    });

    testWidgets(
        'a WORKER board covers the shell and its chats tab is not mounted: '
        'the contractor list underneath leaves the tap for the board',
        (t) async {
      final c = await _pumpChats(t);
      c.read(boardAuthProvider.notifier).enterDemo(BoardRole.worker);
      final nav = t.state<NavigatorState>(find.byType(Navigator));
      // The board, on a tab that is not its chats list.
      unawaited(nav.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('worker board · tasks tab')),
      )));
      await _settle(t);

      c.read(pendingPushThreadProvider.notifier).state = 'th-contractor-worker';
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), 'th-contractor-worker',
          reason: 'must NOT be opened as the contractor over the board');
      expect(find.byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_ChatPage'),
          findsNothing);

      // The worker enters the board's chats: that list takes it, as a worker.
      unawaited(nav.push(MaterialPageRoute<void>(
        builder: (_) => const Directionality(
          textDirection: TextDirection.rtl,
          child: ChatsScreen(persona: BsRole.worker, audience: 'worker'),
        ),
      )));
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), isNull);
    });

    testWidgets(
        'an id left parked under a board is taken by the shell list once it '
        'is on top again', (t) async {
      final c = await _pumpChats(t);
      c.read(boardAuthProvider.notifier).enterDemo(BoardRole.worker);
      final nav = t.state<NavigatorState>(find.byType(Navigator));
      unawaited(nav.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('cover')),
      )));
      await _settle(t);
      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), _thread);

      nav.pop(); // back to the main app
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), isNull);
      expect(_chatIsOpen(t), isTrue);
    });

    testWidgets(
        'the CONTRACTOR on some other main-app screen (no board session): '
        'the tap opens the conversation right away', (t) async {
      final c = await _pumpChats(t);
      final nav = t.state<NavigatorState>(find.byType(Navigator));
      unawaited(nav.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('product page')),
      )));
      await _settle(t);
      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), isNull);
      expect(
          find.byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_ChatPage'),
          findsOneWidget);
    });

    testWidgets(
        'a conversation opened by tapping its ROW is not stacked again by a '
        'notification for it', (t) async {
      final c = await _pumpChats(t);
      await t.tap(find.byKey(const ValueKey(_thread)));
      await _settle(t);
      expect(_chatIsOpen(t), isTrue);

      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(c.read(pendingPushThreadProvider), isNull);

      final nav = t.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await _settle(t);
      expect(nav.canPop(), isFalse, reason: 'only one page for the thread');
    });

    testWidgets(
        'while a tapped thread is still loading the user opens ANOTHER chat: '
        'the late one is not pushed over it and no toast fires', (t) async {
      final c = await _pumpChats(t);
      c.read(pendingPushThreadProvider.notifier).state = 'late-thread';
      await _settle(t);
      expect(_chatIsOpen(t), isFalse);

      await t.tap(find.byKey(const ValueKey(_thread))); // reads another chat
      await _settle(t);
      final pages = find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_ChatPage');
      expect(pages, findsOneWidget);

      await t.pump(const Duration(seconds: 9));
      await t.pump();
      expect(find.text('השיחה לא נמצאה'), findsNothing);
      expect(pages, findsOneWidget);
    });

    testWidgets(
        'chat switched OFF for the org: the id is left for the chat-off '
        'consumer (UpdatesScreen), no conversation opens', (t) async {
      final c = await _pumpChats(t, overrides: [
        orgConfigProvider
            .overrideWith((_) => const OrgConfig(modules: {'chat': false})),
      ]);
      c.read(pendingPushThreadProvider.notifier).state = _thread;
      await _settle(t);
      expect(_chatIsOpen(t), isFalse);
      expect(c.read(pendingPushThreadProvider), _thread);
    });
  });

  group('takeLaunchThread — the web ?thread= launch is honoured once', () {
    ProviderContainer container(String url) {
      final c = ProviderContainer(
          overrides: [launchUrlProvider.overrideWithValue(url)]);
      addTearDown(c.dispose);
      return c;
    }

    test('returns the thread the first time, null ever after', () {
      final c = container('https://app.example/?thread=t-9');
      expect(takeLaunchThread(c.read), 't-9');
      expect(takeLaunchThread(c.read), isNull);
      expect(takeLaunchThread(c.read), isNull);
    });

    test('a launch url with no thread is a no-op', () {
      final c = container('https://app.example/');
      expect(takeLaunchThread(c.read), isNull);
      expect(takeLaunchThread(c.read), isNull);
    });

    test('each app boot (ProviderScope) gets its own latch', () {
      expect(takeLaunchThread(container('https://x/?thread=a').read), 'a');
      expect(takeLaunchThread(container('https://x/?thread=a').read), 'a');
    });
  });

  testWidgets(
      'BuildSmartApp: a consumed ?thread= launch is NOT parked again when the '
      'root rebuilds (settings change)', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          launchUrlProvider.overrideWithValue('https://x/?thread=$_thread'),
        ],
        child: const BuildSmartApp(),
      ),
    );
    await t.pumpAndSettle();
    final c = ProviderScope.containerOf(t.element(find.byType(BuildSmartApp)));

    // Whatever consumed it (or not), clear it: the launch has been handled.
    c.read(pendingPushThreadProvider.notifier).state = null;
    await t.pumpAndSettle();

    // From here on, count every time the thread is parked again. (Looking at
    // the provider afterwards is not enough: the chat screen now consumes a
    // parked id at once — and re-opens the conversation.)
    final reparked = <String>[];
    final sub = c.listen<String?>(pendingPushThreadProvider, (_, id) {
      if (id != null) reparked.add(id);
    });
    addTearDown(sub.close);

    // Any root rebuild — here a settings toggle.
    c
        .read(appSettingsProvider.notifier)
        .update((s) => s.copyWith(reduceMotion: !s.reduceMotion));
    await t.pump();
    await t.pump();
    await t.pumpAndSettle();

    expect(reparked, isEmpty,
        reason: 'the launch url is a one-time fact, not a stream');
    expect(c.read(pendingPushThreadProvider), isNull);
  });
}
