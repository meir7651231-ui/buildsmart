// ✨ חולל ע"י מנוע-הרינדור (render-ds) — לוח-ניווט + שער-הרשאות (בורר-תפקיד חי · נשמר). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_tasks_hub_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_tasks_audit.dart';
import 'gen_app_tasks_behavior.dart';
import 'gen_app_tasks_ent2.dart';
import 'gen_app_tasks_flags.dart';
import 'gen_app_tasks_scr1.dart';
import 'gen_app_tasks_settings.dart';
import 'package:flutter/material.dart';

class GenAppTasksHubScreen extends StatefulWidget {
  const GenAppTasksHubScreen({super.key});

  @override
  State<GenAppTasksHubScreen> createState() => _GenAppTasksHubScreenState();
}

class _GenAppTasksHubScreenState extends State<GenAppTasksHubScreen> {
  static const List<List<int>> _vis = [[0, 1, 2, 3, 4, 5]];

  List<Widget> _tiles(BuildContext context) => [
        DsNavTile(glyph: gen_app_tasks_hub_c2, title: gen_app_tasks_hub_c3, sub: gen_app_tasks_hub_c4, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksScr1Screen()))),
        DsNavTile(glyph: gen_app_tasks_hub_c5, title: gen_app_tasks_hub_c6, sub: gen_app_tasks_hub_c7, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksEnt2Screen()))),
        DsNavTile(glyph: gen_app_tasks_hub_c8, title: gen_app_tasks_hub_c9, sub: gen_app_tasks_hub_c10, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksAuditScreen()))),
        DsNavTile(glyph: gen_app_tasks_hub_c11, title: gen_app_tasks_hub_c12, sub: gen_app_tasks_hub_c13, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksFlagsScreen()))),
        DsNavTile(glyph: gen_app_tasks_hub_c14, title: gen_app_tasks_hub_c15, sub: gen_app_tasks_hub_c16, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksSettingsScreen()))),
        DsNavTile(glyph: gen_app_tasks_hub_c17, title: gen_app_tasks_hub_c18, sub: gen_app_tasks_hub_c19, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksBehaviorScreen()))),
  ];

  @override
  Widget build(BuildContext context) {
    final all = _tiles(context);
    final vis = _vis[appStore.role.clamp(0, _vis.length - 1)];
    return DsScaffold(
      title: gen_app_tasks_hub_c0,
      subtitle: '${vis.length} מסכים גלויים',
      icon: gen_app_tasks_hub_c1,
      children: [
        for (final i in vis) all[i],
      ],
    );
  }
}
