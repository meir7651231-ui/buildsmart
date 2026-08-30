// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import 'package:flutter/material.dart';

class GenAppEnt2Screen extends StatelessWidget {
  const GenAppEnt2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent2_c0,
      subtitle: gen_app_ent2_c1,
      icon: gen_app_ent2_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent2_c3),
      children: [
      DsSection(title: gen_app_ent2_c4, children: [
        DsField(label: gen_app_ent2_c7, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent2_c8, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent2_c9),
        DsField(label: gen_app_ent2_c10, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent2_c11, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent2_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent2_c13, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent2_c14, hint: '', value: '', onChanged: (_) {}),
      ]),
      DsSection(title: gen_app_ent2_c5, children: const [DsEmpty(label: gen_app_ent2_c6)]),
      ],
    );
  }
}
