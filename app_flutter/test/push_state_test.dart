// S6 FCM PUSH — unit coverage for push_state: the PushGateway seam, the
// PushController (token follows identity), the users/{uid}.fcmToken writer,
// and the S6.2 message surfaces (foreground toast + tap navigation hook).
//
// NO Firebase here: the push seam ([PushGateway]) is driven by a HAND-ROLLED
// fake ([_FakePushGateway]) and the `users` write-site by a recording fake
// [RemoteCollectionSource] — no firebase mocks, no new packages (the
// auth_state_test.dart pattern). Live push delivery is untestable in this
// sandbox (network blocks Firebase); these fakes pin the LOGIC, and device
// verification (real permission prompt + real delivery) happens later.
//
// Pins (the S6 contract):
//   • without a gateway (Firebase-free) the controller is fully INERT: no
//     permission prompt, no token fetch, no writes — the suite stays green;
//   • sign-in → permission → token → users/{uid}.fcmToken, exactly once per
//     identity (claims re-emissions don't re-register);
//   • token refresh re-writes under the CURRENT uid only;
//   • sign-out clears the field ('' write) + invalidates the device token;
//   • an account switch clears the old uid BEFORE the new uid registers;
//   • denied permission / missing token / failed write → logged, swallowed,
//     NOTHING thrown into the UI, and the controller keeps working;
//   • foreground payload → the toast surface; tapped notifications (initial +
//     opened) → the navigation hook seam.

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/push_state.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [PushGateway]: manually-driven message/refresh streams +
/// an in-memory record of every call, with failure/permission knobs.
class _FakePushGateway implements PushGateway {
  bool permissionGranted = true;

  /// What [getToken] resolves with (null = "no token available yet").
  /// Placeholder values only — fake gateway, nothing real.
  String? token = 'tok-1'; // placeholder

  /// When non-null, [getToken] throws it (web-without-VAPID / APNS-not-ready).
  Exception? tokenError;

  /// The tap that launched the app from terminated, when set.
  PushMessage? initial;

  int permissionRequests = 0;
  int tokenFetches = 0;
  int deleteTokenCalls = 0;

  final refresh = StreamController<String>.broadcast();
  final foreground = StreamController<PushMessage>.broadcast();
  final opened = StreamController<PushMessage>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<String?> getToken() async {
    tokenFetches++;
    final e = tokenError;
    if (e != null) throw e;
    return token;
  }

  @override
  Future<void> deleteToken() async {
    deleteTokenCalls++;
  }

  @override
  Stream<String> onTokenRefresh() => refresh.stream;

  @override
  Stream<PushMessage> onForegroundMessage() => foreground.stream;

  @override
  Future<PushMessage?> initialMessage() async => initial;

  @override
  Stream<PushMessage> onMessageOpenedApp() => opened.stream;

  Future<void> close() async {
    await refresh.close();
    await foreground.close();
    await opened.close();
  }
}

/// A recording fake of the `users` write-site ([RemoteCollectionSource]) —
/// every `set` is captured in order, with a one-shot failure knob.
class _FakeUsersSink implements RemoteCollectionSource {
  final List<({String id, Map<String, dynamic> data})> sets = [];
  bool failNextSet = false;

  /// The last fcmToken value written for [uid] (null = never written).
  String? tokenOf(String uid) {
    for (final s in sets.reversed) {
      if (s.id == uid && s.data.containsKey(kFcmTokenField)) {
        return s.data[kFcmTokenField] as String?;
      }
    }
    return null;
  }

  @override
  Stream<List<RemoteDoc>> snapshots() => const Stream<List<RemoteDoc>>.empty();

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    if (failNextSet) {
      failNextSet = false;
      throw StateError('users write rejected');
    }
    sets.add((id: id, data: Map<String, dynamic>.of(data)));
  }

  @override
  Future<void> delete(String id) async {}
}

/// A minimal fake [AuthGateway] — just enough to drive authStateProvider's
/// stream (the seam CONTRACT: current state emitted on subscribe). Claims are
/// irrelevant to S6 and resolve empty.
class _FakeAuthGateway implements AuthGateway {
  final _controller = StreamController<AuthUser?>.broadcast();

  AuthUser? current;

