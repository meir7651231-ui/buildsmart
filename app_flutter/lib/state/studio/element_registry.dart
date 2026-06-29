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
///
/// ⚠️ FROZEN (step 12.5 · seam-freeze before step 30) — Pillars 2/4/5 ground their
/// `validateSafe` on the six governance fields below. Changing/removing a field
/// needs a schema migration + an update to `descriptor_contract_test`; do NOT edit
/// the shape casually.
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
  // Step-14 pilot — the 5 cockpit KPI labels (manager_dashboard _MetricGrid), wired.
  ElementDescriptor(
    id: 'manager.cockpit.kpi.openOrders',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — הזמנות פתוחות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.products',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — מוצרים בקטלוג',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.accessories',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — אביזרים נלווים',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.available',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — זמינים כעת',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.stores',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — חנויות פעילות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // ── Phase-E content adoption (step 29) — high-value screen literals wrapped as
  // CfgText, the literal kept as the fallback (OFF ⇒ verbatim). Append-only.
  ElementDescriptor(
    id: 'manager.cockpit.copilot.title',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'כותרת קו-פיילוט',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // ── Critical/protected set (step 26) — navigation + auth the owner may RENAME but
  // never hide or re-route. `kImmutable:true` is the canonical critical flag (R1-A1);
  // declared here (wired:false) so the merge defence + publish validator protect them
  // even before a widget adopts them (defence-in-depth — §8.1).
  ElementDescriptor(
    id: 'auth.login.cta',
    screen: 'welcome',
    area: 'auth',
    labelHe: 'כניסה (מסך פתיחה)',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'auth.logout',
    screen: 'app',
    area: 'auth',
    labelHe: 'התנתקות',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'nav.bottombar',
    screen: 'app',
    area: 'nav',
    labelHe: 'סרגל ניווט תחתון',
    kind: ElementKind.container,
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'manager.entry',
    screen: 'app',
    area: 'nav',
    labelHe: 'כניסת מנהל',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'studio.exit',
    screen: 'studio',
    area: 'chrome',
    labelHe: 'יציאה מהסטודיו',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
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

/// The critical/immutable set — every registered id flagged `kImmutable` (R1-A1).
/// SINGLE source for both the merge defence (resolve drops a hide/reroute on these)
/// and the publish validator, so the two can never drift (gate-118 · step 26).
final criticalIdsProvider = Provider<Set<String>>(
  (ref) => ref
      .watch(elementRegistryProvider)
      .where((d) => d.kImmutable)
      .map((d) => d.id)
      .toSet(),
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
