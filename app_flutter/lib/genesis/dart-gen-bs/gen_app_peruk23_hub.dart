// ✨ חולל ע"י מנוע-הרינדור (render-ds) — לוח-ניווט + שער-הרשאות (בורר-תפקיד חי · נשמר). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk23_hub_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_peruk23_audit.dart';
import 'gen_app_peruk23_behavior.dart';
import 'gen_app_peruk23_ent1.dart';
import 'gen_app_peruk23_flags.dart';
import 'gen_app_peruk23_px1.dart';
import 'gen_app_peruk23_rp1.dart';
import 'gen_app_peruk23_scr2.dart';
import 'gen_app_peruk23_settings.dart';
import 'package:flutter/material.dart';

class GenAppPeruk23HubScreen extends StatefulWidget {
  const GenAppPeruk23HubScreen({super.key});

  @override
  State<GenAppPeruk23HubScreen> createState() => _GenAppPeruk23HubScreenState();
}

class _GenAppPeruk23HubScreenState extends State<GenAppPeruk23HubScreen> {
  static const List<List<int>> _vis = [[0, 1, 2, 3, 4, 5, 6, 7]];

  List<Widget> _tiles(BuildContext context) => [
        DsNavTile(glyph: gen_app_peruk23_hub_c2, title: gen_app_peruk23_hub_c3, sub: gen_app_peruk23_hub_c4, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Ent1Screen()))),
        DsNavTile(glyph: gen_app_peruk23_hub_c5, title: gen_app_peruk23_hub_c6, sub: gen_app_peruk23_hub_c7, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Scr2Screen()))),
        DsNavTile(glyph: gen_app_peruk23_hub_c8, title: gen_app_peruk23_hub_c9, sub: gen_app_peruk23_hub_c10, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Rp1Screen()))),
        DsNavTile(glyph: gen_app_peruk23_hub_c11, title: gen_app_peruk23_hub_c12, sub: gen_app_peruk23_hub_c13, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Px1Screen()))),
        DsNavTile(glyph: gen_app_peruk23_hub_c14, title: gen_app_peruk23_hub_c15, sub: gen_app_peruk23_hub_c16, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23AuditScreen()))),
        DsNavTile(glyph: gen_app_peruk23_hub_c17, title: gen_app_peruk23_hub_c18, sub: gen_app_peruk23_hub_c19, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23FlagsScreen()))),
        DsNavTile(glyph: gen_app_peruk23_hub_c20, title: gen_app_peruk23_hub_c21, sub: gen_app_peruk23_hub_c22, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23SettingsScreen()))),
        DsNavTile(glyph: gen_app_peruk23_hub_c23, title: gen_app_peruk23_hub_c24, sub: gen_app_peruk23_hub_c25, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23BehaviorScreen()))),
  ];

  @override
  Widget build(BuildContext context) {
    final all = _tiles(context);
    final vis = _vis[appStore.role.clamp(0, _vis.length - 1)];
    return DsScaffold(
      title: gen_app_peruk23_hub_c0,
      subtitle: '${vis.length} מסכים גלויים',
      icon: gen_app_peruk23_hub_c1,
      children: [
        for (final i in vis) all[i],
      ],
    );
  }
}
