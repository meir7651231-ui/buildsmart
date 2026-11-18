// Nightly 2026-11-18 — settings load gate (continuation of #84).
//
// Before: a toggle that arrived BEFORE the initial load landed
//   • server path: saved `defaults + toggle` over the user's whole settings doc
//     (`notifSettings|chatSettings|storeSettings|appSettings/{uid}`), wiping
//     every stored setting; then the late load snapped the toggle back in the UI.
//   • prefs path: the late load overwrote the toggle in memory, so it was lost.
// After: the early edit is shown immediately, queued, replayed on top of the
// loaded value, and the merge is persisted ONCE after the load.
import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/repositories/app_settings_repository.dart';
import 'package:buildsmart/data/repositories/chat_settings_repository.dart';
import 'package:buildsmart/data/repositories/notif_settings_repository.dart';
import 'package:buildsmart/data/repositories/store_settings_repository.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A server repo whose load is held open until [release] — models the
/// Firestore read still in flight when the user flips a toggle.
class _Gate<S> {
  _Gate(this.stored);
  final S? stored;
  final _c = Completer<void>();
  final saves = <S>[];
  Future<S?> load(String uid) async {
    await _c.future;
    return stored;
  }

  Future<void> save(String uid, S s) async => saves.add(s);
  void release() => _c.complete();
}

