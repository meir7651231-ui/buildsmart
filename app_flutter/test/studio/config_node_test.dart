// Pins the Studio config value-objects (#studio · Pillar 1 · step 1). The whole
// No-Code tree is built from these, so the load-bearing invariants are: sparse
// JSON (all-null ⇒ {}), tolerant decode (unknown keys survive in `extra`, unknown
// enum-names fall back, never throws), and a faithful round-trip. Pure — no pump.
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CfgNode — sparse JSON + identity', () {
    test('the all-null node IS the identity and serialises to {}', () {
      expect(const CfgNode().isEmpty, isTrue);
      expect(const CfgNode().toJson(), <String, dynamic>{});
      expect(CfgNode.identity, const CfgNode());
    });

    test('toJson omits every null axis (sparse) — only set axes appear', () {
      final j = const CfgNode(text: 'שלח').toJson();
      expect(j, {'text': 'שלח'}); // no hidden/order/style/action/emoji keys
    });

    test('a populated node round-trips to an equal node', () {
      const node = CfgNode(
        text: 'הזמן עכשיו',
        emoji: '🛒',
        hidden: true,
        order: 3,
        style: CfgStyle(colorToken: 'brand', fontScale: 1.2, pad: EdgeKey.md),
        action: CfgAction(kind: 'navigate', args: {'route': 'cart'}),
      );
      expect(CfgNode.fromJson(node.toJson()), node);
    });
  });

  group('CfgNode — forward-compat (the load-bearing tolerance)', () {
    test('an UNKNOWN key survives the round-trip in `extra`', () {
      final decoded = CfgNode.fromJson({'text': 'x', 'futureAxis': 42});
      expect(decoded.text, 'x');
      expect(decoded.extra, {'futureAxis': 42});
      // …and it re-emits, so a newer-authored doc isn't lossy on an older client.
      expect(decoded.toJson()['futureAxis'], 42);
    });

    test('known axes are NOT duplicated into `extra`', () {
      final decoded = CfgNode.fromJson({'text': 'x', 'hidden': true});
      expect(decoded.extra, isEmpty);
      expect(decoded.hidden, isTrue);
    });

    test('a real unknown key is never clobbered by a known axis on re-emit', () {
      final j = CfgNode.fromJson({'order': 1, 'zzz': 'keep'}).toJson();
      expect(j['order'], 1);
      expect(j['zzz'], 'keep');
    });
  });

  group('CfgStyle — tolerant + clamped', () {
    test('an unknown pad enum-name falls back to null (never throws)', () {
      expect(CfgStyle.fromJson({'pad': 'bogus'}).pad, isNull);
      expect(CfgStyle.fromJson({'pad': 'md'}).pad, EdgeKey.md);
    });

    test('fontScale is clamped to 0.8..1.6 on decode', () {
      expect(CfgStyle.fromJson({'fontScale': 5.0}).fontScale, 1.6);
      expect(CfgStyle.fromJson({'fontScale': 0.1}).fontScale, 0.8);
    });

    test('fontScale arriving as a JSON int is coerced to double', () {
      final fs = CfgStyle.fromJson({'fontScale': 1}).fontScale;
      expect(fs, 1.0);
      expect(fs, isA<double>());
    });

    test('a non-numeric fontScale is tolerated (→ null, never throws)', () {
      expect(CfgStyle.fromJson({'fontScale': 'big'}).fontScale, isNull);
      expect(CfgStyle.fromJson({'fontScale': true}).fontScale, isNull);
      // a bad value must NOT poison the whole node decode (else the sink would
      // discard the entire persisted doc).
      expect(
        CfgNode.fromJson(const {
          'style': {'fontScale': 'big'},
        }).style?.fontScale,
        isNull,
      );
    });

    test('empty style ⇒ isEmpty and is dropped from the parent node JSON', () {
      expect(const CfgStyle().isEmpty, isTrue);
      expect(const CfgNode(style: CfgStyle()).toJson(), <String, dynamic>{});
    });
  });

  group('CfgAction', () {
    test('a missing kind decodes to the safe "noop"', () {
      expect(CfgAction.fromJson(const {}).kind, 'noop');
    });

    test('round-trips kind + args; empty args is omitted', () {
      expect(const CfgAction(kind: 'noop').toJson(), {'kind': 'noop'});
      const a = CfgAction(kind: 'navigate', args: {'route': 'home'});
      expect(CfgAction.fromJson(a.toJson()), a);
    });
  });

  group('copyWith changes a single axis', () {
    test('text only — every other axis is preserved', () {
      const base = CfgNode(text: 'a', hidden: true, order: 2);
      final next = base.copyWith(text: 'b');
      expect(next.text, 'b');
      expect(next.hidden, isTrue);
      expect(next.order, 2);
    });
  });

  group('equality (skip-rebuild contract)', () {
    test('structurally-equal nodes are == (incl. extra map)', () {
      expect(
        CfgNode.fromJson({'text': 'x', 'k': 1}),
        CfgNode.fromJson({'text': 'x', 'k': 1}),
      );
    });
    test('a changed axis breaks equality', () {
      expect(const CfgNode(text: 'a') == const CfgNode(text: 'b'), isFalse);
    });
  });
}
