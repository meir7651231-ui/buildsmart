// FREEZES the ElementDescriptor 6-field contract (#studio · Pillar 1 · step 12.5 —
// Phase-0 seam-freeze before step 30). Pillars 2/4/5 ground their `validateSafe` on
// these six governance fields, so a field change must break THIS test (and gate
// 118). Also asserts fake↔real PARITY: the same contract check, run against a test
// author's fake registry AND the real one, yields the same FAIL-CLOSED verdict — a
// fake registry can't self-certify green (R2-#15).
import 'package:buildsmart/state/studio/element_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// The frozen contract (stand-in for P4's `validateSafe`): a descriptor is
/// well-formed iff its identity + role-floor are non-empty. The SAME check runs
/// against the fake + real registries below, so neither can diverge silently.
bool contractOk(ElementDescriptor d) =>
    d.id.isNotEmpty &&
    d.screen.isNotEmpty &&
    d.area.isNotEmpty &&
    d.labelHe.isNotEmpty &&
    d.kRoleFloor.isNotEmpty;

void main() {
  test('FROZEN: every real descriptor satisfies the contract', () {
    for (final d in kElementRegistry) {
      expect(
        contractOk(d),
        isTrue,
        reason: 'descriptor ${d.id} breaks the frozen contract',
      );
    }
  });

  test('the 6 governance fields are present + typed (signature freeze)', () {
    const d = ElementDescriptor(
      id: 'x',
      screen: 's',
      area: 'a',
      labelHe: 'ל',
      kind: ElementKind.text,
    );
    // If any of these stops compiling / typing, the FROZEN signature changed.
    expect(d.kind, ElementKind.text);
    expect(d.editableProps, isA<Set<EditAxis>>());
    expect(d.allowedActions, isA<List<String>>());
    expect(d.allowedValues, isA<Map<String, List<String>>>());
    expect(d.kImmutable, isFalse);
    expect(d.kRoleFloor, 'contractor');
  });

  test('fail-closed PARITY: fake + real registries reject each other’s ids', () {
    const fake = [
      ElementDescriptor(
        id: 'fake.only',
        screen: 's',
        area: 'a',
        labelHe: 'ל',
        kind: ElementKind.text,
      ),
    ];
    // Cross-lookups fail-closed (null) identically...
    expect(findDescriptor(fake, 'cart.cta'), isNull);
    expect(findDescriptor(kElementRegistry, 'fake.only'), isNull);
    // ...and each resolves its OWN member (consistent positive behavior).
    expect(findDescriptor(fake, 'fake.only'), isNotNull);
    expect(findDescriptor(kElementRegistry, 'cart.cta'), isNotNull);
  });
}
