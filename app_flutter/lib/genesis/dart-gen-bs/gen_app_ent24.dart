// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent24_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import 'package:flutter/material.dart';

class GenAppEnt24Screen extends StatelessWidget {
  const GenAppEnt24Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent24_c0,
      subtitle: gen_app_ent24_c1,
      icon: gen_app_ent24_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent24_c3),
      children: [
      DsSection(title: gen_app_ent24_c4, children: [
        DsField(label: gen_app_ent24_c7, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent24_c8, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent24_c9),
        DsField(label: gen_app_ent24_c10, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent24_c11, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent24_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent24_c13, hint: '', value: '', onChanged: (_) {}),
      ]),
      DsSection(title: gen_app_ent24_c5, children: const [DsEmpty(label: gen_app_ent24_c6)]),
      ],
    );
  }
}
