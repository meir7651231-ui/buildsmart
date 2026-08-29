// #8/3b — the CLIENT directory reader: the DirectoryEntry model + parser (pure)
// and the directoryProvider filtering (self-exclusion, empty-name drop, the
// byte-identical-when-off empty). The server doc shape is
// `directory/{uid} = {role, displayName, status, updatedAt}` (doc-id = uid).
// The Firestore path itself is Firebase-only; here a fake RemoteCollectionSource
// drives the provider, the same seam the existing directory tests use.

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/directory.dart';
import 'package:buildsmart/state/sys_chat.dart' show BsRole;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fixed-doc source (mirrors the `_FakeSource` in
/// directory_unblocks_chat_test.dart) so the provider can be driven with no
/// Firebase. A single [Stream.value] snapshot is all a directory read needs.
class _FakeSource implements RemoteCollectionSource {
  _FakeSource(this.docs);

  final List<RemoteDoc> docs;

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(docs);

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;
}

RemoteDoc _doc(String id, Map<String, dynamic> data) => RemoteDoc(id, data);

void main() {
  group('#8/3b parseBsRole', () {
    test('every non-bot role resolves from its name', () {
      expect(parseBsRole('contractor'), BsRole.contractor);
      expect(parseBsRole('store'), BsRole.store);
      expect(parseBsRole('courier'), BsRole.courier);
      expect(parseBsRole('worker'), BsRole.worker);
      expect(parseBsRole('manager'), BsRole.manager);
    });

    test('bot / unknown / non-string / null all resolve to null', () {
      // The bot is the system, never a directory row — it must not surface as a
      // person even if a stray value said so.
      expect(parseBsRole('bot'), isNull);
      expect(parseBsRole('admin'), isNull); // not a BsRole
      expect(parseBsRole(''), isNull);
      expect(parseBsRole(42), isNull);
      expect(parseBsRole(null), isNull);
    });
  });

  group('#8/3b DirectoryEntry.fromDoc', () {
    test('parses uid (=doc id) + displayName + role + status', () {
      final e = DirectoryEntry.fromDoc(_doc('uid-a', {
        'displayName': 'אבי',
        'role': 'store',
        'status': 'online',
        'updatedAt': 123, // ignored
      }));
      expect(e.uid, 'uid-a');
      expect(e.displayName, 'אבי');
      expect(e.role, BsRole.store);
      expect(e.status, 'online');
    });

    test('tolerant: missing/odd fields degrade, never throw', () {
      final e = DirectoryEntry.fromDoc(_doc('uid-b', {'role': 'nonsense'}));
      expect(e.uid, 'uid-b');
      expect(e.displayName, ''); // absent → '' (dropped by the provider)
      expect(e.role, isNull); // unknown role → null (display-neutral)
      expect(e.status, ''); // absent → ''

      // Non-String displayName/status coerce to '' rather than crashing.
      final e2 = DirectoryEntry.fromDoc(_doc('uid-c', {
        'displayName': 7,
        'status': false,
      }));
      expect(e2.displayName, '');
      expect(e2.status, '');
    });
  });

  group('#8/3b directoryProvider', () {
    Future<List<DirectoryEntry>> read(ProviderContainer c) =>
        c.read(directoryProvider.future);

    test('maps docs, EXCLUDES self, DROPS empty-name rows', () async {
      final c = ProviderContainer(overrides: [
        currentUidProvider.overrideWithValue('me'),
        directorySourceProvider.overrideWithValue(_FakeSource([
          _doc('me', {'displayName': 'אני', 'role': 'contractor'}),
          _doc('uid-a', {'displayName': 'אבי', 'role': 'store'}),
          _doc('uid-b', {'displayName': '', 'role': 'courier'}), // no name
          _doc('uid-c', {'displayName': 'גדי', 'role': 'worker'}),
        ])),
      ]);
      addTearDown(c.dispose);

      final entries = await read(c);
      expect(entries.map((e) => e.uid), ['uid-a', 'uid-c'],
          reason: 'self excluded, the empty-name row dropped');
      expect(entries.first.displayName, 'אבי');
      expect(entries.first.role, BsRole.store);
    });

    test('null current uid → nobody is excluded (still drops empty names)',
        () async {
      final c = ProviderContainer(overrides: [
        currentUidProvider.overrideWithValue(null),
        directorySourceProvider.overrideWithValue(_FakeSource([
          _doc('uid-a', {'displayName': 'אבי', 'role': 'store'}),
          _doc('uid-b', {'displayName': 'בני', 'role': 'courier'}),
        ])),
      ]);
      addTearDown(c.dispose);
      expect((await read(c)).map((e) => e.uid), ['uid-a', 'uid-b']);
    });

    test('OFF (no source override) → empty list, byte-identical when off',
        () async {
      // useFirebaseBackend is false Firebase-free, so directorySourceProvider is
      // null and the provider yields a single empty emission — the picker keeps
      // its hardcoded fallback and nothing ever touches Firestore.
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(await read(c), isEmpty);
    });
  });
}
