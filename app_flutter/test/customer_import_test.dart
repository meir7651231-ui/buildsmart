// GIANT Phase-2 wave-3c — the pure customer bulk-import parser on the shared
// csv_kernel. name required; phone/email validated (wave-2a); deterministic
// dedup-key ids; atomic canCommit gate (mirrors company_catalog_import).

import 'package:buildsmart/data/customer_import.dart';
import 'package:buildsmart/logic/input_validators.dart' show normalizePhone;
import 'package:buildsmart/logic/text_normalize.dart' show normName;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('happy path — rows parse, tags split, canCommit', () {
    final r = parseCustomerCsv(
      'שם הלקוח,טלפון,אימייל,הערות,תגיות\n'
      'ישראל ישראלי,0501234567,a@b.com,קבוע,קמעונאי|VIP\n'
      'דנה כהן,0521112222,,,\n',
    );
    expect(r.errors, isEmpty);
    expect(r.canCommit, isTrue);
    expect(r.valid.length, 2);
    expect(r.valid[0].name, 'ישראל ישראלי');
    expect(r.valid[0].tags, ['קמעונאי', 'VIP']);
    expect(r.valid[1].phone, '0521112222');
    expect(r.valid[1].email, isEmpty, reason: 'optional, absent');
  });

  test('deterministic id = imp: + normName|normalizePhone (no wall clock)', () {
    final r = parseCustomerCsv('שם הלקוח,טלפון\nדנה כהן,050-123-4567\n');
    final c = r.valid.single;
    expect(c.id, 'imp:${normName('דנה כהן')}|${normalizePhone('050-123-4567')}');
    // A re-import yields the SAME id ⇒ upsert replaces, never duplicates.
    final again = parseCustomerCsv('שם הלקוח,טלפון\nדנה כהן,0501234567\n');
    expect(again.valid.single.id, c.id);
  });

  test('missing name COLUMN → single row-1 error, nothing valid', () {
    final r = parseCustomerCsv('טלפון,אימייל\n0501234567,a@b.com\n');
    expect(r.canCommit, isFalse);
    expect(r.valid, isEmpty);
    expect(r.errors.single.row, 1);
    expect(r.errors.single.messageHe, contains('שם הלקוח'));
  });

  test('missing name CELL → per-row error at the physical line', () {
    final r = parseCustomerCsv('שם הלקוח,טלפון\n,0501234567\n');
    expect(r.canCommit, isFalse);
    expect(r.errors.single.row, 2);
    expect(r.errors.single.messageHe, contains('חסר שם'));
  });

  test('invalid phone and invalid email are rejected with the value', () {
    final rp = parseCustomerCsv('שם הלקוח,טלפון\nדנה,12345\n');
    expect(rp.errors.single.messageHe, contains('טלפון לא תקין'));
    final re = parseCustomerCsv('שם הלקוח,אימייל\nדנה,not-an-email\n');
    expect(re.errors.single.messageHe, contains('אימייל לא תקין'));
  });

  test('in-file exact duplicate (same name+phone) is a hard error', () {
    final r = parseCustomerCsv(
      'שם הלקוח,טלפון\n'
      'דנה כהן,0501234567\n'
      'דנה כהן,050-123-4567\n', // same after normalize → duplicate
    );
    expect(r.canCommit, isFalse);
    expect(r.errors.single.messageHe, contains('לקוח כפול'));
  });

  test('atomic — any error ⇒ canCommit false, though valid still accumulates',
      () {
    final r = parseCustomerCsv(
      'שם הלקוח,טלפון\n'
      'תקין,0501234567\n'
      ',0509999999\n', // missing name
    );
    expect(r.canCommit, isFalse, reason: 'one bad row blocks the whole commit');
    expect(r.valid.length, 1, reason: 'the clean row is still tracked');
  });

  test('semicolon file auto-detects', () {
    final r = parseCustomerCsv('שם הלקוח;טלפון\nדנה;0501234567\n');
    expect(r.canCommit, isTrue);
    expect(r.valid.single.phone, '0501234567');
  });

  test('the untouched template parses to zero rows (canCommit false)', () {
    final r = parseCustomerCsv(customerCatalogTemplateCsv());
    expect(r.errors, isEmpty);
    expect(r.valid, isEmpty, reason: 'legend + example rows are all skipped');
    expect(r.canCommit, isFalse);
  });

  test('optional ח״פ (businessId) — valid is stored, invalid is rejected', () {
    final ok = parseCustomerCsv('שם הלקוח,ח.פ\nאלי בניין,512345679\n');
    expect(ok.canCommit, isTrue);
    expect(ok.valid.single.businessId, '512345679');

    final bad = parseCustomerCsv('שם הלקוח,ח.פ\nאלי בניין,512345678\n');
    expect(bad.canCommit, isFalse, reason: 'a bad check-digit blocks the row');
    expect(bad.errors.single.messageHe, contains('ח.פ לא תקין'));
  });

  test('ח״פ absent → businessId is empty (the column is optional)', () {
    final r = parseCustomerCsv('שם הלקוח,טלפון\nדנה,0501234567\n');
    expect(r.valid.single.businessId, isEmpty);
  });
}
