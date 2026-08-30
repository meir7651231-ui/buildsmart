// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - כרטיסי-מוצר
// 🧬 בקשה: רכיבים חיים - כרטיסי-מוצר: · הירו 💳 כרטיסים | מחירון פרופיל ומוצר ממשפט · כותרת כרטיסים · מחירון 280 חבילת פרו | 99 לחודש · פרופיל 240 דנה כהן | מעצבת מוצר · מוצר 240 אוזניות פרימיום | 349 · המלצה 200 המנוע הזה שינה לנו את כל תהליך הפיתוח | יוסי לוי · באנר כל כרטיס כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · PricingCard · ProfileCard · ProductCard · TestimonialCard · CoinBanner
import '../dart-data-bs/auto/gen_cards11_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/pricing_card.dart';
import '../dart-ui-bs/product_card.dart';
import '../dart-ui-bs/profile_card.dart';
import '../dart-ui-bs/testimonial_card.dart';
import 'package:flutter/material.dart';

class GenCards11Screen extends StatefulWidget {
  const GenCards11Screen({super.key});

  @override
  State<GenCards11Screen> createState() => _GenCards11ScreenState();
}

class _GenCards11ScreenState extends State<GenCards11Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_cards11_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_cards11_card_glyph, title: gen_cards11_card_title, sub: gen_cards11_card_sub, onTap: () => _toast(gen_cards11_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_cards11_header_text),
          PricingCard(title: gen_cards11_pricing_title, sub: gen_cards11_pricing_sub, height: 280, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ProfileCard(title: gen_cards11_profile_title, sub: gen_cards11_profile_sub, height: 240, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ProductCard(title: gen_cards11_product_title, sub: gen_cards11_product_sub, height: 240, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          TestimonialCard(title: gen_cards11_testimonial_title, sub: gen_cards11_testimonial_sub, height: 200, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_cards11_banner_sub),
          ],
        ),
      ),
    );
  }
}
