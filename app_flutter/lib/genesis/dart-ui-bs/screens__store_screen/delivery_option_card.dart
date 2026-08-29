// 🧼 אטום · DeliveryOptionCard — כרטיס-אפשרות-משלוח: גליף + תווית + עלות, מצב active.
// מוצא: screens__store_screen.dart:2474 (_DeliveryCard). שורות-האפשרויות = content
// (deliveryOptions); feeLabel מפורמט בקופסה (t_323814d1 כשהעלות 0, אחרת ₪);
// הבחירה (cartDeliveryProvider) = קופסה.
import 'package:flutter/material.dart';

class DeliveryOptionCard extends StatelessWidget {
  const DeliveryOptionCard({
    required this.emoji, required this.label, required this.feeLabel,
    required this.active, required this.onTap,
    required this.accentColor, required this.inkColor, required this.mutedColor,
    required this.idleBgColor, required this.idleBorderColor, super.key,
  });
  final String emoji, label, feeLabel;
  final bool active;
  final VoidCallback onTap;
  final Color accentColor, inkColor, mutedColor, idleBgColor, idleBorderColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? accentColor.withValues(alpha: 0.12) : idleBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? accentColor : idleBorderColor),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? accentColor : inkColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(feeLabel, style: TextStyle(color: mutedColor, fontSize: 11)),
            ],
          ),
        ),
      );
}
