// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent5_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt5Screen extends StatelessWidget {
  const GenAppEnt5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent5_c0,
      subtitle: gen_app_ent5_c1,
      icon: gen_app_ent5_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent5_c3),
      children: [
      DsSection(title: gen_app_ent5_c4, children: [
        DsField(label: gen_app_ent5_c7, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent5_c8, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent5_c9, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent5_c10),
        DsField(label: gen_app_ent5_c11, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent5_c12),
        DsNumberField(label: gen_app_ent5_c13),
        DsToggleTile(label: gen_app_ent5_c14),
      ]),
      DsSection(title: gen_app_ent5_c5, children: const [DsEmpty(label: gen_app_ent5_c6)]),
      ],
    );
  }
}
