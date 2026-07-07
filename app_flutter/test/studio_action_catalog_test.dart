// Step 72 — the static ACTION CATALOG grounded in real route()s + open*Sheet()s.
//
// This suite pins `logic/studio/action_catalog.dart`. It mirrors
// studio_registry_view_test.dart: a grounding group (a model string resolves ONLY
// to a REAL target, never an invented one, never a throw), a golden-list snapshot
// that forces an explicit edit on any catalog change (תוספת-ב), the governance #84
// closed-by-omission audit (no auth / no nav-structure action, no mutation outside
// a confirm-gate), the addition-a context-narrowing, and anti-vacuous checks that
// each predicate actually selects real actions/targets.
import 'package:buildsmart/logic/studio/action_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// GOLDEN — the sorted list of ALL catalog ActionIds (תוספת-ב). Adding/removing an
/// action MUST force an explicit edit here (a gate against silent catalog-growth).
const List<String> kGoldenActionIds = <String>[
  'cart.add',
  'cart.open',
  'nav.screen',
  'share.text',
  'sheet.cheaperAlt',
  'sheet.priceCompare',
  'sheet.scanPlan',
];

/// GOLDEN — the EXACT ~38 no-arg screen ids (the only legal nav.screen targets).
/// Pinned so a silent add/remove of a nav target forces an explicit edit here.
const Set<String> kGoldenNavScreenIds = <String>{
  'AIHubScreen',
  'AiAssistantScreen',
  'BudgetScreen',
  'ChatSettingsScreen',
  'CourierAttendanceScreen',
  'CourierCertsScreen',
  'CourierDashboardScreen',
  'CourierFormsScreen',
  'CourierProfileScreen',
  'CourierSettingsScreen',
  'DescribeToCartScreen',
  'HomeContentReorder',
  'LipskeyBrandScreen',
  'ManagerCopilotScreen',
  'ManagerDashboardScreen',
  'ManagerProfileScreen',
  'NotifSettingsScreen',
  'ProfileScreen',
  'ProjectsScreen',
  'RegressionPanelScreen',
  'RewardsHubScreen',
  'RoleRequestsInboxScreen',
  'SmartProjectScreen',
  'StockScreen',
  'StoreDashboardScreen',
  'StoreProfileScreen',
  'StoreSettingsScreen',
  'SuppliersScreen',
  'TasksScreen',
  'TradeBuilderHomeScreen',
  'TradeDefineStepScreen',
  'WorkerAppScreen',
  'WorkerAttendanceScreen',
  'WorkerFormsScreen',
  'WorkerProfileScreen',
  'WorkerSafetyScreen',
  'WorkerSettingsScreen',
  'WorkerTaskBoardScreen',
};

/// A handful of LIVE typed-arg-only screens (they own a `route(<args>)` and NO
/// no-arg `route()`), so they are DELIBERATELY out of [kNavScreenIds] — a
/// nav.screen target must degrade / be greyed, never resolve to a guessed arg.
const List<String> kTypedArgScreenIds = <String>[
  'AiFinderScreen',
  'BusinessSummaryScreen',
  'CatalogSettingsScreen',
  'ChatsArchiveScreen',
  'ComingSoonScreen',
  'LegalScreen',
  'LipskeySectionScreen',
  'RejectReasonScreen',
  'SpecCopilotScreen',
  'ProductAuthoringScreen',
  'CategoryTreeEditorScreen',
  'ConnectionRuleStudioScreen',
];

/// The auth / nav-STRUCTURE tokens governance #84 forbids from ANY catalog id.
/// (Deliberately specific — bare `nav`/`tab` are NOT here, so `nav.screen` and a
/// future `cart.*` don't false-positive; only a structure MUTATION token trips it.)
const List<String> kForbiddenTokens = <String>[
  // auth capabilities
  'auth', 'login', 'logout', 'signin', 'signout', 'grantrole', 'grant',
  'role', 'permission', 'password', '2fa', 'otp',
  // nav-STRUCTURE mutations
  'navstructure', 'hidetab', 'showtab', 'removetab', 'addtab', 'reordernav',
  'tab.hide', 'tab.remove', 'tab.add', 'nav.hide', 'nav.remove', 'nav.add',
  'nav.reorder', 'bottomnav', 'retab',
];

/// True when [id] carries a forbidden auth / nav-structure token (governance #84).
bool _isForbidden(String id) {
  final lower = id.toLowerCase();
  return kForbiddenTokens.any(lower.contains);
}

