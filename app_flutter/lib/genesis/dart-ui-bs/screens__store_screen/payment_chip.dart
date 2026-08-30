// 🧼 אטום · PaymentChip — צ׳יפ-אמצעי-תשלום: גליף + תווית, מצב active (מסגרת רק בכבוי).
// מוצא: screens__store_screen.dart:2703 (_PaymentChip). שורות-האמצעים = content
// (paymentOptions); שער supplierCreditEnabled (הסתרת אשראי-ספק) = קופסה.
import 'package:flutter/material.dart';

class PaymentChip extends StatelessWidget {
  const PaymentChip({
    required this.emoji, required this.label, required this.active, required this.onTap,
    required this.activeColor, required this.activeInkColor,
    required this.idleColor, required this.idleInkColor, required this.idleBorderColor,
    super.key,
  });
  final String emoji, label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor, activeInkColor, idleColor, idleInkColor, idleBorderColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? activeColor : idleColor,
            borderRadius: BorderRadius.circular(20),
            border: active ? null : Border.all(color: idleBorderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? activeInkColor : idleInkColor,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
}
