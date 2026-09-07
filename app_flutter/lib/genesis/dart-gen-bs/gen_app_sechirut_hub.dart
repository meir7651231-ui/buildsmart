// ✨ חולל ע"י מנוע-הרינדור (render-ds) — לוח-ניווט + שער-הרשאות (בורר-תפקיד חי · נשמר). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_sechirut_hub_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_sechirut_audit.dart';
import 'gen_app_sechirut_bind1.dart';
import 'gen_app_sechirut_bind2.dart';
import 'gen_app_sechirut_bind3.dart';
import 'gen_app_sechirut_bind4.dart';
import 'gen_app_sechirut_ent1.dart';
import 'gen_app_sechirut_ent2.dart';
import 'gen_app_sechirut_ent3.dart';
import 'gen_app_sechirut_ent4.dart';
import 'gen_app_sechirut_flags.dart';
import 'gen_app_sechirut_over1.dart';
import 'gen_app_sechirut_over2.dart';
import 'gen_app_sechirut_rec1.dart';
import 'gen_app_sechirut_rec2.dart';
import 'gen_app_sechirut_rec3.dart';
import 'gen_app_sechirut_rec4.dart';
import 'gen_app_sechirut_scr5.dart';
import 'gen_app_sechirut_settings.dart';
import 'package:flutter/material.dart';

class GenAppSechirutHubScreen extends StatefulWidget {
  const GenAppSechirutHubScreen({super.key});

  @override
  State<GenAppSechirutHubScreen> createState() => _GenAppSechirutHubScreenState();
}

class _GenAppSechirutHubScreenState extends State<GenAppSechirutHubScreen> {
  static const List<List<int>> _vis = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], [0, 1, 2, 5, 7, 8, 9, 11, 12, 13]];

  List<Widget> _tiles(BuildContext context) => [
        DsNavTile(glyph: gen_app_sechirut_hub_c3, title: gen_app_sechirut_hub_c4, sub: gen_app_sechirut_hub_c5, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt1Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c6, title: gen_app_sechirut_hub_c7, sub: gen_app_sechirut_hub_c8, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt2Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c9, title: gen_app_sechirut_hub_c10, sub: gen_app_sechirut_hub_c11, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt3Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c12, title: gen_app_sechirut_hub_c13, sub: gen_app_sechirut_hub_c14, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt4Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c15, title: gen_app_sechirut_hub_c16, sub: gen_app_sechirut_hub_c17, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutScr5Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c18, title: gen_app_sechirut_hub_c19, sub: gen_app_sechirut_hub_c20, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutOver1Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c21, title: gen_app_sechirut_hub_c22, sub: gen_app_sechirut_hub_c23, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutOver2Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c24, title: gen_app_sechirut_hub_c25, sub: gen_app_sechirut_hub_c26, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutRec1Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c27, title: gen_app_sechirut_hub_c28, sub: gen_app_sechirut_hub_c29, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutRec2Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c30, title: gen_app_sechirut_hub_c31, sub: gen_app_sechirut_hub_c32, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutRec3Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c33, title: gen_app_sechirut_hub_c34, sub: gen_app_sechirut_hub_c35, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutRec4Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c36, title: gen_app_sechirut_hub_c37, sub: gen_app_sechirut_hub_c38, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutBind1Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c39, title: gen_app_sechirut_hub_c40, sub: gen_app_sechirut_hub_c41, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutBind2Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c42, title: gen_app_sechirut_hub_c43, sub: gen_app_sechirut_hub_c44, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutBind3Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c45, title: gen_app_sechirut_hub_c46, sub: gen_app_sechirut_hub_c47, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutBind4Screen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c48, title: gen_app_sechirut_hub_c49, sub: gen_app_sechirut_hub_c50, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutAuditScreen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c51, title: gen_app_sechirut_hub_c52, sub: gen_app_sechirut_hub_c53, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutFlagsScreen()))),
        DsNavTile(glyph: gen_app_sechirut_hub_c54, title: gen_app_sechirut_hub_c55, sub: gen_app_sechirut_hub_c56, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutSettingsScreen()))),
  ];

  Widget _actorBar(BuildContext context) => AnimatedBuilder(
    animation: appStore,
    builder: (context, _) {
      final opts = <String>{...appStore.distinctValues('app_sechirut_ent1', gen_app_sechirut_hub_c2)}.toList()..sort();
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Text('מציג כ:', style: TextStyle(fontSize: 12.5, color: DsTokens.muted, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: appStore.actor,
            underline: const SizedBox.shrink(),
            items: [const DropdownMenuItem<String>(value: '', child: Text('הכל')), for (final o in opts) if (o.isNotEmpty) DropdownMenuItem<String>(value: o, child: Text(o))],
            onChanged: (v) => setState(() => appStore.setActor(v ?? '')),
          ),
          const Spacer(),
          const Text('סינון-תצוגה', style: TextStyle(fontSize: 11, color: DsTokens.faint)),
        ]),
      );
    },
  );

  Widget _roleChip(int i, String label) {
    final sel = appStore.role == i;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Material(
        color: sel ? DsTokens.accent : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => appStore.setRole(i)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(label, style: TextStyle(color: sel ? Colors.white : DsTokens.muted, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = _tiles(context);
    final vis = _vis[appStore.role.clamp(0, _vis.length - 1)];
    return DsScaffold(
      title: gen_app_sechirut_hub_c0,
      subtitle: '${vis.length} מסכים גלויים',
      icon: gen_app_sechirut_hub_c1,
      children: [
        _actorBar(context),
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Wrap(children: [_roleChip(0, gen_app_sechirut_hub_c57), _roleChip(1, gen_app_sechirut_hub_c58)]),
        ),
        for (final i in vis) all[i],
      ],
    );
  }
}
