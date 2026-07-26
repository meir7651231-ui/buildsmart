// CLEAN EMPTY-SHELL contract (owner 2026-07-25: "לא — הקטלוג גם צריך להיות
// נקי"): profile 'clean' ships the ENGINE with ZERO content — no product
// catalog, no demo record seeds; 'company2' keeps a catalog (the own-catalog
// proof) but ships zero record seeds; demo + buildsmart keep today's content
// byte-identical.
//
// Three locks (the app_profile_flags_test idiom):
//   a. the per-profile MATRIX via the pure mirrors (catalogEmptyForProfile /
//      seedsEmptyForProfile) + mirror ↔ const self-consistency;
//   b. LIVE gate pins — load-bearing in BOTH worlds: under the define-less
//      suite (= demo) they pin every gated seed NON-empty (today's content
//      can't silently vanish); under a profiled run
//      (flutter test --dart-define=APP_PROFILE=clean …) the SAME expectations
//      ARE the empty-shell proof. Config consts (kVipTiers · kPaymentTerms ·
//      kStores) are pinned non-empty on EVERY profile — options/identity are
//      engine, not content (emptying kVipTiers would crash currentTier).
//   c. a CLOSED-SET sweep — every file consuming a content gate is registered
//      here, so a future seed/fixture must consciously join (the
//      boundedness-sweep idiom).

import 'dart:io';

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/chat_seeds.dart' show kChatThreads;
import 'package:buildsmart/data/lipskey_hotwater.dart' show kCompatCatalog;
import 'package:buildsmart/data/persona_data.dart' show kPersonaTasks;
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/data/projects.dart' show kProjects;
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/data/supplier_data.dart' show kStores;
import 'package:buildsmart/features/word_finder/dive_pool.dart'
    show kDivePool;
import 'package:buildsmart/logic/manager_dashboard.dart'
    show kManagerOrderSeed;
import 'package:buildsmart/state/app_profile.dart';
import 'package:buildsmart/state/orders_engine.dart' show kOrdersEngineSeed;
import 'package:buildsmart/state/rewards_state.dart'
    show
        kBuildCoinsSeed,
        kLeaderboardSeed,
        kMonthlyChallengesSeed,
        kVipTiers;
import 'package:flutter_test/flutter_test.dart';

/// Files consuming [kProfileEmptyCatalog] in CODE (not comments): the gate's
/// declaration, the one-point catalog seam, the fixture pools, the two
/// brand-entry hides, and the in-app QA harness expectation. A new consumer
/// fails the sweep and forces a conscious registration.
const Set<String> kCatalogGateConsumers = {
  'lib/state/app_profile.dart', // the gate's declaration
  'lib/data/catalog_source.dart', // the ONE-point catalog seam
  'lib/features/word_finder/dive_pool.dart',
  'lib/features/ring_dive/plain_dive.dart',
  'lib/data/lipskey_hotwater.dart', // kCompatCatalog engine fixture
  'lib/data/smart_tree.dart', // kSmartProducts
  'lib/screens/suppliers_screen.dart', // brand-entry hide + honest empty
  'lib/screens/keyboard_tool_tree.dart', // brand-entry hide
  'lib/test_harness/tests/dsync.dart', // in-app QA: expectation flips
  // import feature (owner "כן" 2026-07-25) — the company-catalog pour-in:
  'lib/state/company_catalog_store.dart', // hydrate guard (clean-only)
  'lib/screens/catalog_screen.dart', // clean-only import-card mount
  // clean-100 (E2E honesty catch): the shell's onboarding must not promise
  // BuildSmart's "thousands of products" — the body line is profile-gated:
  'lib/screens/onboarding_screen.dart',
};

/// Files consuming [kProfileEmptySeeds] in CODE: the declaration + the eight
/// record-seed families (orders+customers · tasks · rewards · site/phaseb ·
/// projects · chat · notifications · finance rows · store projects).
const Set<String> kSeedsGateConsumers = {
  'lib/state/app_profile.dart', // the gate's declaration
  'lib/logic/manager_dashboard.dart', // kManagerOrderSeed (orders+customers)
  'lib/data/persona_data.dart', // kPersonaTasks
  'lib/state/rewards_state.dart', // coins/challenges/leaderboard
  'lib/data/phaseb_seeds.dart', // site-hub family + stock + history
  'lib/data/projects.dart', // kProjects
  'lib/data/chat_seeds.dart', // kChatThreads
  'lib/screens/notifications_screen.dart', // _activeNotifs extension
  'lib/screens/finance_hub_sheets.dart', // 3 demo-row extensions
  'lib/screens/store_screen.dart', // storeProjectsProvider seed
  // completion round: the 3 demo project-name SEARCH rows ride the seeds gate
  'lib/data/search_index.dart',
};

/// Files consuming [kProfileRawShell] in CODE: the gate's declaration + the
/// raw-shell chrome hides (home strip/teaser/scan-row · departments grid+tap ·
/// profession auto-skip · welcome tagline · keyboard dept chips/destinations/
/// deriver · search-index content rows).
const Set<String> kRawShellGateConsumers = {
  'lib/state/app_profile.dart', // the gate's declaration
  'lib/screens/smart_home_screen.dart',
  'lib/screens/departments_screen.dart',
  'lib/screens/onboarding_screen.dart',
  'lib/screens/welcome_screen.dart',
  'lib/screens/keyboard_destinations.dart',
  'lib/screens/keyboard_tool_tree.dart',
  'lib/screens/keyboard_dept_deriver.dart', // crash-guard arm (loud root)
  'lib/data/search_index.dart',
  // completion round: the install-picker chips derive from the live universe
  'lib/screens/install_studio_screen.dart',
  // completion final wave: AI-hub price/plan/analytics tiles + store svc-5
  'lib/screens/ai_hub_screen.dart',
  'lib/screens/store_screen.dart',
};

