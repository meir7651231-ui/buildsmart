// Giant-system Phase 1 / V1 — the runtime OrgConfig layer, pure tier.
// Locks: (a) the DEFAULT is all-on by construction (absent=on — byte-identity
// needs no name enumeration); (b) toggle semantics: only false turns off,
// module-off cascades, core modules never turn off; (c) termOf returns the
// SAME fallback object when unbranded (identity — the cheap path is provable);
// (d) the codec is tolerant per-field and null only on structural corruption;
// (e) the resolver is TOTAL: owner beats company beats default, a corrupt
// layer is a skipped layer. This is also the toggle-matrix SEED for V2.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/state/studio/element_registry.dart'
    show kElementRegistry;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flag ships OFF (compile default — the arming-layer backstop)', () {
    expect(kOrgConfigFlag, isFalse);
  });

  group('default = all-on by construction', () {
    test('every module/feature reads ON against the empty default', () {
      for (final m in ['catalog', 'orders', 'finance', 'anything-future']) {
        expect(moduleOn(kDefaultOrgConfig, m), isTrue, reason: m);
        expect(featureOn(kDefaultOrgConfig, m, 'x'), isTrue, reason: '$m.x');
      }
    });

    test('termOf returns the SAME fallback object when unbranded', () {
      const fb = 'ברזים וכיורים';
      expect(identical(termOf(kDefaultOrgConfig, 'nav.catalog', fb), fb),
          isTrue);
    });
  });

  group('toggle matrix seed (the V2 template)', () {
    const cfg = OrgConfig(
      modules: {'finance': false, 'chat': true},
      features: {'manager.approvals': false, 'finance.credit': true},
    );

    test('absent=on · true=on · only false=off', () {
      expect(moduleOn(cfg, 'chat'), isTrue);
      expect(moduleOn(cfg, 'rewards'), isTrue, reason: 'absent');
      expect(moduleOn(cfg, 'finance'), isFalse);
      expect(featureOn(cfg, 'manager', 'approvals'), isFalse);
      expect(featureOn(cfg, 'manager', 'anything-else'), isTrue);
    });

    test('module-off CASCADES to its features (even explicitly-true ones)',
        () {
      expect(featureOn(cfg, 'finance', 'credit'), isFalse,
          reason: 'finance module is off — its true feature must not leak');
    });

    test('core modules never turn off; a core FEATURE still can', () {
      const hostile = OrgConfig(
        modules: {'catalog': false, 'orders': false},
        features: {'catalog.import': false},
      );
      for (final core in kCoreModules) {
        expect(moduleOn(hostile, core), isTrue, reason: core);
      }
      expect(featureOn(hostile, 'catalog', 'import'), isFalse);
      expect(featureOn(hostile, 'catalog', 'browse'), isTrue);
    });

    test('featureEnabled is opt-IN (Phase-2): absent=OFF · true=on · '
        'false=off · module-off cascades', () {
      // The live default: a NET-NEW surface is DARK unless explicitly enabled.
      expect(featureEnabled(kDefaultOrgConfig, 'manager', 'attention'), isFalse,
          reason: 'absent ⇒ off (the byte-identical live app)');
      expect(
          featureEnabled(const OrgConfig(features: {'manager.attention': true}),
              'manager', 'attention'),
          isTrue);
      expect(
          featureEnabled(
              const OrgConfig(features: {'manager.attention': false}),
              'manager',
              'attention'),
          isFalse);
      expect(
          featureEnabled(
              const OrgConfig(
                modules: {'manager': false},
                features: {'manager.attention': true},
              ),
              'manager',
              'attention'),
          isFalse,
          reason: 'a dark module forces its opt-in feature off too');
    });
  });

  group('codec — tolerant per-field, structural-null only', () {
    test('round-trip preserves the config', () {
      const c = OrgConfig(
        slug: 'alpha',
        orgName: 'אלפא בע"מ',
        modules: {'finance': false},
        features: {'manager.approvals': false},
        terms: {'entity.customer': 'לקוח קצה'},
      );
      final back = decodeOrgConfig(encodeOrgConfig(c))!;
      expect(back.slug, 'alpha');
      expect(back.orgName, 'אלפא בע"מ');
      expect(back.modules['finance'], isFalse);
      expect(back.terms['entity.customer'], 'לקוח קצה');
    });

    test('structural corruption → null; never throws', () {
      expect(decodeOrgConfig('garbage{'), isNull);
      expect(decodeOrgConfig('[]'), isNull);
      expect(decodeOrgConfig('{"v":2}'), isNull);
    });

    test('a wrong-typed field is skipped — siblings survive (iron-rule-1)',
        () {
      final c = decodeOrgConfig(
          '{"v":1,"orgName":"אלפא","modules":"not-a-map",'
          '"terms":{"k":"ערך"}}');
      expect(c, isNotNull);
      expect(c!.orgName, 'אלפא');
      expect(c.modules, isEmpty, reason: 'bad field dropped, not fatal');
      expect(c.terms['k'], 'ערך');
    });
  });

  group('resolver — TOTAL, owner > company > default', () {
    test('owner wins; company fills when owner is corrupt; default last', () {
      final owner = encodeOrgConfig(const OrgConfig(orgName: 'בעלים'));
      final company = encodeOrgConfig(const OrgConfig(orgName: 'חברה'));
      expect(resolveOrgConfig(ownerJson: owner, companyJson: company).orgName,
          'בעלים');
      expect(
          resolveOrgConfig(ownerJson: 'garbage{', companyJson: company)
              .orgName,
          'חברה',
          reason: 'a corrupt layer is a skipped layer');
      expect(
          identical(resolveOrgConfig(ownerJson: 'garbage{', companyJson: '['),
              kDefaultOrgConfig),
          isTrue);
      expect(identical(resolveOrgConfig(), kDefaultOrgConfig), isTrue);
    });
  });

  // ── giant · setup-wizard element show/hide axis (org_config.dart) ──
  // The wizard recycles the Studio element_registry as per-element toggles,
  // stored in [features] under an `element.<id>` key so they ride the EXISTING
  // codec with ZERO schema change: absent=shown (byte-identical), only an
  // explicit false hides. The kImmutable force-visible core-lock lives one
  // layer up in the gate (org_gates.elementVisible) — see the matrix suite.
  group('element show/hide axis — absent=shown, only false hides', () {
    test('absent = SHOWN for every registry id (byte-identity, no enumeration)',
        () {
      expect(kElementRegistry, isNotEmpty, reason: 'the toggle source is real');
      const cfg = OrgConfig();
      for (final d in kElementRegistry) {
        expect(elementShown(cfg, d.id), isTrue, reason: d.id);
      }
    });

    test('explicit false hides that id ONLY; every sibling stays shown', () {
      const cfg = OrgConfig(features: {'element.cart.cta': false});
      expect(elementShown(cfg, 'cart.cta'), isFalse);
      expect(elementShown(cfg, 'home.topbar.brand'), isTrue,
          reason: 'only the named element hides');
      expect(elementShown(cfg, 'not-in-any-registry'), isTrue,
          reason: 'absent ⇒ shown, exactly like a registry id');
    });

    test('byte-identity: the all-shown default carries NO element key', () {
      // every element defaults shown ⇒ the config encodes to the bare envelope
      // (the A4 omit-empty idiom) — byte-identical to the pre-axis app, no
      // element name ever enumerated into the persisted blob.
      final encoded = encodeOrgConfig(const OrgConfig());
      expect(encoded, '{"v":1}');
      expect(encoded.contains('element.'), isFalse);
    });

    test('a hidden element rides the existing codec — round-trip stable', () {
      const cfg = OrgConfig(features: {'element.cart.cta': false});
      final back = decodeOrgConfig(encodeOrgConfig(cfg))!;
      expect(back.features['element.cart.cta'], isFalse);
      expect(elementShown(back, 'cart.cta'), isFalse,
          reason: 'the hide survives encode→decode with zero schema change');
    });
  });
}
