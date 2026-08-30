// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent3_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt3Screen extends StatelessWidget {
  const GenAppEnt3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent3_c0,
      subtitle: gen_app_ent3_c1,
      icon: gen_app_ent3_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent3_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent3_c7, gen_app_ent3_c8, gen_app_ent3_c9, gen_app_ent3_c10, gen_app_ent3_c11, gen_app_ent3_c12], current: 2),
      DsSection(title: gen_app_ent3_c4, children: [
        DsNumberField(label: gen_app_ent3_c13),
        DsField(label: gen_app_ent3_c14, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent3_c15, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent3_c16, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent3_c17, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent3_c18),
        DsField(label: gen_app_ent3_c19, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent3_c20),
        DsNumberField(label: gen_app_ent3_c21),
        DsDateField(label: gen_app_ent3_c22),
        DsDateField(label: gen_app_ent3_c23),
        DsToggleTile(label: gen_app_ent3_c24),
      ]),
      DsSection(title: gen_app_ent3_c5, children: const [DsEmpty(label: gen_app_ent3_c6)]),
      ],
    );
  }
}
