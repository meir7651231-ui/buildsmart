import 'package:buildsmart/data/search_index.dart';
import 'package:flutter_test/flutter_test.dart';

/// W0 microcopy guard (2026-06-08): the system-manager persona name is the
/// canonical **'מנהל המערכת'** (with the definite article ה) everywhere —
/// matching `personas.dart`, `sections`, and `chat_seeds`. The bug had bare
/// 'מנהל מערכת' (missing ה) in the RBAC access-list and the role-notification
/// search entries. ('מנהל מערכת' is NOT a substring of 'מנהל המערכת', so the
/// `contains` check distinguishes the two cleanly.)
void main() {
  group('search_index — persona copy is canonical', () {
    test('no SearchEntry title uses the bare "מנהל מערכת" (missing ה)', () {
      final bad = kSearchIndex
          .where((e) => e.title.contains('מנהל מערכת'))
          .map((e) => e.title)
          .toList();
      expect(bad, isEmpty, reason: 'use canonical "מנהל המערכת": $bad');
    });

    test('the canonical "מנהל המערכת" persona entries are present', () {
      expect(
        kSearchIndex.where((e) => e.title.contains('מנהל המערכת')),
        isNotEmpty,
      );
    });
  });
}
