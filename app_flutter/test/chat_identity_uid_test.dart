// #chat-identity (uid-based mine/theirs) — ratchet for [chatMessageIsMine].
//
// THE BUG (owner field-test, filtered line): the chat decided "mine vs theirs"
// from `fromRole == persona`. A MANAGER answering a client from the CONTRACTOR
// board sends `fromRole: contractor`; from the MANAGER board he sends
// `fromRole: manager`. So the SAME person was treated as TWO — and his
// contractor-board line was indistinguishable from the REAL contractor client's
// (both `contractor`), so the filtered client saw the manager's reply rendered
// as the client's OWN message.
//
// THE FIX: when a message carries a real sender uid AND the reader's uid is
// known, "mine" is `fromUid == readerUid` — ONE PERSON on every board. Missing
// uid (seed / legacy / local / signed-out / the whole test suite) falls back to
// the role compare, BYTE-IDENTICAL to before.
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessage _msg({
  required BsRole fromRole,
  String fromUid = '',
  String text = 'שלום',
}) =>
    ChatMessage(
      id: 'm-1-${fromRole.name}',
      threadId: 'dm-a__b',
      fromRole: fromRole,
      text: text,
      ts: DateTime(2026, 8, 12, 10),
      fromUid: fromUid,
    );

void main() {
  group('chatMessageIsMine — זהות לפי אדם, לא לפי לוח', () {
    const managerUid = 'uid-manager';
    const clientUid = 'uid-client';

    test('מנהל קורא: הודעתו-שלו — משני הלוחות — היא "שלי"', () {
      // מנהל שלח מלוח-מנהל (fromRole: manager) — שלי:
      expect(
        chatMessageIsMine(
            _msg(fromRole: BsRole.manager, fromUid: managerUid),
            BsRole.manager,
            managerUid),
        isTrue,
      );
      // אותו מנהל שלח מלוח-קבלן (fromRole: contractor) — עדיין שלי (אותו uid),
      // אף שהתפקיד שונה. זה הליבה של התיקון.
      expect(
        chatMessageIsMine(
            _msg(fromRole: BsRole.contractor, fromUid: managerUid),
            BsRole.manager,
            managerUid),
        isTrue,
      );
    });

    test('לקוח קורא: הודעת-המנהל מלוח-קבלן היא "שלו" (לא שלי) — הבאג המקורי', () {
      // לפני התיקון: fromRole(contractor) == persona(contractor) ⇒ נחשב בטעות
      // כהודעה של הלקוח עצמו. עכשיו: uid המנהל ≠ uid הלקוח ⇒ לא-שלי. ✓
      expect(
        chatMessageIsMine(
            _msg(fromRole: BsRole.contractor, fromUid: managerUid),
            BsRole.contractor,
            clientUid),
        isFalse,
      );
      // והודעת הלקוח-עצמו מלוח-קבלן — שלי:
      expect(
        chatMessageIsMine(
            _msg(fromRole: BsRole.contractor, fromUid: clientUid),
            BsRole.contractor,
            clientUid),
        isTrue,
      );
    });

    test('נפילה-לאחור (zero regression): בלי fromUid ⇒ השוואת-תפקיד הלגאסית', () {
      // seed/legacy/local — אין uid על ההודעה:
      expect(
        chatMessageIsMine(_msg(fromRole: BsRole.contractor), BsRole.contractor,
            clientUid),
        isTrue,
      );
      expect(
        chatMessageIsMine(
            _msg(fromRole: BsRole.manager), BsRole.contractor, clientUid),
        isFalse,
      );
    });

    test('נפילה-לאחור: reader uid לא-ידוע (signed-out/טסטים) ⇒ תפקיד', () {
      // גם אם ההודעה נושאת uid, קורא ללא-זהות נופל להשוואת-תפקיד — כך שכל
      // הסוויטה חסרת-ה-Firebase נשארת זהה-לביט.
      for (final readerUid in <String?>[null, '']) {
        expect(
          chatMessageIsMine(
              _msg(fromRole: BsRole.contractor, fromUid: clientUid),
              BsRole.contractor,
              readerUid),
          isTrue,
        );
        expect(
          chatMessageIsMine(
              _msg(fromRole: BsRole.manager, fromUid: managerUid),
              BsRole.contractor,
              readerUid),
          isFalse,
        );
      }
    });
  });
}
