import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currently-previewed temperature (°C) for the in-card "hot-water suitability"
/// affordance. Transient session state (not persisted): the user previews
/// 60 → 80 → 95 → 60 on tap; default is 60. Roadmap step 26.
final displayTempProvider = StateProvider<int>((_) => 60);

/// Pure cycle: 60 → 80 → 95 → 60 → ...
/// Any other input snaps back to 60 (defensive — shouldn't happen via UI).
int cycleDisplayTemp(int current) {
  switch (current) {
    case 60:
      return 80;
    case 80:
      return 95;
    case 95:
      return 60;
  }
  return 60;
}
