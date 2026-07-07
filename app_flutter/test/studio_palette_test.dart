// Step 73 — the static COMPONENT PALETTE with typed required-prop schemas.
//
// This suite pins `logic/studio/component_palette.dart`. It mirrors
// studio_action_catalog_test.dart: a palette-integrity group (every ComponentType
// resolves to exactly one template with a Hebrew label + a typed schema), the
// allowedContainers-vs-ElementKind enforcement (a legal content container is
// accepted, an illegal / control container is rejected — the §4 "button into auth"
// guard reconciled to the frozen `ElementKind`), the required-prop enforcement
// (a missing required prop drops the AddComponent, §5), the §9 attached-action
// grounding against the step-72 catalog, the §10 flood ceiling, the §6
// promptSafeText defanging, a golden-list snapshot (silent-growth gate), and
// anti-vacuous checks that each predicate actually selects real templates.
import 'package:buildsmart/logic/studio/action_catalog.dart'
    show actionCatalogIds;
import 'package:buildsmart/logic/studio/component_palette.dart';
import 'package:buildsmart/state/studio/element_registry.dart'
    show ElementKind;
import 'package:flutter_test/flutter_test.dart';

/// GOLDEN — the sorted list of ALL palette type names. Adding/removing a component
/// MUST force an explicit edit here (a gate against silent palette growth).
const List<String> kGoldenComponentTypes = <String>[
  'badge',
  'button',
  'divider',
  'infoCard',
  'linkRow',
  'textBlock',
];

/// GOLDEN — each type's EXACT required-prop schema (§5). A silent schema change
/// (dropping `actionId` from `button`, say) forces an explicit edit here.
const Map<String, List<String>> kGoldenRequiredProps = <String, List<String>>{
  'button': ['label', 'actionId'],
  'textBlock': ['text'],
  'badge': ['text'],
  'divider': [],
  'infoCard': ['title', 'body'],
  'linkRow': ['label', 'actionId'],
};

/// The container kinds that are NOT content containers — a component into any of
/// these must be rejected (`action` is the reconciled "auth/control" kind, §4).
const List<ElementKind> kNonContentKinds = <ElementKind>[
  ElementKind.action,
  ElementKind.text,
  ElementKind.theme,
];

/// True when [containers] lists a control / leaf / styling kind — the §4 guard the
/// palette must NEVER trip. Kept local so its anti-vacuous fire can be proven below.
bool _listsNonContentKind(Set<ElementKind> containers) =>
    containers.any(kNonContentKinds.contains);

