// Pins the Studio config DOCUMENT (#studio · Pillar 1 · step 2): empty=inert,
// faithful round-trip of a layered doc (global + per-persona + history), in-place
// schema migration, and the defensive history cap. Pure — no pump.
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfigDoc.empty is inert', () {
    test('empty doc carries nothing live + round-trips to {schemaVersion}', () {
      expect(ConfigDoc.empty.isEmpty, isTrue);
      expect(ConfigDoc.empty.draftNodeCount, 0);
      expect(ConfigDoc.empty.toJson(), {'schemaVersion': kSchemaVersion});
      expect(ConfigDoc.fromJson(ConfigDoc.empty.toJson()), ConfigDoc.empty);
    });
  });

  group('round-trip — layered doc (global + persona + history)', () {
    final doc = ConfigDoc(
      published: const ConfigLayer(
        global: {'cart.cta': CfgNode(text: 'הזמן עכשיו')},
        persona: {
          'courier': {'tab.purchasing': CfgNode(hidden: true)},
        },
      ),
      draft: const ConfigLayer(global: {'home.title': CfgNode(text: 'בית')}),
      history: [
        ConfigVersion(
          id: 1718900000000,
          publishedAtMs: 1718900000000,
          note: 'גרסה ראשונה',
          byEmail: 'meir@x.com',
          snapshot: const ConfigLayer(global: {'cart.cta': CfgNode(text: 'ישן')}),
        ),
      ],
    );

    test('a populated doc round-trips to an equal doc', () {
      expect(ConfigDoc.fromJson(doc.toJson()), doc);
    });

    test('draftNodeCount counts global + persona draft overrides', () {
      final d = doc.copyWith(
        draft: const ConfigLayer(
          global: {'a': CfgNode(text: 'x'), 'b': CfgNode(text: 'y')},
          persona: {
            'worker': {'c': CfgNode(hidden: true)},
          },
        ),
      );
      expect(d.draftNodeCount, 3);
    });

    test('persona map-of-maps survives the round-trip', () {
      final back = ConfigDoc.fromJson(doc.toJson());
      expect(back.published.persona['courier']!['tab.purchasing']!.hidden, true);
    });
  });

  group('migration + tolerance', () {
    test('a doc with NO schemaVersion is read as v1 (migrate, no throw)', () {
      final back = ConfigDoc.fromJson({
        'published': {
          'global': {
            'x': {'text': 'a'},
          },
        },
      });
      expect(back.schemaVersion, kSchemaVersion);
      expect(back.published.global['x']!.text, 'a');
    });

    test('garbage persona/structure casts gracefully, never throws', () {
      final back = ConfigDoc.fromJson({
        'published': {'persona': 'not-a-map', 'structure': 42},
      });
      expect(back.published.persona, isEmpty);
      expect(back.published.structure, isEmpty);
    });

    test('reserved `structure` sub-doc round-trips intact (Pillar-2 forward-compat)',
        () {
      final back = ConfigDoc.fromJson({
        'published': {
          'structure': {'trades': <dynamic>['electrician']},
        },
      });
      expect(back.published.structure['trades'], ['electrician']);
    });

    test('history is defensively capped at kHistoryCap on decode', () {
      final big = {
        'history': List.generate(
          kHistoryCap + 12,
          (i) => {'id': i, 'publishedAtMs': i},
        ),
      };
      expect(ConfigDoc.fromJson(big).history.length, kHistoryCap);
    });
  });
}
