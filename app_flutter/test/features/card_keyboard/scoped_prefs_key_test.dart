import 'package:buildsmart/features/card_keyboard/scoped_prefs_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('null/empty uid preserves the legacy global key (byte-identical)', () {
    expect(scopedPrefsKey('bs.recently-viewed.v1', null), 'bs.recently-viewed.v1');
    expect(scopedPrefsKey('bs.recently-viewed.v1', ''), 'bs.recently-viewed.v1');
  });

  test('a real uid namespaces the key, distinctly per identity', () {
    expect(
      scopedPrefsKey('bs.product-favorites.v1', 'A'),
      'bs.product-favorites.v1::A',
    );
    expect(scopedPrefsKey('k', 'A'), isNot('k'));
    expect(scopedPrefsKey('k', 'A'), isNot(scopedPrefsKey('k', 'B')));
  });

  test('is pure / deterministic', () {
    expect(scopedPrefsKey('k', 'A'), scopedPrefsKey('k', 'A'));
  });
}
