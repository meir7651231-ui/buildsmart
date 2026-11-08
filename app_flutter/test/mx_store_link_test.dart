// Maintenance module — independent-store connection: WhatsApp message, wa.me
// link, Israeli phone normalization, and store price-list import.

import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_store_link.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 8, 10);

  group('phone normalization', () {
    test('Israeli formats → international digits', () {
      expect(mxIntlPhone('050-123 4567'), '972501234567');
      expect(mxIntlPhone('+972 50 1234567'), '972501234567');
      expect(mxIntlPhone('00972501234567'), '972501234567');
      expect(mxIntlPhone('0501234567'), '972501234567');
      expect(mxIntlPhone('02-6234567'), '97226234567');
    });
    test('garbage → empty', () {
      expect(mxIntlPhone(''), '');
      expect(mxIntlPhone('12345'), '');
      expect(mxIntlPhone('050-12'), '');
    });
  });

  group('WhatsApp order message', () {
    (MxDb, MxPurchaseOrder) approved() {
      final (db, ids) = autoReorder(mxDemoSeed(now), now: now);
      final id = ids.firstWhere((i) => db.po(i).storeId == 'st-tambur');
      final db2 = approvePo(db, id);
      return (db2, db2.po(id));
    }

    test('lists every line, total and the store link', () {
      final (db, o) = approved();
      final msg = mxStoreMessage(
        db,
        o,
        baseUrl: 'https://example.test/',
        orgName: 'הארגון',
      );
      expect(msg, startsWith('שלום טמבור השכונה (דוגמה),'));
      expect(msg, contains('הזמנה ${o.id} מהארגון'));
      for (final l in o.lines) {
        expect(msg, contains('• ${l.qty} × ${db.part(l.sku).name}'));
      }
      expect(msg, contains(mxShekels(o.totalAgorot)));
      expect(msg, endsWith('https://example.test/s/${o.token}'));
    });

    test('wa.me uri carries phone and encoded text', () {
      final (db, o) = approved();
      final uri = mxWhatsAppUri(
        db,
        o,
        baseUrl: 'https://example.test',
        orgName: 'הארגון',
      );
      expect(uri.host, 'wa.me');
      expect(uri.path, '/972500000000');
      expect(
        uri.queryParameters['text'],
        mxStoreMessage(
          db,
          o,
          baseUrl: 'https://example.test',
          orgName: 'הארגון',
        ),
      );
    });

    test('not approved / no phone → honest error', () {
      final (db, ids) = autoReorder(mxDemoSeed(now), now: now);
      final o = db.po(ids.first);
      expect(
        () => mxStoreMessage(db, o, baseUrl: 'x', orgName: 'y'),
        throwsA(isA<MxError>()),
      );
      final (db2, o2) = approved();
      final noPhone = db2.copyWith(
        stores: [
          for (final s in db2.stores)
            s.id == o2.storeId
                ? MxStore(id: s.id, name: s.name, types: s.types, phone: '')
                : s,
        ],
      );
      expect(
        () => mxWhatsAppUri(noPhone, o2, baseUrl: 'x', orgName: 'y'),
        throwsA(isA<MxError>()),
      );
    });
  });

  group('price parsing', () {
    test('formats', () {
      expect(mxParseAgorot('12.50'), 1250);
      expect(mxParseAgorot('12,50'), 1250);
      expect(mxParseAgorot('₪ 1,234.5'), 123450);
      expect(mxParseAgorot('1,234'), 123400);
      expect(mxParseAgorot('18 ש"ח'), 1800);
      expect(mxParseAgorot(''), isNull);
      expect(mxParseAgorot('abc'), isNull);
      expect(mxParseAgorot('-3'), isNull);
    });
  });

  group('price list import', () {
    test(
      'maps by explicit column, by same SKU, and by exact name; reports bad rows',
      () {
        const csv =
            'מק"ט,שם,מחיר,מק"ט שלנו\n'
            'T-100,מנגנון שקע לבן,17.90,EL-SK16\n'
            'EL-T8,נורה,19.9,\n'
            'X-9,מעצור חלון 10 ס"מ,32,\n'
            'Q-1,משהו אחר,10,\n'
            'B-2,פגום,לא מחיר,\n'
            'C-3,לא קיים,5,ZZZ\n';
        final imp = mxParsePriceList(csv, kMxParts);
        expect(
          {for (final r in imp.matched) r.ourSku: r.agorot},
          {'EL-SK16': 1790, 'EL-T8': 1990, 'HW-WSTOP': 3200},
        );
        expect(
          imp.unmatched.map((r) => r.storeSku),
          containsAll(['Q-1', 'C-3']),
        );
        expect(imp.errors.length, 2);
        expect(imp.errors.first, contains('שורה 6'));
        expect(imp.errors.last, contains('ZZZ'));
      },
    );

    test('semicolon separated + English headers', () {
      const csv = 'SKU;Name;Price\nPL-SIF;siphon;33.00\n';
      final imp = mxParsePriceList(csv, kMxParts);
      expect(imp.matched.single.ourSku, 'PL-SIF');
      expect(imp.matched.single.agorot, 3300);
    });

    test('missing price column / empty file → clear error', () {
      expect(mxParsePriceList('מק"ט,שם\nA,B\n', kMxParts).errors, [
        'חסרה עמודת מחיר',
      ]);
      expect(mxParsePriceList('', kMxParts).errors, isNotEmpty);
    });

    test('apply → used by the next order to that store', () {
      final imp = mxParsePriceList('מק"ט,מחיר\nEL-T8,19.90\n', kMxParts);
      final db = mxApplyPrices(mxDemoSeed(now), 'st-tambur', imp);
      expect(db.priceAt('st-tambur', 'EL-T8'), 1990);
      expect(
        db.priceAt('st-tambur', 'EL-SW1'),
        1400,
        reason: 'unlisted → reference',
      );
      expect(() => mxApplyPrices(db, 'nope', imp), throwsA(isA<MxError>()));
    });
  });
}
