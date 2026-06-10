// ─────────────────────────────────────────────────────────────────────────────
// push_state — S6 FCM push (server-connect, client side): token registration
// that FOLLOWS identity, plus foreground/tap message handling.
//
// WHAT LIVES HERE (SPEC-server-connect §S6, MICRO rows S6.1–S6.2):
//   • [PushGateway] — the injectable FirebaseMessaging seam (permission, token,
//     refresh, foreground stream, tap-opened initial/opened messages);
//   • [PushController] — S6.1: on sign-in request permission → fetch the token
//     → write `users/{uid}.fcmToken`; re-write on every token refresh; clear on
//     sign-out (and on account switch, before the next uid registers). S6.2:
//     foreground pushes → the app's toast surface (the Hebrew payload the S8.3
//     Functions send); notification taps → the documented navigation hook;
//   • [pushControllerProvider] — the wiring: gateway + users-writer only when
//     `Firebase.apps.isNotEmpty`, registration only when authStateProvider
//     carries a signed-in uid. Background/terminated messages are NOT here —
//     that is the top-level `firebaseMessagingBackgroundHandler` in main.dart
//     (an isolate entry-point cannot live behind an instance seam).
//
// THE SEAM ([PushGateway]): every FirebaseMessaging touch goes through this
// injectable port, which speaks in a NEUTRAL [PushMessage] (title/body/data) —
// NOT in `RemoteMessage`. That keeps the controller (and its tests)
// Firebase-free: the real adapter ([FirebaseMessagingGateway]) resolves
// `FirebaseMessaging.instance` LAZILY (never at construction — same rule as
// [FirebaseAuthGateway] / [FirestoreCollectionSource]), and a hand-rolled fake
// gateway drives the unit tests with zero new packages. The `users/{uid}`
// write goes through the SAME [RemoteCollectionSource] seam the S2 cache base
// uses, pointed at the `users` collection (knowledge/firestore-schema.md).
//
// HARD RULES (violating any of them breaks the S6 contract):
//   1. NOTHING here may touch `FirebaseMessaging.instance` /
//      `FirebaseFirestore.instance` when Firebase is not initialised — the
//      whole existing suite must stay Firebase-free. The provider switch is
//      the same `Firebase.apps.isNotEmpty` gate authGatewayProvider uses.
//   2. Permission is requested (and a token registered) ONLY for a signed-in
//      uid — never on app start for an anonymous user. Push is additive.
//   3. A push failure (denied permission, no token, rejected write) is logged
//      and swallowed — it must NEVER throw into the UI. Same guarded-write
//      spirit as the S2 cache base.
//   4. Registration work is SERIALISED (one FIFO chain): a sign-out clear can
//      never overtake — or get overtaken by — the registration it follows.
//      The `_uid` re-checks inside each task are the `_loaded`/`_gen`
//      discipline of auth_state.dart adapted to a work queue.
//
// Live delivery is untestable in this sandbox (network blocks Firebase) — the
// fakes pin the logic; device verification (real SMS + real push) is a later,
// on-device step. Comment density/voice intentionally mirrors auth_state.dart.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_messaging/firebase_messaging.dart' as fm;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The collection the token lands in — `users/{uid}.fcmToken` per
/// knowledge/firestore-schema.md (S6.1). Doc-id = the Firebase Auth uid.
const String kPushUsersCollection = 'users';

/// The single field this controller owns inside `users/{uid}`. Written with
/// merge semantics ([RemoteCollectionSource.set] is a merge-set), so the
/// admin-owned `role` / `displayName` fields are never clobbered.
const String kFcmTokenField = 'fcmToken';

