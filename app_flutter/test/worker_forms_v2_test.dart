// Guard tests for cluster #85ח · forms v2 (#106/#107) — the NEW declaration +
// signature + employer-autofill fields added to Form101 / SickNote / and the
// VacationRequest model. Two contracts per model:
//   1. round-trip — the new fields survive toJson → tryFromJson byte-for-byte,
//   2. back-compat — an OLD persisted payload missing the new keys decodes to
//      the defaults ('' / false), so existing callers + stored JSON keep
//      working (the GLOBAL "every new field is optional" rule of _wave3).
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Form101 (#106) — signature + declaration + employer autofill ──────────
  group('Form101 v2 fields', () {
    test('round-trip — signature/declared/employer* survive toJson→tryFromJson',
        () {
      final f = Form101(
        username: 'ran',
        year: 2026,
        fullName: 'רן ישראלי',
        idNumber: '123456782',
        phone: '0501234567',
        specialty: 'אינסטלציה',
        maritalStatus: 'נשוי/אה',
        savedTs: DateTime(2026, 6, 14, 10, 30),
        sentTs: DateTime(2026, 6, 14, 11),
        signature: 'data:image/png;base64,AAA=',
        declared: true,
        employerName: 'בנייה חכמה בע״מ',
        employerBusinessId: '514999888',
        employerAddress: 'הרצל 1, תל אביב',
      );

      final back = Form101.tryFromJson(f.toJson());
      expect(back, isNotNull);
      expect(back!.signature, 'data:image/png;base64,AAA=');
      expect(back.declared, true);
      expect(back.employerName, 'בנייה חכמה בע״מ');
      expect(back.employerBusinessId, '514999888');
      expect(back.employerAddress, 'הרצל 1, תל אביב');
      // the original fields are untouched by the additive change
      expect(back.username, 'ran');
      expect(back.year, 2026);
      expect(back.fullName, 'רן ישראלי');
      expect(back.maritalStatus, 'נשוי/אה');
      expect(back.sentTs, DateTime(2026, 6, 14, 11));
    });

    test('OLD payload missing v2 keys → defaults (back-compat)', () {
      // A pre-v2 record — handcrafted WITHOUT the new keys (NOT via toJson(),
      // which now always writes them).
      final back = Form101.tryFromJson({
        'username': 'omer',
        'year': 2025,
        'fullName': 'עומר',
        'idNumber': '111111118',
        'phone': '0502222222',
        'specialty': 'חשמל',
        'maritalStatus': 'רווק/ה',
        'savedTs': DateTime(2025, 1, 1).toIso8601String(),
      });
      expect(back, isNotNull);
      expect(back!.signature, '', reason: 'missing signature → empty');
      expect(back.declared, false, reason: 'missing declared → false');
      expect(back.employerName, '');
      expect(back.employerBusinessId, '');
      expect(back.employerAddress, '');
      // unchanged legacy decode still works
      expect(back.fullName, 'עומר');
      expect(back.sentTs, isNull, reason: 'no sentTs key → not sent');
    });

    test('copyWith widened — sets new fields AND still serves markForm101Sent',
        () {
      final base = Form101(
        username: 'ran',
        year: 2026,
        fullName: 'רן',
        idNumber: '123456782',
        phone: '050',
        specialty: 'x',
        maritalStatus: 'רווק/ה',
        savedTs: DateTime(2026, 1, 1),
      );

      // markForm101Sent relies on copyWith(sentTs:) — must still compile/work.
      final sent = base.copyWith(sentTs: DateTime(2026, 6, 14));
      expect(sent.sentTs, DateTime(2026, 6, 14));
      expect(sent.signature, '', reason: 'untouched fields keep their value');

      // the widened copyWith can set the new fields too
      final signed = base.copyWith(
        signature: 'data:image/png;base64,BBB=',
        declared: true,
        employerName: 'מעסיק',
      );
      expect(signed.signature, 'data:image/png;base64,BBB=');
      expect(signed.declared, true);
      expect(signed.employerName, 'מעסיק');
      expect(signed.year, 2026, reason: 'identity fields preserved');
    });
  });

  // ── SickNote (#107) — declaration + optional signature ────────────────────
  group('SickNote v2 fields', () {
    test('round-trip — signature/declared survive toJson→tryFromJson', () {
      final s = SickNote(
        id: 'sick-1',
        username: 'ran',
        ts: DateTime(2026, 6, 14, 9),
        photo: 'data:image/png;base64,PHOTO=',
        signature: 'data:image/png;base64,SIG=',
        declared: true,
      );
      final back = SickNote.tryFromJson(s.toJson());
      expect(back, isNotNull);
      expect(back!.signature, 'data:image/png;base64,SIG=');
      expect(back.declared, true);
      expect(back.photo, 'data:image/png;base64,PHOTO=');
      expect(back.id, 'sick-1');
    });

    test('OLD payload missing v2 keys → defaults (back-compat)', () {
      final back = SickNote.tryFromJson({
        'id': 'sick-old',
        'username': 'omer',
        'ts': DateTime(2025, 5, 1).toIso8601String(),
        'photo': 'data:image/png;base64,OLD=',
      });
      expect(back, isNotNull);
      expect(back!.signature, '');
      expect(back.declared, false);
      expect(back.photo, 'data:image/png;base64,OLD=');
    });
  });

  // ── VacationRequest (#107) — declaration + signature ──────────────────────
  group('VacationRequest v2 fields', () {
    test('round-trip — signature/declared survive toJson→tryFromJson', () {
      final v = VacationRequest(
        id: 'vac-1',
        username: 'ran',
        workerName: 'רן',
        from: DateTime(2026, 6, 12),
        to: DateTime(2026, 6, 14),
        reason: 'חתונה',
        createdTs: DateTime(2026, 6, 1),
        signature: 'data:image/png;base64,VSIG=',
        declared: true,
      );
      final back = VacationRequest.tryFromJson(v.toJson());
      expect(back, isNotNull);
      expect(back!.signature, 'data:image/png;base64,VSIG=');
      expect(back.declared, true);
      // existing fields/back-compat behavior intact
      expect(back.role, 'worker');
      expect(back.status, kVacationPending);
      expect(back.range, '12.6.2026–14.6.2026');
    });

    test('OLD payload missing v2 keys → defaults (back-compat)', () {
      final back = VacationRequest.tryFromJson({
        'id': 'vac-old',
        'username': 'omer',
        'workerName': 'עומר',
        'from': DateTime(2025, 2, 1).toIso8601String(),
        'to': DateTime(2025, 2, 2).toIso8601String(),
        'reason': 'ישן',
        'createdTs': DateTime(2025, 1, 20).toIso8601String(),
        'status': kVacationPending,
      });
      expect(back, isNotNull);
      expect(back!.signature, '');
      expect(back.declared, false);
      expect(back.role, 'worker', reason: 'legacy role default still holds');
    });

    test('copyWith carries signature/declared', () {
      final base = VacationRequest(
        id: 'vac-2',
        username: 'ran',
        workerName: 'רן',
        from: DateTime(2026, 7, 1),
        to: DateTime(2026, 7, 1),
        reason: '',
        createdTs: DateTime(2026, 6, 1),
      );
      final signed = base.copyWith(signature: 'data:image/png;base64,Z=', declared: true);
      expect(signed.signature, 'data:image/png;base64,Z=');
      expect(signed.declared, true);
      expect(signed.status, kVacationPending, reason: 'other fields preserved');
      // copyWith(status:) still works for the manager decision path
      final approved = base.copyWith(status: kVacationApproved, decidedTs: DateTime(2026, 6, 2));
      expect(approved.status, kVacationApproved);
      expect(approved.declared, false, reason: 'untouched field stays default');
    });
  });
}
