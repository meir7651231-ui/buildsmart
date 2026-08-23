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
//   • F5 — [LocalNotificationsGateway] (flutter_local_notifications): the
//     Android side that creates the importance-high notification CHANNELS
//     ([kPushChannels]) at init, asks for the Android-13 POST_NOTIFICATIONS
//     runtime permission, and RE-SHOWS a FOREGROUND message as an OS
//     notification (Android draws no tray notification for foreground
//     messages). Same gate + same swallow-don't-throw discipline; null on the
//     demo / no-Firebase path → the F5 additions are completely inert there.
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

import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/push_routing.dart'
    show pendingPushThreadProvider, threadIdFrom;
import 'package:buildsmart/widgets/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fm;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The collection the token lands in — `users/{uid}.fcmToken` per
/// knowledge/firestore-schema.md (S6.1). Doc-id = the Firebase Auth uid.
const String kPushUsersCollection = 'users';

/// The single field this controller owns inside `users/{uid}`. Written with
/// merge semantics ([RemoteCollectionSource.set] is a merge-set), so the
/// admin-owned `role` / `displayName` fields are never clobbered.
const String kFcmTokenField = 'fcmToken';

// ── F5 — Android notification channels ──────────────────────────────────────
//
// Android 8+ (API 26+) drops any notification whose channel does not exist, so
// the channels below are CREATED at init (importance-high → heads-up) and the
// ids are the single source of truth shared with the native side. The "general"
// id MUST stay byte-identical to `default_notification_channel_id` in
// android/app/src/main/res/values/strings.xml (the FCM fallback channel the
// manifest meta-data points at). orders/chat let the user mute one stream
// without losing the others, and match the `data['type']` the S8.3 senders set.

/// The fallback / general channel id — MUST equal the manifest's
/// `@string/default_notification_channel_id` (`bs_general`).
const String kDefaultPushChannelId = 'bs_general';

/// Order lifecycle pushes (`data['type'] == 'order'`) — "הזמנות".
const String kOrdersPushChannelId = 'bs_orders';

/// Chat / message pushes (`data['type'] == 'chat'`) — "צ׳אט".
const String kChatPushChannelId = 'bs_chat';

/// A single Android notification-channel definition — PURE data (no plugin
/// type), so the channel set is unit-testable headless. The real
/// [LocalNotificationsGateway] adapter maps each of these to an
/// `AndroidNotificationChannel`. Names/descriptions are the Hebrew the user sees
/// in Android Settings → Notifications.
@immutable
class PushChannel {
  const PushChannel({
    required this.id,
    required this.name,
    required this.description,
  });

  /// The stable channel id (also written into a payload's android channel).
  final String id;

  /// User-visible channel name (Android Settings → App → Notifications).
  final String name;

  /// User-visible channel description.
  final String description;
}

/// The channels this app creates at init. Order matters only for the Settings
/// list; `kPushChannels.first` is the general/default one.
const List<PushChannel> kPushChannels = <PushChannel>[
  PushChannel(
    id: kDefaultPushChannelId,
    name: 'כללי',
    description: 'התראות כלליות מ-${AppBrand.name}',
  ),
  PushChannel(
    id: kOrdersPushChannelId,
    name: 'הזמנות',
    description: 'עדכוני סטטוס הזמנות ומשלוחים',
  ),
  PushChannel(
    id: kChatPushChannelId,
    name: 'הודעות',
    description: 'הודעות צ׳אט חדשות',
  ),
];

/// Route a foreground [PushMessage] to the channel it should display on, from
/// its `data['type']` (the key the S8.3 Functions stamp). Unknown / missing →
/// the general channel. PURE → unit-testable, and the single place the
/// type→channel mapping lives.
String pushChannelIdFor(PushMessage message) {
  switch (message.data['type']) {
    case 'order':
      return kOrdersPushChannelId;
    case 'chat':
      return kChatPushChannelId;
    default:
      return kDefaultPushChannelId;
  }
}

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

  /// The browser's half of the push handshake, now provisioned.
  ///
  /// Web push is the only platform that needs an application key here: the
  /// browser's own push service (FCM's endpoint for Chrome, Mozilla's for
  /// Firefox) will not mint a subscription without one. Without it `getToken()`
  /// THREW on web, the controller's guard logged and swallowed it, and the
  /// result was the quietest possible failure — the site never registered a
  /// token, `users/{uid}.fcmToken` stayed empty, `sendToUsers` skipped the
  /// recipient as "no token", and nobody on the website ever received a
  /// notification. Mobile was unaffected the whole time, which is exactly why
  /// this could sit unnoticed.
  ///
  /// PUBLIC BY DESIGN — this is the public half of the VAPID key pair and is
  /// handed to every browser that subscribes, so it belongs in the bundle
  /// alongside `firebase_options.dart`'s apiKey and projectId. The PRIVATE half
  /// never leaves the Firebase console. Rotating the pair there invalidates
  /// existing subscriptions, so this constant is replaced, not edited.
  ///
  /// Ignored on Android/iOS, where the platform SDK owns the handshake — hence
  /// one unconditional call rather than a platform branch.
  static const String _vapidPublicKey =
      'BN1BNeE3qvsGIocClUkDinZGOpeylpsjVJZ-Kt8a6HeRXfjW73rT340wPlTycLJXz0oqyrexTVPSB_lN9n2OSCA';

  @override
  Future<String?> getToken() => _messaging.getToken(vapidKey: _vapidPublicKey);

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

