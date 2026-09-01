// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_attendance_screen:_LocationButton (בנייה-חכמה main) · צרור-1 · props-שורש: label2, fallback, onTap
// התוכן: new/dart-data-bs/auto/screens__worker_attendance_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class LocationButton extends StatelessWidget {
  LocationButton({required this.label2, required this.fallback, required this.onTap, required this.label, required this.query});
  final String label2;
  final String fallback;
  final VoidCallback onTap;

  final String label;

  /// `"lat,lng"` from [mapsQueryForDay] — passed through to [openNavSheet].
  final String query;

  @override
  Widget build(BuildContext context) {
    final parts = query.split(',');
    final lat = parts.length == 2 ? double.tryParse(parts[0]) : null;
    final lng = parts.length == 2 ? double.tryParse(parts[1]) : null;
    return Semantics(
      button: true,
      label: label2,
      excludeSemantics: true,
      // composite hide: whole button gone when the org hides this element
      child: CfgVisible(
        'worker_attendance_screen.open_nav',
        child: Material(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3),
            child: Row(
              children: [
                const Icon(Icons.place, color: Color(0xFF1D6FE0), size: 20),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: CfgText(
                    'worker_attendance_screen.open_nav',
                    fallback,
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const Icon(Icons.navigation_outlined,
                    color: Color(0xFF1D6FE0), size: 18),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