  void emit(AuthUser? user) {
    current = user;
    _controller.add(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield current;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => current;

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async =>
      const {};

  @override
  Future<String> sendOtp(String phone) async => 'vid-1';

  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async {}

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {}

  @override
  Future<void> signOut() async => emit(null);

  @override
  Future<void> deleteAccount() async => emit(null);

  @override
  Future<void> setRole({required String uid, required String role}) async {}

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A container with the push seams overridden by fakes (null = the
  /// Firebase-free run). The REAL provider wiring — authStateProvider →
  /// pushControllerProvider (fireImmediately) — is exercised as-is; both
  /// providers are created EAGERLY (like the app, where BuildSmartApp watches
  /// the controller) so subscriptions are live before tests emit.
  ProviderContainer makeContainer({
    _FakeAuthGateway? auth,
    _FakePushGateway? push,
    _FakeUsersSink? users,
  }) {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final c = ProviderContainer(
      overrides: [
        authGatewayProvider.overrideWithValue(auth),
        pushGatewayProvider.overrideWithValue(push),
        pushTokenWriterProvider.overrideWithValue(users),
      ],
    );
    addTearDown(c.dispose);
    if (auth != null) addTearDown(auth.close);
    if (push != null) addTearDown(push.close);
    c
      ..read(authStateProvider)
      ..read(pushControllerProvider);
    return c;
  }

  /// Drain the auth stream + the controller's serialised work chain.
  Future<void> settle(ProviderContainer c) async {
    await pumpEventQueue();
    await c.read(pushControllerProvider).settled;
    await pumpEventQueue();
  }

  group('pushToastText — S6.2 payload formatting (pure)', () {
    test('title·body joined; single part passes through; data-only → null', () {
      expect(
        pushToastText(
          const PushMessage(title: 'הזמנה BS-1042', body: 'יצאה למשלוח 🚚'),
        ),
        'הזמנה BS-1042 · יצאה למשלוח 🚚',
      );
      expect(
        pushToastText(const PushMessage(body: 'הודעה חדשה מהחנות')),
        'הודעה חדשה מהחנות',
      );
      expect(
        pushToastText(const PushMessage(title: 'עדכון הזמנה')),
        'עדכון הזמנה',
      );
      expect(
        pushToastText(const PushMessage(data: {'type': 'order'})),
        isNull,
        reason: 'data-only — nothing human-readable to toast',
      );
      expect(pushToastText(const PushMessage(title: '  ', body: '')), isNull);
    });
  });

  group('without Firebase (gateway = null) — zero regression', () {
    test('controller is fully inert: sign-in prompts nothing, writes nothing',
        () async {
      final auth = _FakeAuthGateway();
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, users: users); // push gateway = null

      auth.emit(const AuthUser(uid: 'u1', phone: '+972501234567'));
      await settle(c);

      expect(users.sets, isEmpty, reason: 'no gateway → no registration');
      expect(
        c.read(authStateProvider).user?.uid,
        'u1',
        reason: 'auth itself is untouched by the inert push layer',
      );
    });
  });

  group('S6.1 — token follows identity', () {
    test('sign-in → permission → token → users/{uid}.fcmToken, exactly once',
        () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()..token = 'tok-abc'; // placeholder
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u1'));
      await settle(c);

      expect(push.permissionRequests, 1);
      expect(users.tokenOf('u1'), 'tok-abc');
      expect(
        users.sets,
        hasLength(1),
        reason: 'claims re-emissions for the SAME uid must not re-register',
      );
    });

    test('a RESTORED session registers via fireImmediately (no new event)',
        () async {
      final auth = _FakeAuthGateway()..current = const AuthUser(uid: 'u-restored');
      final push = _FakePushGateway()..token = 'tok-restored'; // placeholder
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      await settle(c);

      expect(users.tokenOf('u-restored'), 'tok-restored');
    });

    test('token refresh re-registers under the signed-in uid', () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()..token = 'tok-old'; // placeholder
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u1'));
      await settle(c);
      push.refresh.add('tok-new');
      await settle(c);

      expect(users.tokenOf('u1'), 'tok-new');
      expect(users.sets, hasLength(2));
      expect(
        push.permissionRequests,
        1,
        reason: 'refresh re-writes the token, it never re-prompts',
      );
    });

    test('a refresh while signed OUT is dropped (nobody to bind to)', () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway();
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      push.refresh.add('tok-orphan');
      await settle(c);

      expect(users.sets, isEmpty);
    });

    test('sign-out clears users/{uid}.fcmToken and invalidates the device token',
        () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()..token = 'tok-1'; // placeholder
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u1'));
      await settle(c);
      auth.emit(null); // sign-out lands on the auth stream
      await settle(c);

      expect(
        users.tokenOf('u1'),
        '',
        reason: 'the cleared field stops the S8.3 senders',
      );
      expect(push.deleteTokenCalls, 1);
    });