/// One push message — the NEUTRAL shape the push seam speaks in (instead of
/// `RemoteMessage`). [title]/[body] are the OS-notification payload (Hebrew,
/// composed server-side by the S8.3 Functions); [data] is the key→value map
/// the deep-nav follow-up will route on (e.g. `{type: 'order', id: 'BS-1042'}`).
@immutable
class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  /// Notification title (null/empty for data-only messages).
  final String? title;

  /// Notification body (null/empty for data-only messages).
  final String? body;

  /// The data payload — routing material for the tap-navigation seam.
  final Map<String, dynamic> data;
}

/// The injectable FirebaseMessaging seam. The controller touches push ONLY
/// through this port, so a hand-rolled fake can drive every unit test and the
/// real impl ([FirebaseMessagingGateway]) stays the only thing that resolves a
/// live `FirebaseMessaging.instance`.
abstract class PushGateway {
  /// Ask the OS for notification permission (iOS/web prompt; Android 13+
  /// runtime prompt; older Android auto-grants). True = authorized or
  /// provisional — a token is worth registering.
  Future<bool> requestPermission();

  /// The device's FCM registration token (null when unavailable — e.g. web
  /// without a VAPID key, iOS before the APNS token lands).
  Future<String?> getToken();

  /// Invalidate the device token (sign-out hygiene: a server-side stale copy
  /// of it can no longer reach this device; the next sign-in mints a new one).
  Future<void> deleteToken();

  /// Fires whenever FCM rotates the token — the controller re-registers it
  /// under the signed-in uid (S6.1 "re-register on refresh").
  Stream<String> onTokenRefresh();

  /// Pushes that arrive while the app is FOREGROUND (the OS shows no tray
  /// notification) — surfaced as in-app toasts (S6.2).
  Stream<PushMessage> onForegroundMessage();

  /// The notification tap that LAUNCHED the app from terminated, if any —
  /// consumed once at startup, then null.
  Future<PushMessage?> initialMessage();

  /// Notification taps that bring the app back from BACKGROUND (not
  /// terminated) — same navigation hook as [initialMessage].
  Stream<PushMessage> onMessageOpenedApp();
}

/// The REAL FirebaseMessaging adapter. Resolves `FirebaseMessaging.instance`
/// LAZILY — never in the constructor — so merely constructing the gateway
/// (e.g. when a provider is read) does NOT require Firebase to be initialised;
/// the instance is only touched on the first call.
class FirebaseMessagingGateway implements PushGateway {
  FirebaseMessagingGateway({fm.FirebaseMessaging? messaging})
      : _injected = messaging;

  /// Optional pre-resolved instance (tests / DI). When null the instance is
  /// resolved lazily from the singleton on first use.
  final fm.FirebaseMessaging? _injected;

  /// Lazily-resolved messaging handle — `FirebaseMessaging.instance` is read
  /// ONLY here, on demand, never at construction (so a Firebase-free app/test
  /// can construct the gateway without initialising Firebase).
  fm.FirebaseMessaging get _messaging =>
      _injected ?? fm.FirebaseMessaging.instance;

  static PushMessage _toPushMessage(fm.RemoteMessage message) => PushMessage(
        title: message.notification?.title,
        body: message.notification?.body,
        data: Map<String, dynamic>.of(message.data),
      );

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == fm.AuthorizationStatus.authorized ||
        settings.authorizationStatus == fm.AuthorizationStatus.provisional;
  }

  /// NOTE (web): web push needs a VAPID key (console → Cloud Messaging → Web
  /// Push certificates) passed as `getToken(vapidKey: …)`. Until that key is
  /// provisioned this throws on web — which the controller's guard logs and
  /// swallows (mobile is unaffected). Follow-up: console task + const here.
  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Future<void> deleteToken() => _messaging.deleteToken();

  @override
  Stream<String> onTokenRefresh() => _messaging.onTokenRefresh;

  // The foreground/opened streams are STATIC on FirebaseMessaging (fed by the
  // platform channel, not the instance) — mapping them here is still lazy:
  // nothing subscribes until the controller does, and the controller only
  // exists wired-to-a-gateway when Firebase is initialised.
  @override
  Stream<PushMessage> onForegroundMessage() =>
      fm.FirebaseMessaging.onMessage.map(_toPushMessage);

  @override
  Future<PushMessage?> initialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toPushMessage(message);
  }

  @override
  Stream<PushMessage> onMessageOpenedApp() =>
      fm.FirebaseMessaging.onMessageOpenedApp.map(_toPushMessage);
}

