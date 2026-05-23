import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which FAB dial is currently open. Only ONE dial is open at a time
/// (R1 — 5 FABs, never two trays at once). Null = nothing open.
enum OpenDial { none, bs, search, bsMode, menu }

final openDialProvider = StateProvider<OpenDial>((_) => OpenDial.none);

/// Active persona within the BS dial (null = root, showing 5 tiles).
final activePersonaProvider = StateProvider<String?>((_) => null);

/// Active tab within the Menu dial (null = root, showing 4 tabs).
enum MenuTab { home, projects, cart, settings }

final menuTabProvider = StateProvider<MenuTab?>((_) => null);
