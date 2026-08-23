import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('InputFieldKind has exactly 9 kinds', () {
    expect(InputFieldKind.values.length, 9);
  });

  test('kSmartInputFlag is the verbatim feature-flag key', () {
    expect(kSmartInputFlag, 'kSmartInput');
  });

  test('SmartInputContext defaults: empty screenId + empty payload', () {
    const ctx = SmartInputContext(kind: InputFieldKind.freeTextHe);
    expect(ctx.screenId, '');
    expect(ctx.payload, isEmpty);
  });

  test('Suggestion.display falls back to text, then prefers label', () {
    expect(const Suggestion('x').display, 'x');
    expect(const Suggestion('x', label: 'L').display, 'L');
  });

  test('Suggestion.isPrimary defaults to false', () {
    expect(const Suggestion('x').isPrimary, isFalse);
  });
}
