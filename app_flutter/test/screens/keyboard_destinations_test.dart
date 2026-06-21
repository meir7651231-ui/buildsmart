// keyboard_destinations — the universal destination registry + its PURE matcher.
//
// These tests cover ONLY the pure surface ([matchDestinations] +
// [kbDestinations] shape) — no widgets, no providers. The `run` actions are
// exercised through the floating keyboard's widget test (a destination chip tap
// navigates) rather than here, because they need a live Navigator/ProviderScope.
//
// SharedPreferences.setMockInitialValues({}) is set in setUp per the swarm
// convention, even though the pure matcher does not read prefs — it keeps these
// safe if a future assertion touches a provider-backed helper.

import 'package:buildsmart/screens/keyboard_destinations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('kbDestinations — registry shape', () {
    test('is non-empty and every entry is well-formed', () {
      final all = kbDestinations();
      expect(all, isNotEmpty, reason: 'the registry lists real destinations');
      for (final d in all) {
        expect(d.label.trim(), isNotEmpty, reason: 'every label is non-blank');
        expect(d.keywords, isNotEmpty,
            reason: '"${d.label}" must carry search keywords');
        for (final k in d.keywords) {
          expect(k.trim(), isNotEmpty,
              reason: '"${d.label}" has a blank keyword');
        }
      }
    });

    test('covers the headline destinations the owner asked for', () {
      final labels = {for (final d in kbDestinations()) d.label};
      // 4 tabs, departments, catalog sections, store sections, global actions,
      // settings/AI, the new no-arg screens/sheets, and the 5 boards — a
      // representative slice (exact labels).
      const required = <String>[
        // tabs
        'בית', 'מחלקות', 'עדכונים', 'חנות',
        // the 4 LIVE departments (per-department destinations)
        'אינסטלציה', 'ברזים וסניטריים', 'כלי עבודה ידני', 'כלי עבודה חשמלי',
        // updates sub-tabs
        'התראות', 'שיחות',
        // store sections
        'הסל שלי', 'ההזמנות שלי',
        // catalog sections
        'מאתר', 'עץ חכם', 'מועדפים', 'קטגוריות', 'וריאנטים',
        'תכנון חיבור', 'חיפושים אחרונים',
        // global actions
        'מצלמה', 'מצב היכרות', 'פרופיל', 'בורר תפקידים',
        // pushed screens / no-arg sheets & hubs
        'הגדרות', 'בינה', 'מלאי', 'משימות',
        'סידור מסך הבית', 'מועדון BuildSmart', 'פרויקטים', 'פרויקט חכם',
        'תקציב', 'כספים', 'אודיט', 'חלופות זולות', 'השוואת מחירים',
        'סריקת תוכנית', 'תנאי שימוש', 'מדיניות פרטיות',
        // the 5 boards
        'קבלן', 'מנהל', 'חנות ספק', 'שליח', 'עובד',
      ];
      for (final r in required) {
        expect(labels.contains(r), isTrue,
            reason: 'registry must include the "$r" destination');
      }
    });

    test('every label is UNIQUE (no two destinations share a label)', () {
      final labels = [for (final d in kbDestinations()) d.label];
      expect(labels.toSet().length, labels.length,
          reason: 'duplicate labels would make a typed term ambiguous');
    });
  });

  group('matchDestinations — pure matcher', () {
    test('empty / blank query → empty list', () {
      expect(matchDestinations(''), isEmpty,
          reason: 'an empty query surfaces NO destinations (product words only)');
      expect(matchDestinations('   '), isEmpty,
          reason: 'a blank (whitespace) query is treated as empty');
    });

    test('"הגדרות" returns the settings destination', () {
      final hits = matchDestinations('הגדרות');
      expect(hits, isNotEmpty);
      expect(hits.map((d) => d.label), contains('הגדרות'),
          reason: 'typing הגדרות must surface Settings');
    });

    test('"מחלקות" returns the departments destination', () {
      final hits = matchDestinations('מחלקות');
      expect(hits.map((d) => d.label), contains('מחלקות'),
          reason: 'typing מחלקות must surface Departments');
    });

    test('each LIVE department name surfaces its own department destination', () {
      // The 4 live departments (departments_screen.dart:105-110): typing the
      // exact name must land on that single department's destination.
      const depts = <String>[
        'אינסטלציה',
        'ברזים וסניטריים',
        'כלי עבודה ידני',
        'כלי עבודה חשמלי',
      ];
      for (final name in depts) {
        final hits = matchDestinations(name);
        expect(hits.map((d) => d.label), contains(name),
            reason: 'typing "$name" must surface its department destination');
      }
    });

    test('a department SYNONYM keyword resolves to its department', () {
      // 'אסלות' is a ברזים-וסניטריים keyword; 'ריתוך' a כלי-עבודה-חשמלי keyword;
      // 'צנרת' an אינסטלציה keyword — none is the label, so this proves the
      // department keywords (not just labels) are matched.
      expect(matchDestinations('אסלות').map((d) => d.label),
          contains('ברזים וסניטריים'),
          reason: 'אסלות → ברזים וסניטריים');
      expect(matchDestinations('ריתוך').map((d) => d.label),
          contains('כלי עבודה חשמלי'),
          reason: 'ריתוך → כלי עבודה חשמלי');
      expect(matchDestinations('צנרת').map((d) => d.label),
          contains('אינסטלציה'),
          reason: 'צנרת → אינסטלציה');
    });

    test('new no-arg screens/sheets are reachable by typing', () {
      // Each newly-wired standalone destination must surface on a representative
      // term (label or a distinctive keyword).
      expect(matchDestinations('תקציב').map((d) => d.label), contains('תקציב'),
          reason: 'תקציב → Budget');
      expect(matchDestinations('פרויקטים').map((d) => d.label),
          contains('פרויקטים'),
          reason: 'פרויקטים → Projects');
      expect(matchDestinations('מועדון').map((d) => d.label),
          contains('מועדון BuildSmart'),
          reason: 'מועדון → Rewards hub');
      expect(matchDestinations('אודיט').map((d) => d.label), contains('אודיט'),
          reason: 'אודיט → Audit screen');
      expect(matchDestinations('פרטיות').map((d) => d.label),
          contains('מדיניות פרטיות'),
          reason: 'פרטיות → Privacy policy (LegalTab.privacy)');
      expect(matchDestinations('תנאי שימוש').map((d) => d.label),
          contains('תנאי שימוש'),
          reason: 'תנאי שימוש → Terms (LegalTab.terms)');
      // 'terms' and 'privacy' resolve to DISTINCT legal destinations.
      expect(matchDestinations('terms').map((d) => d.label),
          contains('תנאי שימוש'));
      expect(matchDestinations('privacy').map((d) => d.label),
          contains('מדיניות פרטיות'));
    });

    test('a board term ("מנהל") returns its board destination', () {
      final hits = matchDestinations('מנהל');
      expect(hits.map((d) => d.label), contains('מנהל'),
          reason: 'typing מנהל must surface the Manager board');
    });

    test('another board term ("שליח") returns the courier board', () {
      final hits = matchDestinations('שליח');
      expect(hits.map((d) => d.label), contains('שליח'),
          reason: 'typing שליח must surface the Courier board');
    });

    test('matches a SYNONYM keyword, not only the label ("עגלה" → סל)', () {
      final hits = matchDestinations('עגלה');
      expect(hits.map((d) => d.label), contains('הסל שלי'),
          reason: 'a keyword synonym (עגלה) resolves to the cart destination');
    });

    test('matches an English keyword ("settings" → הגדרות)', () {
      final hits = matchDestinations('settings');
      expect(hits.map((d) => d.label), contains('הגדרות'),
          reason: 'English keyword resolves to the Hebrew-labelled destination');
    });

    test('is case-insensitive ("STORE" → חנות)', () {
      final lower = matchDestinations('store').map((d) => d.label).toSet();
      final upper = matchDestinations('STORE').map((d) => d.label).toSet();
      expect(upper, equals(lower),
          reason: 'matching ignores case for ASCII keywords');
      expect(lower, contains('חנות'));
    });

    test('a prefix matches ("הזמ" → orders-ish destinations)', () {
      final hits = matchDestinations('הזמ');
      expect(hits, isNotEmpty,
          reason: 'a Hebrew prefix matches its keywords/labels');
      // 'ההזמנות שלי' carries the keyword 'הזמנות' (prefix 'הזמ' hits it).
      expect(hits.map((d) => d.label), contains('ההזמנות שלי'));
    });

    test('respects the cap (max)', () {
      // A very common substring that hits many destinations' keywords.
      final capped = matchDestinations('ה', max: 3);
      expect(capped.length, lessThanOrEqualTo(3),
          reason: 'never returns more than max');
      final capped1 = matchDestinations('ה', max: 1);
      expect(capped1.length, lessThanOrEqualTo(1));
    });

    test('de-duplicates: each destination appears at most once', () {
      // 'אינסטלציה' is a keyword on BOTH מחלקות and תכנון חיבור; whatever matches,
      // no single destination may repeat in the result.
      final hits = matchDestinations('אינסטלציה');
      final labels = hits.map((d) => d.label).toList();
      expect(labels.toSet().length, labels.length,
          reason: 'no destination is listed twice');
    });

    test('a non-matching query → empty list', () {
      final hits = matchDestinations('zzzqqq-nothing-here');
      expect(hits, isEmpty,
          reason: 'a query that matches nothing surfaces no destinations');
    });

    test('is deterministic: same query ⇒ identical labels', () {
      final a = matchDestinations('מ').map((d) => d.label).toList();
      final b = matchDestinations('מ').map((d) => d.label).toList();
      expect(a, equals(b), reason: 'pure: identical input ⇒ identical output');
    });
  });
}
