import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎮 מועדון BuildSmart — the rewards/loyalty hub (T3.G).
///
/// A faithful native port of proto Category H (`openRewardsHub` @21452 +
/// `rwFeature` views @21497-21658). The proto opens an overlay grid of 7 tiles;
/// each tile swaps a second overlay (`rwFeature`). Here the hub is a screen and
/// each tile pushes the matching [_RewardsFeatureScreen]; all 7 features render
/// their real content (challenges/leaderboard/green/coupons/referral/VIP/redeem)
/// and the live coin/challenge mutations run through [rewardsProvider].
///
/// WIRE: reached via the home menu-dial settings tree (the מועדון leaves) and
/// the profile card — see the WIRE notes in the agent report. The dial leaf
/// should `Navigator.push(RewardsHubScreen.route())`.
class RewardsHubScreen extends ConsumerWidget {
  const RewardsHubScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const RewardsHubScreen());

  /// The 7 hub tiles — VERBATIM fn/ic/t from proto `items` @21464-21472.
  static const List<({String id, String ic, String t, String s})> _tiles = [
    (id: 'challenges', ic: '🎯', t: 'אתגרים חודשיים', s: 'פעילים'),
    (id: 'leaderboard', ic: '🏆', t: 'לוח מובילים', s: 'הדירוג שלך'),
    (id: 'green', ic: '🌿', t: 'תגי ירוק', s: 'בנייה בת-קיימא'),
    (id: 'coupons', ic: '📍', t: 'קופונים לפי מיקום', s: 'מבצעים בקרבת מקום'),
    (id: 'referral', ic: '👥', t: 'הזמן חבר', s: '+100 לכל הזמנה'),
    (id: 'vip', ic: '💎', t: 'מועדון VIP', s: 'דרגות והטבות'),
    (id: 'redeem', ic: '🎁', t: 'מימוש הטבות', s: 'החלף מטבעות בפרסים'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rw = ref.watch(rewardsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: _hubAppBar(context, '🎮 מועדון BuildSmart'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [
            const _MdHead(
              ic: '🎮',
              title: 'מועדון BuildSmart',
              sub: 'צבור מטבעות, השלם אתגרים וקבל הטבות.',
            ),
            const SizedBox(height: BsTokens.space3),
            // Coin balance banner — proto `rw-coin-banner` @21457-21462.
            _CoinBanner(coins: rw.coins, sub: '🔥 רצף של $kLoginStreak ימים פעילים'),
            const SizedBox(height: BsTokens.space4),
            // The 7-tile grid — proto `fin-grid` @21474-21481.
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: BsTokens.space3,
              crossAxisSpacing: BsTokens.space3,
              childAspectRatio: 1.45,
              children: [
                for (final t in _tiles)
                  _FinTile(
                    ic: t.ic,
                    title: t.t,
                    sub: t.id == 'challenges'
                        ? '${rw.challenges.length} פעילים'
                        : t.s,
                    onTap: () => Navigator.of(context)
                        .push(_RewardsFeatureScreen.route(t.id)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One rewards feature view (proto `rwFeature` overlays @21497-21658).
class _RewardsFeatureScreen extends ConsumerWidget {
  const _RewardsFeatureScreen(this.id);

  final String id;

  static Route<void> route(String id) =>
      MaterialPageRoute<void>(builder: (_) => _RewardsFeatureScreen(id));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = switch (id) {
      'challenges' => const _Challenges(),
      'leaderboard' => const _Leaderboard(),
      'green' => const _Green(),
      'coupons' => const _Coupons(),
      'referral' => const _Referral(),
      'vip' => const _Vip(),
      'redeem' => const _Redeem(),
      _ => const SizedBox.shrink(),
    };
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: _hubAppBar(context, '🎮 מועדון'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [body],
        ),
      ),
    );
  }
}

// ─── 72. MONTHLY CHALLENGES — proto rwChallenges @21497 ───────────────────────
class _Challenges extends ConsumerWidget {
  const _Challenges();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rw = ref.watch(rewardsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MdHead(
          ic: '🎯',
          title: 'אתגרים חודשיים',
          sub: 'השלם אתגרים וזכה ב-BuildCoins.',
        ),
        const SizedBox(height: BsTokens.space3),
        if (rw.challenges.isEmpty)
          const _Empty('כל האתגרים הושלמו 🎉')
        else
          for (final c in rw.challenges)
            _CaCard(
              overdue: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CaTop(title: '🎯 ${c.name}', pill: '🪙 ${c.reward}'),
                  const SizedBox(height: 4),
                  _CaSub('${c.progress} / ${c.goal}'),
                  const SizedBox(height: 6),
                  _Bar(pct: (c.progress / c.goal * 100).clamp(0, 100).round()),
                  const SizedBox(height: 8),
                  if (c.done)
                    _CardBtn(
                      label: 'קבל ${c.reward} מטבעות',
                      onTap: () {
                        ref.read(rewardsProvider.notifier).claimChallenge(c.id);
                        showToast(context, '+${c.reward} BuildCoins — אתגר הושלם');
                      },
                    )
                  else
                    _CaSub('המשך כדי להשלים את האתגר'),
                ],
              ),
            ),
      ],
    );
  }
}

// ─── 73. LEADERBOARD — proto rwLeaderboard @21527 ─────────────────────────────
class _Leaderboard extends ConsumerWidget {
  const _Leaderboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...ref.watch(rewardsProvider).leaderboard]
      ..sort((a, b) => b.coins.compareTo(a.coins));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MdHead(
          ic: '🏆',
          title: 'לוח המובילים',
          sub: 'דירוג הקבלנים לפי BuildCoins החודש.',
        ),
        const SizedBox(height: BsTokens.space3),
        for (var i = 0; i < sorted.length; i++)
          _LbRow(
            rank: i == 0
                ? '🥇'
                : i == 1
                    ? '🥈'
                    : i == 2
                        ? '🥉'
                        : '${i + 1}.',
            name: sorted[i].name + (sorted[i].me ? ' (אתה)' : ''),
            coins: sorted[i].coins,
            me: sorted[i].me,
          ),
      ],
    );
  }
}

