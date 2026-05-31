import 'package:buildsmart/screens/_size_norm.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pure-logic coverage of the finder's size axis. These run against the
/// extracted size_norm utility so the tests stay independent of UI.
void main() {
  group('parseSizeTokens — by structure, not substring', () {
    test('inch fractions (½", 1/2", 1.5") collapse to one canonical form', () {
      final a = parseSizeTokens('ברז 1/2"').map((t) => t.label).toSet();
      final b = parseSizeTokens('ברז ½"').map((t) => t.label).toSet();
      final c = parseSizeTokens('ברז 1.5"').map((t) => t.label).toSet();
      expect(a, equals(b),
          reason: '1/2" and ½" must yield the same chip label');
      expect(c.first, equals('1½"'),
          reason: '1.5" must pretty-print to 1½"');
    });

    test('mm / cm / metre / DN are tagged with the correct family', () {
      expect(parseSizeTokens('זרוע 200 מ"מ').first.family, SizeFamily.mm);
      expect(parseSizeTokens('ראש 25 ס"מ').first.family, SizeFamily.cm);
      expect(parseSizeTokens('צינור DN40').first.family, SizeFamily.dnDiameter);
      expect(parseSizeTokens('ברז 1/2"').first.family, SizeFamily.inchDiameter);
    });

    test('angles are NOT size tokens (separate axis)', () {
      final t = parseSizeTokens('ברך 45°');
      expect(t.where((x) => x.family != SizeFamily.angle).isEmpty, isTrue);
    });

    test('cross-dim (25 ס"מ × 30 ס"מ) yields BOTH tokens', () {
      final t = parseSizeTokens('ראש 25 ס"מ × 30 ס"מ');
      final labels = t.map((x) => x.label).toSet();
      expect(labels, containsAll(['25 ס"מ', '30 ס"מ']));
    });

    test('long compound tokens are NOT silently dropped', () {
      // ½"×¾"×½" — older code's length<=12 cap would have hidden this.
      final t = parseSizeTokens('מסעף ½"×¾"×½"');
      expect(t, isNotEmpty);
    });

    test('decimal cross-dim (20×2.8) survives in FULL', () {
      // multilayer pipe `20×2.8` (20 mm OD × 2.8 mm wall) — regression: an
      // earlier regex truncated to `20×2` and broke card-render tests.
      final t = parseSizeTokens('צינור רב-שכבתי 20×2.8');
      expect(t.first.label, '20×2.8');
    });

    test('"25 שנים אחריות" does NOT yield a size token', () {
      final t = parseSizeTokens('ברז 25 שנים אחריות');
      expect(t, isEmpty);
    });
  });

  group('tokenFromDims — DN / L(cm) fallback', () {
    test('DN+L(cm) both, produces two tokens', () {
      final t = tokensFromDims({'DN': '40', 'L (cm)': '50'});
      final labels = t.map((x) => x.label).toSet();
      expect(labels, containsAll(['DN40', '0.5 מ׳']));
    });
    test('missing DN/L returns empty', () {
      expect(tokensFromDims({'material': 'PVC'}), isEmpty);
    });
  });

  group('leading zeros (P15) — `020 מ"מ` reads as `20 מ"מ`', () {
    test('mm token strips leading zeros from the number', () {
      expect(parseSizeTokens('זרוע 020 מ"מ').first.label, '20 מ"מ');
      expect(parseSizeTokens('זרוע 040 מ"מ').first.label, '40 מ"מ');
    });
    test('DN token strips leading zeros', () {
      expect(parseSizeTokens('צינור DN040').first.label, 'DN40');
    });
    test('cm token strips leading zeros', () {
      expect(parseSizeTokens('ראש 025 ס"מ').first.label, '25 ס"מ');
    });
    test('non-zero-prefixed labels unchanged', () {
      expect(parseSizeTokens('זרוע 200 מ"מ').first.label, '200 מ"מ');
      expect(parseSizeTokens('צינור DN40').first.label, 'DN40');
    });
  });

  group('font-safe glyphs (P13) — fold ⅛/⅜/⅝/⅞ to ASCII', () {
    test('rare unicode fractions fold to ASCII (canvaskit font miss)', () {
      expect(prettyInch('⅜"'), '3/8"');
      expect(prettyInch('⅛"'), '1/8"');
      expect(prettyInch('⅝"'), '5/8"');
      expect(prettyInch('⅞"'), '7/8"');
    });
    test('common fractions stay as glyphs (font renders them fine)', () {
      expect(prettyInch('½"'), '½"');
      expect(prettyInch('¼"'), '¼"');
      expect(prettyInch('¾"'), '¾"');
      expect(prettyInch('1¼"'), '1¼"');
    });
    test('parseSizeTokens propagates the ASCII label so filter+card agree', () {
      final t = parseSizeTokens('צינור ⅜"');
      expect(t.first.label, '3/8"');
    });
  });

  group('displaySizeLabel (P12) — strip noise prefix, pretty-fold inch', () {
    test('Ø-prefixed inch is reduced to canonical glyph', () {
      expect(displaySizeLabel('Ø1/2"'), '½"');
      expect(displaySizeLabel('Ø3/4"'), '¾"');
      expect(displaySizeLabel('Ø1.25"'), '1¼"');
    });
    test('clean inch passes through prettyInch', () {
      expect(displaySizeLabel('1.25"'), '1¼"');
      expect(displaySizeLabel('½"'),    '½"');
    });
    test('DN/cm/mm tokens come back canonical', () {
      expect(displaySizeLabel('DN40'),    'DN40');
      expect(displaySizeLabel('25 ס"מ'),  '25 ס"מ');
      expect(displaySizeLabel('200 מ"מ'), '200 מ"מ');
    });
    test('non-size word passes through unchanged', () {
      expect(displaySizeLabel('שחור'), 'שחור');
      expect(displaySizeLabel('foo'), 'foo');
    });
  });

  group('dedup length by mm (P11) — cm wins over equivalent meters', () {
    test('15 ס"מ + 0.15 מ׳ → ONE chip (cm form survives)', () {
      final tokens = [
        SizeToken(label: '15 ס"מ',  family: SizeFamily.cm,     mm: 150),
        SizeToken(label: '0.15 מ׳', family: SizeFamily.meters,  mm: 150),
        SizeToken(label: '3 מ׳',    family: SizeFamily.meters,  mm: 3000),
        SizeToken(label: '300 ס"מ', family: SizeFamily.cm,     mm: 3000),
      ];
      final out = dedupLengthByMm(tokens);
      final labels = out.map((t) => t.label).toSet();
      expect(labels, equals({'15 ס"מ', '300 ס"מ'}));
    });

    test('meters survives when no cm twin exists', () {
      final tokens = [
        SizeToken(label: '5 מ׳', family: SizeFamily.meters, mm: 5000),
      ];
      final out = dedupLengthByMm(tokens);
      expect(out.map((t) => t.label), ['5 מ׳']);
    });

    test('non-length tokens (DN/inch/angle) pass through untouched', () {
      final tokens = [
        SizeToken(label: 'DN40', family: SizeFamily.dnDiameter, mm: 40),
        SizeToken(label: '½"',   family: SizeFamily.inchDiameter, mm: 12.7),
        SizeToken(label: '45°',  family: SizeFamily.angle,        mm: 45),
      ];
      final out = dedupLengthByMm(tokens);
      expect(out.length, 3);
    });
  });

  group('union — name AND dims both contribute (P10)', () {
    test('pipe: name has length (300 ס"מ), dims has diameter (DN110) — '
        'BOTH must surface (the finder filter needs the DN axis even when '
        'the name carries a length axis)', () {
      final fromName = parseSizeTokens('צנרת 300 ס"מ');
      final fromDims = tokensFromDims({'DN': '110'});
      final union = {...fromName, ...fromDims};
      final labels = union.map((t) => t.label).toSet();
      expect(labels, containsAll(['300 ס"מ', 'DN110']));
    });
  });

  group('sortSizeTokens — numeric, not lexical', () {
    test('mm pool sorts by value: 25, 30, 200, 250', () {
      final toks = [
        SizeToken(label: '250 מ"מ', family: SizeFamily.mm, mm: 250),
        SizeToken(label: '25 מ"מ',  family: SizeFamily.mm, mm: 25),
        SizeToken(label: '200 מ"מ', family: SizeFamily.mm, mm: 200),
        SizeToken(label: '30 מ"מ',  family: SizeFamily.mm, mm: 30),
      ];
      sortSizeTokens(toks);
      expect(toks.map((t) => t.label).toList(),
          ['25 מ"מ', '30 מ"מ', '200 מ"מ', '250 מ"מ']);
    });

    test('DN tokens: DN16, DN20, DN32 in order', () {
      final toks = [
        SizeToken(label: 'DN32', family: SizeFamily.dnDiameter, mm: 32),
        SizeToken(label: 'DN16', family: SizeFamily.dnDiameter, mm: 16),
        SizeToken(label: 'DN20', family: SizeFamily.dnDiameter, mm: 20),
      ];
      sortSizeTokens(toks);
      expect(toks.map((t) => t.label).toList(), ['DN16', 'DN20', 'DN32']);
    });

    test('mixed inch + DN — diameter family precedes by precedence, '
        'NOT mixed numerically across families', () {
      final toks = [
        SizeToken(label: 'DN32', family: SizeFamily.dnDiameter, mm: 32),
        SizeToken(label: '½"',   family: SizeFamily.inchDiameter, mm: 12.7),
        SizeToken(label: 'DN16', family: SizeFamily.dnDiameter, mm: 16),
      ];
      sortSizeTokens(toks);
      // The contract is: family-grouped, then numeric inside the family.
      final fams = toks.map((t) => t.family).toList();
      // The first run is one family, the next run is another — never interleaved.
      var i = 1;
      while (i < fams.length && fams[i] == fams[0]) {
        i++;
      }
      expect(fams.skip(i).every((f) => f != fams[0]), isTrue,
          reason: 'families must not interleave after sort');
    });
  });

  group('mixed-family pool — keep all, group coherently', () {
    test('200 מ"מ · 25 ס"מ · 250 מ"מ · 30 ס"מ → mm group first, then cm; '
        'inside each group numeric ascending', () {
      final toks = [
        SizeToken(label: '200 מ"מ', family: SizeFamily.mm, mm: 200),
        SizeToken(label: '25 ס"מ',  family: SizeFamily.cm, mm: 250),
        SizeToken(label: '250 מ"מ', family: SizeFamily.mm, mm: 250),
        SizeToken(label: '30 ס"מ',  family: SizeFamily.cm, mm: 300),
      ];
      sortSizeTokens(toks);
      expect(toks.map((t) => t.label).toList(),
          ['200 מ"מ', '250 מ"מ', '25 ס"מ', '30 ס"מ']);
    });
  });

  group('prettyInch — display-only fold', () {
    test('decimal & two-int inch forms collapse to the fraction glyph', () {
      expect(prettyInch('1.25"'), '1¼"');
      expect(prettyInch('11/4"'), '1¼"');
      expect(prettyInch('1.5"'),  '1½"');
      expect(prettyInch('1/2"'),  '½"');
    });
    test('already-pretty labels pass through', () {
      expect(prettyInch('½"'), '½"');
      expect(prettyInch('1¼"'), '1¼"');
    });
    test('non-inch labels pass through unchanged', () {
      expect(prettyInch('DN40'), 'DN40');
      expect(prettyInch('25 ס"מ'), '25 ס"מ');
      expect(prettyInch('foo'), 'foo');
    });
  });

  group('dominantFamily — pool-level chooser pick', () {
    test('mixed inch + mm: diameter wins for the chooser', () {
      final fam = dominantFamily([
        SizeToken(label: '½"',     family: SizeFamily.inchDiameter, mm: 12.7),
        SizeToken(label: '25 מ"מ', family: SizeFamily.mm, mm: 25),
        SizeToken(label: '50 מ"מ', family: SizeFamily.mm, mm: 50),
      ]);
      expect(fam, SizeFamily.inchDiameter);
    });

    test('only-mm pool returns mm', () {
      final fam = dominantFamily([
        SizeToken(label: '25 מ"מ', family: SizeFamily.mm, mm: 25),
        SizeToken(label: '50 מ"מ', family: SizeFamily.mm, mm: 50),
      ]);
      expect(fam, SizeFamily.mm);
    });

    test('empty list returns null', () {
      expect(dominantFamily(const []), isNull);
    });
  });
}
