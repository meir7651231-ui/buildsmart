import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: BuildSmartApp()));
}

class BuildSmartApp extends ConsumerWidget {
  const BuildSmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final locale = switch (settings.lang) {
      BsLang.he => const Locale('he', 'IL'),
      BsLang.ar => const Locale('ar'),
      BsLang.en => const Locale('en', 'US'),
    };
    return MaterialApp(
      title: 'BuildSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode:
          settings.theme == BsTheme.dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('ar'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}
