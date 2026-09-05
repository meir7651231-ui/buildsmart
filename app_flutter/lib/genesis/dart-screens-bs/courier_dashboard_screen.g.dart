// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__courier_dashboard_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/flat_card.dart';
import '../dart-ui-bs/auto/stat.dart';
import '../dart-ui-bs/auto/vehicle_button.dart';
import '../dart-data-bs/auto/screens__courier_dashboard_screen_content.dart';
import '../dart-data-bs/auto/screens__courier_dashboard_screen_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CourierDashboardScreenTokens {
  const CourierDashboardScreenTokens();

}

class CourierDashboardScreenComposed extends StatelessWidget {
  const CourierDashboardScreenComposed({required this.onTap, required this.child, required this.ic, required this.name, required this.on, required this.preferred, required this.value, required this.t, super.key});

  final VoidCallback onTap;
  final Widget child;
  final String ic;
  final String name;
  final bool on;
  final bool preferred;
  final String value;
  final CourierDashboardScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          VehicleButton(
            fallback: vehicle_button_fallback,
            ic: ic,
            name: name,
            on: on,
            preferred: preferred,
            onTap: onTap,
          ),
          FlatCard(
            child: child,
          ),
          Stat(
            value: value,
            label: stat_label,
          ),
        ],
      );
}
