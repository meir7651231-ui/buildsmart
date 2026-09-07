// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-מערכת. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk04_flags_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk04FlagsScreen extends StatelessWidget {
  const GenAppPeruk04FlagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(title: gen_app_peruk04_flags_c0, subtitle: gen_app_peruk04_flags_c1, icon: gen_app_peruk04_flags_c2, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk04_flags_c0, gen_app_peruk04_flags_c1]), ...[
        ForgeTitledSection(fields: [gen_app_peruk04_flags_c3, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        DsToggleTile(label: gen_app_peruk04_flags_c4),
        DsToggleTile(label: gen_app_peruk04_flags_c5),
        ]])),
      ]]);
  }
}