// ─── 74. GREEN BADGES — proto rwGreen @21544 ──────────────────────────────────
class _Green extends StatelessWidget {
  const _Green();

  @override
  Widget build(BuildContext context) {
    final earned = kGreenBadges.where((b) => b.earned).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MdHead(
          ic: '🌿',
          title: 'תגי ירוק',
          sub: 'תגים על בנייה בת-קיימא ושמירה על הסביבה.',
        ),
        const SizedBox(height: BsTokens.space3),
        _Callout(label: 'תגים ירוקים שנצברו', value: '$earned / ${kGreenBadges.length}'),
        const SizedBox(height: BsTokens.space2),
        for (final b in kGreenBadges)
          _BadgeRow(badge: b),
      ],
    );
  }
}

// ─── 75. LOCATION COUPONS — proto rwCoupons @21562 ────────────────────────────
class _Coupons extends StatelessWidget {
  const _Coupons();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MdHead(
          ic: '📍',
          title: 'קופונים לפי מיקום',
          sub: 'מבצעים זמינים מספקים בקרבת מקום אליך.',
        ),
        const SizedBox(height: BsTokens.space3),
        const _ServerNote('⚙️ בפרודקשן: איתור לפי מיקום GPS בזמן אמת'),
        const SizedBox(height: BsTokens.space2),
        for (final c in kLocationCoupons)
          _CaCard(
            overdue: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CaTop(title: '${c.ic} ${c.place}', pill: c.dist),
                const SizedBox(height: 4),
                Text(
                  '🎟️ ${c.deal}',
                  style: const TextStyle(
                    color: BsTokens.brandDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                _CardBtn(
                  label: 'שמור קופון',
                  onTap: () => showToast(context, 'הקופון נשמר לארנק שלך'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 76. REFERRAL — proto rwReferral @21577 ───────────────────────────────────
class _Referral extends StatelessWidget {
  const _Referral();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MdHead(
          ic: '👥',
          title: 'הזמן חבר',
          sub: 'הזמן קבלן אחר — שניכם תרוויחו BuildCoins.',
        ),
        const SizedBox(height: BsTokens.space3),
        Container(
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            children: const [
              Text('קוד ההזמנה שלך',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
              SizedBox(height: 6),
              Text(
                kReferralCode,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        const _FinRow(label: 'חבר נרשם', value: '+50 🪙', up: true),
        const _FinRow(label: 'הזמנה ראשונה של החבר', value: '+100 🪙', up: true),
        const _FinRow(label: 'החבר מקבל', value: 'קופון ₪40', up: true),
        const SizedBox(height: BsTokens.space3),
        _Primary(
          label: '📤 שתף את הקוד',
          onTap: () => showToast(context, 'קוד ההזמנה הועתק — שתף אותו עם חברים'),
        ),
      ],
    );
  }
}

// ─── 78. VIP TIERS — proto rwVIP @21604 ───────────────────────────────────────
class _Vip extends ConsumerWidget {
  const _Vip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rw = ref.watch(rewardsProvider);
    final cur = rw.currentTier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MdHead(
          ic: '💎',
          title: 'מועדון VIP',
          sub: 'ככל שצוברים יותר — ההטבות גדלות.',
        ),
        const SizedBox(height: BsTokens.space3),
        for (final t in kVipTiers)
          _VipCard(
            tier: t,
            current: t.name == cur.name,
            reached: rw.coins >= t.min,
          ),
      ],
    );
  }
}

// ─── 80. REDEMPTION — proto rwRedeem @21621 ───────────────────────────────────
class _Redeem extends ConsumerWidget {
  const _Redeem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rw = ref.watch(rewardsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MdHead(
          ic: '🎁',
          title: 'מימוש הטבות',
          sub: 'החלף BuildCoins בפרסים אמיתיים.',
        ),
        const SizedBox(height: BsTokens.space3),
        _CoinBanner(coins: rw.coins, sub: 'היתרה שלך למימוש'),
        const SizedBox(height: BsTokens.space3),
        for (final r in kRewardsCatalog)
          _CaCard(
            overdue: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CaTop(
                  title: '${r.ic} ${r.name}',
                  pill: '🪙 ${r.cost}',
                  danger: rw.coins < r.cost,
                ),
                const SizedBox(height: 8),
                if (rw.coins >= r.cost)
                  _CardBtn(
                    label: 'ממש עכשיו',
                    onTap: () {
                      final ok = ref.read(rewardsProvider.notifier).redeem(r);
                      if (ok) {
                        showToast(context, '🎁 ${r.name} מומש בהצלחה!');
                      } else {
                        showToast(context, 'אין מספיק BuildCoins');
                      }
                    },
                  )
                else
                  _CaSub('חסרים ${r.cost - rw.coins} מטבעות'),
              ],
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Shared presentation primitives (style-matched to the proto CSS classes).
// ════════════════════════════════════════════════════════════════════════════

PreferredSizeWidget _hubAppBar(BuildContext context, String title) => AppBar(
      backgroundColor: BsTokens.cardLight,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: BsTokens.space4,
      title: Text(
        title,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text(
            '‹ חזרה',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
          ),
        ),
      ],
    );

class _MdHead extends StatelessWidget {
  const _MdHead({required this.ic, required this.title, required this.sub});

  final String ic;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ic, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
      ],
    );
  }
}

class _CoinBanner extends StatelessWidget {
  const _CoinBanner({required this.coins, required this.sub});

  final int coins;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        ),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 34)),
          const SizedBox(width: BsTokens.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$coins BuildCoins',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinTile extends StatelessWidget {
  const _FinTile({
    required this.ic,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final String ic;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ic, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaCard extends StatelessWidget {
  const _CaCard({required this.child, required this.overdue});

  final Widget child;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(
          color: overdue ? const Color(0xFFE57373) : const Color(0xFFEEEEEE),
        ),
      ),
      child: child,
    );
  }
}