    test('account switch A→B: A is cleared BEFORE B registers (strict order)',
        () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()..token = 'tok-shared-device'; // placeholder
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u-a'));
      await settle(c);
      auth.emit(const AuthUser(uid: 'u-b'));
      await settle(c);

      expect(
        [for (final s in users.sets) '${s.id}=${s.data[kFcmTokenField]}'],
        [
          'u-a=tok-shared-device',
          'u-a=',
          'u-b=tok-shared-device',
        ],
        reason: 'clear-old must run ahead of register-new on the FIFO chain',
      );
    });

    test('permission denied → no token fetched, nothing written', () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()..permissionGranted = false;
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u1'));
      await settle(c);

      expect(push.permissionRequests, 1);
      expect(push.tokenFetches, 0);
      expect(users.sets, isEmpty);
    });

    test('no token available (null) → nothing written, nothing thrown',
        () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()..token = null;
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u1'));
      await settle(c);

      expect(users.sets, isEmpty);
      // The promised recovery path: a LATER refresh registers the token.
      push.refresh.add('tok-late');
      await settle(c);
      expect(users.tokenOf('u1'), 'tok-late');
    });

    test('a THROWING getToken is swallowed and the chain keeps working',
        () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()
        ..tokenError = Exception('messaging/apns-token-not-set');
      final users = _FakeUsersSink();
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u1'));
      await settle(c); // must complete — the failure is logged, not thrown

      expect(users.sets, isEmpty);
      push.refresh.add('tok-after-failure');
      await settle(c);
      expect(users.tokenOf('u1'), 'tok-after-failure');
    });

    test('a rejected users-write is swallowed (rule: never into the UI)',
        () async {
      final auth = _FakeAuthGateway();
      final push = _FakePushGateway()..token = 'tok-1'; // placeholder
      final users = _FakeUsersSink()..failNextSet = true;
      final c = makeContainer(auth: auth, push: push, users: users);

      auth.emit(const AuthUser(uid: 'u1'));
      await settle(c); // must complete green

      expect(users.sets, isEmpty);
      push.refresh.add('tok-retry');
      await settle(c);
      expect(users.tokenOf('u1'), 'tok-retry');
    });
  });

  group('S6.2 — message surfaces', () {
    test('a foreground push lands on the foreground hook with its payload',
        () async {
      final push = _FakePushGateway();
      final delivered = <PushMessage>[];
      final controller = PushController(
        gateway: push,
        users: _FakeUsersSink(),
        onForeground: delivered.add,
      );
      addTearDown(controller.dispose);
      addTearDown(push.close);

      push.foreground.add(
        const PushMessage(
          title: 'הזמנה BS-1042',
          body: 'מוכנה לאיסוף 📦',
          data: {'type': 'order', 'id': 'BS-1042'},
        ),
      );
      await pumpEventQueue();

      expect(delivered, hasLength(1));
      expect(delivered.single.title, 'הזמנה BS-1042');
      expect(delivered.single.data['id'], 'BS-1042');
    });

    test('tapped notifications — terminated-launch AND background-resume — '
        'land on the navigation hook seam', () async {
      final push = _FakePushGateway()
        ..initial = const PushMessage(data: {'type': 'chat', 'id': 't-1'});
      final opened = <PushMessage>[];
      final controller = PushController(
        gateway: push,
        users: _FakeUsersSink(),
        onOpened: opened.add,
      );
      addTearDown(controller.dispose);
      addTearDown(push.close);

      await controller.settled; // the queued initial-message delivery
      push.opened.add(const PushMessage(data: {'type': 'order', 'id': 'BS-7'}));
      await pumpEventQueue();

      expect(
        [for (final m in opened) m.data['type']],
        ['chat', 'order'],
        reason: 'initial (terminated) first, then the opened-stream tap',
      );
    });

    testWidgets('DEFAULT foreground path surfaces in the app toast pill',
        (tester) async {
      final push = _FakePushGateway();
      final controller = PushController(gateway: push, users: _FakeUsersSink());
      addTearDown(controller.dispose);
      addTearDown(push.close);

      // The real surface: MaterialApp wired to bsMessengerKey (as main.dart is).
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: bsMessengerKey,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      push.foreground.add(
        const PushMessage(title: 'הזמנה BS-1042', body: 'יצאה למשלוח 🚚'),
      );
      await tester.pump(); // deliver the stream event
      await tester.pump(); // start the SnackBar animation

      expect(find.text('הזמנה BS-1042 · יצאה למשלוח 🚚'), findsOneWidget);

      // Let the toast time out so no timers leak out of the test.
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
