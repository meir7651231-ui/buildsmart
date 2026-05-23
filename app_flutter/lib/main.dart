import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: BuildSmartApp()));
}

class BuildSmartApp extends StatelessWidget {
  const BuildSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildSmart',
      debugShowCheckedModeBanner: false,
      theme: BsTheme.dark(),
      darkTheme: BsTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: const Locale('he', 'IL'),
      supportedLocales: const [Locale('he', 'IL'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}
