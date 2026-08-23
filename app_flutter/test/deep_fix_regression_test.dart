// Deep-fix regression guards — three behavioural locks for bugs just fixed.
//
//   HIGH#1  cart-per-project round-trip — the projects_screen `_switch` swap,
//           replicated end-to-end against the LIVE smartCartProvider +
//           projectsProvider (a switch must stash the outgoing cart and
//           restore the incoming one, so a project's cart survives a round-trip).
//   MED#4   vacuum-breaker for 'ציוד גן' — a garden-equipment supply product
//           must surface the same anti-siphon ('שובר-ואקום') warning a 'ברזי גן'
//           garden tap does (install_engine.lineComplianceChecklist, :186-204).
//   HIGH#3  profile-isolation — ProfileScreen only offers '🔄 החלפת תפקיד' to
//           the contractor (activePersona == null); every other persona opens
//           the same screen from inside its world and must NOT see it.
//
// Harness idioms reused verbatim:
//   • ProviderContainer + SharedPreferences.setMockInitialValues({})
//       — from repositories_test.dart.
//   • pump(): ProviderScope > MaterialApp(he) > Directionality.rtl > Scaffold,
//     6×100ms pumps — from settings_honesty_test.dart.
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/lipskey_hotwater.dart' show kCompatCatalog;
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  // ── HIGH#1 · cart-per-project round-trip (the real _switch swap) ────────────
  group('HIGH#1 cart-per-project round-trip (projects_screen._switch)', () {
    // A SmartCartLine is immutable; a tiny factory keeps the cases readable.
    SmartCartLine line(String key, String name, int price) => SmartCartLine(
          productKey: key,
          productName: name,
          productEmoji: '🚿',
          brandName: 'X',
          brandPrice: price,
          productQty: 1,
          accessories: const [],
        );

    // Replicates projects_screen._switch verbatim: read the live shared cart,
    // hand it to switchProject as the outgoing snapshot, then load the returned
    // incoming snapshot back into the live shared cart (null = no-op, skip).
    void switchTo(ProviderContainer c, String id) {
      final outgoing = c.read(smartCartProvider);
      final incoming = c
          .read(projectsProvider.notifier)
          .switchProject(id, outgoingCart: outgoing);
      if (incoming != null) {
        c.read(smartCartProvider.notifier).loadSnapshot(incoming);
      }
    }

    test("A's cart survives a switch to B and back to A", () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // Start on the seed-active project (PRJ-1). Add a line to its live cart.
      expect(c.read(projectsProvider).activeId, 'PRJ-1');
      c.read(smartCartProvider.notifier).add(line('k-a', 'ברז A', 100));
      expect(c.read(smartCartProvider).map((l) => l.productKey), ['k-a']);

      // Switch to PRJ-2 → its (empty) snapshot becomes the live cart.
      switchTo(c, 'PRJ-2');
      expect(c.read(projectsProvider).activeId, 'PRJ-2');
      expect(c.read(smartCartProvider), isEmpty,
          reason: "B's snapshot is empty, so the live cart is cleared");

      // Add a DIFFERENT line on B.
      c.read(smartCartProvider.notifier).add(line('k-b', 'ברז B', 200));
      expect(c.read(smartCartProvider).map((l) => l.productKey), ['k-b']);

      // Switch back to A → A's ORIGINAL line is restored (the fix under test).
      switchTo(c, 'PRJ-1');
      expect(c.read(projectsProvider).activeId, 'PRJ-1');
      expect(c.read(smartCartProvider).map((l) => l.productKey), ['k-a'],
          reason: "A's cart must be restored intact after the round-trip");

      // And B still holds its own line — switch forward once more to prove it.
      switchTo(c, 'PRJ-2');
      expect(c.read(smartCartProvider).map((l) => l.productKey), ['k-b'],
          reason: "B's stashed cart is independent of A's");
    });
  });

  // ── MED#4 · vacuum-breaker for 'ציוד גן' (anti-siphon warning) ──────────────
  group("MED#4 vacuum-breaker warning for 'ציוד גן'", () {
    const vacuumLabel = 'שובר-ואקום למניעת זרימה-חוזרת';

    // The vacuum-breaker LineCheck fires only on a SUPPLY line that also carries
    // a garden outlet (categoryHe 'ברזי גן' OR 'ציוד גן'). `lineIsSupply` reads
    // verified specs, NOT the category — so we anchor the chain with a product
    // the engine itself classifies as supply, then add the garden part. Both
    // selections come from the live catalog via the engine's own predicates, so
    // the test stays correct if the catalog is reshuffled (and fails loudly if a
    // required product ever disappears).
    LipskeyCatalogProduct firstWhereOrThrow(
        bool Function(LipskeyCatalogProduct) test, String what) {
      final hit = kCompatCatalog.where(test);
      expect(hit, isNotEmpty, reason: 'catalog must contain $what');
      return hit.first;
    }

    bool hasVacuumWarning(List<LipskeyCatalogProduct> chain) =>
        // tempC 20 (cold) keeps the hot-water checks out of the way; the
        // accessories set is empty (we only care whether the warning appears).
        lineComplianceChecklist(chain, 20, const {})
            .any((c) => c.label == vacuumLabel && !c.satisfied);

    test("a 'ציוד גן' supply product triggers the anti-siphon warning", () {
      // A guaranteed-supply anchor (the engine classifies it as supply).
      final supply =
          firstWhereOrThrow((p) => lineIsSupply([p]), 'a supply product');
      // A real garden-equipment part.
      final gardenEquip = firstWhereOrThrow(
          (p) => p.categoryHe == 'ציוד גן', "a 'ציוד גן' product");

      expect(hasVacuumWarning([supply, gardenEquip]), isTrue,
          reason: "a supply line carrying a 'ציוד גן' part needs a "
              'vacuum-breaker (anti-siphon) — it must not silently pass');
    });

    test("'ציוד גן' triggers the SAME warning a 'ברזי גן' tap does", () {
      final supply =
          firstWhereOrThrow((p) => lineIsSupply([p]), 'a supply product');
      final gardenTap = firstWhereOrThrow(
          (p) => p.categoryHe == 'ברזי גן', "a 'ברזי גן' product");
      final gardenEquip = firstWhereOrThrow(
          (p) => p.categoryHe == 'ציוד גן', "a 'ציוד גן' product");

      // The known-good case ('ברזי גן') and the fixed case ('ציוד גן') must
      // both raise the identical vacuum-breaker LineCheck.
      expect(hasVacuumWarning([supply, gardenTap]), isTrue,
          reason: "'ברזי גן' is the established trigger");
      expect(hasVacuumWarning([supply, gardenEquip]),
          hasVacuumWarning([supply, gardenTap]),
          reason: "'ציוד גן' must behave identically to 'ברזי גן'");
    });
  });

  // ── HIGH#3 · profile-isolation (role-switch only for the contractor) ────────
  group('HIGH#3 profile role-switch isolation', () {
    const switchRoleLabel = '🔄 החלפת תפקיד';

    // pump() — copied from settings_honesty_test.dart, plus the [overrides] hook
    // so each case can pin activePersonaProvider before the first frame.
    Future<void> pump(WidgetTester t,
        {List<Override> overrides = const []}) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            locale: const Locale('he'),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: const Scaffold(body: ProfileScreen()),
            ),
          ),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('a non-null persona (store) hides the role-switch row',
        (t) async {
      await pump(t, overrides: [
        activePersonaProvider.overrideWith((_) => 'store'),
      ]);
      expect(find.text(switchRoleLabel), findsNothing,
          reason: 'role-switching is reachable only from the contractor');
    });

    testWidgets('the default persona (null = contractor) shows the row',
        (t) async {
      await pump(t); // no override → activePersonaProvider defaults to null
      expect(find.text(switchRoleLabel), findsOneWidget,
          reason: 'the contractor world surfaces the role picker');
    });
  });
}
