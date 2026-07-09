// Drives [FirestoreConfigSink] + the ConfigStore live-merge WITHOUT Firebase —
// a fake [ConfigDocPort] stands in for the `studioConfigLive/current` doc and a
// fake [ConfigSink] for the local cache, so the whole shared-sync path is unit
// tested on the pure config value-objects (the project's Firebase-free rule).
import 'dart:async';

import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_sink_firebase.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the single Firestore doc — records writes/removes and
/// pushes snapshots through a broadcast stream.
class _FakePort implements ConfigDocPort {
  Map<String, dynamic>? doc;
  int writes = 0;
  int removes = 0;
  final _ctrl = StreamController<Map<String, dynamic>?>.broadcast();

  @override
  Future<Map<String, dynamic>?> read() async => doc;

  @override
  Future<void> write(Map<String, dynamic> data) async {
    doc = data;
    writes++;
    _ctrl.add(data);
  }

  @override
  Future<void> remove() async {
    doc = null;
    removes++;
    _ctrl.add(null);
  }

  @override
  Stream<Map<String, dynamic>?> snapshots() => _ctrl.stream;

  /// Simulate a remote snapshot from ANOTHER device (bypasses this port's write).
  void emit(Map<String, dynamic>? data) => _ctrl.add(data);

  Future<void> close() => _ctrl.close();
}

/// In-memory local cache sink (no SharedPreferences needed).
class _MemSink implements ConfigSink {
  ConfigDoc? saved;
  @override
  Future<void> save(ConfigDoc doc) async => saved = doc;
  @override
  Future<ConfigDoc?> load() async => saved;
  @override
  Stream<ConfigDoc>? watch() => null;
}

ConfigLayer _pub(String id, String text) =>
    ConfigLayer(global: {id: CfgNode(text: text)});

void main() {
  group('FirestoreConfigSink.save', () {
    test('writes the published layer to the remote doc (draft stripped)',
        () async {
      final port = _FakePort();
      addTearDown(port.close);
      final sink = FirestoreConfigSink(port, cache: _MemSink());

      await sink.save(ConfigDoc(published: _pub('a', 'X'), draft: _pub('d', 'w')));

      expect(port.writes, 1);
      final back = ConfigDoc.fromJson(port.doc!);
      expect(back.published.global['a']?.text, 'X');
      expect(back.draft.isEmpty, isTrue, reason: 'draft is per-device, not shared');
    });

    test('a DRAFT-only change does NOT write to the remote', () async {
      final port = _FakePort();
      addTearDown(port.close);
      final cache = _MemSink();
      final sink = FirestoreConfigSink(port, cache: cache);
      final published = _pub('a', 'X');

      await sink.save(ConfigDoc(published: published)); // publish
      expect(port.writes, 1);
      await sink.save(ConfigDoc(published: published, draft: _pub('b', 'wip')));
      expect(port.writes, 1, reason: 'published unchanged → no second write');
      expect(cache.saved?.draft.global['b']?.text, 'wip',
          reason: 'the local cache still mirrors the draft');
    });

    test('a first DRAFT keystroke (never published) never touches the remote',
        () async {
      final port = _FakePort();
      addTearDown(port.close);
      final sink = FirestoreConfigSink(port, cache: _MemSink());

      await sink.save(ConfigDoc(draft: _pub('b', 'wip'))); // published still empty

      expect(port.writes, 0);
      expect(port.removes, 0, reason: 'must not delete another device\'s live doc');
    });

    test('an empty published layer after a publish REMOVES the remote doc',
        () async {
      final port = _FakePort();
      addTearDown(port.close);
      final sink = FirestoreConfigSink(port, cache: _MemSink());

      await sink.save(ConfigDoc(published: _pub('a', 'X'))); // publish
      await sink.save(const ConfigDoc()); // reset-to-baseline

      expect(port.removes, 1);
      expect(port.doc, isNull);
    });
  });

  group('FirestoreConfigSink.load', () {
    test('overlays the LOCAL draft onto the REMOTE published', () async {
      final port = _FakePort()
        ..doc = ConfigDoc(published: _pub('a', 'REMOTE')).toJson();
      addTearDown(port.close);
      final cache = _MemSink()..saved = ConfigDoc(draft: _pub('b', 'LOCALWIP'));
      final sink = FirestoreConfigSink(port, cache: cache);

      final loaded = await sink.load();

      expect(loaded!.published.global['a']?.text, 'REMOTE');
      expect(loaded.draft.global['b']?.text, 'LOCALWIP');
    });

    test('falls back to the local cache when the remote doc is absent',
        () async {
      final port = _FakePort(); // doc == null
      addTearDown(port.close);
      final cache = _MemSink()..saved = ConfigDoc(published: _pub('a', 'LOCAL'));
      final sink = FirestoreConfigSink(port, cache: cache);

      final loaded = await sink.load();

      expect(loaded!.published.global['a']?.text, 'LOCAL');
    });
  });

  group('FirestoreConfigSink.watch', () {
    test('maps snapshots to ConfigDoc (null → empty)', () async {
      final port = _FakePort();
      addTearDown(port.close);
      final sink = FirestoreConfigSink(port, cache: _MemSink());
      final seen = <ConfigDoc>[];
      final sub = sink.watch()!.listen(seen.add);
      addTearDown(sub.cancel);

      port.emit(ConfigDoc(published: _pub('a', 'PUSHED')).toJson());
      port.emit(null);
      await Future<void>.delayed(Duration.zero);

      expect(seen.first.published.global['a']?.text, 'PUSHED');
      expect(seen.last, ConfigDoc.empty);
    });
  });

  group('ConfigStore ← remote watch (live-for-everyone merge)', () {
    test('a remote publish updates published but PRESERVES the local draft',
        () async {
      final port = _FakePort();
      addTearDown(port.close);
      final store = ConfigStore(FirestoreConfigSink(port, cache: _MemSink()));
      addTearDown(store.dispose);
      await Future<void>.delayed(Duration.zero); // let _load settle

      store.applyOps([SetText('x', 'draftText')]); // owner's local WIP
      expect(store.state.draft.global['x']?.text, 'draftText');

      port.emit(ConfigDoc(published: _pub('y', 'remotePub')).toJson());
      await Future<void>.delayed(Duration.zero);

      expect(store.state.published.global['y']?.text, 'remotePub',
          reason: 'the shared publish is adopted');
      expect(store.state.draft.global['x']?.text, 'draftText',
          reason: 'the per-device draft survives a remote publish');
    });
  });
}
