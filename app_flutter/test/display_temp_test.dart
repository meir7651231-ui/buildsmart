// Roadmap step 26 — interactive temperature picker (cycle).
import 'package:buildsmart/state/display_temp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cycle: 60 → 80 → 95 → 60', () {
    expect(cycleDisplayTemp(60), 80);
    expect(cycleDisplayTemp(80), 95);
    expect(cycleDisplayTemp(95), 60);
  });

  test('any unexpected value snaps to 60', () {
    expect(cycleDisplayTemp(20), 60);
    expect(cycleDisplayTemp(120), 60);
    expect(cycleDisplayTemp(0), 60);
  });

  test('repeated cycling returns to start every 3 steps', () {
    var t = 60;
    for (var i = 0; i < 9; i++) {
      t = cycleDisplayTemp(t);
    }
    expect(t, 60);
  });
}
