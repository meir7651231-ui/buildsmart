// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «נושאים»: 9 נושאים (מסמך-המוצר §7) ⇒ 30 מודולים לפי חפיפת-מילים · חיבורים · התנהגות. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_topics_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'gen_balagan_behavior.dart';
import 'gen_balagan_keys.dart';
import 'gen_app_calendar_ent1.dart';
import 'gen_app_tasks_ent1.dart';
import 'gen_app_peruk01_ent1.dart';
import 'gen_app_peruk02_ent1.dart';
import 'gen_app_peruk03_ent1.dart';
import 'gen_app_peruk04_ent1.dart';
import 'gen_app_peruk05_ent1.dart';
import 'gen_app_peruk06_ent1.dart';
import 'gen_app_peruk07_ent1.dart';
import 'gen_app_peruk08_ent1.dart';
import 'gen_app_peruk09_ent1.dart';
import 'gen_app_peruk10_ent1.dart';
import 'gen_app_peruk11_ent1.dart';
import 'gen_app_peruk12_ent1.dart';
import 'gen_app_peruk13_ent1.dart';
import 'gen_app_peruk14_ent1.dart';
import 'gen_app_peruk15_ent1.dart';
import 'gen_app_peruk16_ent1.dart';
import 'gen_app_peruk17_ent1.dart';
import 'gen_app_peruk18_ent1.dart';
import 'gen_app_peruk19_ent1.dart';
import 'gen_app_peruk20_ent1.dart';
import 'gen_app_peruk21_ent1.dart';
import 'gen_app_peruk22_ent1.dart';
import 'gen_app_peruk23_ent1.dart';
import 'gen_app_peruk24_ent1.dart';
import 'gen_app_peruk25_ent1.dart';
import 'gen_app_peruk26_ent1.dart';
import 'gen_app_peruk27_ent1.dart';
import 'gen_app_peruk28_ent1.dart';
import 'package:flutter/material.dart';

class GenBalaganTopicsScreen extends StatelessWidget {
  const GenBalaganTopicsScreen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_balagan_topics_c0, subtitle: gen_balagan_topics_c1, icon: gen_balagan_topics_c2, children: [
    DsSection(title: gen_balagan_topics_c3, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c4, sub: gen_balagan_topics_c5, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppCalendarEnt1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c6, sub: gen_balagan_topics_c7, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksEnt1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c8, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c9, sub: gen_balagan_topics_c10, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c11, sub: gen_balagan_topics_c12, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk02Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c13, sub: gen_balagan_topics_c14, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk03Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c15, sub: gen_balagan_topics_c16, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk04Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c17, sub: gen_balagan_topics_c18, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk05Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c19, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c20, sub: gen_balagan_topics_c21, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk21Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c22, sub: gen_balagan_topics_c23, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk22Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c24, sub: gen_balagan_topics_c25, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c26, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c27, sub: gen_balagan_topics_c28, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk11Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c29, sub: gen_balagan_topics_c30, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk12Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c31, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c32, sub: gen_balagan_topics_c33, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk13Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c34, sub: gen_balagan_topics_c35, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk14Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c36, sub: gen_balagan_topics_c37, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk15Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c38, sub: gen_balagan_topics_c39, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk16Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c40, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c41, sub: gen_balagan_topics_c42, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk06Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c43, sub: gen_balagan_topics_c44, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk07Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c45, sub: gen_balagan_topics_c46, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk08Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c47, sub: gen_balagan_topics_c48, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk10Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c49, sub: gen_balagan_topics_c50, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk17Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c51, sub: gen_balagan_topics_c52, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk18Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c53, sub: gen_balagan_topics_c54, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk19Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c55, sub: gen_balagan_topics_c56, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk20Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c57, sub: gen_balagan_topics_c58, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk26Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c59, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c60, sub: gen_balagan_topics_c61, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk24Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c62, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c63, sub: gen_balagan_topics_c64, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk09Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c65, sub: gen_balagan_topics_c66, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk25Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c67, sub: gen_balagan_topics_c68, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk28Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c69, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c70, sub: gen_balagan_topics_c71, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk27Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c72, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c73, sub: gen_balagan_topics_c74, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenBalaganKeysScreen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c75, sub: gen_balagan_topics_c76, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenBalaganBehaviorScreen()))),
    ]),
  ]);
}
