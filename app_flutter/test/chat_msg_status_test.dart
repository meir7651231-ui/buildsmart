// #chat-delivery-status — model coverage for the HONEST per-message delivery
// status on [ChatMessage]. The check-mark a message renders is now driven
// STRUCTURALLY by [MsgStatus] (where the message came from), replacing the
// cosmetic `readReceipts` ✓✓ toggle. This pins the model contract the whole
// honest flow rests on:
//   • the DEFAULT status is `sent` and is OMITTED from toJson — so the seed +
//     every legacy doc stays byte-identical (zero-regression, the same rule
//     `fromUid` follows);
//   • a non-default status (pending/delivered/failed) round-trips via its name;
//   • an OLD json with NO `status` reads back `sent` (tolerant decode, mirroring
//     the `LineStatus` idiom in persona_fulfillment.dart);
//   • copyWith(status:) changes ONLY the status, leaving every other field.
//
// The honest INVARIANT itself (✓✓ only via the server `fromDoc`) is pinned in
// chat_firebase_repo_test.dart; this file pins the model the invariant uses.

import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessage _msg({MsgStatus status = MsgStatus.sent}) => ChatMessage(
      id: 'm-1',
      threadId: 'th-contractor-store',
      fromRole: BsRole.contractor,
      text: 'שלום',
      ts: DateTime(2026, 6, 16, 9),
      status: status,
    );

void main() {
  group('toJson — default sent is OMITTED (byte-identical seed)', () {
    test('a default(sent) message has NO status key in toJson', () {
      final json = _msg().toJson();
      expect(json.containsKey('status'), isFalse);
      // The rest of the payload is exactly the pre-status shape.
      expect(json.keys.toSet(), {'id', 'threadId', 'fromRole', 'text', 'ts'});
    });

    test('the default constructor value IS sent (back-compat)', () {
      expect(
        ChatMessage(
          id: 'm-x',
          threadId: 't',
          fromRole: BsRole.store,
          text: 'x',
          ts: DateTime(2026),
        ).status,
        MsgStatus.sent,
      );
    });
  });

  group('toJson/tryFromJson — non-default status round-trips via name', () {
    for (final s in [MsgStatus.pending, MsgStatus.delivered, MsgStatus.failed]) {
      test('$s is written and read back losslessly', () {
        final json = _msg(status: s).toJson();
        expect(json['status'], s.name);
        final back = ChatMessage.tryFromJson(json);
        expect(back, isNotNull);
        expect(back!.status, s);
      });
    }
  });

  group('tryFromJson — tolerant read (zero regression)', () {
    test('OLD json with no status reads back sent', () {
      final back = ChatMessage.tryFromJson({
        'id': 'm-legacy',
        'threadId': 'th-contractor-store',
        'fromRole': 'store',
        'text': 'מהעבר',
        'ts': '2026-06-10T09:00:00.000',
      });
      expect(back, isNotNull);
      expect(back!.status, MsgStatus.sent);
    });

    test('an unknown status string falls back to sent', () {
      final back = ChatMessage.tryFromJson({
        ..._msg().toJson(),
        'status': 'bananas',
      });
      expect(back!.status, MsgStatus.sent);
    });
  });

  group('copyWith', () {
    test('copyWith(status:) changes ONLY the status', () {
      final base = _msg();
      final next = base.copyWith(status: MsgStatus.delivered);
      expect(next.status, MsgStatus.delivered);
      // every other field is preserved
      expect(next.id, base.id);
      expect(next.threadId, base.threadId);
      expect(next.fromRole, base.fromRole);
      expect(next.text, base.text);
      expect(next.ts, base.ts);
      expect(next.fromUid, base.fromUid);
    });

    test('copyWith() with no args is an exact copy', () {
      final base = _msg(status: MsgStatus.failed);
      final clone = base.copyWith();
      expect(clone.status, base.status);
      expect(clone.id, base.id);
      expect(clone.text, base.text);
    });
  });
}
