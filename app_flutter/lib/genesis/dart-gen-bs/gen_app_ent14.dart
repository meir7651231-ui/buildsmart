// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent14_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt14Screen extends StatelessWidget {
  const GenAppEnt14Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent14_c0,
      subtitle: gen_app_ent14_c1,
      icon: gen_app_ent14_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent14_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent14_c7, gen_app_ent14_c8, gen_app_ent14_c9, gen_app_ent14_c10], current: 2),
      DsSection(title: gen_app_ent14_c4, children: [
        DsNumberField(label: gen_app_ent14_c11),
        DsField(label: gen_app_ent14_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent14_c13, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent14_c14, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent14_c15),
        DsDateField(label: gen_app_ent14_c16),
        DsToggleTile(label: gen_app_ent14_c17),
      ]),
      DsSection(title: gen_app_ent14_c5, children: const [DsEmpty(label: gen_app_ent14_c6)]),
      ],
    );
  }
}
