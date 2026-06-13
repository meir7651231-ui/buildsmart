// V2 — the dead "הגדרות שיחות" (call-settings) tree is HIDDEN.
//
// That whole settings sub-tree described features that DO NOT EXIST (read
// receipts, typing indicator, call ringtone, video compression, cloud backup,
// …) so it was removed from the search index AND from the chat menu (its only
// route into ChatSettingsScreen). These guards fail if any dead title comes
// back — and assert the REAL working chat entry stays present.
//
// Mirrors test/placeholder_hide_test.dart (hidden-department guard) +
// test/search_index_persona_copy_test.dart (kSearchIndex content assertions).

import 'package:buildsmart/data/search_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('search_index — dead call-settings tree is gone', () {
    /// Every title that belonged ONLY to the dead "הגדרות שיחות" tree.
    const deadTitles = [
      'הגדרות שיחות', // the top settings entry
      'דחיסת וידאו', // video compression — never existed
      'צלצול שיחה נכנסת', // incoming-call ringtone — never existed
      'אישורי קריאה', // read receipts (this tree's leaf)
      'חיווי הקלדה', // typing indicator
      'גיבוי לענן', // cloud backup
      'תדירות גיבוי',
      'מי יכול לפתוח שיחה',
    ];

    for (final t in deadTitles) {
      test('no SearchEntry titled "$t"', () {
        expect(
          kSearchIndex.where((e) => e.title == t),
          isEmpty,
          reason: 'dead call-settings title "$t" must not be searchable',
        );
      });
    }

    test('no breadcrumb is rooted under "הגדרות שיחות"', () {
      final leaked = kSearchIndex
          .where((e) => e.breadcrumb.contains('הגדרות שיחות'))
          .map((e) => '${e.title} (${e.breadcrumb})')
          .toList();
      expect(leaked, isEmpty, reason: 'orphan call-settings leaves: $leaked');
    });
  });

  group('search_index — the real chat is KEPT', () {
    test('the working "שיחות" screen entry still exists', () {
      final chat = kSearchIndex.where(
        (e) => e.title == 'שיחות' && e.type == SearchType.screen,
      );
      expect(chat, isNotEmpty);
    });

    test('the kept sibling settings trees are untouched', () {
      // Removing the call tree must NOT take out the neighboring settings.
      for (final t in ['הגדרות חנות', 'הגדרות התראות', 'הגדרות קטלוג']) {
        expect(
          kSearchIndex.where((e) => e.title == t),
          isNotEmpty,
          reason: '"$t" should still be searchable',
        );
      }
    });
  });
}
