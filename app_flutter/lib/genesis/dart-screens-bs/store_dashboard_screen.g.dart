// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__store_dashboard_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/action_card.dart';
import '../dart-ui-bs/auto/big_button.dart';
import '../dart-ui-bs/auto/flat_card.dart';
import '../dart-ui-bs/auto/portal_tile_button.dart';
import '../dart-ui-bs/auto/stat.dart';
import '../dart-ui-bs/auto/store_dashboard_chip.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class PortalTileButtonItem {
  const PortalTileButtonItem({required this.title, required this.sub, required this.onTap});
  final String title;
  final String sub;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StoreDashboardScreenTokens {
  const StoreDashboardScreenTokens({required this.color});
  final Color color;
}

class StoreDashboardScreenComposed extends StatelessWidget {
  const StoreDashboardScreenComposed({required this.onTap, required this.badge, required this.child, required this.label, required this.on, required this.portalTileButtonItems, required this.sub, required this.title, required this.value, required this.t, super.key});

  final VoidCallback onTap;
  final String badge;
  final Widget child;
  final String label;
  final bool on;
  final List<PortalTileButtonItem> portalTileButtonItems;
  final String sub;
  final String title;
  final String value;
  final StoreDashboardScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          ActionCard(
            color: t.color,
            badge: badge,
            title: title,
            sub: sub,
            onTap: onTap,
          ),
          FlatCard(
            child: child,
          ),
          Stat(
            value: value,
            label: label,
          ),
          BigButton(
            label: label,
            onTap: onTap,
          ),
          StoreDashboardChip(
            label: label,
            on: on,
            onTap: onTap,
          ),
          for (final t in portalTileButtonItems) ...[
          PortalTileButton(
            title: t.title,
            sub: t.sub,
            onTap: t.onTap,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
