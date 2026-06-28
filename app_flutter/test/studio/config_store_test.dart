// Pins the config store (#studio · Pillar 1 · step 6): the op-based draft API,
// undo/redo (exact round-trip, batch = one step), publish (prune + version),
// discard, forward-only rollback, JSON round-trip — all against a fake ConfigSink
// (no SharedPreferences). editDraft is exercised only via applyOps (it's internal).
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSink implements ConfigSink {
  ConfigDoc? saved;
  int saves = 0;
  @override
  Future<void> save(ConfigDoc doc) async {
    saved = doc;
    saves++;
  }

  @override
  Future<ConfigDoc?> load() async => null;
  @override
  Stream<ConfigDoc>? watch() => null;
}

void main() {
  ConfigStore store() => ConfigStore(_FakeSink());

  group('applyOps + undo/redo', () {
    test('applyOps writes the draft; undo reverts; redo restores (exact)', () {
      final s = store();
      s.applyOps([const SetText('cta', 'הזמן עכשיו')]);
      expect(s.state.draft.global['cta']!.text, 'הזמן עכשיו');

      s.undo();
      expect(s.state.draft.global['cta'], isNull); // back to empty
      expect(s.canRedo, isTrue);

      s.redo();
      expect(s.state.draft.global['cta']!.text, 'הזמן עכשיו'); // exact restore
    });

    test('a batch applyOps is a SINGLE undo step', () {
      final s = store();
      s.applyOps([const SetText('a', 'x'), const SetHidden('b', true)]);
      expect(s.state.draft.global.length, 2);
      s.undo(); // one undo clears the whole batch
      expect(s.state.draft.global, isEmpty);
    });

    test('a new applyOps clears the redo stack', () {
      final s = store();
      s.applyOps([const SetText('a', '1')]);
      s.undo();
      expect(s.canRedo, isTrue);
      s.applyOps([const SetText('a', '2')]);
      expect(s.canRedo, isFalse); // redo invalidated by a fresh edit
    });
  });

  group('publish', () {
    test('promotes draft→published, clears draft, appends a version', () {
      final s = store();
      s.applyOps([const SetText('cta', 'live')]);
      s.publish(byEmail: 'meir@x.com', note: 'v1', nowMs: 100);

      expect(s.state.published.global['cta']!.text, 'live');
      expect(s.state.draft.isEmpty, isTrue);
      expect(s.state.history.length, 1);
      expect(s.state.history.first.byEmail, 'meir@x.com');
      // every published node is non-empty (prune invariant)
      expect(
        s.state.published.global.values.every((n) => !n.isEmpty),
        isTrue,
      );
    });

    test('a draft restyle field-merges onto the published node', () {
      final s = store();
      s.applyOps([const SetStyle('h', CfgStyle(colorToken: 'brand'))]);
      s.publish(nowMs: 1);
      s.applyOps([const SetStyle('h', CfgStyle(fontScale: 1.4))]);
      s.publish(nowMs: 2);
      final st = s.state.published.global['h']!.style!;
      expect(st.fontScale, 1.4); // new
      expect(st.colorToken, 'brand'); // preserved (field-merge)
    });
  });

  group('discard + rollback', () {
    test('discardDraft drops edits, leaves published live', () {
      final s = store();
      s.applyOps([const SetText('cta', 'pub')]);
      s.publish(nowMs: 1);
      s.applyOps([const SetText('cta', 'wip')]);
      s.discardDraft();
      expect(s.state.draft.isEmpty, isTrue);
      expect(s.state.published.global['cta']!.text, 'pub'); // still live
    });

    test('rollback re-publishes an old snapshot as a NEW forward version', () {
      final s = store();
      s.applyOps([const SetText('cta', 'one')]);
      s.publish(nowMs: 10);
      final v1 = s.state.history.first.id;
      s.applyOps([const SetText('cta', 'two')]);
      s.publish(nowMs: 20);
      expect(s.state.published.global['cta']!.text, 'two');

      final ok = s.rollback(v1, nowMs: 30);
      expect(ok, isTrue);
      expect(s.state.published.global['cta']!.text, 'one'); // restored
      expect(s.state.history.length, 3); // forward-only: history GREW
      expect(s.rollback(999999, nowMs: 40), isFalse); // unknown id
    });
  });

  group('persistence + round-trip', () {
    test('every mutation reaches the sink', () {
      final sink = _FakeSink();
      final s = ConfigStore(sink);
      s.applyOps([const SetText('a', 'x')]);
      s.publish(nowMs: 1);
      expect(sink.saves, greaterThanOrEqualTo(2));
      expect(sink.saved!.published.global['a']!.text, 'x');
    });

    test('the resulting doc round-trips through JSON', () {
      final s = store();
      s.applyOps([
        const SetText('cta', 'live'),
        const SetHidden('tab', true),
      ]);
      s.publish(nowMs: 7);
      expect(ConfigDoc.fromJson(s.state.toJson()), s.state);
    });
  });
}
