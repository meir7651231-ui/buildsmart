// GIANT Phase-2 wave-2b — the saved customer entity + dedup-on-input. The pure
// upsert/lookup contract (the CRM core) plus the persist round-trip + tolerant
// decode (the orders_engine discipline). AUGMENT-only: nothing here touches the
// derived managerCustomersProvider.

import 'package:buildsmart/state/customers_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('pure dedup (upsertCustomer)', () {
    test('a fresh customer appends', () {
      final out = upsertCustomer(const [], const SavedCustomer(id: '1', name: 'כהן'));
      expect(out, hasLength(1));
      expect(out.single.name, 'כהן');
    });

    test('same name+phone (folded) → EDIT in place, keeps id and position', () {
      const list = [
        SavedCustomer(id: 'a', name: 'שמעון', phone: '050-1234567'),
        SavedCustomer(id: 'b', name: 'לוי'),
      ];
      // different id, same folded name+phone ('שימעון'? no — same name, phone
      // written internationally): dedup hit → edits 'a', keeps id 'a' + slot 0.
      final out = upsertCustomer(
          list, const SavedCustomer(id: 'zzz', name: 'שמעון', phone: '+972501234567', notes: 'VIP'));
      expect(out, hasLength(2), reason: 'no duplicate created');
      expect(out.first.id, 'a', reason: 'existing id kept');
      expect(out.first.notes, 'VIP', reason: 'the edit landed');
      expect(out[1].name, 'לוי', reason: 'others untouched');
    });

    test('final-letter / whitespace fold makes names equal for dedup', () {
      const list = [SavedCustomer(id: '1', name: 'בן דוד')];
      final out =
          upsertCustomer(list, const SavedCustomer(id: '2', name: 'בןדוד'));
      expect(out, hasLength(1), reason: "'בן דוד' ≡ 'בןדוד'");
      expect(out.single.id, '1');
    });

    test('same id → replace even if name changed', () {
      const list = [SavedCustomer(id: '1', name: 'כהן')];
      final out =
          upsertCustomer(list, const SavedCustomer(id: '1', name: 'כהן-לוי'));
      expect(out, hasLength(1));
      expect(out.single.name, 'כהן-לוי');
    });
  });

  group('customerForName (order→customer by-name join)', () {
    test('matches on normalized name; null when none', () {
      const list = [SavedCustomer(id: '1', name: 'משפחת כהן', phone: '0501112222')];
      expect(customerForName(list, 'משפחת כהן')?.id, '1');
      expect(customerForName(list, 'משפחת כהנ')?.id, '1', reason: 'ן↔נ fold');
      expect(customerForName(list, 'לוי'), isNull);
    });
  });

  group('codec tolerance', () {
    test('a row without id/name is dropped; siblings survive', () {
      expect(SavedCustomer.tryFromJson({'name': 'no-id'}), isNull);
      expect(SavedCustomer.tryFromJson({'id': 'x'}), isNull);
      final ok = SavedCustomer.tryFromJson(
          {'id': '1', 'name': 'כהן', 'tags': ['זהב', 42, 'קבוע']});
      expect(ok!.tags, ['זהב', 'קבוע'], reason: 'non-string tag skipped');
    });

    test('empty fields are omitted from json (compact)', () {
      const c = SavedCustomer(id: '1', name: 'כהן');
      expect(c.toJson().containsKey('phone'), isFalse);
      expect(c.toJson()['name'], 'כהן');
    });
  });

  group('store persist', () {
    test('upsert round-trips through prefs; remove drops', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final store = c.read(savedCustomersProvider.notifier)
        ..upsert(const SavedCustomer(id: '1', name: 'כהן', phone: '0501234567'))
        ..upsert(const SavedCustomer(id: '2', name: 'לוי'));
      expect(c.read(savedCustomersProvider), hasLength(2));
      // persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kSavedCustomersKey), contains('כהן'));
      store.remove('1');
      expect(c.read(savedCustomersProvider).map((x) => x.id), ['2']);
    });

    test('hydrate from prefs decodes saved rows, drops corrupt ones', () async {
      SharedPreferences.setMockInitialValues({
        kSavedCustomersKey:
            '[{"id":"1","name":"כהן","tags":["זהב"]},{"bad":true},"nope"]',
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      // first read triggers the async load; settle it
      c.read(savedCustomersProvider);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final list = c.read(savedCustomersProvider);
      expect(list, hasLength(1));
      expect(list.single.name, 'כהן');
      expect(list.single.tags, ['זהב']);
    });
  });
}
