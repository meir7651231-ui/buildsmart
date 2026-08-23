// TEMP demo entry (NOT shipped). Runs the REAL BuildSmart app with BOTH
// kWordFinder + kCardKeyboard forced ON, so the catalog shows the existing
// 'מאתר חכם' pill AND the new 'מקלדת חכמה' (#38 unified card-keyboard) pill side
// by side — the A/B the owner asked for. Firebase is intentionally NOT
// initialised here, so the app boots on its local seed data (per main.dart's
// "Firebase absent -> local repos" invariant). Mirrors _app_wordfinder_demo.dart.
//
// The LIVE deploy does NOT enable kCardKeyboard (no --dart-define), so the site
// stays byte-identical; this entry is how you reach the A/B during the trial.
//
// Run:  flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5000 -t lib/_app_cardkeyboard_demo.dart
import 'package:buildsmart/features/card_keyboard/card_keyboard_flag.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/main.dart' show BuildSmartApp;
import 'package:buildsmart/state/feature_flags.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        featureFlagsProvider.overrideWith((ref) {
          return FeatureFlagsNotifier()
            ..enable(kWordFinderFlag)
            ..enable(kCardKeyboardFlag);
        }),
      ],
      child: const BuildSmartApp(),
    ),
  );
}