class _NotifRepo implements NotifSettingsRepository {
  _NotifRepo(this.g);
  final _Gate<NotifSettings> g;
  @override
  String get currentUid => 'u1';
  @override
  Future<NotifSettings?> load(String uid) => g.load(uid);
  @override
  Future<void> save(String uid, NotifSettings s) => g.save(uid, s);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _ChatRepo implements ChatSettingsRepository {
  _ChatRepo(this.g);
  final _Gate<ChatSettings> g;
  @override
  String get currentUid => 'u1';
  @override
  Future<ChatSettings?> load(String uid) => g.load(uid);
  @override
  Future<void> save(String uid, ChatSettings s) => g.save(uid, s);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StoreRepo implements StoreSettingsRepository {
  _StoreRepo(this.g);
  final _Gate<StoreSettings> g;
  @override
  String get currentUid => 'u1';
  @override
  Future<StoreSettings?> load(String uid) => g.load(uid);
  @override
  Future<void> save(String uid, StoreSettings s) => g.save(uid, s);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _AppRepo implements AppSettingsRepository {
  _AppRepo(this.g);
  final _Gate<AppSettings> g;
  @override
  String get currentUid => 'u1';
  @override
  Future<AppSettings?> load(String uid) => g.load(uid);
  @override
  Future<void> save(String uid, AppSettings s) => g.save(uid, s);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// One notifier under test, expressed generically. `a` is the field the user
/// had STORED (≠ default); `b` is the field toggled before the load lands.
class _Case<S> {
  _Case({
    required this.name,
    required this.prefsKey,
    required this.defaults,
    required this.stored,
    required this.toJson,
    required this.make,
    required this.update,
    required this.reset,
    required this.state,
    required this.toggleB,
    required this.a,
    required this.b,
  });
  final String name;
  final String prefsKey;
  final S defaults;
  final S stored;
  final Map<String, dynamic> Function(S) toJson;
  final Object Function(_Gate<S>? gate) make;
  final void Function(Object n, S Function(S) f) update;
  final Future<void> Function(Object n) reset;
  final S Function(Object n) state;
  final S Function(S) toggleB;
  final bool Function(S) a;
  final bool Function(S) b;
}

Future<void> _flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void _suite<S>(_Case<S> c) {
  group('${c.name} load gate', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'server: toggle before load does not overwrite the stored doc',
      () async {
        final g = _Gate<S>(c.stored);
        final n = c.make(g);
        c.update(n, c.toggleB);
        // Optimistic UI: the toggle is visible immediately …
        expect(c.b(c.state(n)), !c.b(c.defaults));
        // … but nothing is written over the server doc yet.
        expect(g.saves, isEmpty);

        g.release();
        await _flush();

        final s = c.state(n);
        expect(c.a(s), c.a(c.stored), reason: 'stored setting kept');
        expect(c.b(s), !c.b(c.defaults), reason: 'early toggle kept');
        expect(g.saves, hasLength(1));
        expect(c.a(g.saves.single), c.a(c.stored));
        expect(c.b(g.saves.single), !c.b(c.defaults));
      },
    );

    test(
      'server: no edit before load ⇒ no write, loaded value shown',
      () async {
        final g = _Gate<S>(c.stored);
        final n = c.make(g);
        g.release();
        await _flush();
        expect(c.a(c.state(n)), c.a(c.stored));
        expect(g.saves, isEmpty);
      },
    );

    test('server: edit after load persists immediately', () async {
      final g = _Gate<S>(c.stored);
      final n = c.make(g);
      g.release();
      await _flush();
      c.update(n, c.toggleB);
      await _flush();
      expect(g.saves, hasLength(1));
      expect(c.a(g.saves.single), c.a(c.stored));
    });

    test('server: reset before load wins over the late load', () async {
      final g = _Gate<S>(c.stored);
      final n = c.make(g);
      c.update(n, c.toggleB);
      await c.reset(n);
      g.release();
      await _flush();
      expect(c.toJson(c.state(n)), c.toJson(c.defaults));
      expect(g.saves, hasLength(1));
      expect(c.toJson(g.saves.single), c.toJson(c.defaults));
    });

    test('prefs: toggle before load keeps both stored and toggled', () async {
      SharedPreferences.setMockInitialValues({
        c.prefsKey: jsonEncode(c.toJson(c.stored)),
      });
      final n = c.make(null);
      c.update(n, c.toggleB);
      await _flush();
      final s = c.state(n);
      expect(c.a(s), c.a(c.stored));
      expect(c.b(s), !c.b(c.defaults));
      final prefs = await SharedPreferences.getInstance();
      final saved = jsonDecode(prefs.getString(c.prefsKey)!) as Map;
      expect(saved, c.toJson(s));
    });
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  _suite<NotifSettings>(
    _Case(
      name: 'NotifSettings',
      prefsKey: 'bs.notif-settings.v1',
      defaults: NotifSettings.defaults,
      stored: NotifSettings.defaults.copyWith(pushEnabled: false),
      toJson: (s) => s.toJson(),
      make: (g) => NotifSettingsNotifier(g == null ? null : _NotifRepo(g)),
      update: (n, f) => (n as NotifSettingsNotifier).update(f),
      reset: (n) => (n as NotifSettingsNotifier).reset(),
      state: (n) => (n as NotifSettingsNotifier).debugState,
      toggleB: (s) => s.copyWith(emailEnabled: !s.emailEnabled),
      a: (s) => s.pushEnabled,
      b: (s) => s.emailEnabled,
    ),
  );

  _suite<ChatSettings>(
    _Case(
      name: 'ChatSettings',
      prefsKey: 'bs.chat-settings.v1',
      defaults: ChatSettings.defaults,
      stored: ChatSettings.defaults.copyWith(readReceipts: false),
      toJson: (s) => s.toJson(),
      make: (g) => ChatSettingsNotifier(g == null ? null : _ChatRepo(g)),
      update: (n, f) => (n as ChatSettingsNotifier).update(f),
      reset: (n) => (n as ChatSettingsNotifier).reset(),
      state: (n) => (n as ChatSettingsNotifier).debugState,
      toggleB: (s) => s.copyWith(typingIndicator: !s.typingIndicator),
      a: (s) => s.readReceipts,
      b: (s) => s.typingIndicator,
    ),
  );

  _suite<StoreSettings>(
    _Case(
      name: 'StoreSettings',
      prefsKey: 'bs.store-settings.v1',
      defaults: StoreSettings.defaults,
      stored: StoreSettings.defaults.copyWith(vatInclusive: false),
      toJson: (s) => s.toJson(),
      make: (g) => StoreSettingsNotifier(g == null ? null : _StoreRepo(g)),
      update: (n, f) => (n as StoreSettingsNotifier).update(f),
      reset: (n) => (n as StoreSettingsNotifier).reset(),
      state: (n) => (n as StoreSettingsNotifier).debugState,
      toggleB: (s) => s.copyWith(notifDeals: !s.notifDeals),
      a: (s) => s.vatInclusive,
      b: (s) => s.notifDeals,
    ),
  );

  _suite<AppSettings>(
    _Case(
      name: 'AppSettings',
      prefsKey: 'bs.settings.v1',
      defaults: AppSettings.defaults,
      stored: AppSettings.defaults.copyWith(reduceMotion: true),
      toJson: (s) => s.toJson(),
      make: (g) => AppSettingsNotifier(g == null ? null : _AppRepo(g)),
      update: (n, f) => (n as AppSettingsNotifier).update(f),
      reset: (n) => (n as AppSettingsNotifier).reset(),
      state: (n) => (n as AppSettingsNotifier).debugState,
      toggleB: (s) => s.copyWith(express: !s.express),
      a: (s) => s.reduceMotion,
      b: (s) => s.express,
    ),
  );

  test(
    'AppSettings pre-hydrated (seeded) local path persists edits at once',
    () async {
      SharedPreferences.setMockInitialValues({});
      final seeded = AppSettings.defaults.copyWith(reduceMotion: true);
      final n = AppSettingsNotifier(null, seeded);
      n.update((s) => s.copyWith(express: true));
      await _flush();
      final prefs = await SharedPreferences.getInstance();
      final saved = AppSettings.fromJson(
        jsonDecode(prefs.getString('bs.settings.v1')!) as Map<String, dynamic>,
      );
      expect(saved.reduceMotion, isTrue);
      expect(saved.express, isTrue);
    },
  );
}
