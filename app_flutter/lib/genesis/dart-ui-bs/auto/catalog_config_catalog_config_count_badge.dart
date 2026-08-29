// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: features__catalog_config__catalog_config_screen:_CountBadge (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class CatalogConfigCatalogConfigCountBadge extends StatelessWidget {
  const CatalogConfigCatalogConfigCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space2,
        vertical: 2,
      ),
      decoration: const BoxDecoration(
        color: BsTokens.brand,
        borderRadius: BorderRadius.all(Radius.circular(BsTokens.radiusPill)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: BsTokens.typeCaption,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
