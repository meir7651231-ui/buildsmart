// Pins the Pillar-2 trade-builder flags (step 31): all three are default-OFF in a
// fresh FeatureFlagsNotifier and are NEVER force-enabled — the golden guard that
// keeps the whole pillar byte-identical until the owner stages it. The owner-stage
// path (`enable`) still turns one ON without a rebuild, exactly like 'kStudio'.
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/trade_builder_flags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const flags = [kTradeBuilderFlag, kTradeStudioFlag, kTradeImportFlag];

  test('all three trade flags are default-OFF and never force-enabled', () async {
    SharedPreferences.setMockInitialValues({});
    final n = FeatureFlagsNotifier();
    await _settle(); // initial _load (state := loaded ∪ _forcedOnFlags)
    for (final f in flags) {
      // OFF ⇒ neither persisted nor in _forcedOnFlags (else the pillar would leak
      // ON without owner sign-off).
      expect(n.isOn(f), isFalse, reason: '$f must be OFF by default');
      expect(n.state.contains(f), isFalse, reason: '$f must NOT be force-enabled');
    }
    expect(flags.toSet().length, flags.length); // distinct names (no collision)
  });

  test('the owner-stage path turns one flag ON without touching the others', () async {
    SharedPreferences.setMockInitialValues({});
    final n = FeatureFlagsNotifier();
    await _settle();
    n.enable(kTradeBuilderFlag);
    expect(n.isOn(kTradeBuilderFlag), isTrue);
    expect(n.isOn(kTradeStudioFlag), isFalse); // siblings stay off
    expect(n.isOn(kTradeImportFlag), isFalse);
  });
}
