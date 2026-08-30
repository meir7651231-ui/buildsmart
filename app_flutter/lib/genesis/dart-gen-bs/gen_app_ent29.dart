// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent29_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt29Screen extends StatelessWidget {
  const GenAppEnt29Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent29_c0,
      subtitle: gen_app_ent29_c1,
      icon: gen_app_ent29_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent29_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent29_c7, gen_app_ent29_c8, gen_app_ent29_c9, gen_app_ent29_c10, gen_app_ent29_c11], current: 2),
      DsSection(title: gen_app_ent29_c4, children: [
        DsField(label: gen_app_ent29_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent29_c13, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent29_c14),
        DsField(label: gen_app_ent29_c15, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent29_c16, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent29_c17, hint: '', value: '', onChanged: (_) {}),
        DsToggleTile(label: gen_app_ent29_c18),
      ]),
      DsSection(title: gen_app_ent29_c5, children: const [DsEmpty(label: gen_app_ent29_c6)]),
      ],
    );
  }
}
