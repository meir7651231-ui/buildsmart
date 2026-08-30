// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 דוח יומי עם מזג אוויר | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 דוח יומי עם מזג אוויר | נבנה מתיאור חופשי · אטום WeatherCard מזג אוויר · אטום ProductCard תמונות · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: WeatherCard · ProductCard · CoinBanner
import '../dart-data-bs/auto/gen_app_scr8_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/product_card.dart';
import '../dart-ui-bs/weather_card.dart';
import 'package:flutter/material.dart';

class GenAppScr8Screen extends StatefulWidget {
  const GenAppScr8Screen({super.key});

  @override
  State<GenAppScr8Screen> createState() => _GenAppScr8ScreenState();
}

class _GenAppScr8ScreenState extends State<GenAppScr8Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_scr8_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          WeatherCard(title: gen_app_scr8_weather_title, sub: gen_app_scr8_weather_sub, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ProductCard(title: gen_app_scr8_product_title, sub: gen_app_scr8_product_sub, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_scr8_banner_sub),
          ],
        ),
      ),
    );
  }
}
