// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent8_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt8Screen extends StatelessWidget {
  const GenAppEnt8Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent8_c0,
      subtitle: gen_app_ent8_c1,
      icon: gen_app_ent8_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent8_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent8_c7, gen_app_ent8_c8, gen_app_ent8_c9, gen_app_ent8_c10], current: 2),
      DsSection(title: gen_app_ent8_c4, children: [
        DsNumberField(label: gen_app_ent8_c11),
        DsField(label: gen_app_ent8_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent8_c13, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent8_c14),
        DsDateField(label: gen_app_ent8_c15),
        DsDateField(label: gen_app_ent8_c16),
        DsDateField(label: gen_app_ent8_c17),
        DsField(label: gen_app_ent8_c18, hint: '', value: '', onChanged: (_) {}),
        DsToggleTile(label: gen_app_ent8_c19),
      ]),
      DsSection(title: gen_app_ent8_c5, children: const [DsEmpty(label: gen_app_ent8_c6)]),
      ],
    );
  }
}
