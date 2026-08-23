import 'package:buildsmart/screens/chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the 2026-06-08 chat-bubble RTL inversion (W1 #1).
///
/// SPEC §1 כיווניות (`sys_chat.dart`): the reading persona's OWN messages render
/// on the **start** edge (physical right in RTL), others on the **end** (left).
/// The bug used absolute `Alignment.centerLeft/centerRight`, which do NOT flip
/// for RTL, so own messages landed on the wrong (left) side. The fix routes both
/// the message bubble and the typing bubble through [chatBubbleAlignment], which
/// returns a directional alignment that resolves correctly under RTL.
void main() {
  group('chatBubbleAlignment — bubble side contract', () {
    test('own message → start (directional)', () {
      expect(chatBubbleAlignment(isMe: true), AlignmentDirectional.centerStart);
    });

    test('other message → end (directional)', () {
      expect(chatBubbleAlignment(isMe: false), AlignmentDirectional.centerEnd);
    });

    test('own and other never share an edge', () {
      expect(
        chatBubbleAlignment(isMe: true),
        isNot(chatBubbleAlignment(isMe: false)),
      );
    });

    test('under RTL: own resolves physical-right, other physical-left', () {
      // start in RTL = physical right (x = +1.0); end = physical left (-1.0).
      expect(chatBubbleAlignment(isMe: true).resolve(TextDirection.rtl).x, 1.0);
      expect(
        chatBubbleAlignment(isMe: false).resolve(TextDirection.rtl).x,
        -1.0,
      );
    });
  });
}
