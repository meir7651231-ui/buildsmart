// Track T3 G/H/I DoD guards (Phase-B parallel build).
//   T3.G — rewards/loyalty hub: 7 features display + live coin/challenge/redeem.
//   T3.H — AI hub: 9 tools, alternatives reuse cheaperAlternativeBrand + catalog.
//   T3.I — home content: reorder logic over the prototype section order.
//
// Verbatim numbers/strings are anchored to index.html lines per `expect`.
import 'package:buildsmart/logic/ai_hub_logic.dart';
import 'package:buildsmart/state/home_content_order.dart';
import 'package:buildsmart/state/screen_sections.dart'
    show screenSectionsProvider;
import 'package:buildsmart/state/rewards_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // #99 — rewardsProvider now watches boardAuthProvider (per-username key), which
  // touches SharedPreferences; init the binding + an empty mock so reading it in
  // a bare ProviderContainer no longer hits "Binding not initialized".
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(const <String, Object>{}));

  // ─── T3.G — REWARDS / LOYALTY (proto Category H @21402-21659) ────────────────
  group('T3.G rewards hub', () {
    test('7 hub features map to the 7 verbatim leaves [L21464-21472]', () {
      // The 7 rwFeature flows: challenges/leaderboard/green/coupons/referral/
      // VIP/redeem (rwAchievements was refactored out @21469-21470).
      expect(kMonthlyChallengesSeed, hasLength(3)); // 🎯 אתגרים
      expect(kLeaderboardSeed, hasLength(5)); // 🏆 לוח מובילים
      expect(kGreenBadges, hasLength(4)); // 🌿 תגי ירוק
      expect(kLocationCoupons, hasLength(2)); // 📍 קופונים
      expect(kReferralCode, 'BUILD-7K29'); // 👥 הזמן חבר
      expect(kVipTiers, hasLength(3)); // 💎 VIP
      expect(kRewardsCatalog, hasLength(4)); // 🎁 מימוש
    });

    test('seed coins/streak verbatim [L21409-21411]', () {
      expect(kBuildCoinsSeed, 340);
      expect(kLoginStreak, 4);
    });

    test('awardCoins adds + syncs the "me" leaderboard row [L21487]', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(rewardsProvider.notifier).awardCoins(60);
      final s = c.read(rewardsProvider);
      expect(s.coins, 400);
      final me = s.leaderboard.firstWhere((l) => l.me);
      expect(me.coins, 400);
    });

    test('claimChallenge awards reward + drops the challenge [L21516]', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      // ch3 is already complete (progress 1 / goal 1, reward 100).
      c.read(rewardsProvider.notifier).claimChallenge('ch3');
      final s = c.read(rewardsProvider);
      expect(s.coins, 340 + 100);
      expect(s.challenges.any((x) => x.id == 'ch3'), isFalse);
      expect(s.challenges, hasLength(2));
    });

    test('redeem spends coins when affordable, refuses otherwise [L21640]', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(rewardsProvider.notifier);
      // r3 = 180 (affordable from 340).
      expect(n.redeem(kRewardsCatalog[2]), isTrue);
      expect(c.read(rewardsProvider).coins, 160);
      // r4 = 400 (now unaffordable).
      expect(n.redeem(kRewardsCatalog[3]), isFalse);
      expect(c.read(rewardsProvider).coins, 160);
    });

    test('currentTier walks up tiers by balance [L21605]', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(rewardsProvider).currentTier.name, 'כסף'); // 340 < 500
      c.read(rewardsProvider.notifier).awardCoins(200); // → 540
      expect(c.read(rewardsProvider).currentTier.name, 'זהב');
    });
  });

  // ─── T3.H — AI HUB (proto Category G @21123-21400) ───────────────────────────
  group('T3.H AI hub', () {
    test('predictive-stock seed urgency flag [L21157]', () {
      expect(kStockPreds, hasLength(4));
      // PEX (days 1) + cement (days 3) are urgent (<=3); rebar/glue are not.
      expect(kStockPreds.where((p) => p.urgent).length, 2);
    });

    test('aiAlternatives reuses cheaperAlternativeBrand → cheaper picks', () {
      final alts = aiAlternatives();
      expect(alts, isNotEmpty);
      expect(alts.length, lessThanOrEqualTo(5)); // top-5 [L21255]
      // Every result is genuinely cheaper (positive savings).
      expect(alts.every((a) => a.save > 0), isTrue);
      // From kHomeProductBrands: ברז → rec 189, cheaper 139, save 50.
      final faucet = alts.where((a) => a.cat == 'ברז לכיור');
      expect(faucet, isNotEmpty);
      expect(faucet.first.fromPrice, 189);
      expect(faucet.first.toPrice, 139);
      expect(faucet.first.save, 50);
    });

    test('three-way matching flags mismatches [L21308]', () {
      expect(kThreeWayDocs, hasLength(3));
      expect(kThreeWayDocs.where((d) => !d.match).length, 2); // 1042 + 1039
      expect(kThreeWayDocs.firstWhere((d) => d.id == 'BS-1041').match, isTrue);
    });

    test('weather warns on rain days [L21338]', () {
      expect(kWeather, hasLength(4));
      expect(kWeather.where((d) => d.warn).length, 2);
    });

    test('gear wear pct + worn threshold (>=85%) [L21368]', () {
      expect(kGear, hasLength(4));
      final gen = kGear.firstWhere((g) => g.name == 'גנרטור 5kW');
      expect(gen.pct, 98); // 880/900
      expect(gen.worn, isTrue);
      final hammer = kGear.firstWhere((g) => g.name == 'פטיש חשמלי');
      expect(hammer.worn, isFalse); // 30%
    });

    test('analytics seeds present [L21387]', () {
      expect(kInsights, hasLength(4));
    });
  });

  // ─── T3.I — HOME CONTENT REORDER (proto §1 view-home) ────────────────────────
  group('T3.I home content reorder', () {
    test('default order matches the prototype section sequence', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(homeContentOrderProvider), [
        HomeSection.categories,
        HomeSection.products,
        HomeSection.workPath,
        HomeSection.promise,
        HomeSection.reorderHistory,
      ]);
    });

    test('reorder moves a section (ReorderableListView contract)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(homeContentOrderProvider.notifier);
      // Move products (index 1) to the top (index 0).
      n.reorder(1, 0);
      expect(c.read(homeContentOrderProvider).first, HomeSection.products);
    });

    test('moveUp / moveDown shift one slot and clamp', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(homeContentOrderProvider.notifier);
      n.moveDown(HomeSection.categories); // 0 → 1
      expect(c.read(homeContentOrderProvider)[1], HomeSection.categories);
      n.moveUp(HomeSection.categories); // back to 0
      expect(c.read(homeContentOrderProvider).first, HomeSection.categories);
      // Clamp: can't move the first element up.
      n.moveUp(c.read(homeContentOrderProvider).first);
      expect(c.read(homeContentOrderProvider).first, HomeSection.categories);
    });

    test('reset restores the default order', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(homeContentOrderProvider.notifier);
      n.reorder(0, 5);
      expect(c.read(homeContentOrderProvider).first, isNot(HomeSection.categories));
      n.reset();
      expect(c.read(homeContentOrderProvider), kDefaultHomeOrder);
    });

    test('order always covers every section (no drops)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(homeContentOrderProvider.notifier);
      n.reorder(2, 0);
      n.reorder(4, 1);
      final order = c.read(homeContentOrderProvider);
      expect(order.toSet(), HomeSection.values.toSet());
      expect(order, hasLength(HomeSection.values.length));
    });

    // screen-mgmt slice-3 — the live home now renders through the UNIFIED
    // per-screen model (order + HIDE), keyed 'home', ids == HomeSection.name.
    test('slice-3 — home reads screenSections: default is byte-identical; hide '
        'drops a section from the rendered order; reorder still works', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(screenSectionsProvider.notifier);
      // default = the full prototype order, nothing hidden (byte-identical).
      expect(n.visibleIds(kHomeScreenKey, kHomeSectionIds),
          [for (final s in kDefaultHomeOrder) s.name]);
      // hide workPath → it drops from what SmartHomeBody renders.
      n.hide(kHomeScreenKey, HomeSection.workPath.name);
      expect(n.visibleIds(kHomeScreenKey, kHomeSectionIds),
          isNot(contains(HomeSection.workPath.name)));
      // order still covers every section (hide is non-destructive).
      expect(n.orderedIds(kHomeScreenKey, kHomeSectionIds).toSet(),
          kHomeSectionIds.toSet());
      // reorder is per-screen.
      n.moveDown(kHomeScreenKey, kHomeSectionIds, HomeSection.categories.name);
      expect(n.orderedIds(kHomeScreenKey, kHomeSectionIds).first,
          isNot(HomeSection.categories.name));
    });
  });
}
