// Giant-system V4 — vertical packs: the registry is closed-set and honest,
// applyVerticalPack is a deterministic FULL REPLACE of terms+modules (never a
// merge — no residue from a previous pack), and everything else in the config
// survives byte-equal. Pure tier — no widgets (the V5 wizard is the consumer).

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/config/vertical_packs.dart';
import 'package:flutter_test/flutter_test.dart';

/// The wave-1 module registry (org_gates law): the ONLY keys a pack may
/// toggle. Core (catalog/orders) is deliberately absent — packs cannot even
/// TRY to kill it.
const _moduleRegistry = {
  'chat', 'manager', 'supplier', 'courier', 'worker', 'finance', 'rewards',
  'site', 'compat', 'ai', 'dive', 'search', 'intel',
};

/// The consumed term keys (V3 registry — brand.* + nav.*). Site-level CfgText
/// ids are legal too, but starter packs stick to the documented core set.
const _termRegistry = {
  'brand.name', 'brand.club',
  'nav.home', 'nav.catalog', 'nav.updates', 'nav.store',
};

void main() {
  test('registry integrity — 6 packs, unique ids, the default leads', () {
    expect(kVerticalPacks, hasLength(6));
    final ids = kVerticalPacks.map((p) => p.id).toSet();
    expect(ids, hasLength(6), reason: 'ids are unique');
    expect(kVerticalPacks.first.id, 'building_supplier',
        reason: 'the first pack is the identity/default vertical');
    expect(kVerticalPacks.first.terms, isEmpty);
    expect(kVerticalPacks.first.modules, isEmpty);
    for (final p in kVerticalPacks) {
      expect(p.emoji, isNotEmpty, reason: p.id);
      expect(p.label, isNotEmpty, reason: p.id);
    }
  });

  test('closed-set — packs only speak registered keys and never touch core',
      () {
    for (final p in kVerticalPacks) {
      for (final m in p.modules.keys) {
        expect(_moduleRegistry.contains(m), isTrue,
            reason: '${p.id} toggles unregistered module "$m"');
      }
      expect(p.modules.containsKey('catalog'), isFalse, reason: p.id);
      expect(p.modules.containsKey('orders'), isFalse, reason: p.id);
      for (final t in p.terms.keys) {
        expect(_termRegistry.contains(t), isTrue,
            reason: '${p.id} terms unregistered key "$t"');
      }
    }
  });

  test('domain honesty — compat (the pipe-thread engine) stays ON for '
      'plumbing, OFF for electric/tools/ceramics', () {
    OrgConfig applied(String id) =>
        applyVerticalPack(const OrgConfig(), verticalPackById(id)!);
    expect(moduleOn(applied('plumbing'), 'compat'), isTrue);
    for (final id in ['electric', 'tools', 'ceramics']) {
      expect(moduleOn(applied(id), 'compat'), isFalse, reason: id);
    }
  });

  test('apply = FULL replace of terms+modules; identity/theme/features '
      'preserved byte-equal', () {
    const dirty = OrgConfig(
      slug: 'acme',
      orgName: 'אלמוג בניין',
      theme: {'brand': '#123456'},
      features: {'orders.services': false},
      modules: {'chat': false, 'zzz': true},
      terms: {'nav.home': 'JUNK', 'stale.key': 'x'},
    );
    final pack = verticalPackById('plumbing')!;
    final out = applyVerticalPack(dirty, pack);
    expect(out.modules, equals(pack.modules),
        reason: 'no residue — the stale zzz/chat keys are gone');
    expect(out.terms, equals(pack.terms), reason: 'JUNK terms wiped');
    expect(out.slug, 'acme');
    expect(out.orgName, 'אלמוג בניין');
    expect(out.theme, equals(const {'brand': '#123456'}));
    expect(out.features, equals(const {'orders.services': false}),
        reason: 'features are NOT pack territory (V4.3 — the rest survives)');
  });

  test('deterministic — applying twice equals applying once', () {
    const base = OrgConfig(slug: 's', modules: {'ai': false});
    final pack = verticalPackById('electric')!;
    final once = applyVerticalPack(base, pack);
    final twice = applyVerticalPack(once, pack);
    expect(twice.modules, equals(once.modules));
    expect(twice.terms, equals(once.terms));
    expect(twice.slug, once.slug);
  });

  test('reversible — the default pack restores the all-on base', () {
    const base = OrgConfig(slug: 's', orgName: 'n');
    final tuned = applyVerticalPack(base, verticalPackById('electric')!);
    expect(moduleOn(tuned, 'compat'), isFalse, reason: 'precondition');
    final back =
        applyVerticalPack(tuned, verticalPackById('building_supplier')!);
    expect(back.modules, isEmpty);
    expect(back.terms, isEmpty);
    for (final m in _moduleRegistry) {
      expect(moduleOn(back, m), isTrue, reason: m);
    }
    expect(back.slug, 's');
    expect(back.orgName, 'n');
  });

  test('lookup — verticalPackById finds all six, null for unknown', () {
    for (final p in kVerticalPacks) {
      expect(verticalPackById(p.id), same(p));
    }
    expect(verticalPackById('no_such_vertical'), isNull);
  });
}
