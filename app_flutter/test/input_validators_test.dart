// Guard tests for task #64 · client-side FORMAT validators
// (lib/logic/input_validators.dart) — pure, dependency-free functions, so
// these are plain unit tests: valid/invalid Israeli mobile, email shape,
// 9-digit business id, strictly-positive amount, end-after-start date range.
import 'package:buildsmart/logic/input_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ─── validIsraeliMobile ────────────────────────────────────────────────────
  test('mobile — 0501234567 is valid', () {
    expect(validIsraeliMobile('0501234567'), true);
  });

  test('mobile — dashes/spaces are stripped before the check', () {
    expect(validIsraeliMobile('050-123 4567'), true);
  });

  test('mobile — letters are invalid', () {
    expect(validIsraeliMobile('abc'), false);
  });

  test('mobile — 9 digits (too short) is invalid', () {
    expect(validIsraeliMobile('050123456'), false);
  });

  test('mobile — 11 digits (too long) is invalid', () {
    expect(validIsraeliMobile('05012345678'), false);
  });

  test('mobile — must start with 05 (landline prefix rejected)', () {
    expect(validIsraeliMobile('0312345678'), false);
  });

  test('mobile — empty input is invalid', () {
    expect(validIsraeliMobile(''), false);
  });

  // ─── validEmail ────────────────────────────────────────────────────────────
  test('email — simple x@y.z shape is valid', () {
    expect(validEmail('kablan@example.co.il'), true);
  });

  test('email — surrounding whitespace is trimmed', () {
    expect(validEmail('  user@site.com  '), true);
  });

  test('email — missing @ is invalid', () {
    expect(validEmail('user.site.com'), false);
  });

  test('email — missing dot in domain is invalid', () {
    expect(validEmail('user@site'), false);
  });

  test('email — inner whitespace is invalid', () {
    expect(validEmail('us er@site.com'), false);
  });

  test('email — two @ signs is invalid', () {
    expect(validEmail('user@@site.com'), false);
  });

  test('email — empty input is invalid', () {
    expect(validEmail(''), false);
  });

  // ─── waMeDigits (📞/💬 WhatsApp normalization) ─────────────────────────────
  test('waMe — Israeli local 0501234567 → 972501234567', () {
    expect(waMeDigits('0501234567'), '972501234567');
  });

  test('waMe — separators (dashes/spaces/parens) are stripped first', () {
    expect(waMeDigits('050-123 4567'), '972501234567');
    expect(waMeDigits('(052) 765-4321'), '972527654321');
  });

  test('waMe — already +972 keeps its digits (no extra 972)', () {
    expect(waMeDigits('+972 50 123 4567'), '972501234567');
  });

  test('waMe — bare 972… (no leading 0) is left untouched', () {
    expect(waMeDigits('972501234567'), '972501234567');
  });

  test('waMe — 00-prefixed international drops the 00', () {
    expect(waMeDigits('00972501234567'), '972501234567');
  });

  test('waMe — empty / no-digit input returns empty (button hidden)', () {
    expect(waMeDigits(''), '');
    expect(waMeDigits('   '), '');
    expect(waMeDigits('---'), '');
  });

  test('waMe — does NOT double-prefix an Israeli number to 972972…', () {
    // The 0→972 conversion must replace the trunk 0, not prepend to it.
    expect(waMeDigits('0501234567').startsWith('972972'), isFalse);
    expect(waMeDigits('0501234567'), '972501234567');
  });

  // ─── validBusinessId (9 digits + Israeli 1-2-1-2 check digit) ───────────────
  // 512345679 is check-VALID (weighted sum 40 ≡ 0 mod 10); 512345678 is
  // check-INVALID (sum 39) — the exact case the pre-fix validator wrongly let
  // through.
  test('business id — a check-VALID 9-digit id passes', () {
    expect(validBusinessId('512345679'), true);
  });

  test('business id — dashes/spaces are stripped before the check', () {
    expect(validBusinessId('51-234 5679'), true);
  });

  test('business id — a wrong CHECK DIGIT is rejected (the Phase-2 fix)', () {
    expect(validBusinessId('512345678'), false,
        reason: 'weighted sum 39 — was wrongly accepted before the fix');
    expect(validBusinessId('123456789'), false, reason: 'sum 47');
  });

  test('business id — 8 digits is invalid', () {
    expect(validBusinessId('51234567'), false);
  });

  test('business id — 10 digits is invalid', () {
    expect(validBusinessId('5123456789'), false);
  });

  test('business id — letters are invalid', () {
    expect(validBusinessId('51234567a'), false);
  });

  // ─── normalizePhone (canonical local 0… form for CRM dedup) ────────────────
  test('phone normalize — strips separators, keeps local 05…', () {
    expect(normalizePhone('050-123 4567'), '0501234567');
    expect(normalizePhone('(050) 123-4567'), '0501234567');
  });

  test('phone normalize — international 972/+972/00972 → local 0…', () {
    expect(normalizePhone('+972-50-123-4567'), '0501234567');
    expect(normalizePhone('972501234567'), '0501234567');
    expect(normalizePhone('00972501234567'), '0501234567');
  });

  test('phone normalize — empty when no digits', () {
    expect(normalizePhone('  -- '), '');
  });

  // ─── validPositiveAmount ───────────────────────────────────────────────────
  test('amount — positive int/double are valid', () {
    expect(validPositiveAmount(500), true);
    expect(validPositiveAmount(0.5), true);
  });

  test('amount — -500 is rejected', () {
    expect(validPositiveAmount(-500), false);
  });

  test('amount — 0 is rejected (strictly greater than 0)', () {
    expect(validPositiveAmount(0), false);
  });

  test('amount — null (failed tryParse) is rejected', () {
    expect(validPositiveAmount(null), false);
  });

  test('amount — non-finite values are rejected', () {
    expect(validPositiveAmount(double.infinity), false);
    expect(validPositiveAmount(double.nan), false);
  });

  // ─── validDateRange ────────────────────────────────────────────────────────
  test('date range — end strictly after start is valid', () {
    expect(
      validDateRange(DateTime(2026, 6, 1), DateTime(2026, 6, 10)),
      true,
    );
  });

  test('date range — end equal to start is invalid', () {
    final d = DateTime(2026, 6, 10);
    expect(validDateRange(d, d), false);
  });

  test('date range — end before start is invalid', () {
    expect(
      validDateRange(DateTime(2026, 6, 10), DateTime(2026, 6, 1)),
      false,
    );
  });
}
