// Roadmap step 57 — persisted profession mode + default detail mapping.
import 'package:buildsmart/state/card_detail_mode.dart';
import 'package:buildsmart/state/profession_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to contractor', () {
    SharedPreferences.setMockInitialValues({});
    final n = ProfessionModeNotifier();
    expect(n.state, ProfessionMode.contractor);
  });

  test('defaultDetailFor: diy → simple, contractor/pro → expert', () {
    expect(defaultDetailFor(ProfessionMode.diy), CardDetailMode.simple);
    expect(defaultDetailFor(ProfessionMode.contractor), CardDetailMode.expert);
    expect(defaultDetailFor(ProfessionMode.pro), CardDetailMode.expert);
  });

  test('nextProfessionMode cycles diy → contractor → pro → diy', () {
    expect(nextProfessionMode(ProfessionMode.diy), ProfessionMode.contractor);
    expect(nextProfessionMode(ProfessionMode.contractor), ProfessionMode.pro);
    expect(nextProfessionMode(ProfessionMode.pro), ProfessionMode.diy);
  });

  test('labelForProfession returns a non-empty label per mode', () {
    for (final p in ProfessionMode.values) {
      final l = labelForProfession(p);
      expect(l.emoji, isNotEmpty);
      expect(l.label, isNotEmpty);
    }
  });

  test('set persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = ProfessionModeNotifier();
    n1.set(ProfessionMode.diy);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = ProfessionModeNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.state, ProfessionMode.diy);
  });
}
