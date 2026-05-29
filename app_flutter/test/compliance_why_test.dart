// Roadmap step 58 — every compliance trigger the card can show must have a
// plain-language "why it matters" explanation, so the UI never shows a bare
// label with no rationale.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every distinct compliance-trigger label has a non-null why', () {
    final labels = <String>{};
    for (final p in kLipskeyCatalog) {
      for (final t in complianceTriggersFor(p)) {
        labels.add(t.label);
      }
    }
    expect(labels, isNotEmpty, reason: 'catalog should trigger some compliance');
    final missing = labels.where((l) => complianceWhyHe(l) == null).toList();
    expect(missing, isEmpty,
        reason: 'labels with no "why": ${missing.join(" | ")}');
  });

  test('an unknown label returns null (no fabricated explanation)', () {
    expect(complianceWhyHe('🛡 פריט דמיוני שלא קיים'), isNull);
  });
}
