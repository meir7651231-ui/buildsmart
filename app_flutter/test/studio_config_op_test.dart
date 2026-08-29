// Step 69 — round-trip + grounding-free contract for the ConfigOp JSON layer.
//
// The op family itself is P1's (frozen SEAM-2 in `config_store.dart`); this suite
// pins the step-69 additions in `logic/studio/config_op.dart`:
//   • `fromJson(toJson(op))` round-trips EVERY variant (by value + by JSON),
//   • enums serialise by NAME (not a drift-prone int index),
//   • a `schemaVersion` tag rides inside the JSON,
//   • an unknown/stale/missing tag → `null` (drop), and partial/hostile JSON
//     NEVER throws — the TOTAL-parser guarantee (mirrors parseAssistantIntent).
import 'package:buildsmart/logic/studio/config_op.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Assert op → JSON → op is lossless: non-null, value-equal, same kind, and the
  // re-serialised JSON is deep-equal (so nested style/action maps are covered too).
  void expectRoundTrip(ConfigOp op) {
    final json = configOpToJson(op);
    final back = configOpFromJson(json);
    expect(back, isNotNull, reason: 'round-trip lost $op');
    final rt = back!;
    expect(rt.kind, op.kind, reason: 'kind drift for $op');
    expect(configOpEquals(rt, op), isTrue, reason: 'value drift for $op');
    expect(configOpToJson(rt), equals(json), reason: 'JSON drift for $op');
    expect(json['schemaVersion'], kConfigOpSchema);
  }

  group('round-trip — every variant (payload + null-payload)', () {
    test('SetText', () {
      expectRoundTrip(const SetText('cart.cta', 'שלח הזמנה'));
      expectRoundTrip(const SetText('cart.cta', null)); // clear-axis
    });
    test('SetEmoji', () {
      expectRoundTrip(const SetEmoji('cart.cta', '🛒'));
      expectRoundTrip(const SetEmoji('cart.cta', null));
    });
    test('SetHidden', () {
      expectRoundTrip(const SetHidden('catalog.card.productBadge', true));
      expectRoundTrip(const SetHidden('catalog.card.productBadge', false));
      expectRoundTrip(const SetHidden('catalog.card.productBadge', null));
    });
    test('SetOrder', () {
      expectRoundTrip(const SetOrder('catalog.action.proposal', 3));
      expectRoundTrip(const SetOrder('catalog.action.proposal', 0));
      expectRoundTrip(const SetOrder('catalog.action.proposal', null));
    });
    test('SetStyle', () {
      expectRoundTrip(
        const SetStyle(
          'manager.cockpit.kpi.openOrders',
          CfgStyle(
            colorToken: 'brand',
            bgToken: 'surface',
            fontScale: 1.2,
            weightToken: 'bold',
            sizeToken: 'typeSubhead',
            pad: EdgeKey.lg,
          ),
        ),
      );
      expectRoundTrip(const SetStyle('x', CfgStyle())); // empty style ≠ null
      expectRoundTrip(const SetStyle('x', null)); // clear-axis
    });
    test('SetAction', () {
      expectRoundTrip(
        const SetAction('x', CfgAction(kind: 'navigate', args: {'route': 'cart'})),
      );
      expectRoundTrip(const SetAction('x', CfgAction(kind: 'noop')));
      expectRoundTrip(const SetAction('x', null));
    });
  });

  group('anti-drift — enums serialise by NAME, not int index', () {
    test('CfgStyle.pad is the enum name string', () {
      final j = configOpToJson(const SetStyle('x', CfgStyle(pad: EdgeKey.lg)));
      expect((j['style'] as Map)['pad'], 'lg'); // "lg", not 2
    });
    test('op tag + action kind are strings', () {
      final j = configOpToJson(
        const SetAction('x', CfgAction(kind: 'navigate')),
      );
      expect(j['op'], 'setAction');
      expect((j['action'] as Map)['kind'], 'navigate');
    });
  });

  group('degrade — unknown/missing tag drops to null (never throws)', () {
    test('unknown op tag → null', () {
      expect(configOpFromJson({'op': 'setFoo', 'id': 'x'}), isNull);
    });
    test('stale-family tag (addComponent/addRule/setVisible) → null', () {
      // P1 has no variant for these pre-S3.K tags → they drop, not half-build.
      expect(configOpFromJson({'op': 'addComponent', 'id': 'x'}), isNull);
      expect(configOpFromJson({'op': 'addRule', 'id': 'x'}), isNull);
      expect(
        configOpFromJson({'op': 'setVisible', 'id': 'x', 'visible': true}),
        isNull,
      );
    });
    test('missing op tag → null', () {
      expect(configOpFromJson({'id': 'x', 'text': 'y'}), isNull);
    });
    test('missing / blank / non-string id → null (fail-closed identity)', () {
      expect(configOpFromJson({'op': 'setText', 'text': 'y'}), isNull);
      expect(configOpFromJson({'op': 'setText', 'id': ''}), isNull);
      expect(configOpFromJson({'op': 'setText', 'id': 42}), isNull);
    });
  });

  group('TOTAL — partial / hostile JSON never throws', () {
    test('non-map inputs → null', () {
      for (final bad in <Object?>[null, 42, 'not a map', <int>[1, 2], true]) {
        expect(configOpFromJson(bad), isNull, reason: 'threw/parsed on $bad');
      }
      expect(configOpFromJson(const <String, dynamic>{}), isNull);
    });
    test('wrong-typed fields degrade to a null-axis, never a cast-throw', () {
      // hidden as a String would blow up a naive `as bool` — must degrade.
      expect(
        (configOpFromJson({'op': 'setHidden', 'id': 'x', 'hidden': 'true'})
                as SetHidden)
            .hidden,
        isNull,
      );
      expect(
        (configOpFromJson({'op': 'setOrder', 'id': 'x', 'order': 'NaN'})
                as SetOrder)
            .order,
        isNull,
      );
      expect(
        (configOpFromJson({'op': 'setStyle', 'id': 'x', 'style': 'oops'})
                as SetStyle)
            .style,
        isNull,
      );
      expect(
        (configOpFromJson({'op': 'setText', 'id': 'x', 'text': 99}) as SetText)
            .text,
        isNull,
      );
    });
    test('object-keyed nested map (platform Map<Object?,Object?>) is tolerated',
        () {
      final raw = <String, dynamic>{
        'op': 'setStyle',
        'id': 'x',
        'style': <dynamic, dynamic>{'colorToken': 'brand'},
      };
      final op = configOpFromJson(raw);
      expect(op, isA<SetStyle>());
      expect((op! as SetStyle).style?.colorToken, 'brand');
    });
  });

  group('batch — configOpsToJson / configOpsFromJson', () {
    test('list round-trips in order', () {
      const ops = <ConfigOp>[
        SetText('a', 'שלום'),
        SetHidden('b', true),
        SetOrder('c', 5),
      ];
      final back = configOpsFromJson(configOpsToJson(ops));
      expect(back.length, ops.length);
      for (var i = 0; i < ops.length; i++) {
        expect(configOpEquals(back[i], ops[i]), isTrue);
      }
    });
    test('unknown entries are DROPPED, valid ones survive (degrade)', () {
      final back = configOpsFromJson(<Object?>[
        {'op': 'setText', 'id': 'a', 'text': 'ok'},
        {'op': 'addComponent', 'id': 'b'}, // stale → drop
        'garbage', // non-map → drop
        {'op': 'setHidden', 'id': 'c', 'hidden': true},
      ]);
      expect(back.length, 2);
      expect(back.map((o) => o.id), ['a', 'c']);
    });
    test('non-list input → empty (never throws)', () {
      expect(configOpsFromJson(null), isEmpty);
      expect(configOpsFromJson('nope'), isEmpty);
    });
  });

  group('configOpEquals — value semantics', () {
    test('reflexive', () {
      const op = SetText('x', 'y');
      expect(configOpEquals(op, op), isTrue);
      expect(configOpEquals(const SetText('x', 'y'), const SetText('x', 'y')),
          isTrue);
    });
    test('differing id / field / kind → false', () {
      expect(configOpEquals(const SetText('x', 'y'), const SetText('z', 'y')),
          isFalse);
      expect(configOpEquals(const SetText('x', 'y'), const SetText('x', 'w')),
          isFalse);
      expect(configOpEquals(const SetText('x', 'y'), const SetEmoji('x', 'y')),
          isFalse);
      expect(configOpEquals(const SetStyle('x', CfgStyle()), const SetStyle('x', null)),
          isFalse); // empty style is not the null axis
    });
  });

  group('kind getter — grouping without an is-ladder', () {
    test('each variant reports its kind', () {
      expect(const SetText('x', null).kind, ConfigOpKind.setText);
      expect(const SetEmoji('x', null).kind, ConfigOpKind.setEmoji);
      expect(const SetHidden('x', null).kind, ConfigOpKind.setHidden);
      expect(const SetOrder('x', null).kind, ConfigOpKind.setOrder);
      expect(const SetStyle('x', null).kind, ConfigOpKind.setStyle);
      expect(const SetAction('x', null).kind, ConfigOpKind.setAction);
    });
  });
}