/// The toast line for a foreground push: `title · body` when both exist,
/// whichever one exists otherwise, and null for a data-only message (nothing
/// human-readable — the controller skips the toast). The payload itself is the
/// Hebrew the S8.3 Functions composed; no client-side copy is invented here.
/// Pure → unit-testable.
String? pushToastText(PushMessage message) {
  final title = message.title?.trim() ?? '';
  final body = message.body?.trim() ?? '';
  if (title.isEmpty && body.isEmpty) return null;
  if (title.isEmpty) return body;
  if (body.isEmpty) return title;
  return '$title · $body';
}

/// The S6 push controller — follows [AuthSnapshot] changes (fed by
/// [pushControllerProvider]) and keeps `users/{uid}.fcmToken` true to the
/// device, while routing foreground/tapped messages to their surfaces.
/// Constructed WITHOUT a gateway (tests, the Firebase-free sandbox) it is
/// completely inert: no subscriptions, no permission prompt, no writes.
class PushController {
  PushController({
    PushGateway? gateway,
    RemoteCollectionSource? users,
    void Function(PushMessage message)? onForeground,
    void Function(PushMessage message)? onOpened,
  })  : _gateway = gateway,
        _users = users,
        _onForeground = onForeground,
        _onOpened = onOpened {
    final g = _gateway;
    if (g == null) return; // Firebase-free — inert, exactly today's app.
    // Message surfaces are wired for the whole controller lifetime (they are
    // identity-independent — FCM only delivers to this device while a token
    // is registered, and registration follows auth below).
    _foregroundSub = g.onForegroundMessage().listen(
          _handleForeground,
          onError: (Object e, StackTrace st) =>
              debugPrint('PushController: foreground stream error: $e'),
        );
    _openedSub = g.onMessageOpenedApp().listen(
          _handleOpened,
          onError: (Object e, StackTrace st) =>
              debugPrint('PushController: opened stream error: $e'),
        );
    _refreshSub = g.onTokenRefresh().listen(
          _handleTokenRefresh,
          onError: (Object e, StackTrace st) =>
              debugPrint('PushController: token refresh stream error: $e'),
        );
    // The tap that LAUNCHED the app (terminated → notification) — queued so
    // it lands in the same guarded, awaitable chain as everything else.
    _enqueue(_deliverInitialMessage);
  }

  final PushGateway? _gateway;

  /// The injectable `users/{uid}` writer (S6.1) — the SAME seam shape the S2
  /// cache base speaks ([RemoteCollectionSource]), pointed at `users`. `set`
  /// is merge-semantics, so only [kFcmTokenField] is touched.
  final RemoteCollectionSource? _users;

  /// S6.2 foreground hook — null = the default: [pushToastText] →
  /// [showGlobalToast] (the app's existing toast pill, context-free via
  /// [bsMessengerKey]). Injected by tests to record deliveries.
  final void Function(PushMessage message)? _onForeground;

  /// THE NAVIGATION SEAM (S6.2 tap-handling): a tapped notification —
  /// terminated-launch ([PushGateway.initialMessage]) or background-resume
  /// ([PushGateway.onMessageOpenedApp]) — lands here with its [PushMessage.data]
  /// routing payload. Actual deep-navigation (order screen / chat thread from
  /// `data['type']`/`data['id']`) is a documented FOLLOW-UP: it needs a
  /// navigator owned by the app shell, so the default below only logs. Wire it
  /// by passing `onOpened` where the controller is created.
  final void Function(PushMessage message)? _onOpened;

