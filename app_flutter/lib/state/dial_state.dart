import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active persona — the role the user picked in the role picker (null =
/// contractor / main app). Read by the dashboards to scope their view.
final activePersonaProvider = StateProvider<String?>((_) => null);

/// Which main bottom-nav tab is active.
/// 0 = קטלוג · 1 = שיחות · 2 = התראות · 3 = חנות
final mainTabProvider = StateProvider<int>((_) => 0);

/// True when the active tab's header is scrolled out of view.
/// Each screen sets this; the AppBar reads it to show/hide the search icon.
final tabHeaderHiddenProvider = StateProvider<bool>((_) => false);

void resetAllDials(WidgetRef ref) {
  ref.read(activePersonaProvider.notifier).state = null;
}
