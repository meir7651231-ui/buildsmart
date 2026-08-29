// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__profile_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/field.dart';
import '../dart-ui-bs/auto/field_label.dart';
import '../dart-ui-bs/auto/link_row.dart';
import '../dart-ui-bs/auto/section_label.dart';
import '../dart-data-bs/auto/screens__profile_screen_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ProfileScreenTokens {
  const ProfileScreenTokens();

}

class ProfileScreenComposed extends StatelessWidget {
  const ProfileScreenComposed({required this.onTap, required this.validator, required this.controller, required this.number, required this.text, required this.t, super.key});

  final VoidCallback onTap;
  final String? Function(String value)? validator;
  final TextEditingController controller;
  final bool number;
  final String text;
  final ProfileScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SectionLabel(
            text,
          ),
          Field(
            label: field_label,
            controller: controller,
            number: number,
            validator: validator,
          ),
          FieldLabel(
            text,
          ),
          LinkRow(
            label: link_row_label,
            onTap: onTap,
          ),
        ],
      );
}
