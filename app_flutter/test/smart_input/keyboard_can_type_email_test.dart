// GATE FOR WAVE 2 (forms) — can our keyboard actually type what a form needs?
//
// Wave 1 wired search/list/address fields: plain Hebrew text, obviously covered.
// Wave 2 is registration + profile, which means EMAIL and PASSWORD. Those need
// characters no Hebrew letter layer has — `@`, `.`, digits, ASCII letters — and
// the failure mode is severe and silent: `readOnly:true` on a field whose needed
// characters are unreachable is a user who CANNOT REGISTER. That is the exact
// lockout this project spent a day escaping, so it gets proven, not assumed.
//
// These assertions are over the PURE layout data (no widgets, no pumping), so
// they stay fast and they fail loudly the moment a key is dropped from a layer.

import 'package:buildsmart/widgets/smart_input/keyboard/english_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/hebrew_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every character a user can produce from a layer, as a set of labels.
Set<String> _chars(List<List<KbKey>> rows) =>
    rows.expand((r) => r).map((k) => k.label).toSet();

/// The union of all three layers — what the keyboard can type in total, since
/// the layer-switch key reaches each of them from any other.
Set<String> get _all =>
    _chars(kHebrewRows).union(_chars(kEnglishRows)).union(_chars(kSymbolsRows));

void main() {
  group('symbols layer is INDEPENDENT (reachable from English too)', () {
    test('kSymbolsRows is its own layer, not part of the Hebrew letters', () {
      // bs_keyboard renders Hebrew XOR English XOR symbols. If the symbols were
      // nested inside the Hebrew rows, an English-typing user could never reach
      // `@` — which is precisely the email case.
      final hebrew = _chars(kHebrewRows);
      expect(hebrew.contains('@'), isFalse,
          reason: 'symbols must be a separate layer, not Hebrew-only keys');
      expect(_chars(kSymbolsRows).contains('@'), isTrue);
    });
  });

  group('EMAIL is typable', () {
    test('the @ and the dot both exist', () {
      expect(_all.contains('@'), isTrue, reason: 'no @ ⇒ no email ⇒ lockout');
      expect(_all.contains('.'), isTrue, reason: 'no dot ⇒ no domain');
    });

    test('every character of a realistic address is reachable', () {
      const email = 'meir7651231@gmail.com';
      final missing = email
          .split('')
          .where((c) => c != ' ' && !_all.contains(c) && !_all.contains(c.toUpperCase()))
          .toSet();
      expect(missing, isEmpty,
          reason: 'unreachable characters would make this address untypable');
    });

    test('ASCII letters and digits are covered', () {
      for (final c in 'abcdefghijklmnopqrstuvwxyz'.split('')) {
        expect(_all.contains(c) || _all.contains(c.toUpperCase()), isTrue,
            reason: 'latin letter "$c" missing ⇒ half the emails are untypable');
      }
      for (final d in '0123456789'.split('')) {
        expect(_all.contains(d), isTrue, reason: 'digit "$d" missing');
      }
    });
  });

  group('PASSWORD characters', () {
    test('a strong password of the usual shape is typable', () {
      const pwd = 'Test123456';
      final missing = pwd
          .split('')
          .where((c) => !_all.contains(c) && !_all.contains(c.toLowerCase()))
          .toSet();
      expect(missing, isEmpty);
    });

    test('common special characters exist for stronger passwords', () {
      // Not every symbol is required, but a password field is useless if NONE
      // are reachable — assert the set the layout does ship.
      for (final c in ['!', '?', '-', '_', '#', '%', '&', '+']) {
        expect(_all.contains(c), isTrue, reason: 'special "$c" missing');
      }
    });
  });

  group('Israeli phone number', () {
    test('digits and the dash are enough for 050-1234567', () {
      const phone = '050-1234567';
      final missing =
          phone.split('').where((c) => !_all.contains(c)).toSet();
      expect(missing, isEmpty);
    });
  });
}
