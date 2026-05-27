// Verify chip structure for products across multiple categories.
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';

void main() {
  group('chip structure — ראשי מקלחת', () {
    final showers = kLipskeyCatalog
        .where((p) => p.categoryHe == 'ראשי מקלחת')
        .toList();

    for (final p in showers) {
      test(p.nameHe, () {
        final words = p.nameHe.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        final chips = <(String, AttrKind)>[];
        for (final w in words) {
          final k = _testAttrKindFor(w);
          if (k != null) chips.add((w, k));
        }
        final kinds = chips.map((c) => c.$2).toSet();
        // Every דיור shower head should have model + size chips at minimum
        if (p.nameHe.contains('דיור')) {
          expect(kinds.contains(AttrKind.model), isTrue,
              reason: 'expected model chip in ${p.nameHe}');
          expect(kinds.contains(AttrKind.size), isTrue,
              reason: 'expected size chip in ${p.nameHe}');
        }
        // products with ניקל/זהב/שחור should have a color chip
        if (p.nameHe.contains('ניקל') || p.nameHe.contains('זהב') || p.nameHe.contains('שחור')) {
          expect(kinds.contains(AttrKind.color), isTrue,
              reason: 'expected color chip in ${p.nameHe}');
        }
        // מוברש/מט → colorMod chip
        if (p.nameHe.contains('מוברש') || p.nameHe.contains(' מט ')) {
          expect(kinds.contains(AttrKind.colorMod), isTrue,
              reason: 'expected colorMod chip in ${p.nameHe}');
        }
        // עגול/מרובע → subtype chip
        if (p.nameHe.contains('עגול') || p.nameHe.contains('מרובע')) {
          expect(kinds.contains(AttrKind.subtype), isTrue,
              reason: 'expected subtype chip in ${p.nameHe}');
        }
        // No compound "ניקל מוברש" or "שחור מט" should appear as a single chip;
        // they must be split into separate color + colorMod chips.
        for (final entry in kLipskeyColors) {
          if (entry.contains(' ') && p.nameHe.contains(entry)) {
            // multi-word color entry → must see BOTH color and colorMod chips
            expect(kinds.contains(AttrKind.color), isTrue,
                reason: 'compound "$entry" → color chip in ${p.nameHe}');
            expect(kinds.contains(AttrKind.colorMod), isTrue,
                reason: 'compound "$entry" → colorMod chip in ${p.nameHe}');
          }
        }
      });
    }
  });

  group('chip structure — מזלפי יד', () {
    final products = kLipskeyCatalog
        .where((p) => p.categoryHe == 'מזלפי יד')
        .toList();

    for (final p in products) {
      test(p.nameHe, () {
        final words = p.nameHe.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        final chips = <(String, AttrKind)>[];
        for (final w in words) {
          final k = _testAttrKindFor(w);
          if (k != null) chips.add((w, k));
        }
        final kinds = chips.map((c) => c.$2).toSet();
        // Compound colors must be split
        for (final entry in kLipskeyColors) {
          if (entry.contains(' ') && p.nameHe.contains(entry)) {
            expect(kinds.contains(AttrKind.color), isTrue,
                reason: 'compound "$entry" → color chip in ${p.nameHe}');
            expect(kinds.contains(AttrKind.colorMod), isTrue,
                reason: 'compound "$entry" → colorMod chip in ${p.nameHe}');
          }
        }
      });
    }
  });

  group('sibling pickers — ראשי מקלחת', () {
    test('עגול ניקל 200 — color picker shows ניקל + שחור', () {
      final p = kLipskeyCatalog.firstWhere(
          (q) => q.nameHe == 'דיור ראש מקלחת עגול ניקל 200 מ"מ');
      final siblings = findAttrSiblings(p, 'ניקל', AttrKind.color);
      expect(siblings.length, greaterThan(1));
      final colorWords = siblings
          .expand((s) => s.nameHe.split(RegExp(r'\s+')))
          .where((w) => kLipskeyColors.any((c) =>
              c.split(RegExp(r'\s+')).contains(w)))
          .toSet();
      expect(colorWords, contains('ניקל'));
      expect(colorWords, contains('שחור'));
    });

    test('מרובע ניקל 200 — size picker shows 200 + 250', () {
      final p = kLipskeyCatalog.firstWhere(
          (q) => q.nameHe == 'דיור ראש מקלחת מרובע ניקל 200 מ"מ');
      final siblings = findAttrSiblings(p, '200', AttrKind.size);
      expect(siblings.length, equals(2));
      final sizes = siblings
          .expand((s) => s.nameHe.split(RegExp(r'\s+')))
          .where(isSizeToken)
          .toSet();
      expect(sizes, contains('200'));
      expect(sizes, contains('250'));
    });

    test('מרובע ניקל 200 — subtype picker shows מרובע + עגול', () {
      final p = kLipskeyCatalog.firstWhere(
          (q) => q.nameHe == 'דיור ראש מקלחת מרובע ניקל 200 מ"מ');
      final siblings = findAttrSiblings(p, 'מרובע', AttrKind.subtype);
      expect(siblings.length, equals(2));
      final subtypes = siblings
          .expand((s) => s.nameHe.split(RegExp(r'\s+')))
          .where((w) => kLipskeySubtypes.contains(w))
          .toSet();
      expect(subtypes, contains('מרובע'));
      expect(subtypes, contains('עגול'));
    });
  });
}

// Local copy so tests can call it without being inside the widget
AttrKind? _testAttrKindFor(String word) {
  if (isSizeToken(word)) return AttrKind.size;
  const mods = {'מוברש', 'מט'};
  if (mods.contains(word)) return AttrKind.colorMod;
  // Check color: word is a sub-word of any kLipskeyColors entry
  final colorSubWords = <String>{
    for (final v in kLipskeyColors) ...v.split(RegExp(r'\s+')).where((w) => w.length >= 2),
  };
  if (colorSubWords.contains(word)) return AttrKind.color;
  if (kLipskeyModels.contains(word)) return AttrKind.model;
  if (kLipskeySubtypes.contains(word)) return AttrKind.subtype;
  return null;
}