class _CaTop extends StatelessWidget {
  const _CaTop({required this.title, required this.pill, this.danger = false});

  final String title;
  final String pill;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        _Pill(pill, danger: danger),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFFEBEE) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: danger ? const Color(0xFFC62828) : BsTokens.inkLight,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CaSub extends StatelessWidget {
  const _CaSub(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
      );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.pct});

  final int pct;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: LinearProgressIndicator(
        value: pct / 100,
        minHeight: 8,
        backgroundColor: const Color(0xFFEEEEEE),
        valueColor: const AlwaysStoppedAnimation<Color>(BsTokens.brand),
      ),
    );
  }
}

class _CardBtn extends StatelessWidget {
  const _CardBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: BsTokens.brandDark,
          side: const BorderSide(color: BsTokens.brand),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Primary extends StatelessWidget {
  const _Primary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: BsTokens.brand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
        ),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}

class _LbRow extends StatelessWidget {
  const _LbRow({
    required this.rank,
    required this.name,
    required this.coins,
    required this.me,
  });

  final String rank;
  final String name;
  final int coins;
  final bool me;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space3,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: me ? const Color(0xFFFFF3E0) : BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(
          color: me ? const Color(0xFFFFB74D) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(rank, style: const TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: me ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text('🪙 $coins',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.badge});

  final RwGreenBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: badge.earned ? const Color(0xFFE8F5E9) : BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(
          color: badge.earned ? const Color(0xFFA5D6A7) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          Text(badge.ic, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: BsTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.name,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
                const SizedBox(height: 2),
                Text(badge.desc,
                    style:
                        const TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
              ],
            ),
          ),
          Text(badge.earned ? '✓' : '🔒', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _VipCard extends StatelessWidget {
  const _VipCard({
    required this.tier,
    required this.current,
    required this.reached,
  });

  final RwVipTier tier;
  final bool current;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: current ? const Color(0xFFFFF3E0) : BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(
          color: current
              ? BsTokens.brand
              : reached
                  ? const Color(0xFFFFCC80)
                  : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CaTop(
            title: '💎 דרגת ${tier.name}${current ? ' · אתה כאן' : ''}',
            pill: tier.min == 0 ? 'התחלה' : '${tier.min}+ 🪙',
          ),
          const SizedBox(height: 6),
          _CaSub(tier.perks),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              )),
        ],
      ),
    );
  }
}

class _FinRow extends StatelessWidget {
  const _FinRow({required this.label, required this.value, this.up = false});

  final String label;
  final String value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 14)),
          Text(value,
              style: TextStyle(
                color: up ? const Color(0xFF2E7D32) : BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}

class _ServerNote extends StatelessWidget {
  const _ServerNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(text,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BsTokens.space5),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
    );
  }
}
