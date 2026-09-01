// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__site_hub_screen:_HubTile (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class HubTile extends StatelessWidget {
  const HubTile({
    required this.ic,
    required this.t,
    required this.s,
    required this.onTap,
  });
  final String ic;
  final String t;
  final String s;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE6E6E6)),
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ic, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                t,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
