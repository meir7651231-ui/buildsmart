// ✨ חולל ע"י מנוע-הרינדור (render-ds) — לוח-ניווט + שער-הרשאות (בורר-תפקיד חי · נשמר). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk01_hub_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_peruk01_audit.dart';
import 'gen_app_peruk01_bind1.dart';
import 'gen_app_peruk01_bind2.dart';
import 'gen_app_peruk01_ent1.dart';
import 'gen_app_peruk01_ent2.dart';
import 'gen_app_peruk01_flags.dart';
import 'gen_app_peruk01_over1.dart';
import 'gen_app_peruk01_px1.dart';
import 'gen_app_peruk01_px2.dart';
import 'gen_app_peruk01_rec1.dart';
import 'gen_app_peruk01_rec2.dart';
import 'gen_app_peruk01_rp1.dart';
import 'gen_app_peruk01_scr3.dart';
import 'gen_app_peruk01_settings.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk01HubScreen extends StatefulWidget {
  const GenAppPeruk01HubScreen({super.key});

  @override
  State<GenAppPeruk01HubScreen> createState() => _GenAppPeruk01HubScreenState();
}

class _GenAppPeruk01HubScreenState extends State<GenAppPeruk01HubScreen> {
  static const List<List<int>> _vis = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]];

  List<Widget> _tiles(BuildContext context) => [
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Ent1Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c3, gen_app_peruk01_hub_c4])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Ent2Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c6, gen_app_peruk01_hub_c7])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Scr3Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c9, gen_app_peruk01_hub_c10])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Rp1Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c12, gen_app_peruk01_hub_c13])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Px1Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c15, gen_app_peruk01_hub_c16])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Px2Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c18, gen_app_peruk01_hub_c19])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Over1Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c21, gen_app_peruk01_hub_c22])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Rec1Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c24, gen_app_peruk01_hub_c25])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Rec2Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c27, gen_app_peruk01_hub_c28])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Bind1Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c30, gen_app_peruk01_hub_c31])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Bind2Screen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c33, gen_app_peruk01_hub_c34])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01AuditScreen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c36, gen_app_peruk01_hub_c37])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01FlagsScreen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c39, gen_app_peruk01_hub_c40])),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01SettingsScreen())), child: ForgeGridHubCard(fields: [gen_app_peruk01_hub_c42, gen_app_peruk01_hub_c43])),
  ];

  @override
  Widget build(BuildContext context) {
    final all = _tiles(context);
    final vis = _vis[appStore.role.clamp(0, _vis.length - 1)];
    return DsScaffold(title: gen_app_peruk01_hub_c0, subtitle: '${vis.length} מסכים גלויים', icon: gen_app_peruk01_hub_c1, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk01_hub_c0, '${vis.length} מסכים גלויים']), ...[
        for (final i in vis) all[i],
      ]]);
  }
}
