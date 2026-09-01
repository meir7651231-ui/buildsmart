// ✨ חולל ע"י מנוע-הרינדור (render-ds) — שורש-האפליקציה (main + MaterialApp + theme + RTL). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_main_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'gen_app_hub.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GenAppMainScreen());

class GenAppMainScreen extends StatelessWidget {
  const GenAppMainScreen({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: gen_app_main_c0,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Heebo',
          scaffoldBackgroundColor: DsTokens.bg,
          colorScheme: ColorScheme.fromSeed(seedColor: DsTokens.accent),
        ),
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const GenAppHubScreen(),
      );
}