  StreamSubscription<PushMessage>? _foregroundSub;
  StreamSubscription<PushMessage>? _openedSub;
  StreamSubscription<String>? _refreshSub;

  /// The uid whose token this device is (being) registered under — null when
  /// signed out. Mutated SYNCHRONOUSLY in [onAuthChanged]; the queued tasks
  /// re-check it before every write (rule #4's staleness discipline).
  String? _uid;

  bool _disposed = false;

  /// The serialised work chain (rule #4): register / clear / refresh tasks run
  /// strictly FIFO, each individually guarded — one failed task is logged and
  /// the chain continues.
  Future<void> _chain = Future<void>.value();

  /// Await all queued push work — the test hook (same spirit as the awaitable
  /// `guardWrite` future in the S2 base).
  @visibleForTesting
  Future<void> get settled => _chain;

  void _enqueue(Future<void> Function() task) {
    if (_disposed) return;
    _chain = _chain.then((_) async {
      try {
        await task();
      } on Object catch (e) {
        // Rule #3 — a push failure is logged and swallowed, never thrown.
        debugPrint('PushController: push task failed (ignored): $e');
      }
    });
  }

  // ── S6.1 — token follows identity ──────────────────────────────────────────

  /// Fed every [AuthSnapshot] by [pushControllerProvider]. Claims-resolution
  /// re-emissions for the SAME uid are idempotent (no re-prompt, no re-write);
  /// an identity CHANGE clears the old uid's token before the new uid
  /// registers (strict FIFO order on the chain).
  void onAuthChanged(AuthSnapshot snapshot) {
    if (_disposed) return;
    final uid = snapshot.user?.uid;
    if (uid == _uid) return; // same identity — nothing moved
    final previous = _uid;
    _uid = uid;
    if (previous != null) _enqueue(() => _unregister(previous));
    if (uid != null) _enqueue(() => _register(uid));
  }

  /// Permission → token → `users/{uid}.fcmToken` (S6.1). Every await is
  /// followed by a `_uid` re-check so a sign-out that happened mid-flight
  /// (the tail of the queue) can never resurrect a registration.
  Future<void> _register(String uid) async {
    final g = _gateway;
    final users = _users;
    if (g == null || users == null) return;
    if (_uid != uid) return; // identity moved on while queued
    final granted = await g.requestPermission();
    if (!granted) {
      // The user said no — honored silently (no token, no nagging retry this
      // session; the next sign-in asks again, which iOS/Android coalesce).
      debugPrint('PushController: notification permission denied — '
          'no token registered');
      return;
    }
    if (_uid != uid) return;
    final token = await g.getToken();
    if (token == null || token.isEmpty) {
      // No token (web without VAPID key / APNS not ready) — a later
      // onTokenRefresh will register it; nothing to write now.
      debugPrint('PushController: no FCM token available — nothing registered');
      return;
    }
    if (_uid != uid) return;
    await users.set(uid, <String, dynamic>{kFcmTokenField: token});
  }

  /// Sign-out / account-switch clear: blank `users/{uid}.fcmToken` so the S8.3
  /// senders stop targeting this device, then invalidate the device token. If
  /// the SAME uid signed back in before this queued task ran, the clear is
  /// skipped — the (re-)registration ahead in the chain stands.
  Future<void> _unregister(String uid) async {
    if (_uid == uid) return; // signed back in — registration stands
    final users = _users;
    if (users != null) {
      try {
        await users.set(uid, <String, dynamic>{kFcmTokenField: ''});
      } on Object catch (e) {
        // Offline sign-out etc. — logged; the token is still invalidated
        // below, so a stale server copy cannot reach this device.
        debugPrint('PushController: token clear write failed (ignored): $e');
      }
    }
    try {
      await _gateway?.deleteToken();
    } on Object catch (e) {
      debugPrint('PushController: deleteToken failed (ignored): $e');
    }
  }

