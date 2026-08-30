// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 דשבורד בטיחות עם בדיקות פתוחות | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 דשבורד בטיחות עם בדיקות פתוחות | נבנה מתיאור חופשי · אטום QuickToolsList דשבורד בטיחות עם בדיקות פתוחות · אטום CartChatBubble דשבורד בטיחות עם בדיקות פתוחות · אטום SlideSheet דשבורד בטיחות עם בדיקות פתוחות · אטום ProjectDone דשבורד בטיחות עם בדיקות פתוחות · אטום PaymentChip דשבורד בטיחות עם בדיקות פתוחות · אטום CartItemRow דשבורד בטיחות עם בדיקות פתוחות · אטום OrderCard דשבורד בטיחות עם בדיקות פתוחות · אטום ColorSwatchRow דשבורד בטיחות עם בדיקות פתוחות · אטום Timeline אירועים · כותרת דשבורד בטיחות עם בדיקות פתוחות · לוגיקה חיה · חישוב סיווג אזור של מספר (phoneRegion) · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: QuickToolsList · CartChatBubble · SlideSheet · ProjectDone · PaymentChip · CartItemRow · OrderCard · ColorSwatchRow · Timeline · CaSubTitle · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_scr34_content.dart';
import '../dart-maor/phone-region.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/project_done.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/color_swatch.dart';
import '../dart-ui-bs/order_card.dart';
import '../dart-ui-bs/quick_tools_list.dart';
import '../dart-ui-bs/screens__home_shell/cart_chat_bubble.dart';
import '../dart-ui-bs/screens__store_screen/cart_item_row.dart';
import '../dart-ui-bs/screens__store_screen/payment_chip.dart';
import '../dart-ui-bs/slide_sheet.dart';
import '../dart-ui-bs/timeline_flow.dart';
import 'package:flutter/material.dart';

class GenAppScr34Screen extends StatefulWidget {
  const GenAppScr34Screen({super.key});

  @override
  State<GenAppScr34Screen> createState() => _GenAppScr34ScreenState();
}

class _GenAppScr34ScreenState extends State<GenAppScr34Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_scr34_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          QuickToolsList(tools: (null as dynamic) /* לא-ממולא */, cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CartChatBubble(emoji: gen_app_scr34_other_glyph, name: gen_app_scr34_other_name, attrs: gen_app_scr34_other_attrs, priceLabel: gen_app_scr34_other_price_label, qtyLabel: gen_app_scr34_other_qty_label, onTap: () => _toast(gen_app_scr34_other_toast), onClose: () => _toast(gen_app_scr34_other_toast2), closeSemanticsLabel: gen_app_scr34_other_close_semantics_label, closeTooltip: gen_app_scr34_other_close_tooltip, bubbleColor: BsTokens.inkLight, borderColor: BsTokens.divider, shadowColor: BsTokens.inkLight, nameColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, priceColor: BsTokens.inkLight, editIconColor: BsTokens.inkLight, closeFillColor: BsTokens.cardLight, closeBorderColor: BsTokens.divider, closeIconColor: BsTokens.inkLight),
          SlideSheet(title: gen_app_scr34_sheet_title, sub: gen_app_scr34_sheet_sub, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ProjectDone(fallback: gen_app_scr34_other_fallback),
          PaymentChip(emoji: gen_app_scr34_chip_glyph, label: gen_app_scr34_chip_label, active: false, onTap: () => _toast(gen_app_scr34_chip_toast), activeColor: BsTokens.brand, activeInkColor: BsTokens.brand, idleColor: BsTokens.inkLight, idleInkColor: BsTokens.inkLight, idleBorderColor: BsTokens.divider),
          CartItemRow(emoji: gen_app_scr34_row_glyph, name: gen_app_scr34_row_name, unitPriceLabel: gen_app_scr34_row_unit_price_label, qtyLabel: gen_app_scr34_row_qty_label, lineTotalLabel: gen_app_scr34_row_line_total_label, removeLabel: gen_app_scr34_row_remove_label, onRemove: () => _toast(gen_app_scr34_row_toast), minusButton: const SizedBox(height: 4), plusButton: const SizedBox(height: 4), surfaceColor: BsTokens.cardLight, stepperColor: BsTokens.inkLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, removeIconColor: BsTokens.inkLight),
          OrderCard(stageLabel: gen_app_scr34_card_stage_label, itemsLabel: gen_app_scr34_card_items_label, sumLabel: gen_app_scr34_card_sum_label, onTap: () => _toast(gen_app_scr34_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12, width: 16),
          ColorSwatchRow(height: 16, swatches: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          Timeline(height: 16, events: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_scr34_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: phoneRegion(null), label: gen_app_scr34_stat_label)])),
          CoinBanner(coins: 0, sub: gen_app_scr34_banner_sub),
          ],
        ),
      ),
    );
  }
}
