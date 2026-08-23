// #user-data — the notification-settings local→server migration (→
// notifSettings/{uid}). Unblocked after Preact retired (notif left the שער-25
// freeze). Two things pinned: (1) the repo is null when the flag/backend is off
// (the provider yields null → SharedPreferences path), and (2) the
// NotifSettingsRepository round-trips a settings blob through the neutral
// RemoteCollectionSource seam. Firebase-free — a hand-rolled fake source drives
// it, exactly like the carts/users suites (no fake_cloud_firestore).
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/notif_settings_repository.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [RemoteCollectionSource] that actually STORES what `set` writes
/// and re-emits it from `snapshots()` — so a save→load round-trips (same fake
/// shape as the carts suite; the settings repo also writes, so it must persist).
class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(
        [for (final e in docs.entries) RemoteDoc(e.key, e.value)],
      );

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    docs[id] = {...?docs[id], ...data}; // merge:true contract
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true; // scoped to the uid (documentId ==)
}

void main() {
  group('#user-data notif-settings migration — provider gating', () {
    test(
        'notifSettingsRepositoryProvider is null with no backend (flutter test '
        'env: no dart-defines) → the settings stay on SharedPreferences', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(notifSettingsRepositoryProvider), isNull);
    });
  });

  group('#user-data NotifSettingsRepository round-trip (notifSettings/{uid})', () {
    test('save writes {…toJson, updatedAt}; load decodes the settings back',
        () async {
      final src = _FakeSource();
      final repo = NotifSettingsRepository(src, currentUid: 'u1');

      // A blob that differs from the defaults across several field TYPES (bool,
      // int, enum) so the round-trip proves each survives the seam.
      final settings = NotifSettings.defaults.copyWith(
        pushEnabled: false,
        quietStartHour: 23,
        importanceFilter: NotifImportance.critical,
        lockScreen: NotifLockScreen.hidden,
        weeklySummary: true,
      );

      await repo.save('u1', settings);
      expect(src.docs['u1']!['pushEnabled'], false);
      expect(src.docs['u1']!.containsKey('updatedAt'), isTrue);

      final back = await repo.load('u1');
      expect(back, isNotNull);
      expect(back!.pushEnabled, false);
      expect(back.quietStartHour, 23);
      expect(back.importanceFilter, NotifImportance.critical);
      expect(back.lockScreen, NotifLockScreen.hidden);
      expect(back.weeklySummary, true);
      // A default-valued field still survives untouched.
      expect(back.emailEnabled, true);
    });

    test('load with no doc ⇒ null (caller keeps NotifSettings.defaults)',
        () async {
      final repo = NotifSettingsRepository(_FakeSource(), currentUid: 'u1');
      expect(await repo.load('u1'), isNull);
    });
  });
}
