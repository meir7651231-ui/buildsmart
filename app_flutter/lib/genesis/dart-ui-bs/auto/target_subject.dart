// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__manager_role_assign_sheet:_TargetSubject (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class TargetSubject extends StatelessWidget {
  const TargetSubject({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('role-assign-target'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Text(
        '👤 $name',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: BsTokens.inkLight,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
