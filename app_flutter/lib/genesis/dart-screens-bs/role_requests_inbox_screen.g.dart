// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__role_requests_inbox_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/role_requests_inbox_empty.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class RoleRequestsInboxScreenTokens {
  const RoleRequestsInboxScreenTokens();

}

class RoleRequestsInboxScreenComposed extends StatelessWidget {
  const RoleRequestsInboxScreenComposed({required this.icon, required this.text, required this.t, super.key});


  final IconData icon;
  final String text;
  final RoleRequestsInboxScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          RoleRequestsInboxEmpty(
            icon: icon,
            text: text,
          ),
        ],
      );
}
