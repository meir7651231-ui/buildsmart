import 'package:buildsmart/screens/finder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// I1 — the finder group circles render a Material icon instead of an emoji
/// glyph canvaskit's bundled font can't draw (the home screen showed empty
/// boxes). Every group must have a mapped icon — a missing entry would fall
/// back to a generic placeholder, which is the bug we're closing.
void main() {
  test('every finder group has a dedicated (non-fallback) icon', () {
    final unmapped = <String>[];
    for (final g in kFinderGroups) {
      if (!kFinderGroupIcons.containsKey(g.label)) unmapped.add(g.label);
    }
    expect(unmapped, isEmpty,
        reason: 'finder groups without an icon mapping: ${unmapped.join(", ")}');
  });

  test('finderGroupIcon returns the mapped icon, fallback only for unknown', () {
    expect(finderGroupIcon('ברזים'), isNot(Icons.category),
        reason: 'a known group must not resolve to the catch-all fallback');
    expect(finderGroupIcon('__no_such_group__'), Icons.category);
  });

  test('no two groups share the same icon (each is visually distinct)', () {
    final icons = kFinderGroups.map((g) => finderGroupIcon(g.label)).toList();
    expect(icons.toSet().length, icons.length,
        reason: 'duplicate icons make groups indistinguishable: $icons');
  });

  // Designer 3D product icons (the primary glyph; icon is the fallback).
  test('every finder group has a dedicated 3D product image', () {
    final unmapped = <String>[];
    for (final g in kFinderGroups) {
      if (!kFinderGroupImage.containsKey(g.label)) unmapped.add(g.label);
    }
    expect(unmapped, isEmpty,
        reason: 'finder groups without a product image: ${unmapped.join(", ")}');
  });

  test('finderGroupImageAsset points under assets/lipskey/categories', () {
    expect(finderGroupImageAsset('ברזים'),
        'assets/lipskey/categories/faucets.png');
    expect(finderGroupImageAsset('צנרת PPR'),
        'assets/lipskey/categories/ppr.png');
    expect(finderGroupImageAsset('__no_such_group__'), isNull);
  });

  test('no two groups share the same product image', () {
    final imgs = kFinderGroupImage.values.toList();
    expect(imgs.toSet().length, imgs.length,
        reason: 'duplicate product images: $imgs');
  });
}
