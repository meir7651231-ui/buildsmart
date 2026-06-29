// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 12 — the element registry.
//
// [ElementDescriptor] is the contract for ONE editable element. It carries the SIX
// governance fields (R1-A1) — editableProps · allowedActions · allowedValues ·
// kImmutable · kRoleFloor · kind — plus identity (id/screen/area/labelHe). The
// inspector lists descriptors; `validateSafe` (P4) gates every write against them.
//
// [findDescriptor] is FAIL-CLOSED: an id NOT in the registry ⇒ null ⇒ the inspector
// won't edit it and a publish validator rejects it (no vacuous green — R1-A1/R2-#15).
// `kElementRegistry` is `const` (zero runtime cost); [elementRegistryProvider] chains
// [domainElementsProvider] so Pillar-2's no-code domain builder can append rows.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped whenever the registry's SHAPE changes — lets Pillar-3 analytics annotate
/// funnels across builds without a full diff.
const int kElementRegistryVersion = 1;

/// The axes an element exposes for editing (mirrors the CfgNode axes).
enum EditAxis { text, emoji, hidden, order, style, action }

/// The broad kind of an element — drives which inspector panel + wrapper apply.
enum ElementKind { text, container, list, action, theme }

/// The contract for one editable element.
@immutable
class ElementDescriptor {
  const ElementDescriptor({
    required this.id,
    required this.screen,
    required this.area,
    required this.labelHe,
    required this.kind,
    this.editableProps = const {},
    this.allowedActions = const [],
    this.allowedValues = const {},
    this.kImmutable = false,
    this.kRoleFloor = 'contractor',
    this.wired = false,
  });

  // identity
  final String id;
  final String screen;
  final String area;
  final String labelHe;

  // the 6 governance fields (R1-A1)
  final ElementKind kind;
  final Set<EditAxis> editableProps;
  final List<String> allowedActions;
  final Map<String, List<String>> allowedValues;

  /// Critical — can never be hidden / action-rerouted (enforced in merge + publish).
  final bool kImmutable;

  /// The minimum canonical roleKey that may see/edit this element.
  final String kRoleFloor;

  /// Flipped true once a widget actually adopts this id (step 14 / Phase E); lets the
  /// inspector show "not yet wired" without a warn-scan.
  final bool wired;
}

/// The built-in elements. SEED set (pilot targets, `wired: false`); step 14 wraps the
/// widgets + flips them wired, and adopts the rest screen-by-screen.
const List<ElementDescriptor> kElementRegistry = [
  ElementDescriptor(
    id: 'cart.cta',
    screen: 'cart',
    area: 'checkout',
    labelHe: 'כפתור הזמנה (עגלה)',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.emoji, EditAxis.style},
  ),
  ElementDescriptor(
    id: 'home.kpi.title',
    screen: 'home',
    area: 'kpi',
    labelHe: 'כותרת מדד (KPI)',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
  ),
];

/// Pillar-2 (the no-code domain builder) overrides this to append domain elements.
/// Empty until then, so the registry is exactly [kElementRegistry].
final domainElementsProvider =
    Provider<List<ElementDescriptor>>((_) => const []);

/// The full registry = built-ins ⊕ domain elements.
final elementRegistryProvider = Provider<List<ElementDescriptor>>(
  (ref) => [...kElementRegistry, ...ref.watch(domainElementsProvider)],
);

/// FAIL-CLOSED lookup: returns null for an id not in [all] (the inspector then
/// refuses to edit it and the publish validator rejects it).
ElementDescriptor? findDescriptor(Iterable<ElementDescriptor> all, String id) {
  for (final d in all) {
    if (d.id == id) return d;
  }
  return null;
}

/// The descriptor for `id` across the live (built-in ⊕ domain) registry, or null.
final descriptorProvider = Provider.family<ElementDescriptor?, String>(
  (ref, id) => findDescriptor(ref.watch(elementRegistryProvider), id),
);
