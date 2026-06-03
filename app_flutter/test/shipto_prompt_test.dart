import 'package:buildsmart/screens/store_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Benzi #4 — the "לאן לשלוח" popup is ONE-TIME (first product selection only).
/// `loadShipToPrompted` / `saveShipToPrompted` are the persisted guard that makes
/// it never repeat. (`shipToPromptedProvider` defaults true so widget tests skip
/// it; `main()` seeds it from these helpers.)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh install → load is false (the popup will show once)', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await loadShipToPrompted(), isFalse);
  });

  test('save persists → load is true (never prompts again)', () async {
    SharedPreferences.setMockInitialValues({});
    await saveShipToPrompted();
    expect(await loadShipToPrompted(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kShipToPromptedKey), isTrue);
  });
}
