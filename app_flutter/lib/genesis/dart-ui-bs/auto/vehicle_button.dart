// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__courier_dashboard_screen:_VehicleButton (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 2 שדות · props-שורש: fallback, ic, name
// התוכן: new/dart-data-bs/auto/screens__courier_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class VehicleButton extends StatelessWidget {
  VehicleButton({required this.fallback, required this.ic, required this.name, 
    
    required this.on,
    required this.onTap,
    this.preferred = false,});
  final String fallback;
  final String ic;
  final String name;
  final bool on;

  /// F-30 — true כשזה "סוג הרכב המועדף" מפרופיל-השליח (#86.1): תג "מועדף"
  /// כן — ברירת-מחדל מוצעת בלבד, הבחירה למשמרת נשארת של השליח.
  final bool preferred;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: on ? BsTokens.brand : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
          child: Column(
            children: [
              Text(ic, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                name,
                style: TextStyle(
                  // F-28 — bsOnAccent על מילוי-מותג (לא לבן קשיח): מכבד את
                  // מתג הניגודיות-הגבוהה.
                  color: on ? bsOnAccent(context) : BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5),
              ),
              if (preferred) ...[
                const SizedBox(height: 2),
                CfgText(
                  'courier.vehicle.preferred',
                  fallback,
                  style: TextStyle(
                    color: on ? bsOnAccent(context) : BsTokens.brandDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
