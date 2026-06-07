// 🎮 מועדון BuildSmart — runtime state for the rewards/loyalty hub (T3.G).
//
// A faithful port of proto Category H — GAMIFICATION & LOYALTY
// (index.html:21402-21659, openRewardsHub @21452). The prototype keeps these as
// module-scoped mutable vars (`buildCoins` / `monthlyChallenges` / `leaderboard`
// / `rewardsCatalog`); restored here as Riverpod state that STARTS from verbatim
// seed literals and mutates exactly like the proto flows:
//   • awardCoins(n)          @21487 — adds coins + syncs the "me" leaderboard row.
//   • claimChallenge(id)     @21516 — awards reward, drops the challenge.
//   • redeemReward(id)       @21640 — spends coins (guarded by balance).
//
// All seed numbers/strings are VERBATIM from the prototype (R8 — no invented
// values). The display-only seeds (greenBadges / locationCoupons / vipTiers) are
// plain consts consumed by the screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Seeds — VERBATIM from index.html:21409-21444.
// ─────────────────────────────────────────────────────────────────────────────

/// Starting coin balance — proto `var buildCoins=340` @21409.
const int kBuildCoinsSeed = 340;

/// Consecutive active days — proto `var loginStreak=4` @21410.
const int kLoginStreak = 4;

/// Referral code — proto `var referralCode='BUILD-7K29'` @21411.
const String kReferralCode = 'BUILD-7K29';

/// One monthly challenge — proto `monthlyChallenges` object @21412-21416.
class RwChallenge {
  const RwChallenge({
    required this.id,
    required this.name,
    required this.goal,
    required this.progress,
    required this.reward,
  });

  final String id;
  final String name;
  final int goal;
  final int progress;
  final int reward;

  bool get done => progress >= goal;
}

/// proto `monthlyChallenges` @21412-21416 — VERBATIM.
const List<RwChallenge> kMonthlyChallengesSeed = [
  RwChallenge(id: 'ch1', name: 'בצע 5 הזמנות החודש', goal: 5, progress: 3, reward: 80),
  RwChallenge(id: 'ch2', name: 'הזמן 3 קטגוריות שונות', goal: 3, progress: 2, reward: 60),
  RwChallenge(id: 'ch3', name: 'אפס חריגות תקציב', goal: 1, progress: 1, reward: 100),
];

/// One leaderboard row — proto `leaderboard` object @21417-21423.
class RwLeader {
  const RwLeader({
    required this.name,
    required this.coins,
    required this.rank,
    this.me = false,
  });

  final String name;
  final int coins;
  final int rank;
  final bool me;
}

/// proto `leaderboard` @21417-21423 — VERBATIM.
const List<RwLeader> kLeaderboardSeed = [
  RwLeader(name: 'קבלן לוי ובניו', coins: 1240, rank: 1),
  RwLeader(name: 'שיפוצי הצפון', coins: 980, rank: 2),
  RwLeader(name: 'אתה', coins: 340, rank: 3, me: true),
  RwLeader(name: 'בנייה ירוקה בע״מ', coins: 295, rank: 4),
  RwLeader(name: 'דוד אינסטלציה', coins: 210, rank: 5),
];

/// One green sustainability badge — proto `greenBadges` object @21424-21429.
class RwGreenBadge {
  const RwGreenBadge({
    required this.ic,
    required this.name,
    required this.desc,
    required this.earned,
  });

  final String ic;
  final String name;
  final String desc;
  final bool earned;
}

/// proto `greenBadges` @21424-21429 — VERBATIM.
const List<RwGreenBadge> kGreenBadges = [
  RwGreenBadge(ic: '♻️', name: 'מחזור חומרים', desc: '10 בקשות החזרה של עודפים', earned: true),
  RwGreenBadge(ic: '🌱', name: 'רכש בר-קיימא', desc: '5 הזמנות של חומרים ירוקים', earned: true),
  RwGreenBadge(ic: '📦', name: 'אריזה חוזרת', desc: '20 משטחים שהוחזרו', earned: false),
  RwGreenBadge(ic: '⚡', name: 'חיסכון אנרגיה', desc: 'בחירת ציוד חסכוני', earned: false),
];

/// One location coupon — proto `locationCoupons` object @21430-21433.
class RwCoupon {
  const RwCoupon({
    required this.ic,
    required this.place,
    required this.deal,
    required this.dist,
  });

  final String ic;
  final String place;
  final String deal;
  final String dist;
}

/// proto `locationCoupons` @21430-21433 — VERBATIM.
const List<RwCoupon> kLocationCoupons = [
  RwCoupon(ic: '🏪', place: 'מחסני אינסטלציה תל-אביב', deal: '10% הנחה — בקרבת מקום', dist: '0.8 ק״מ'),
  RwCoupon(ic: '🏬', place: 'ספקי סניטריה השרון', deal: 'משלוח חינם להזמנה הבאה', dist: '2.3 ק״מ'),
];

