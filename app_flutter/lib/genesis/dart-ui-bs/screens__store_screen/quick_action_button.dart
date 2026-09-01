// 🧼 אטום · QuickActionButton — כפתור-פעולה עגול (62dp) עם badge אדום אופציונלי.
// מוצא: screens__store_screen.dart:855 (_QuickAction). התווית מוזרקת (t_8b041840 /
// t_de21005d / t_085a5652 / t_1c96b9bd / t_bf99e582); badge>0 ⇒ מונה. הפעולה callback.
import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    required this.icon, required this.label, required this.onTap,
    required this.circleColor, required this.iconColor,
    required this.badgeColor, required this.badgeInkColor, required this.labelColor,
    this.badge = 0, super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color circleColor, iconColor, badgeColor, badgeInkColor, labelColor;
  final int badge;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                    child: Text(
                      badge.toString(),
                      style: TextStyle(
                        color: badgeInkColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: labelColor, fontSize: 12),
            ),
          ],
        ),
      );
}
