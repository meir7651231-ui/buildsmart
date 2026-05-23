import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which FAB dial is currently open. Only ONE dial is open at a time
/// (R1 — 5 FABs, never two trays at once). Null = nothing open.
enum OpenDial { none, bs, search, bsMode, menu }

final openDialProvider = StateProvider<OpenDial>((_) => OpenDial.none);

/// Active persona within the BS dial (null = root, showing 5 tiles).
final activePersonaProvider = StateProvider<String?>((_) => null);

/// Drill path within the active persona's tree (by section title).
/// Empty = at the persona's L2 view. Each entry = one anchor deeper.
final bsDrillPathProvider = StateProvider<List<String>>((_) => const []);

/// Which menu tab is currently drilled into (null = 4-tab root).
enum MenuTab { home, projects, cart, settings }

final menuTabProvider = StateProvider<MenuTab?>((_) => null);

/// Active tool within the Search FAB (null = 5-tool root).
enum SearchTool { voice, barcode, filters, sort, catalog }

final searchToolProvider = StateProvider<SearchTool?>((_) => null);

/// Resets every drill state when the user closes the FAB rail.
void resetAllDials(WidgetRef ref) {
  ref.read(openDialProvider.notifier).state = OpenDial.none;
  ref.read(activePersonaProvider.notifier).state = null;
  ref.read(bsDrillPathProvider.notifier).state = const [];
  ref.read(menuTabProvider.notifier).state = null;
  ref.read(searchToolProvider.notifier).state = null;
}