  /// FCM rotated the token — re-register it under the CURRENT uid (resolved
  /// when the queued task runs, not when the event fired). Signed out → drop.
  void _handleTokenRefresh(String token) {
    if (token.isEmpty) return;
    _enqueue(() async {
      final uid = _uid;
      final users = _users;
      if (uid == null || users == null) return; // nobody to bind the token to
      await users.set(uid, <String, dynamic>{kFcmTokenField: token});
    });
  }

  // ── S6.2 — message surfaces ────────────────────────────────────────────────

  /// Foreground push → the app's toast pill with the server-composed Hebrew
  /// payload (data-only messages have nothing to show and are skipped).
  void _handleForeground(PushMessage message) {
    try {
      final hook = _onForeground;
      if (hook != null) {
        hook(message);
        return;
      }
      final text = pushToastText(message);
      if (text == null) return;
      showGlobalToast(text);
    } on Object catch (e) {
      debugPrint('PushController: foreground handler failed (ignored): $e');
    }
  }

  /// Notification tap (terminated-launch or background-resume) → the
  /// navigation seam ([_onOpened]); default logs the routing payload until the
  /// deep-nav follow-up wires a navigator.
  void _handleOpened(PushMessage message) {
    try {
      final hook = _onOpened;
      if (hook != null) {
        hook(message);
        return;
      }
      debugPrint('PushController: notification opened '
          '(deep-nav follow-up): data=${message.data}');
    } on Object catch (e) {
      debugPrint('PushController: opened handler failed (ignored): $e');
    }
  }

  Future<void> _deliverInitialMessage() async {
    final g = _gateway;
    if (g == null) return;
    final initial = await g.initialMessage();
    if (initial != null && !_disposed) _handleOpened(initial);
  }

  void dispose() {
    _disposed = true;
    _foregroundSub?.cancel();
    _foregroundSub = null;
    _openedSub?.cancel();
    _openedSub = null;
    _refreshSub?.cancel();
    _refreshSub = null;
  }
}

/// The push gateway — null when Firebase is not initialised (the entire
/// Firebase-free test suite + this sandbox), so nothing can ever touch
/// `FirebaseMessaging.instance` there. The same `Firebase.apps.isNotEmpty`
/// switch authGatewayProvider / the S2-S3 repo providers use. Tests override
/// this with a hand-rolled fake.
final pushGatewayProvider = Provider<PushGateway?>((ref) {
  if (Firebase.apps.isNotEmpty) return FirebaseMessagingGateway();
  return null;
});

/// The `users/{uid}` token writer (S6.1) — the S2 seam pointed at `users`,
/// null without Firebase. Kept its own provider so tests inject a recording
/// fake and S5 rules work can find the single client write-site of
/// `users.fcmToken`.
final pushTokenWriterProvider = Provider<RemoteCollectionSource?>((ref) {
  if (Firebase.apps.isNotEmpty) {
    return FirestoreCollectionSource(kPushUsersCollection);
  }
  return null;
});

/// S6 wiring — the controller lives for the app's lifetime (woken by the one
/// `ref.watch` in BuildSmartApp) and follows auth: signed-in uid → permission
/// + token registered under `users/{uid}.fcmToken`; refresh → re-write;
/// sign-out → clear. Firebase-free: gateway/writer are null → fully inert,
/// zero regression for the suite and the sandbox.
final pushControllerProvider = Provider<PushController>((ref) {
  final controller = PushController(
    gateway: ref.watch(pushGatewayProvider),
    users: ref.watch(pushTokenWriterProvider),
  );
  // fireImmediately: a RESTORED session (AuthStateNotifier is born seeded from
  // gateway.currentUser) must register without waiting for the next auth event.
  ref
    ..onDispose(controller.dispose)
    ..listen<AuthSnapshot>(
      authStateProvider,
      (_, next) => controller.onAuthChanged(next),
      fireImmediately: true,
    );
  return controller;
});
