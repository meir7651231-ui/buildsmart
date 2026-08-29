import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show SignalChip;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('infoGain is NOT part of == / hashCode (P2.46)', () {
    const a = SignalChip(
        axisId: 'size', value: 'DN15', displayLabel: '½"', infoGain: 1);
    const b = SignalChip(
        axisId: 'size', value: 'DN15', displayLabel: '½"', infoGain: 2);
    expect(a, b, reason: 'chips are equal when all fields but infoGain match');
    expect(a.hashCode, b.hashCode);
    expect({a, b}, hasLength(1), reason: 'a Set dedups infoGain-only diffs');
  });

  test('an identity field still breaks equality', () {
    const a = SignalChip(axisId: 'size', value: 'DN15', displayLabel: '½"');
    const b = SignalChip(axisId: 'size', value: 'DN20', displayLabel: '¾"');
    expect(a, isNot(b));
  });

  test('infoGain is still carried (display tier preserved)', () {
    const a = SignalChip(
        axisId: 'size', value: 'DN15', displayLabel: '½"', infoGain: 3.5);
    expect(a.infoGain, 3.5);
  });
}
