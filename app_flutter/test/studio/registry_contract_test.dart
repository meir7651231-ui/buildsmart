// Pins the element-registry contract (#studio · Pillar 1 · step 12): ids are
// unique, every descriptor carries non-empty identity + a kind, and the lookup is
// FAIL-CLOSED — an unknown id resolves to null (so the inspector refuses to edit it
// and the publish validator rejects it; no vacuous green — R1-A1 / R2-#15).
import 'package:buildsmart/state/studio/element_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('built-in ids are unique', () {
    final ids = kElementRegistry.map((d) => d.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every descriptor has non-empty identity + a kind', () {
    for (final d in kElementRegistry) {
      expect(d.id, isNotEmpty);
      expect(d.screen, isNotEmpty);
      expect(d.area, isNotEmpty);
      expect(d.labelHe, isNotEmpty);
      expect(d.kind, isA<ElementKind>());
    }
  });

  test('findDescriptor is FAIL-CLOSED for an unknown id', () {
    expect(findDescriptor(kElementRegistry, 'no.such.id'), isNull);
  });

  test('findDescriptor returns the matching descriptor', () {
    final d = findDescriptor(kElementRegistry, 'cart.cta');
    expect(d, isNotNull);
    expect(d!.editableProps, contains(EditAxis.text));
  });

  test('elementRegistryProvider = built-ins (domain empty by default)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(elementRegistryProvider).length, kElementRegistry.length);
    expect(c.read(descriptorProvider('cart.cta')), isNotNull);
    expect(c.read(descriptorProvider('nope')), isNull); // fail-closed
  });

  test('domain elements are appended (Pillar-2 seam)', () {
    final c = ProviderContainer(
      overrides: [
        domainElementsProvider.overrideWithValue(const [
          ElementDescriptor(
            id: 'domain.electrician.wire',
            screen: 'catalog',
            area: 'domain',
            labelHe: 'כבל חשמל',
            kind: ElementKind.text,
          ),
        ]),
      ],
    );
    addTearDown(c.dispose);
    expect(c.read(descriptorProvider('domain.electrician.wire')), isNotNull);
    expect(
      c.read(elementRegistryProvider).length,
      kElementRegistry.length + 1,
    );
  });
}
