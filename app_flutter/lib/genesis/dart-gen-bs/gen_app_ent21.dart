// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent21_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt21Screen extends StatelessWidget {
  const GenAppEnt21Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent21_c0,
      subtitle: gen_app_ent21_c1,
      icon: gen_app_ent21_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent21_c3),
      children: [
      DsSection(title: gen_app_ent21_c4, children: [
        DsField(label: gen_app_ent21_c7, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent21_c8, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent21_c9, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent21_c10, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent21_c11),
        DsField(label: gen_app_ent21_c12, hint: '', value: '', onChanged: (_) {}),
        DsToggleTile(label: gen_app_ent21_c13),
      ]),
      DsSection(title: gen_app_ent21_c5, children: const [DsEmpty(label: gen_app_ent21_c6)]),
      ],
    );
  }
}
