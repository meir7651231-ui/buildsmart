import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drill paths within each menu tab. Each entry = one anchor deeper.
final homeDrillProvider     = StateProvider<List<String>>((_) => const []);
final projectsDrillProvider = StateProvider<List<String>>((_) => const []);
final cartDrillProvider     = StateProvider<List<String>>((_) => const []);

/// Settings sub-state — which of the 10 groups is open, and the drill
/// path within that group.
final settingsGroupProvider     = StateProvider<String?>((_) => null);
final settingsDrillProvider     = StateProvider<List<String>>((_) => const []);