void main() {
  // ── Palette integrity — every ComponentType resolves to one typed template ────
  group('palette integrity · every ComponentType → one template', () {
    test('no dangling type: each ComponentType has a template + he + schema', () {
      expect(kComponentPalette, isNotEmpty);
      for (final type in ComponentType.values) {
        final t = templateFor(type);
        expect(t, isNotNull, reason: 'ComponentType <$type> has no template');
        expect(t!.type, type);
        expect(t.he.trim(), isNotEmpty, reason: '<$type> has no Hebrew label');
        expect(t.requiredProps, isA<List<String>>());
        expect(componentHe(type), t.he);
      }
    });

    test('templateForName resolves an exact type name; invented / blank → null', () {
      expect(templateForName('button')?.type, ComponentType.button);
      expect(templateForName('infoCard')?.type, ComponentType.infoCard);
      expect(templateForName('hologram'), isNull);
      expect(templateForName(''), isNull);
      expect(templateForName('   '), isNull);
    });

    test('no duplicate types in the palette', () {
      final types = [for (final t in kComponentPalette) t.type];
      expect(types.toSet().length, types.length, reason: 'duplicate type(s)');
    });

    test('requiredProps and optionalProps are DISJOINT (schema is coherent)', () {
      for (final t in kComponentPalette) {
        final opt = t.optionalProps ?? const <String>[];
        final overlap = t.requiredProps.toSet().intersection(opt.toSet());
        expect(overlap, isEmpty,
            reason: '<${t.type}> lists $overlap as BOTH required and optional');
      }
    });
  });

  // ── §4/§5 allowedContainers enforced vs ElementKind ───────────────────────────
  group('§4 · allowedContainers enforced vs ElementKind', () {
    test('every template drops into a CONTENT container (container / list)', () {
      for (final t in kComponentPalette) {
        expect(t.allowedContainers, isNotEmpty,
            reason: '<${t.type}> has nowhere to drop');
        expect(canPlace(t.type, ElementKind.container), isTrue,
            reason: '<${t.type}> should be placeable in a container');
        expect(canPlace(t.type, ElementKind.list), isTrue,
            reason: '<${t.type}> should be placeable in a list');
      }
    });

    test('a template into a LEGAL container is accepted', () {
      // button needs label + a valid catalog actionId.
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.button,
          props: {'label': 'הזמן'},
          actionId: 'cart.add',
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
      expect(v.template!.type, ComponentType.button);
    });

    test('a template into an ILLEGAL (control / leaf / styling) container → reject',
        () {
      for (final kind in kNonContentKinds) {
        expect(canPlace(ComponentType.button, kind), isFalse,
            reason: 'button must NOT be placeable in a ${kind.name} kind');
        final v = validateAddComponent(
          const AddComponentRequest(
            type: ComponentType.button,
            props: {'label': 'הזמן'},
            actionId: 'cart.add',
          ),
          container: kind,
        );
        expect(v.ok, isFalse,
            reason: 'button into a ${kind.name} kind must be rejected');
        expect(v.reasonHe, isNotNull);
        expect(v.reasonHe!.trim(), isNotEmpty);
      }
    });
  });

  // ── §4 governance — NO template allows a control / immutable (auth) kind ───────
  group('§4 governance · no component into an auth/control kind', () {
    test('NO template lists action / text / theme in allowedContainers', () {
      for (final t in kComponentPalette) {
        expect(t.allowedContainers.contains(ElementKind.action), isFalse,
            reason: '<${t.type}> allows dropping onto a control (action) kind — '
                'the reconciled §4 "button into auth" guard forbids it');
        expect(_listsNonContentKind(t.allowedContainers), isFalse,
            reason: '<${t.type}> allows a non-content container kind');
        // Positively: every allowed kind is a content-container kind.
        expect(t.allowedContainers.every(kContentContainerKinds.contains), isTrue,
            reason: '<${t.type}> allowedContainers ⊄ {container, list}');
      }
    });

    test('anti-vacuous — the non-content detector actually FIRES', () {
      // If a template ever listed `action`, THIS would catch it — prove it isn't
      // a no-op by feeding it a synthetic bad set.
      expect(_listsNonContentKind({ElementKind.action}), isTrue);
      expect(_listsNonContentKind({ElementKind.text}), isTrue);
      expect(_listsNonContentKind({ElementKind.theme}), isTrue);
      // …and it does NOT fire on the legitimate content kinds.
      expect(_listsNonContentKind({ElementKind.container, ElementKind.list}),
          isFalse);
    });

    test('anti-vacuous — kContentContainerKinds excludes the control kind', () {
      expect(kContentContainerKinds, contains(ElementKind.container));
      expect(kContentContainerKinds, contains(ElementKind.list));
      expect(kContentContainerKinds, isNot(contains(ElementKind.action)));
      expect(kContentContainerKinds, isNot(contains(ElementKind.text)));
      expect(kContentContainerKinds, isNot(contains(ElementKind.theme)));
    });
  });

  // ── §5 required props — a missing one DROPS the AddComponent ──────────────────
  group('§5 · missing required prop → reject (no half-built AddComponent)', () {
    test('button with NO label → reject', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.button,
          actionId: 'cart.add',
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isFalse);
      expect(v.reasonHe, contains('label'));
    });

    test('button with a label but NO actionId → reject (actionId is required)', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.button,
          props: {'label': 'הזמן'},
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isFalse);
      expect(v.reasonHe, contains('actionId'));
    });

    test('infoCard with a title but NO body → reject', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.infoCard,
          props: {'title': 'שים לב'},
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isFalse);
      expect(v.reasonHe, contains('body'));
    });

    test('a whitespace-only required value counts as MISSING (defanged empty)', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.textBlock,
          props: {'text': '   \n\t '},
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isFalse);
      expect(v.reasonHe, contains('text'));
    });

    test('all required props present → accept (textBlock / badge / infoCard)', () {
      expect(
        validateAddComponent(
          const AddComponentRequest(
              type: ComponentType.textBlock, props: {'text': 'שלום'}),
          container: ElementKind.list,
        ).ok,
        isTrue,
      );
      expect(
        validateAddComponent(
          const AddComponentRequest(
              type: ComponentType.badge, props: {'text': 'חדש'}),
          container: ElementKind.container,
        ).ok,
        isTrue,
      );
      expect(
        validateAddComponent(
          const AddComponentRequest(
            type: ComponentType.infoCard,
            props: {'title': 'שים לב', 'body': 'גוף הכרטיס'},
          ),
          container: ElementKind.container,
        ).ok,
        isTrue,
      );
    });

    test('divider needs NO props → accepts an empty request', () {
      final v = validateAddComponent(
        const AddComponentRequest(type: ComponentType.divider),
        container: ElementKind.container,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
      expect(templateFor(ComponentType.divider)!.requiredProps, isEmpty);
    });
  });

  // ── §9 attached-action grounding against the step-72 catalog ──────────────────
  group('§9 · attached action grounded against the step-72 catalog', () {
    test('button with a REAL catalog actionId → accept + grounded safeActionId', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.button,
          props: {'label': 'סרוק'},
          actionId: 'sheet.scanPlan',
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
      expect(v.safeActionId, 'sheet.scanPlan');
    });

    test('button with an INVENTED actionId → reject (not in the catalog)', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.button,
          props: {'label': 'הרץ'},
          actionId: 'drop.database',
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isFalse);
      expect(v.reasonHe, contains('drop.database'));
    });

    test('linkRow with a REAL catalog actionId → accept', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.linkRow,
          props: {'label': 'פתח סל'},
          actionId: 'cart.open',
        ),
        container: ElementKind.list,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
      expect(v.safeActionId, 'cart.open');
    });

    test('a NON-action component carrying an action id → reject (unsupported)', () {
      // textBlock has optionalAction:false — attaching an action is illegal.
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.textBlock,
          props: {'text': 'שלום'},
          actionId: 'cart.add',
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isFalse);
      expect(v.reasonHe, contains('אינו תומך'));
    });

    test('anti-vacuous — the grounded id is a REAL catalog member', () {
      // Else the accept above could pass on a dead catalog. Prove the catalog has
      // the id, and only button / linkRow carry optionalAction.
      expect(actionCatalogIds(), contains('cart.add'));
      final actionBearing = kComponentPalette
          .where((t) => t.optionalAction)
          .map((t) => t.type)
          .toSet();
      expect(actionBearing,
          unorderedEquals({ComponentType.button, ComponentType.linkRow}));
    });
  });

  // ── §10 flood ceiling (maxPerContainer) ───────────────────────────────────────
  group('§10 · maxPerContainer flood ceiling', () {
    test('divider under the ceiling → accept; AT the ceiling → reject', () {
      final cap = templateFor(ComponentType.divider)!.maxPerContainer!;
      // one below the cap: still room for one more.
      final under = validateAddComponent(
        const AddComponentRequest(type: ComponentType.divider),
        container: ElementKind.container,
        existingOfType: cap - 1,
      );
      expect(under.ok, isTrue, reason: under.reasonHe);
      // already `cap` present: adding one more would exceed → reject.
      final over = validateAddComponent(
        const AddComponentRequest(type: ComponentType.divider),
        container: ElementKind.container,
        existingOfType: cap,
      );
      expect(over.ok, isFalse);
      expect(over.reasonHe, contains('$cap'));
    });

    test('a CAPLESS template never rejects on count (button, huge existing)', () {
      expect(templateFor(ComponentType.button)!.maxPerContainer, isNull);
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.button,
          props: {'label': 'עוד'},
          actionId: 'cart.add',
        ),
        container: ElementKind.container,
        existingOfType: 9999,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
    });

    test('anti-vacuous — exactly the flood-prone type carries a ceiling', () {
      final capped = kComponentPalette
          .where((t) => t.maxPerContainer != null)
          .map((t) => t.type)
          .toSet();
      expect(capped, contains(ComponentType.divider));
    });
  });

  // ── §6 promptSafeText defanging of free-text props ────────────────────────────
  group('§6 · free-text props run through promptSafeText', () {
    test('a single-line label is COLLAPSED (newlines stripped) in safeProps', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.button,
          props: {'label': 'שלום\nעולם\tמשהו'},
          actionId: 'cart.add',
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
      expect(v.safeProps['label'], isNot(contains('\n')));
      expect(v.safeProps['label'], isNot(contains('\t')));
    });

    test('a multi-line body PRESERVES its line structure (not collapsed)', () {
      final v = validateAddComponent(
        const AddComponentRequest(
          type: ComponentType.infoCard,
          props: {'title': 'כותרת', 'body': 'שורה 1\nשורה 2'},
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
      expect(v.safeProps['body'], contains('\n'),
          reason: 'a card body legitimately spans lines — must NOT be collapsed');
    });

    test('an over-long label is hard-capped', () {
      final long = 'א' * 5000;
      final v = validateAddComponent(
        AddComponentRequest(
          type: ComponentType.button,
          props: {'label': long},
          actionId: 'cart.add',
        ),
        container: ElementKind.container,
      );
      expect(v.ok, isTrue, reason: v.reasonHe);
      expect(v.safeProps['label']!.length, lessThanOrEqualTo(200));
    });
  });

  // ── GOLDEN-LIST snapshot — silent-growth gate ─────────────────────────────────
  group('golden-list snapshot · gate against silent palette growth', () {
    test('ALL type names == the hard-coded sorted golden (edit here on change)', () {
      final actual = componentTypeNames().toList()..sort();
      expect(actual, kGoldenComponentTypes);
      expect(kComponentPalette.length, 6, reason: '§1 — 6 component templates');
      expect(ComponentType.values.length, 6);
    });

    test('each template requiredProps == the golden schema', () {
      for (final t in kComponentPalette) {
        expect(t.requiredProps, kGoldenRequiredProps[t.type.name],
            reason: '<${t.type.name}> required-prop schema drifted');
      }
      // Every golden key is a real type (no stale golden rows).
      expect(kGoldenRequiredProps.keys.toSet(),
          unorderedEquals(componentTypeNames()));
    });
  });

  // ── matchComponentTypeName grounding (reuse of the frozen step-71 matcher) ─────
  group('grounding · matchComponentTypeName over the closed type set', () {
    test('every real type name resolves to ITSELF (exact)', () {
      for (final name in componentTypeNames()) {
        expect(matchComponentTypeName(name), name);
      }
    });

    test('a wrapped real name resolves; an invented / blank one → null', () {
      expect(matchComponentTypeName('add a button here'), 'button');
      expect(matchComponentTypeName('"infoCard"'), 'infoCard');
      expect(matchComponentTypeName('hologram'), isNull);
      expect(matchComponentTypeName(''), isNull);
      expect(matchComponentTypeName('   '), isNull);
    });

    test('anti-vacuous — the type-name set is real and finite', () {
      expect(componentTypeNames(), contains('button'));
      expect(componentTypeNames(), contains('divider'));
      expect(componentTypeNames(), isNot(contains('hologram')));
      expect(componentTypeNames().length, 6);
    });
  });
}
