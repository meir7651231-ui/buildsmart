// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent6_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt6Screen extends StatelessWidget {
  const GenAppEnt6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent6_c0,
      subtitle: gen_app_ent6_c1,
      icon: gen_app_ent6_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent6_c3),
      children: [
      DsSection(title: gen_app_ent6_c4, children: [
        DsField(label: gen_app_ent6_c7, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent6_c8, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent6_c9, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent6_c10),
        DsNumberField(label: gen_app_ent6_c11),
        DsNumberField(label: gen_app_ent6_c12),
        DsField(label: gen_app_ent6_c13, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent6_c14),
        DsToggleTile(label: gen_app_ent6_c15),
      ]),
      DsSection(title: gen_app_ent6_c5, children: const [DsEmpty(label: gen_app_ent6_c6)]),
      ],
    );
  }
}
