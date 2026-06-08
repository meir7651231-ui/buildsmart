import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the W0 design decisions (2026-06-08) so the binding waves — and any
/// future edit — can't silently drift them.
void main() {
  test('radius standardized to 20 (W0)', () {
    expect(BsTokens.radiusCard, 20);
  });

  test('success green = bright #22C55E (W0 choice)', () {
    expect(BsTokens.success, const Color(0xFF22C55E));
  });

  test('fine spacing tokens (W0)', () {
    expect(BsTokens.spaceHair, 2);
    expect(BsTokens.space1_5, 6);
  });

  test('fine timing tokens (W0)', () {
    expect(BsTokens.transitionIn, const Duration(milliseconds: 220));
    expect(BsTokens.microIn, const Duration(milliseconds: 150));
  });

  test('8-step type scale (W0)', () {
    expect(
      const [
        BsTokens.typeCaption,
        BsTokens.typeMicro,
        BsTokens.typeLabel,
        BsTokens.typeBody,
        BsTokens.typeSubhead,
        BsTokens.typeTitleSm,
        BsTokens.typeTitleMd,
        BsTokens.typeTitleLg,
      ],
      const [11.0, 12.0, 13.0, 14.0, 16.0, 18.0, 20.0, 24.0],
    );
  });
}