/// One VIP tier — proto `vipTiers` object @21434-21438.
class RwVipTier {
  const RwVipTier({required this.name, required this.min, required this.perks});

  final String name;
  final int min;
  final String perks;
}

/// proto `vipTiers` @21434-21438 — VERBATIM.
const List<RwVipTier> kVipTiers = [
  RwVipTier(name: 'כסף', min: 0, perks: 'צבירת BuildCoins · תמיכה רגילה'),
  RwVipTier(name: 'זהב', min: 500, perks: 'הנחת 5% · משלוח מהיר · תמיכה מועדפת'),
  RwVipTier(name: 'פלטינה', min: 1500, perks: 'הנחת 10% · מנהל לקוח אישי · מחירים מיוחדים'),
];

/// One redeemable reward — proto `rewardsCatalog` object @21439-21444.
class RwReward {
  const RwReward({
    required this.id,
    required this.ic,
    required this.name,
    required this.cost,
  });

  final String id;
  final String ic;
  final String name;
  final int cost;
}

/// proto `rewardsCatalog` @21439-21444 — VERBATIM.
const List<RwReward> kRewardsCatalog = [
  RwReward(id: 'r1', ic: '🚚', name: 'משלוח אקספרס חינם', cost: 120),
  RwReward(id: 'r2', ic: '🎁', name: 'שובר ₪50 לרכש', cost: 250),
  RwReward(id: 'r3', ic: '🔧', name: 'יום השכרת כלי חינם', cost: 180),
  RwReward(id: 'r4', ic: '⭐', name: 'שדרוג ל-VIP זהב לחודש', cost: 400),
];

// ─────────────────────────────────────────────────────────────────────────────
// Live state — coins, the active challenge list, and the leaderboard (which
// keeps its "me" row's coin count in sync, exactly like the proto).
// ─────────────────────────────────────────────────────────────────────────────

/// The full mutable rewards state for one contractor session.
class RewardsState {
  const RewardsState({
    required this.coins,
    required this.challenges,
    required this.leaderboard,
  });

  final int coins;
  final List<RwChallenge> challenges;
  final List<RwLeader> leaderboard;

  RewardsState copyWith({
    int? coins,
    List<RwChallenge>? challenges,
    List<RwLeader>? leaderboard,
  }) =>
      RewardsState(
        coins: coins ?? this.coins,
        challenges: challenges ?? this.challenges,
        leaderboard: leaderboard ?? this.leaderboard,
      );

  /// The current VIP tier for the live balance — proto `rwVIP` loop @21605-21606
  /// (`cur` walks up while `buildCoins>=t.min`).
  RwVipTier get currentTier {
    var cur = kVipTiers.first;
    for (final t in kVipTiers) {
      if (coins >= t.min) cur = t;
    }
    return cur;
  }
}

class RewardsNotifier extends StateNotifier<RewardsState> {
  RewardsNotifier()
      : super(const RewardsState(
          coins: kBuildCoinsSeed,
          challenges: kMonthlyChallengesSeed,
          leaderboard: kLeaderboardSeed,
        ));

  /// Add [n] coins and keep the "me" leaderboard row in sync — proto
  /// `awardCoins` @21487-21494.
  void awardCoins(int n) {
    final coins = state.coins + n;
    state = state.copyWith(coins: coins, leaderboard: _syncMe(coins));
  }

  /// Claim a completed challenge: award its reward then drop it from the active
  /// list — proto `claimChallenge` @21516-21524.
  void claimChallenge(String id) {
    RwChallenge? c;
    for (final x in state.challenges) {
      if (x.id == id) {
        c = x;
        break;
      }
    }
    if (c == null || !c.done) return;
    final coins = state.coins + c.reward;
    state = state.copyWith(
      coins: coins,
      challenges: [
        for (final x in state.challenges)
          if (x.id != id) x,
      ],
      leaderboard: _syncMe(coins),
    );
  }

  /// Redeem a reward — spends [r.cost] coins if affordable. Returns true when
  /// the redemption succeeded — proto `redeemReward` @21640-21658.
  bool redeem(RwReward r) {
    if (state.coins < r.cost) return false;
    final coins = state.coins - r.cost;
    state = state.copyWith(coins: coins, leaderboard: _syncMe(coins));
    return true;
  }

  /// Rebuild the leaderboard with the "me" row's coins set to [coins] — proto
  /// `me.coins=buildCoins` @21493 / @21649.
  List<RwLeader> _syncMe(int coins) => [
        for (final l in state.leaderboard)
          if (l.me)
            RwLeader(name: l.name, coins: coins, rank: l.rank, me: true)
          else
            l,
      ];
}

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, RewardsState>((_) => RewardsNotifier());
