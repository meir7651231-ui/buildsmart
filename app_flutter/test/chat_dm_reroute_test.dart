// #chat-dm-reroute — ratchet for [chatCounterpartRole], the pure core of routing
// a seed role-thread onto a real dm-<uids> thread.
//
// THE BUG (owner field-test): a shared SEED role-thread (`th-contractor-manager`
// = "תמיכה") can hold at most ONE plain contractor — `ensureParticipantUids`
// stamps participantUids ONCE, and a plain contractor (no role claim) can't
// re-stamp it. So when a real client and the manager talk over that seed thread,
// the SECOND party never enters participantUids: he can't read it (his
// array-contains listen skips it) and can't write to it (the rule denies) — "one
// sends & receives, the other neither". The fix reroutes the tap onto the
// deterministic dm thread with BOTH uids; this guards the role-resolution that
// decides WHO the counterpart is (the async directory + create-or-get is covered
// by the dm-thread + firebase tests).
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('chatCounterpartRole — מי הצד-השני של שרשור-הזרע', () {
    test('קבלן↔מנהל (תמיכה) → הצד-השני הוא מנהל', () {
      expect(
        chatCounterpartRole(
            const [BsRole.contractor, BsRole.manager], BsRole.contractor),
        BsRole.manager,
      );
    });

    test('קבלן↔חנות → הצד-השני הוא חנות', () {
      expect(
        chatCounterpartRole(
            const [BsRole.contractor, BsRole.store], BsRole.contractor),
        BsRole.store,
      );
    });

    test('סימטרי: המנהל שקורא רואה את הקבלן כצד-השני', () {
      expect(
        chatCounterpartRole(
            const [BsRole.contractor, BsRole.manager], BsRole.manager),
        BsRole.contractor,
      );
    });

    test('שרשור-בוט (רב-משתתפים) → null (אין ניתוב, נשאר שרשור-הבוט)', () {
      expect(
        chatCounterpartRole(
          const [
            BsRole.contractor,
            BsRole.worker,
            BsRole.courier,
            BsRole.store,
            BsRole.bot,
          ],
          BsRole.contractor,
        ),
        isNull,
      );
    });

    test('שרשור-dm (participants ריק) → null (כבר dm, אין מה לנתב)', () {
      expect(chatCounterpartRole(const [], BsRole.contractor), isNull);
    });

    test('הקורא-בלבד (רק העצמי) → null', () {
      expect(
        chatCounterpartRole(const [BsRole.contractor], BsRole.contractor),
        isNull,
      );
    });
  });
}
