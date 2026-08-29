// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__notifications_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/date_header.dart';
import '../dart-ui-bs/auto/notif_row.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class NotificationsScreenTokens {
  const NotificationsScreenTokens();

}

class NotificationsScreenComposed extends StatelessWidget {
  const NotificationsScreenComposed({required this.onTap, required this.fallback, required this.label, required this.t, super.key});

  final VoidCallback onTap;
  final String fallback;
  final String label;
  final NotificationsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          DateHeader(
            label: label,
          ),
          NotifRow(
            fallback: fallback,
            onTap: onTap,
          ),
        ],
      );
}