void main() {
  // ── Catalog integrity — every ActionId resolves to a grounded effect ──────────
  group('catalog integrity · every ActionId resolves to one effect', () {
    test('no dangling id: each ActionId has a descriptor with a kind + labels',
        () {
      expect(kActionCatalog, isNotEmpty);
      for (final id in actionCatalogIds()) {
        final d = actionDescriptor(id);
        expect(d, isNotNull, reason: 'dangling ActionId <$id> — no descriptor');
        expect(d!.id, id);
        expect(d.kind, isA<ActionEffectKind>());
        expect(d.he.trim(), isNotEmpty, reason: '<$id> has no Hebrew label');
        expect(d.groundedIn.trim(), isNotEmpty,
            reason: '<$id> is not grounded in a real effect');
      }
    });

    test('every openSheet action names WHICH sheet; non-sheet actions do not', () {
      for (final d in kActionCatalog) {
        if (d.kind == ActionEffectKind.openSheet) {
          expect(d.sheetId, isNotNull,
              reason: '<${d.id}> is an openSheet action but names no sheet');
          expect(d.sheetId!.trim(), isNotEmpty);
        } else {
          expect(d.sheetId, isNull,
              reason: '<${d.id}> is not a sheet but carries a sheetId');
        }
      }
    });

    test('actionDescriptor / actionHe of an invented id → null (fail-closed)', () {
      expect(actionDescriptor('totally.invented'), isNull);
      expect(actionDescriptor(''), isNull);
      expect(actionHe('nope.nope'), isNull);
      // a real id resolves its label.
      expect(actionHe('cart.add'), isNotNull);
    });
  });

  // ── nav.screen grounding — the ~38 no-arg routes ONLY ─────────────────────────
  group('nav.screen grounding · matchScreenId over the ~38 no-arg routes', () {
    test('every real no-arg screen id resolves to ITSELF (exact)', () {
      for (final id in kNavScreenIds) {
        expect(matchScreenId(id), id, reason: '<$id> should resolve to itself');
      }
    });

    test('a prose-wrapped real screen id still resolves (longest-contained)', () {
      expect(matchScreenId('שנה את היעד ל ManagerCopilotScreen בבקשה'),
          'ManagerCopilotScreen');
      expect(matchScreenId('"ProfileScreen"'), 'ProfileScreen');
      // Prefix collision: ProfileScreen ⊂ CourierProfileScreen ⇒ the LONG one wins.
      expect(matchScreenId('open CourierProfileScreen now'),
          'CourierProfileScreen');
    });

    test('a TYPED-ARG screen id → null (greyed / degrade, never a guessed arg)',
        () {
      for (final id in kTypedArgScreenIds) {
        expect(kNavScreenIds.contains(id), isFalse,
            reason: '<$id> is typed-arg and must NOT be a legal target');
        expect(matchScreenId(id), isNull,
            reason: '<$id> must degrade, not resolve to a silent effect');
      }
    });

    test('an invented / blank / whitespace target → null (fail-closed)', () {
      expect(matchScreenId('NoSuchScreen'), isNull);
      expect(matchScreenId('auth.login.screen'), isNull); // governance flavour
      expect(matchScreenId(''), isNull);
      expect(matchScreenId('   '), isNull);
      expect(matchScreenId('\n\t '), isNull);
    });

    test('anti-vacuous — the target set is real AND excludes typed-arg screens',
        () {
      // The predicate actually selects real screens…
      expect(kNavScreenIds, contains('ManagerCopilotScreen'));
      expect(kNavScreenIds, contains('ProfileScreen'));
      // …and genuinely omits the typed-arg ones (else the degrade test is moot).
      expect(kNavScreenIds, isNot(contains('AiFinderScreen')));
      expect(kNavScreenIds, isNot(contains('RejectReasonScreen')));
    });
  });

  // ── matchCatalogActionId — grounding a SetAction string to the closed set ─────
  group('matchCatalogActionId · the closed action set', () {
    test('every real action id resolves to itself (exact)', () {
      for (final id in actionCatalogIds()) {
        expect(matchCatalogActionId(id), id);
      }
    });

    test('a wrapped real id resolves; an invented / blank one → null', () {
      expect(matchCatalogActionId('set it to cart.add please'), 'cart.add');
      expect(matchCatalogActionId('drop.database'), isNull);
      expect(matchCatalogActionId('grantRole'), isNull); // governance flavour
      expect(matchCatalogActionId(''), isNull);
      expect(matchCatalogActionId('   '), isNull);
    });
  });

  // ── GOLDEN-LIST snapshot (תוספת-ב) — silent-growth gate ───────────────────────
  group('golden-list snapshot · gate against silent catalog growth', () {
    test('ALL ActionIds == the hard-coded sorted golden (edit here on change)',
        () {
      final actual = actionCatalogIds().toList()..sort();
      expect(actual, kGoldenActionIds);
      expect(actionCatalogIds().length, kGoldenActionIds.length);
      expect(kActionCatalog.length, 7, reason: '§4 — 7 grounded actions');
    });

    test('no duplicate ActionIds in the catalog', () {
      final ids = [for (final a in kActionCatalog) a.id];
      expect(ids.toSet().length, ids.length, reason: 'duplicate ActionId(s)');
    });

    test('nav.screen target set == the hard-coded 38-id golden', () {
      expect(kNavScreenIds, unorderedEquals(kGoldenNavScreenIds));
      expect(kNavScreenIds.length, 38, reason: 'live tree has 38 no-arg routes');
    });
  });

  // ── Governance #84 — closed BY OMISSION (no auth / no nav-structure) ──────────
  group('governance #84 · closed by omission', () {
    test('ActionEffectKind is CLOSED to the five grounded kinds (no auth kind)',
        () {
      // Adding an `auth` / `navStructure` kind later fails HERE — the capability
      // cannot be expressed while this stays green.
      expect(ActionEffectKind.values.toSet(), <ActionEffectKind>{
        ActionEffectKind.navScreen,
        ActionEffectKind.openSheet,
        ActionEffectKind.cartAdd,
        ActionEffectKind.cartOpen,
        ActionEffectKind.shareText,
      });
      expect(ActionEffectKind.values.length, 5);
    });

    test('NO catalog id is an auth / nav-structure capability', () {
      for (final d in kActionCatalog) {
        expect(_isForbidden(d.id), isFalse,
            reason: '<${d.id}> looks like an auth / nav-structure capability — '
                'governance #84 forbids it in the catalog');
      }
    });

    test('NO mutation is reachable outside a confirm-gate (mutates ⇒ gated)', () {
      for (final d in kActionCatalog) {
        if (d.mutates) {
          expect(d.confirmGated, isTrue,
              reason: '<${d.id}> mutates state but is NOT confirm-gated (§7.5)');
        }
      }
    });

    test('anti-vacuous — the catalog DOES contain a confirm-gated mutator', () {
      // Else "mutates ⇒ gated" and the read-only narrowing would be vacuous.
      final mutators = kActionCatalog.where((d) => d.mutates).toList();
      expect(mutators, isNotEmpty, reason: 'no mutator ⇒ the gate test is moot');
      expect(mutators.map((d) => d.id), contains('cart.add'));
      expect(actionDescriptor('cart.add')!.confirmGated, isTrue);
    });

    test('anti-vacuous — the forbidden-token detector actually FIRES', () {
      // Prove the #84 scan is not a no-op: it must flag real bad ids…
      expect(_isForbidden('auth.login'), isTrue);
      expect(_isForbidden('nav.hideTab'), isTrue);
      expect(_isForbidden('grantRole'), isTrue);
      // …while NOT flagging the legitimate nav-to-a-screen action.
      expect(_isForbidden('nav.screen'), isFalse);
      expect(_isForbidden('cart.open'), isFalse);
    });
  });

  // ── Addition-a — context-narrowing (a read-only button hides mutators) ────────
  group('addition-a · catalogActionIdsFor context-narrowing', () {
    test('a MUTABLE context sees the whole catalog', () {
      expect(catalogActionIdsFor('some.btn', readOnly: false),
          unorderedEquals(actionCatalogIds()));
    });

    test('a READ-ONLY context hides every mutator (no cart.add)', () {
      final ro = catalogActionIdsFor('display.card.btn', readOnly: true);
      expect(ro, isNot(contains('cart.add')));
      // Non-mutating actions remain reachable.
      expect(ro, contains('nav.screen'));
      expect(ro, contains('share.text'));
      expect(ro, contains('cart.open'));
    });

    test('anti-vacuous — read-only is a STRICT subset (it removes real actions)',
        () {
      final all = catalogActionIdsFor('x', readOnly: false);
      final ro = catalogActionIdsFor('x', readOnly: true);
      expect(ro.length, lessThan(all.length),
          reason: 'read-only narrowing removed nothing — the mutator flag is dead');
      expect(all.difference(ro), contains('cart.add'));
    });

    test('a blank elementId is fail-closed (empty set)', () {
      expect(catalogActionIdsFor('', readOnly: false), isEmpty);
      expect(catalogActionIdsFor('   ', readOnly: true), isEmpty);
    });
  });
}
