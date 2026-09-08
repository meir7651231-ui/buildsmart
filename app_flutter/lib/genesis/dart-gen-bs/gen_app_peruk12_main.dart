// ✨ חולל ע"י מנוע-הרינדור (render-ds) — שורש-האפליקציה (main + MaterialApp + theme + RTL + PureScope · עור-נייר (G28)). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk12_main_content.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import 'gen_app_peruk12_shell.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GenAppPeruk12MainScreen());

class GenAppPeruk12MainScreen extends StatelessWidget {
  const GenAppPeruk12MainScreen({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: gen_app_peruk12_main_c0,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          fontFamily: 'Heebo',
          scaffoldBackgroundColor: DsPure.skins['paper']!.canvas,
          colorScheme: ColorScheme.fromSeed(seedColor: DsPure.themes['t-balagan']!.a, brightness: Brightness.light),
        ),
        builder: (context, child) => PureScope(
          theme: DsPure.themes['t-balagan']!,
          skin: DsPure.skins['paper']!,
          fonts: DsPure.fontSets['heebo']!,
          child: Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox.shrink()),
        ),
        home: const GenAppPeruk12ShellScreen(),
      );
}