void main() {
  group('a · matrix — the pure mirrors pin all four profiles', () {
    test('catalog: empty ONLY on clean (company2 keeps the own-catalog proof)',
        () {
      expect(catalogEmptyForProfile('demo'), isFalse);
      expect(catalogEmptyForProfile('buildsmart'), isFalse);
      expect(catalogEmptyForProfile('clean'), isTrue);
      expect(catalogEmptyForProfile('company2'), isFalse);
    });

    test('seeds: empty on clean AND company2 (a company starts life empty)',
        () {
      expect(seedsEmptyForProfile('demo'), isFalse);
      expect(seedsEmptyForProfile('buildsmart'), isFalse);
      expect(seedsEmptyForProfile('clean'), isTrue);
      expect(seedsEmptyForProfile('company2'), isTrue);
    });

    test('shell coherence: a profile with no catalog ships no records either',
        () {
      for (final p in ['demo', 'buildsmart', 'clean', 'company2']) {
        expect(!catalogEmptyForProfile(p) || seedsEmptyForProfile(p), isTrue,
            reason: '$p: an empty-catalog shell must not leak record seeds');
      }
    });

    test('mirror ↔ const self-consistency at the active profile', () {
      expect(kProfileEmptyCatalog, catalogEmptyForProfile(kAppProfile));
      expect(kProfileEmptySeeds, seedsEmptyForProfile(kAppProfile));
      expect(kProfileRawShell, rawShellForProfile(kAppProfile));
    });

    test('raw shell: ONLY clean (BuildMax keeps its chrome-proof) + coherence',
        () {
      expect(rawShellForProfile('demo'), isFalse);
      expect(rawShellForProfile('buildsmart'), isFalse);
      expect(rawShellForProfile('clean'), isTrue);
      expect(rawShellForProfile('company2'), isFalse);
      for (final p in ['demo', 'buildsmart', 'clean', 'company2']) {
        expect(!rawShellForProfile(p) || catalogEmptyForProfile(p), isTrue,
            reason: '$p: a raw shell implies an empty catalog');
      }
    });
  });

  group('b · live gate pins — non-empty under demo, EMPTY under the shell',
      () {
    // Each expectation is two proofs in one:
    //   define-less suite (demo): isEmpty == false → today's content intact;
    //   profiled clean/company2 run: isEmpty == true → truly empty.
    final ce = catalogEmptyForProfile(kAppProfile);
    final se = seedsEmptyForProfile(kAppProfile);

    test('catalog + fixture pools follow the catalog gate', () {
      expect(resolvedCatalogProducts.isEmpty, ce,
          reason: 'the ONE-point seam every consumer inherits');
      expect(kDivePool.isEmpty, ce);
      expect(kCompatCatalog.isEmpty, ce);
      expect(kSmartProducts.isEmpty, ce);
    });

    test('record seeds follow the seeds gate (per family)', () {
      // orders + the derived engine genesis (proves the inheritance chain —
      // a clean deployment can never seed BuildSmart's four demo orders into
      // a fresh company backend):
      expect(kManagerOrderSeed.isEmpty, se);
      expect(kOrdersEngineSeed.isEmpty, se);
      // tasks · rewards · projects · chat:
      expect(kPersonaTasks.isEmpty, se);
      expect(kBuildCoinsSeed == 0, se);
      expect(kMonthlyChallengesSeed.isEmpty, se);
      expect(kLeaderboardSeed.isEmpty, se);
      expect(kProjects.isEmpty, se);
      expect(kChatThreads.isEmpty, se);
      // the site-hub / phaseb family (incl. stock + reorder history):
      expect(kSubcontractors.isEmpty, se);
      expect(kApprovalQueue.isEmpty, se);
      expect(kGanttTasks.isEmpty, se);
      expect(kSnagList.isEmpty, se);
      expect(kInspections.isEmpty, se);
      expect(kArchivedProjects.isEmpty, se);
      expect(kWorkLog.isEmpty, se);
      expect(kStockDemo.isEmpty, se);
      expect(kDemoHistory.isEmpty, se);
    });

    test('config consts are NOT gated — engine identity survives everywhere',
        () {
      expect(kVipTiers, isNotEmpty,
          reason: 'currentTier reads kVipTiers.first — options, not content');
      expect(kPaymentTerms, isNotEmpty,
          reason: 'a picker\'s choices list — options, not records');
      expect(kStores, isNotEmpty,
          reason: 'store_dashboard reads kStores.first — identity/config');
    });
  });

  group('c · closed-set sweep — gate consumers are a registered set', () {
    Set<String> consumersOf(String gateName) {
      final found = <String>{};
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        // Comment-only mentions are fine — scan non-comment lines only
        // (the stage3 sweep idiom).
        final code = f
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        if (code.contains(gateName)) found.add(f.path);
      }
      return found;
    }

    test('every kProfileEmptyCatalog consumer is registered', () {
      expect(consumersOf('kProfileEmptyCatalog'), kCatalogGateConsumers,
          reason: 'a new empty-shell fixture/entry must consciously join '
              'the registry (and get a live pin in group b)');
    });

    test('every kProfileEmptySeeds consumer is registered', () {
      expect(consumersOf('kProfileEmptySeeds'), kSeedsGateConsumers,
          reason: 'a new record-seed gate must consciously join the registry '
              '(and get a live pin in group b)');
    });

    test('every kProfileRawShell consumer is registered', () {
      expect(consumersOf('kProfileRawShell'), kRawShellGateConsumers,
          reason: 'a new raw-shell chrome hide must consciously join the '
              'registry');
    });
  });
}