// ── F5 — the local-notifications seam ────────────────────────────────────────
//
// FCM on Android shows a tray notification only when the app is
// background/terminated; a FOREGROUND message is delivered silently to
// onMessage, so to surface it as an OS notification (on the right channel) the
// app must re-show it itself. flutter_local_notifications is the plugin for
// that AND for creating the channels + the Android-13 runtime permission. As
// with [PushGateway], every plugin touch goes through THIS injectable port so
// the controller (and its tests) stay plugin-free and Firebase-free.

/// The injectable local-notifications seam (channel creation, Android-13
/// permission, foreground display). The real adapter
/// ([FlutterLocalNotificationsGateway]) wraps the plugin LAZILY; tests use a
/// hand-rolled fake; the default (Firebase-free) is null → nothing constructed.
abstract class LocalNotificationsGateway {
  /// One-time init: initialise the plugin and create [kPushChannels] (Android
  /// 8+). Idempotent — safe to call on every registration.
  Future<void> ensureInitialised();

  /// Android 13+ (API 33+) runtime notification permission via the plugin's
  /// Android impl. Returns true when granted / not-applicable (older Android,
  /// iOS, web — where firebase_messaging already owns the prompt). The
  /// firebase_messaging `requestPermission()` ALSO triggers the Android-13
  /// prompt; this is the belt-and-braces plugin path (a no-op once granted).
  Future<bool> requestAndroid13Permission();

  /// Show [message] as an OS notification on [channelId] (foreground re-display).
  Future<void> show(PushMessage message, {required String channelId});
}

/// The REAL flutter_local_notifications adapter. Resolves the plugin LAZILY
/// (never at construction — same rule as [FirebaseMessagingGateway]) and is
/// Android-focused: channel creation + the Android-13 permission are no-ops on
/// other platforms (iOS/web notification permission is firebase_messaging's
/// job). Every call is individually guarded by the caller (rule #3) — a plugin
/// failure is logged and swallowed, never thrown into the UI.
class FlutterLocalNotificationsGateway implements LocalNotificationsGateway {
  FlutterLocalNotificationsGateway({FlutterLocalNotificationsPlugin? plugin})
      : _injected = plugin;

  final FlutterLocalNotificationsPlugin? _injected;

  /// Lazily-resolved plugin handle — constructed ONLY on first use so merely
  /// reading the provider does not spin up the platform plugin.
  late final FlutterLocalNotificationsPlugin _plugin =
      _injected ?? FlutterLocalNotificationsPlugin();

