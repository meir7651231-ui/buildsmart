// Pins the merge keystone (#studio · Pillar 1 · step 3) — the zero-regression
// proof. Empty doc ⇒ identity (so every wrapper is identity-equivalent when OFF);
// layering order default⊕global⊕persona⊕draft; per-FIELD style/action merge;
// critical-can't-hide; canonical roleKeyOf. Pure — imports NO widgets.
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_merge.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roleKeyOf — canonical persona key (R1-A2)', () {
    test('null/empty = contractor; a real role passes through', () {
      expect(roleKeyOf(null), 'contractor');
      expect(roleKeyOf(''), 'contractor');
      expect(roleKeyOf('worker'), 'worker');
      expect(roleKeyOf('manager'), 'manager');
    });
  });

  group('mergeNode — layering order (most-specific wins)', () {
    test('EMPTY doc ⇒ identity (the zero-regression contract)', () {
      expect(
        mergeNode('any.id', ConfigDoc.empty, 'contractor'),
        CfgNode.identity,
      );
    });

    test('published.global applies to everyone', () {
      const doc = ConfigDoc(
        published: ConfigLayer(global: {'cta': CfgNode(text: 'גלובלי')}),
      );
      expect(mergeNode('cta', doc, 'worker').text, 'גלובלי');
    });

    test('published.persona BEATS published.global for that role', () {
      const doc = ConfigDoc(
        published: ConfigLayer(
          global: {'cta': CfgNode(text: 'גלובלי')},
          persona: {
            'courier': {'cta': CfgNode(text: 'לשליח')},
          },
        ),
      );
      expect(mergeNode('cta', doc, 'courier').text, 'לשליח'); // persona wins
      expect(mergeNode('cta', doc, 'worker').text, 'גלובלי'); // others = global
    });

    test('draft BEATS published only when includeDraft', () {
      const doc = ConfigDoc(
        published: ConfigLayer(global: {'cta': CfgNode(text: 'pub')}),
        draft: ConfigLayer(global: {'cta': CfgNode(text: 'draft')}),
      );
      expect(mergeNode('cta', doc, 'contractor').text, 'pub'); // OFF for users
      expect(
        mergeNode('cta', doc, 'contractor', includeDraft: true).text,
        'draft',
      );
    });
  });

  group('mergeNode — per-FIELD style merge (R1-A2-merge · R2-#5)', () {
    test('a draft that sets only fontScale KEEPS published colorToken', () {
      const doc = ConfigDoc(
        published: ConfigLayer(
          global: {
            'h': CfgNode(style: CfgStyle(colorToken: 'brand')),
          },
        ),
        draft: ConfigLayer(
          global: {
            'h': CfgNode(style: CfgStyle(fontScale: 1.4)),
          },
        ),
      );
      final s = mergeNode('h', doc, 'contractor', includeDraft: true).style!;
      expect(s.fontScale, 1.4); // from draft
      expect(s.colorToken, 'brand'); // NOT dropped — preserved from published
    });
  });

  group('mergeNode — critical-id can never be hidden or rerouted', () {
    test('hidden is cleared for an injected critical id', () {
      const doc = ConfigDoc(
        published: ConfigLayer(global: {'nav.home': CfgNode(hidden: true)}),
      );
      final n = mergeNode(
        'nav.home',
        doc,
        'contractor',
        criticalIds: {'nav.home'},
      );
      expect(n.hidden, isNull); // critical → hidden ignored
      // …but a non-critical id keeps its hidden.
      expect(mergeNode('nav.home', doc, 'contractor').hidden, isTrue);
    });

    test('action (reroute) is cleared for a critical id (R2-#26 תוספת-ב)', () {
      const doc = ConfigDoc(
        published: ConfigLayer(
          global: {'nav.home': CfgNode(action: CfgAction(kind: 'navigate'))},
        ),
      );
      final n = mergeNode(
        'nav.home',
        doc,
        'contractor',
        criticalIds: {'nav.home'},
      );
      expect(n.action, isNull); // critical → reroute ignored
      // …but a non-critical id keeps its action.
      expect(mergeNode('nav.home', doc, 'contractor').action, isNotNull);
    });
  });

  group('mergeNode — extra (forward-compat) is unioned across layers', () {
    test('unknown keys from global + draft both survive the merge', () {
      final doc = ConfigDoc(
        published: ConfigLayer(global: {'x': CfgNode.fromJson({'a': 1})}),
        draft: ConfigLayer(global: {'x': CfgNode.fromJson({'b': 2})}),
      );
      final n = mergeNode('x', doc, 'contractor', includeDraft: true);
      expect(n.extra, {'a': 1, 'b': 2});
    });
  });
}
