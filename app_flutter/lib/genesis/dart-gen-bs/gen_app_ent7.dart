// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent7_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt7Screen extends StatelessWidget {
  const GenAppEnt7Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent7_c0,
      subtitle: gen_app_ent7_c1,
      icon: gen_app_ent7_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent7_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent7_c7, gen_app_ent7_c8, gen_app_ent7_c9, gen_app_ent7_c10, gen_app_ent7_c11], current: 2),
      DsSection(title: gen_app_ent7_c4, children: [
        DsNumberField(label: gen_app_ent7_c12),
        DsField(label: gen_app_ent7_c13, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent7_c14, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent7_c15),
        DsField(label: gen_app_ent7_c16, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent7_c17),
        DsToggleTile(label: gen_app_ent7_c18),
      ]),
      DsSection(title: gen_app_ent7_c5, children: const [DsEmpty(label: gen_app_ent7_c6)]),
      ],
    );
  }
}
