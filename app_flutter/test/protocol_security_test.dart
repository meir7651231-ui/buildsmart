// אבטחת פרוטוקול — bypass-tokens לעולם לא ניתנים ל-commit.
// נמצא באודיט 2026-06-01: .emergency_token לא היה ב-.gitignore (לקח #31).
// ה-hook קורא ממנו token לעקיפת כל הפרוטוקול; אם ייווצר ולא-ignored → committable.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('protocol security — bypass tokens never committable', () {
    final gitignore = File('../.gitignore');

    test('.gitignore קיים', () {
      expect(gitignore.existsSync(), isTrue,
          reason: 'שורש הריפו חייב .gitignore');
    });

    final ignored = gitignore.existsSync()
        ? gitignore.readAsLinesSync().map((l) => l.trim()).toSet()
        : <String>{};

    // כל token שה-hook מסוגל לקרוא ממנו חייב להיות ב-.gitignore.
    for (final token in const [
      '.emergency_token',
      '.allow_protocol_edit',
    ]) {
      test('$token ב-.gitignore', () {
        expect(ignored.contains(token), isTrue,
            reason: '$token חייב ב-.gitignore — אחרת ה-bypass token ניתן ל-commit (לקח #31)');
      });
    }

    test('שער 53 ב-hook חוסם staging של bypass-tokens', () {
      final hook = File('../.githooks/pre-commit');
      expect(hook.existsSync(), isTrue);
      final body = hook.readAsStringSync();
      // ההגנה השנייה (defense-in-depth) נגד git add -f.
      expect(body.contains('emergency_token'), isTrue,
          reason: 'שער 53 חייב להזכיר emergency_token כדי לחסום staging');
      expect(
          RegExp(r'STAGED_TOKEN').hasMatch(body), isTrue,
          reason: 'שער 53 חייב בדיקת STAGED_TOKEN שחוסמת bypass-tokens ב-staging');
    });
  });
}
