// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__accessory_rule_editor:_MustChip (בנייה-חכמה main) · צרור-2 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__trade_builder__accessory_rule_editor_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';

class MustChip extends StatelessWidget {
  MustChip({required this.fallback});
  final String fallback;

  @override
  Widget build(BuildContext context) {
    // composite hide: whole 'חובה' chip gone when the org hides this element
    return CfgVisible(
      'accessory_rule_editor.t06',
      child: Chip(
        label: CfgText(
          'accessory_rule_editor.t06',
          fallback,
          style: TextStyle(
            color: _kMustColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: _kMustColor.withValues(alpha: 0.12),
        side: BorderSide.none,
      ),
    );
  }
}

const Color _kMustColor = Color(0xFFB45309);
