import 'package:buildsmart/features/word_finder/size_equiv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the three spellings of one BSP bore fold to a single key', () {
    expect(canonicalSize('1/2"'), 'DN15');
    expect(canonicalSize('DN15'), 'DN15');
    expect(canonicalSize('15mm'), 'DN15');
    expect(canonicalSize('1/2"'), canonicalSize('DN15'));
    expect(canonicalSize('DN15'), canonicalSize('15mm'));
  });

  test('3/4" folds with DN20', () {
    expect(canonicalSize('3/4"'), 'DN20');
    expect(canonicalSize('3/4"'), canonicalSize('DN20'));
  });

  test('pretty glyphs and Hebrew mm fold the same as ASCII', () {
    expect(canonicalSize('½"'), 'DN15');
    expect(canonicalSize('15 מ"מ'), 'DN15');
    expect(canonicalSize('¾"'), 'DN20');
    expect(canonicalSize('Ø1/2"'), 'DN15'); // diameter-prefixed
  });

  test('whole inches resolve through kBspInchToMm', () {
    expect(canonicalSize('1"'), 'DN25');
    expect(canonicalSize('2"'), 'DN50');
  });

  test('cross-dim, cm, metre and angle are not a single bore -> null', () {
    expect(canonicalSize('16×20'), isNull);
    expect(canonicalSize('20×2.8'), isNull);
    expect(canonicalSize('15 ס"מ'), isNull);
    expect(canonicalSize('2 מטר'), isNull);
    expect(canonicalSize('45°'), isNull);
  });

  test('an inch with no BSP-nominal entry returns null', () {
    expect(canonicalSize('5"'), isNull);
  });

  test('idempotent: canonicalSize of a canonical key is itself', () {
    final once = canonicalSize('½"');
    expect(once, 'DN15');
    expect(canonicalSize(once!), 'DN15');
  });

  test('empty / junk returns null', () {
    expect(canonicalSize(''), isNull);
    expect(canonicalSize('   '), isNull);
    expect(canonicalSize('בורג'), isNull);
  });
}
