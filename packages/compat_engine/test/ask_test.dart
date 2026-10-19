// The JSON question interface other engines use (bin/ask.dart).
import 'package:test/test.dart';

import '../bin/ask.dart' as ask;

void main() {
  test('query: words, inch / DN / fraction / mm sizes', () {
    final q = ask.parseQuery('סיפון לכיור 1.25" ו-DN50 עם ברז 1/2 וצינור 32 HDPE');
    expect(q.sizes, containsAll(['1.25', '50', '1/2', '32']));
    expect(q.words, containsAll(['סיפון', 'לכיור', 'HDPE']));
    expect(q.words, isNot(contains('עם')));
  });

  test('search: 1/2 does not match 11/2, prefixes are stripped', () {
    final names = ask.search('הסתעפות HDPE הברגה פנימית 1/2', 20).map((p) => p['name'] as String);
    expect(names, isNotEmpty);
    expect(names.where((n) => n.contains('11/2')), isEmpty);
    expect(ask.search('לכיור 1.25"', 5), isNotEmpty);
  });

  test('candidates: one request naming several parts gets each kind', () {
    final skus = ask
        .candidates('צינור HDPE 32 מהמונה לברז ניל 1/2 מתחת לכיור', 3, 15)
        .map((p) => p['sku'])
        .toSet();
    expect(skus, contains('9103201211')); // מצמד HDPE הברגה חיצונית 32×1/2"
    expect(skus.any((s) => '$s'.startsWith('777752')), isTrue); // a ניל tap
  });

  test('check: wrong chain explains why and offers a real bridge', () {
    final r = ask.check(['9103203210', '77775255'], 20);
    final pair = (r['pairs'] as List).single as Map;
    expect(pair['connects'], isFalse);
    expect(pair['reason'], contains('HDPE'));
    expect(pair['bridge'], isNotEmpty);
    expect(r['allConnect'], isFalse);
    expect(r['kit'], isEmpty);
  });

  test('check: connecting chain gets methods and an install kit', () {
    final r = ask.check(['9103203210', '9103201211', '77775255'], 20);
    expect(r['allConnect'], isTrue);
    expect((r['pairs'] as List).map((p) => (p as Map)['method']), everyElement(isNotEmpty));
    expect((r['kit'] as List).map((k) => (k as Map)['label']).join(' '), contains('טפלון'));
  });

  test('each end joins one neighbour: a 2-ended adapter cannot use one end twice', () {
    // ניל F½ + מעבר 8315 (M½ × F¾) + צינור משוריין F½: every pair matches on
    // its own, but the adapter's only ½" end would be used on both sides.
    final r = ask.check(['9103201211', '77775255', '8315', '77121240'], 20);
    final last = (r['pairs'] as List).last as Map;
    expect(last['connects'], isFalse);
    expect(last['endConflict'], isTrue);
    expect(r['allConnect'], isFalse);
  });

  test('a missing part is a real two-ended fitting (no open tee port, no shower arm)', () {
    final r = ask.check(['77775255', '77121240'], 20); // F½ + F½
    final bridge = ((r['pairs'] as List).single as Map)['bridge'] as List;
    expect(bridge.map((p) => (p as Map)['sku']), ['77777641']); // ניפל כפול ½"
    final fixed = ask.check(['77775255', '77777641', '77121240'], 20);
    expect(fixed['allConnect'], isTrue);
  });

  test('wrong HDPE coupling: the bridge is the straight threaded coupling, not a tee', () {
    final r = ask.check(['9103203210', '77775255'], 20);
    final bridge = ((r['pairs'] as List).single as Map)['bridge'] as List;
    expect(bridge.map((p) => (p as Map)['sku']), ['9103201211']);
  });

  test('unknown SKUs are reported, never guessed', () {
    final r = ask.check(['NOPE', '9103201211'], 20);
    expect(r['unknown'], ['NOPE']);
    expect(r['allConnect'], isFalse);
    expect(ask.answer({'op': 'product', 'sku': 'NOPE'}), isNull);
    expect(ask.answer({'op': 'nope'}), {'error': 'unknown op nope'});
  });
}
