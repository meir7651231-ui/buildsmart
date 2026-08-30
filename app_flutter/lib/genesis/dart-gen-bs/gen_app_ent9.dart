// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent9_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import 'package:flutter/material.dart';

class GenAppEnt9Screen extends StatelessWidget {
  const GenAppEnt9Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent9_c0,
      subtitle: gen_app_ent9_c1,
      icon: gen_app_ent9_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent9_c3),
      children: [
      DsSection(title: gen_app_ent9_c4, children: [
        DsField(label: gen_app_ent9_c7, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent9_c8, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent9_c9),
        DsNumberField(label: gen_app_ent9_c10),
        DsNumberField(label: gen_app_ent9_c11),
        DsField(label: gen_app_ent9_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent9_c13, hint: '', value: '', onChanged: (_) {}),
      ]),
      DsSection(title: gen_app_ent9_c5, children: const [DsEmpty(label: gen_app_ent9_c6)]),
      ],
    );
  }
}
