// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: contractor_home.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/empty_state_card.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/titled_section.dart';
import '../dart-ui-bs/work_path_card.dart';
import '../dart-data-bs/home_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ContractorHomeTokens {
  const ContractorHomeTokens({required this.border, required this.brand, required this.brandDark, required this.card, required this.ink, required this.muted, required this.radius});
  final Color border;
  final Color brand;
  final Color brandDark;
  final Color card;
  final Color ink;
  final Color muted;
  final double radius;
}

class ContractorHomeComposed extends StatelessWidget {
  const ContractorHomeComposed({required this.showEmptyOrders, required this.workPathOn, required this.onHeroTap,VoidCallback, required this.t, super.key});
  final bool showEmptyOrders;
  final bool workPathOn;
  final VoidCallback onHeroTap;

  final ContractorHomeTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          if (workPathOn) TitledSection(
          title: homeSectionTitles['workPath']!,
          inkColor: t.ink,
          child: WorkPathCard(
            badge: workPathContent.badge,
            title: workPathContent.title,
            sub: workPathContent.sub,
            gradStart: t.brand,
            gradEnd: t.brandDark,
            radius: t.radius,
          ),
        ),
          for (final h in homeHeroes) ...[
          HeroCard(
            glyph: h.glyph,
            title: h.title,
            sub: h.sub,
            onTap: onHeroTap,
            cardColor: t.card,
            inkColor: t.ink,
            mutedColor: t.muted,
            borderColor: t.border,
            radius: t.radius,
          ),
          const SizedBox(height: 8),
        ],
          if (showEmptyOrders) EmptyStateCard(
            glyph: '📦',
            message: emptyStateTerms.noOrders,
            surfaceColor: t.card,
            mutedColor: t.muted,
            borderColor: t.border,
            radius: t.radius,
          ),
        ],
      );
}
