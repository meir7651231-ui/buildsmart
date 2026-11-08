import 'package:buildsmart/features/maintenance/mx_hebdate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known dates', () {
    expect(mxHebrewDate(DateTime(2026, 11, 8)), 'כ״ח בחשוון תשפ״ז');
    expect(mxHebrewYmd(DateTime(2026, 9, 12)), (5787, 7, 1)); // ראש השנה
    expect(mxHebrewYmd(DateTime(2025, 9, 23)), (5786, 7, 1));
    expect(mxHebrewYmd(DateTime(2026, 4, 2)), (5786, 1, 15)); // פסח
    expect(mxHebrewYmd(DateTime(2024, 3, 24)), (5784, 13, 14)); // פורים, שנה מעוברת
    expect(mxHebrewDate(DateTime(2025, 12, 15)), 'כ״ה בכסלו תשפ״ו'); // חנוכה
  });
  test('gematria', () {
    expect(mxGematria(15), 'ט״ו');
    expect(mxGematria(16), 'ט״ז');
    expect(mxGematria(1), 'א׳');
    expect(mxGematria(30), 'ל׳');
    expect(mxGematria(5787), 'תשפ״ז');
  });
}
