// cluster #101 · מדיניות מסמכים-נדרשים — proof of the CONTRACTOR's
// employer-scoped required-docs policy notifier + the normalizeDocName matcher.
//
//   addRequirement / removeRequirement / setRequirements (immutable updates),
//   normalize-dedupe (whitespace/case → ONE entry), an empty/whitespace name
//   ignored, a persist round-trip under kRequiredDocsKey (survives a simulated
//   restart), requiredDocsForEmployer scoping, and normalizeDocName unit cases
//   (trim/case/collapse-whitespace; two DISTINCT names stay distinct — NOT
//   substring-collapsed).

import 'package:buildsmart/state/required_docs_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('normalizeDocName (PURE)', () {
    test('trims surrounding whitespace', () {
      expect(normalizeDocName('  בטיחות  '), 'בטיחות');
    });

    test('lower-cases (for latin names)', () {
      expect(normalizeDocName('Safety'), 'safety');
    });

    test('collapses internal whitespace runs to a single space', () {
      expect(normalizeDocName('עבודה   בגובה'), 'עבודה בגובה');
      expect(normalizeDocName('עבודה\tבגובה'), 'עבודה בגובה');
    });

    test('two DISTINCT names stay distinct — NOT substring-collapsed', () {
      // The E2 lesson: 'בטיחות' is not "contained into" 'בטיחות בגובה'.
      expect(
        normalizeDocName('בטיחות') == normalizeDocName('בטיחות בגובה'),
        isFalse,
      );
    });

    test('whitespace/case variants of the same name normalize equal', () {
      expect(
        normalizeDocName('  בטיחות ') == normalizeDocName('בטיחות'),
        isTrue,
      );
    });
  });

  group('RequiredDocsPolicyNotifier (in-memory)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('addRequirement appends a trimmed display-form entry', () {
      final n = RequiredDocsPolicyNotifier();
      n.addRequirement('c1', '  היתר עבודה בגובה ');
      expect(n.state['c1'], ['היתר עבודה בגובה']); // stored trimmed display form
    });

    test('addRequirement dedupes by normalized name (whitespace/case)', () {
      final n = RequiredDocsPolicyNotifier();
      n.addRequirement('c1', 'בטיחות');
      n.addRequirement('c1', ' בטיחות '); // whitespace/case variant
      expect(n.state['c1'], ['בטיחות']); // ONE entry, first display form kept
    });

    test('addRequirement keeps DISTINCT names (no substring collapse)', () {
      final n = RequiredDocsPolicyNotifier();
      n.addRequirement('c1', 'בטיחות');
      n.addRequirement('c1', 'בטיחות בגובה');
      expect(n.state['c1'], ['בטיחות', 'בטיחות בגובה']);
    });

    test('empty / whitespace-only name is ignored', () {
      final n = RequiredDocsPolicyNotifier();
      n.addRequirement('c1', '');
      n.addRequirement('c1', '   ');
      expect(n.state['c1'], isNull);
    });

    test('removeRequirement removes by normalized name', () {
      final n = RequiredDocsPolicyNotifier();
      n.addRequirement('c1', 'בטיחות');
      n.addRequirement('c1', 'עבודה בגובה');
      n.removeRequirement('c1', ' בטיחות '); // normalized match
      expect(n.state['c1'], ['עבודה בגובה']);
    });

    test('setRequirements normalize-dedupes and drops empties', () {
      final n = RequiredDocsPolicyNotifier();
      n.setRequirements('c1', ['בטיחות', ' בטיחות ', '', '  ', 'עבודה בגובה']);
      expect(n.state['c1'], ['בטיחות', 'עבודה בגובה']);
    });
  });

  group('persistence + providers', () {
    test('a requirement survives a simulated restart (round-trip)', () async {
      SharedPreferences.setMockInitialValues({});

      // Session 1 — add a requirement, let the async write land.
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);
      c1.read(requiredDocsPolicyProvider.notifier).addRequirement('c1', 'בטיחות');
      await Future<void>.delayed(Duration.zero); // flush the fire-and-forget write

      // Session 2 — a fresh container reads the persisted policy back.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      await c2.read(requiredDocsPolicyProvider.notifier).stream.first.timeout(
            const Duration(seconds: 1),
            onTimeout: () => c2.read(requiredDocsPolicyProvider),
          );
      expect(c2.read(requiredDocsForEmployer('c1')), ['בטיחות']);
    });

    test('it is persisted under kRequiredDocsKey', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(requiredDocsPolicyProvider.notifier).addRequirement('c1', 'בטיחות');
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kRequiredDocsKey);
      expect(raw, isNotNull);
      expect(raw, contains('בטיחות'));
    });

    test('requiredDocsForEmployer scopes per employer', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(requiredDocsPolicyProvider.notifier).addRequirement('c1', 'x');

      expect(c.read(requiredDocsForEmployer('c1')), ['x']);
      expect(c.read(requiredDocsForEmployer('c2')), isEmpty); // no policy → []
    });

    test('requiredDocsForEmployer is const [] for an unknown employer', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(requiredDocsForEmployer('')), isEmpty);
    });
  });
}
