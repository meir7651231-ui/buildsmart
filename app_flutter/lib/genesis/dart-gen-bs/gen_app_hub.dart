// ✨ חולל ע"י מנוע-הרינדור (render-ds) — לוח-ניווט + שער-הרשאות (בורר-תפקיד חי · נשמר). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_hub_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_audit.dart';
import 'gen_app_bind1.dart';
import 'gen_app_bind2.dart';
import 'gen_app_bind3.dart';
import 'gen_app_bind4.dart';
import 'gen_app_bind5.dart';
import 'gen_app_bind6.dart';
import 'gen_app_ent1.dart';
import 'gen_app_ent2.dart';
import 'gen_app_ent3.dart';
import 'gen_app_ent4.dart';
import 'gen_app_ent5.dart';
import 'gen_app_ent6.dart';
import 'gen_app_flags.dart';
import 'gen_app_over1.dart';
import 'gen_app_over2.dart';
import 'gen_app_over3.dart';
import 'gen_app_rec1.dart';
import 'gen_app_rec2.dart';
import 'gen_app_rec3.dart';
import 'gen_app_rec4.dart';
import 'gen_app_rec5.dart';
import 'gen_app_rec6.dart';
import 'gen_app_scr7.dart';
import 'gen_app_settings.dart';
import 'package:flutter/material.dart';

class GenAppHubScreen extends StatefulWidget {
  const GenAppHubScreen({super.key});

  @override
  State<GenAppHubScreen> createState() => _GenAppHubScreenState();
}

class _GenAppHubScreenState extends State<GenAppHubScreen> {
  static const List<List<int>> _vis = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], [3, 4, 5, 9, 13, 14, 15, 19, 20, 21]];

  List<Widget> _tiles(BuildContext context) => [
        DsNavTile(glyph: gen_app_hub_c3, title: gen_app_hub_c4, sub: gen_app_hub_c5, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt1Screen()))),
        DsNavTile(glyph: gen_app_hub_c6, title: gen_app_hub_c7, sub: gen_app_hub_c8, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt2Screen()))),
        DsNavTile(glyph: gen_app_hub_c9, title: gen_app_hub_c10, sub: gen_app_hub_c11, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt3Screen()))),
        DsNavTile(glyph: gen_app_hub_c12, title: gen_app_hub_c13, sub: gen_app_hub_c14, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt4Screen()))),
        DsNavTile(glyph: gen_app_hub_c15, title: gen_app_hub_c16, sub: gen_app_hub_c17, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt5Screen()))),
        DsNavTile(glyph: gen_app_hub_c18, title: gen_app_hub_c19, sub: gen_app_hub_c20, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt6Screen()))),
        DsNavTile(glyph: gen_app_hub_c21, title: gen_app_hub_c22, sub: gen_app_hub_c23, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppScr7Screen()))),
        DsNavTile(glyph: gen_app_hub_c24, title: gen_app_hub_c25, sub: gen_app_hub_c26, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppOver1Screen()))),
        DsNavTile(glyph: gen_app_hub_c27, title: gen_app_hub_c28, sub: gen_app_hub_c29, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppOver2Screen()))),
        DsNavTile(glyph: gen_app_hub_c30, title: gen_app_hub_c31, sub: gen_app_hub_c32, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppOver3Screen()))),
        DsNavTile(glyph: gen_app_hub_c33, title: gen_app_hub_c34, sub: gen_app_hub_c35, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppRec1Screen()))),
        DsNavTile(glyph: gen_app_hub_c36, title: gen_app_hub_c37, sub: gen_app_hub_c38, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppRec2Screen()))),
        DsNavTile(glyph: gen_app_hub_c39, title: gen_app_hub_c40, sub: gen_app_hub_c41, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppRec3Screen()))),
        DsNavTile(glyph: gen_app_hub_c42, title: gen_app_hub_c43, sub: gen_app_hub_c44, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppRec4Screen()))),
        DsNavTile(glyph: gen_app_hub_c45, title: gen_app_hub_c46, sub: gen_app_hub_c47, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppRec5Screen()))),
        DsNavTile(glyph: gen_app_hub_c48, title: gen_app_hub_c49, sub: gen_app_hub_c50, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppRec6Screen()))),
        DsNavTile(glyph: gen_app_hub_c51, title: gen_app_hub_c52, sub: gen_app_hub_c53, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppBind1Screen()))),
        DsNavTile(glyph: gen_app_hub_c54, title: gen_app_hub_c55, sub: gen_app_hub_c56, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppBind2Screen()))),
        DsNavTile(glyph: gen_app_hub_c57, title: gen_app_hub_c58, sub: gen_app_hub_c59, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppBind3Screen()))),
        DsNavTile(glyph: gen_app_hub_c60, title: gen_app_hub_c61, sub: gen_app_hub_c62, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppBind4Screen()))),
        DsNavTile(glyph: gen_app_hub_c63, title: gen_app_hub_c64, sub: gen_app_hub_c65, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppBind5Screen()))),
        DsNavTile(glyph: gen_app_hub_c66, title: gen_app_hub_c67, sub: gen_app_hub_c68, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppBind6Screen()))),
        DsNavTile(glyph: gen_app_hub_c69, title: gen_app_hub_c70, sub: gen_app_hub_c71, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppAuditScreen()))),
        DsNavTile(glyph: gen_app_hub_c72, title: gen_app_hub_c73, sub: gen_app_hub_c74, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppFlagsScreen()))),
        DsNavTile(glyph: gen_app_hub_c75, title: gen_app_hub_c76, sub: gen_app_hub_c77, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSettingsScreen()))),
  ];

  Widget _actorBar(BuildContext context) => AnimatedBuilder(
    animation: appStore,
    builder: (context, _) {
      final opts = <String>{...appStore.distinctValues('app_ent4', gen_app_hub_c2)}.toList()..sort();
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
      title: gen_app_hub_c0,
      subtitle: '${vis.length} מסכים גלויים',
      icon: gen_app_hub_c1,
      children: [
        _actorBar(context),
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Wrap(children: [_roleChip(0, gen_app_hub_c78), _roleChip(1, gen_app_hub_c79)]),
        ),
        for (final i in vis) all[i],
      ],
    );
  }
}
