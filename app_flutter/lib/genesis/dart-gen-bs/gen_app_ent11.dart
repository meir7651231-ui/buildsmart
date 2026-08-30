// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent11_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt11Screen extends StatelessWidget {
  const GenAppEnt11Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent11_c0,
      subtitle: gen_app_ent11_c1,
      icon: gen_app_ent11_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent11_c3),
      children: [
      DsSection(title: gen_app_ent11_c4, children: [
        DsField(label: gen_app_ent11_c7, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent11_c8),
        DsField(label: gen_app_ent11_c9, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent11_c10, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent11_c11, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent11_c12),
        DsToggleTile(label: gen_app_ent11_c13),
      ]),
      DsSection(title: gen_app_ent11_c5, children: const [DsEmpty(label: gen_app_ent11_c6)]),
      ],
    );
  }
}
