// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — שורש בלגן: אפליקציה אחת, 28 מודולים, חנות אחת. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_main_content.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_balagan_shell.dart';
import 'gen_app_peruk01_relations.dart' as r_peruk01;
import 'gen_app_peruk02_relations.dart' as r_peruk02;
import 'gen_app_peruk04_relations.dart' as r_peruk04;
import 'gen_app_peruk05_relations.dart' as r_peruk05;
import 'gen_app_peruk06_relations.dart' as r_peruk06;
import 'gen_app_peruk09_relations.dart' as r_peruk09;
import 'package:flutter/material.dart';

void main() {
  r_peruk01.registerAppRelations(appStore);
  r_peruk02.registerAppRelations(appStore);
  r_peruk04.registerAppRelations(appStore);
  r_peruk05.registerAppRelations(appStore);
  r_peruk06.registerAppRelations(appStore);
  r_peruk09.registerAppRelations(appStore);
  runApp(const GenBalaganMainScreen());
}

class GenBalaganMainScreen extends StatelessWidget {
  const GenBalaganMainScreen({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: gen_balagan_main_c0,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light, fontFamily: 'Heebo', scaffoldBackgroundColor: DsPure.skins['paper']!.canvas, colorScheme: ColorScheme.fromSeed(seedColor: DsPure.themes['t-balagan']!.a, brightness: Brightness.light)),
        builder: (context, child) => PureScope(theme: DsPure.themes['t-balagan']!, skin: DsPure.skins['paper']!, fonts: DsPure.fontSets['heebo']!, child: Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox.shrink())),
        home: const GenBalaganShellScreen(),
      );
}