  bool _initialised = false;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> ensureInitialised() async {
    if (_initialised) return;
    // The small icon is the white silhouette `@drawable/ic_notification`
    // (defined in res/drawable) — referenced by NAME without the extension.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    );
    await _plugin.initialize(initSettings);
    final android = _android;
    if (android != null) {
      for (final c in kPushChannels) {
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            c.id,
            c.name,
            description: c.description,
            importance: Importance.high,
          ),
        );
      }
    }
    _initialised = true;
  }

  @override
  Future<bool> requestAndroid13Permission() async {
    final android = _android;
    if (android == null) return true; // not Android — nothing to ask here
    final granted = await android.requestNotificationsPermission();
    return granted ?? true; // null = older Android (auto-granted)
  }

  @override
  Future<void> show(PushMessage message, {required String channelId}) async {
    final channel = kPushChannels.firstWhere(
      (c) => c.id == channelId,
      orElse: () => kPushChannels.first,
    );
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
      ),
    );
    // A stable-enough id per message (notification-replacing is a follow-up):
    // the time-derived id keeps each foreground push distinct.
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _plugin.show(id, message.title, message.body, details);
  }
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
    LocalNotificationsGateway? localNotifications,
    void Function(PushMessage message)? onForeground,
    void Function(PushMessage message)? onOpened,
  })  : _gateway = gateway,
        _users = users,
        _local = localNotifications,
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

  /// F5 — the injectable local-notifications seam (channel creation, Android-13
  /// permission, foreground OS display). Null without Firebase / on the demo
  /// path → the F5 additions are completely inert (no channels created, no
  /// extra permission prompt, no OS notification). Independent of [_gateway]:
  /// the FCM token still registers even if this is null.
  final LocalNotificationsGateway? _local;

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
    // F5 — make sure the Android channels exist BEFORE a token is registered, so
    // any push that arrives can land on a real channel (Android 8+ drops one
    // whose channel is missing). Guarded + gated: a null local gateway (demo /
    // no-Firebase) skips this entirely, and a plugin failure is logged, not
    // thrown (rule #3) — channel-setup must never block token registration.
    final local = _local;
    if (local != null) {
      try {
        await local.ensureInitialised();
      } on Object catch (e) {
        debugPrint('PushController: channel init failed (ignored): $e');
      }
    }
    final granted = await g.requestPermission();
    if (!granted) {
      // The user said no — honored silently (no token, no nagging retry this
      // session; the next sign-in asks again, which iOS/Android coalesce).
      debugPrint('PushController: notification permission denied — '
          'no token registered');
      return;
    }
    // F5 — belt-and-braces Android-13 (API 33+) runtime prompt via the local
    // plugin. firebase_messaging.requestPermission() already triggers it, so on
    // a granted device this is a no-op; it is here so the plugin path is honest
    // when only the local seam is wired. Guarded + gated.
    if (_uid != uid) return;
    if (local != null) {
      try {
        await local.requestAndroid13Permission();
      } on Object catch (e) {
        debugPrint('PushController: android-13 permission failed (ignored): $e');
      }
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
      if (text == null) return; // data-only — nothing human-readable to surface
      // The in-app toast pill (the existing surface — also the web/iOS path).
      showGlobalToast(text);
      // F5 (additive, Android) — ALSO raise an OS notification on the routed
      // channel, since Android shows no tray notification for a foreground
      // message. Gated (null on demo/no-Firebase) + guarded (rule #3): a plugin
      // failure is swallowed, the toast above already surfaced the message.
      final local = _local;
      if (local != null) {
        _enqueue(
          () => local.show(message, channelId: pushChannelIdFor(message)),
        );
      }
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
  if (useFirebaseBackend) return FirebaseMessagingGateway();
  return null;
});

/// F5 — the local-notifications gateway (Android channels + foreground OS
/// display + the Android-13 prompt). Null unless the live Firebase backend is
/// up (the SAME `useFirebaseBackend` gate every seam uses), so the whole
/// Firebase-free suite + the demo build never construct the plugin → the F5
/// additions are byte-identically inert there. Tests override with a fake.
final localNotificationsGatewayProvider =
    Provider<LocalNotificationsGateway?>((ref) {
  // Web has no Android channels / runtime notification permission and FCM-web
  // owns its own surface, so the local plugin is mobile-only here (it would be a
  // no-op on web anyway). The gate keeps it off for the demo/no-Firebase path.
  if (useFirebaseBackend && !kIsWeb) return FlutterLocalNotificationsGateway();
  return null;
});

/// The `users/{uid}` token writer (S6.1) — the S2 seam pointed at `users`,
/// null without Firebase. Kept its own provider so tests inject a recording
/// fake and S5 rules work can find the single client write-site of
/// `users.fcmToken`.
final pushTokenWriterProvider = Provider<RemoteCollectionSource?>((ref) {
  if (useFirebaseBackend) {
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
    localNotifications: ref.watch(localNotificationsGatewayProvider),
    // THE TAP FINALLY GOES SOMEWHERE. `_onOpened` was built as a seam and left
    // unwired — its own doc calls deep-navigation "a documented FOLLOW-UP" — so
    // the payload arrived carrying its threadId and the app opened wherever it
    // had been. A notification that names a person and quotes their message and
    // then drops you on the catalog is a broken promise, not a feature.
    //
    // The id is PARKED rather than acted on: `ChatsScreen` may not exist yet
    // (cold launch), and it opens conversations off a `ref.listen` that does not
    // fire for a value set before it started listening. Parking, plus the
    // read-on-arrival in that screen, is what covers both orders. See
    // push_routing.dart.
    onOpened: (message) {
      final threadId = threadIdFrom(message.data);
      if (threadId == null) return; // an order push is not a conversation
      ref.read(pendingPushThreadProvider.notifier).state = threadId;
    },
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
