import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "מצב היכרות" (interactive help / discovery mode).
///
/// When `true`, the main content is frozen and tapping a `HelpTarget`-wrapped
/// element shows a Hebrew explanation of what it does — instead of running its
/// real action. Toggled by the 💡 button in the home app-bar.
///
/// POC scope (task #30): the mechanism + a couple of example targets. The full
/// build-out wraps every interactive element and feeds explanations from a
/// single per-element help registry.
final helpModeProvider = StateProvider<bool>((ref) => false);
