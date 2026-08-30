// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🧾 יומן פעולות | audit — כל שינוי מתועד
// 🧬 בקשה: הירו 🧾 יומן פעולות | audit — כל שינוי מתועד · כותרת פעולות אחרונות · אטום DataGrid יומן פעולות · חישוב תיעוד פעולה (runAudit) · באנר audit: משתמש · פעולה · ערך-קודם · ערך-חדש · תאריך
// 🧬 אטומים שנבחרו: CaSubTitle · DataGrid · CheckRow · CoinBanner
import '../dart-data-bs/auto/gen_app_audit_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/check_row.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/data_grid.dart';
import 'package:flutter/material.dart';

class GenAppAuditScreen extends StatefulWidget {
  const GenAppAuditScreen({super.key});

  @override
  State<GenAppAuditScreen> createState() => _GenAppAuditScreenState();
}

class _GenAppAuditScreenState extends State<GenAppAuditScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_audit_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_audit_header_text),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CheckRow(pass: false, label: gen_app_audit_row_label),
          CoinBanner(coins: 0, sub: gen_app_audit_banner_sub),
          ],
        ),
      ),
    );
  }
}
