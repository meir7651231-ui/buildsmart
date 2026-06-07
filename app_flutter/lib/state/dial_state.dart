import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which FAB dial is currently open. Only ONE dial is open at a time
/// (R1 — never two trays at once). Null = nothing open.
enum OpenDial { none, search }

final openDialProvider = StateProvider<OpenDial>((_) => OpenDial.none);

/// Active persona — the role the user picked in the role picker (null =
/// contractor / main app). Read by the dashboards to scope their view.
final activePersonaProvider = StateProvider<String?>((_) => null);

/// Active tool within the Search FAB (null = 4-tool root).
/// catalog is now a main bottom-nav tab, not a search tool.
enum SearchTool { voice, barcode, filters, sort }

final searchToolProvider = StateProvider<SearchTool?>((_) => null);

/// Which main bottom-nav tab is active.
/// 0 = קטלוג · 1 = שיחות · 2 = התראות · 3 = חנות
final mainTabProvider = StateProvider<int>((_) => 0);

/// True when the active tab's header is scrolled out of view.
/// Each screen sets this; the AppBar reads it to show/hide the search icon.
final tabHeaderHiddenProvider = StateProvider<bool>((_) => false);

void resetAllDials(WidgetRef ref) {
  ref.read(openDialProvider.notifier).state = OpenDial.none;
  ref.read(activePersonaProvider.notifier).state = null;
  ref.read(searchToolProvider.notifier).state = null;
}
