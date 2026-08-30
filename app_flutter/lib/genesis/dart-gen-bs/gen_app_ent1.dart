// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt1Screen extends StatelessWidget {
  const GenAppEnt1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent1_c0,
      subtitle: gen_app_ent1_c1,
      icon: gen_app_ent1_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent1_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent1_c7, gen_app_ent1_c8, gen_app_ent1_c9, gen_app_ent1_c10, gen_app_ent1_c11, gen_app_ent1_c12, gen_app_ent1_c13], current: 2),
      DsSection(title: gen_app_ent1_c4, children: [
        DsField(label: gen_app_ent1_c14, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent1_c15, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent1_c16, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent1_c17, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent1_c18, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent1_c19, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent1_c20),
        DsField(label: gen_app_ent1_c21, hint: '', value: '', onChanged: (_) {}),
        DsToggleTile(label: gen_app_ent1_c22),
      ]),
      DsSection(title: gen_app_ent1_c5, children: const [DsEmpty(label: gen_app_ent1_c6)]),
      ],
    );
  }
}
