// The four settings-blob local→server migrations (app/catalog/chat/store), out of
// the Preact-freeze. Each mirrors notif_settings: pins (1) DORMANT OFF
// (kUserDataServer const-false ⇒ provider null ⇒ SharedPreferences path,
// byte-identical), and (2) the repo round-trips defaults through save→load
// (toJson lossless, the `updatedAt` stamp ignored on the way back).
import 'package:buildsmart/data/repositories/app_settings_repository.dart';
import 'package:buildsmart/data/repositories/catalog_settings_repository.dart';
import 'package:buildsmart/data/repositories/chat_settings_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/store_settings_repository.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};
  @override
  Stream<List<RemoteDoc>> snapshots() =>
      Stream.value([for (final e in docs.entries) RemoteDoc(e.key, e.value)]);
  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      docs[id] = {...?docs[id], ...data};
  @override
  Future<void> delete(String id) async => docs.remove(id);
  @override
  bool get isScoped => true;
}

void main() {
  group('#settings OFF (const-false) ⇒ every repo provider is null', () {
    test('app/catalog/chat/store settings repos are null OFF', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(appSettingsRepositoryProvider), isNull);
      expect(c.read(catalogSettingsRepositoryProvider), isNull);
      expect(c.read(chatSettingsRepositoryProvider), isNull);
      expect(c.read(storeSettingsRepositoryProvider), isNull);
    });
  });

  group('#settings repo round-trips defaults (save→load, lossless)', () {
    test('appSettings', () async {
      final r = AppSettingsRepository(_FakeSource(), currentUid: 'u');
      await r.save('u', AppSettings.defaults);
      final back = await r.load('u');
      expect(back, isNotNull);
      expect(back!.toJson(), AppSettings.defaults.toJson());
    });
    test('catalogSettings', () async {
      final r = CatalogSettingsRepository(_FakeSource(), currentUid: 'u');
      await r.save('u', CatalogSettings.defaults);
      final back = await r.load('u');
      expect(back, isNotNull);
      expect(back!.toJson(), CatalogSettings.defaults.toJson());
    });
    test('chatSettings', () async {
      final r = ChatSettingsRepository(_FakeSource(), currentUid: 'u');
      await r.save('u', ChatSettings.defaults);
      final back = await r.load('u');
      expect(back, isNotNull);
      expect(back!.toJson(), ChatSettings.defaults.toJson());
    });
    test('storeSettings', () async {
      final r = StoreSettingsRepository(_FakeSource(), currentUid: 'u');
      await r.save('u', StoreSettings.defaults);
      final back = await r.load('u');
      expect(back, isNotNull);
      expect(back!.toJson(), StoreSettings.defaults.toJson());
    });

    test('load returns null when the doc is absent (keeps defaults)', () async {
      final r = AppSettingsRepository(_FakeSource(), currentUid: 'u');
      expect(await r.load('u'), isNull);
    });
  });
}
