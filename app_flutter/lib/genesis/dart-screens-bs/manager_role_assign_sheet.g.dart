// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__manager_role_assign_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/assign_button.dart';
import '../dart-ui-bs/auto/target_subject.dart';
import '../dart-data-bs/auto/screens__manager_role_assign_sheet_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ManagerRoleAssignSheetTokens {
  const ManagerRoleAssignSheetTokens();

}

class ManagerRoleAssignSheetComposed extends StatelessWidget {
  const ManagerRoleAssignSheetComposed({required this.onPressed, required this.busy, required this.enabled, required this.name, required this.t, super.key});

  final VoidCallback onPressed;
  final bool busy;
  final bool enabled;
  final String name;
  final ManagerRoleAssignSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          TargetSubject(
            name: name,
          ),
          AssignButton(
            fallback: assign_button_fallback,
            enabled: enabled,
            busy: busy,
            onPressed: onPressed,
          ),
        ],
      );
}
