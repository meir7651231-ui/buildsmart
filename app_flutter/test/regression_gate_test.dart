// Roadmap step 89 — regression gate.
//
// Enforces the "wire ⇒ contract ⇒ test" protocol: every public helper the
// SmartProduct card *depends on* must be referenced from at least one test
// file. If a new helper ships without a guarding test, this gate goes red.
//
// Curated list (not auto-parsed): adding/renaming a helper here is a deliberate
// act that makes you also write its test — by design. Internal/private symbols
// (`_foo`) and trivial getters are excluded.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _kRequiredHelpers = <String>[
  // Compat & connectivity
  'compatibleProductsFor',
  'compatibleProductsCount',
  'connectionExplainHe',
  'connectionJoint',
  'jointLabelHe',
  'chainEdgeLabelHe',
  'connectionNeedsHe',
  'connectionWarningHe',
  'lineFitFor',
  'adapterSuggestionFor',
  'safetyKitItems',
  'chainArrowText',

  // Spec / scoring / discovery
  'engineeringSpecFor',
  'cardReadinessScore',
  'durabilityRatingFor',
  'discoveryTagsFor',
  'frequentlyPairedTypesFor',
  'manufacturerInfoFor',
  'finderGroupFor',
  'israeliStandardsFor',
  'systemSafetyNoteHe',
  'hotWaterSuitabilityFor',
  'brandSuitableForHot',

  // Install / kit
  'installToolsFor',
  'installTipsFor',
  'installEffortFor',
  'installKitFor',
  'acceptanceChecklistFor',

  // Price / share
  'priceFor',
  'lineCostEstimateFor',
  'cheaperAlternativeBrand',
  'quoteTextFor',
  'deepLinkFor',
  'smartCardSummaryHe',

  // Compliance
  'complianceTriggersFor',
  'complianceWhyHe',

  // Variants & brand guide
  'variantSiblingsOf',
  'variantSiblingsCountFor',
  'brandDecisionGuide',

  // Catalog bridge
  'catalogProductForBrand',
  'catalogProductForSku',
  'catalogProductForSmart',
  'smartProductForSku',

  // Project & cart
  'projectQuoteText',
  'projectTemplates',
  'projectItemsAfterAdd',
  'buildSafetyAccessories',
];

void main() {
  test('every required card helper is referenced by at least one test file',
      () {
    // Concatenate every Dart file in the test/ directory (excluding this gate
    // itself, so a helper listed only here doesn't pass its own check).
    final dir = Directory('test');
    final buf = StringBuffer();
    var scanned = 0;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('_test.dart')) continue;
      if (entity.path.endsWith('regression_gate_test.dart')) continue;
      buf.write(entity.readAsStringSync());
      scanned++;
    }
    expect(scanned, greaterThan(20),
        reason: 'sanity — should find many test files');
    final corpus = buf.toString();
    final missing = <String>[
      for (final name in _kRequiredHelpers)
        if (!corpus.contains(name)) name,
    ];
    expect(missing, isEmpty,
        reason:
            'these helpers have no test reference:\n  ${missing.join("\n  ")}');
  });

  test('curated list itself has no duplicates', () {
    expect(_kRequiredHelpers.toSet().length, _kRequiredHelpers.length);
  });
}
