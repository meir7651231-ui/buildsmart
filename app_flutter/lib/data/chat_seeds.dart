// CROSS-PERSONA CHAT SEED — the initial non-empty threads every persona starts
// with (SPEC `SPEC-cross-persona-chat.md` CH-2). Tone/strings mirror the legacy
// `chats_screen.dart` `_kThreads` so the demo reads identically; the difference
// is each thread now carries a [participants] list, which drives cross-persona
// visibility via `ChatEngineNotifier.threadsFor`:
//
//   • contractor↔store    — both 👷 and 🏪 see it
//   • contractor↔courier  — both 👷 and 🛵 see it
//   • contractor↔manager  — both 👷 and 👔 see it (🏪/🛵 do NOT — isolation)
//   • store↔courier       — both 🏪 and 🛵 see it
//   • bot                 — the chatbot thread (auto-reply kept), contractor-side
//
// Timestamps are fixed (not `DateTime.now()`) so the seed is deterministic for
// tests and stable across rebuilds — only user-sent messages use the wall clock.

import 'package:buildsmart/state/sys_chat.dart';

/// A stable seed instant so ordering/ids are deterministic (the demo "today").
final DateTime _seedDay = DateTime(2026, 6, 7, 8);

ChatMessage _seed(
  String threadId,
  BsRole from,
  String text, {
  required int minute,
}) =>
    ChatMessage(
      id: 'seed-$threadId-$minute',
      threadId: threadId,
      fromRole: from,
      text: text,
      ts: _seedDay.add(Duration(minutes: minute)),
    );

/// The verbatim seed threads. Re-applied under the persisted message overlay on
/// load (see `sys_chat.dart` `_load`).
final List<ChatThread> kChatThreads = [
  // 👷 ↔ 🏪 — contractor & building-materials supplier (legacy t1/t2 tone).
  ChatThread(
    id: 'th-contractor-store',
    participants: const [BsRole.contractor, BsRole.store],
    name: 'ספק חומרי בנייה',
    avatar: '🏪',
    messages: [
      _seed('th-contractor-store', BsRole.contractor,
          'בוקר טוב, ההזמנה של פרויקט A מוכנה?', minute: 0),
      _seed('th-contractor-store', BsRole.store,
          'אישור הזמנה #1234 — מוכנה לאיסוף ✅', minute: 4),
      _seed('th-contractor-store', BsRole.store,
          'שלום, ההזמנה שלך תצא בעוד כ-20 דקות.', minute: 14),
    ],
  ),

  // 👷 ↔ 🛵 — contractor & courier (legacy t3 tone).
  ChatThread(
    id: 'th-contractor-courier',
    participants: const [BsRole.contractor, BsRole.courier],
    name: 'השליח',
    avatar: '🛵',
    messages: [
      _seed('th-contractor-courier', BsRole.courier,
          'מתי אפשר לאסוף את BS-1041?', minute: -120),
      _seed('th-contractor-courier', BsRole.contractor,
          'מוכן לאיסוף מהמחסן מ-14:00.', minute: -110),
    ],
  ),

  // 👷 ↔ 👔 — contractor & system manager (legacy t4 tone). 🏪/🛵 must NOT see it.
  ChatThread(
    id: 'th-contractor-manager',
    participants: const [BsRole.contractor, BsRole.manager],
    name: 'מנהל המערכת',
    avatar: '👔',
    messages: [
      _seed('th-contractor-manager', BsRole.manager,
          'עדכון סטטוס פרויקט A — בדיקה נדרשת', minute: -200),
      _seed('th-contractor-manager', BsRole.contractor,
          'מעדכן עד סוף היום, תודה.', minute: -180),
    ],
  ),

  // 🏪 ↔ 🛵 — supplier & courier (cross pair that does NOT involve the contractor).
  ChatThread(
    id: 'th-store-courier',
    participants: const [BsRole.store, BsRole.courier],
    name: 'שליח איסופים',
    avatar: '🛵',
    messages: [
      _seed('th-store-courier', BsRole.store,
          'חבילת BS-1041 ארוזה ומחכה בעמדת איסוף 3.', minute: -60),
      _seed('th-store-courier', BsRole.courier,
          'בדרך, מגיע תוך 15 דקות 🛵', minute: -55),
    ],
  ),

  // 🤖 — chatbot thread (auto-reply kept). Contractor-facing (legacy t5).
  ChatThread(
    id: 'th-bot',
    participants: const [BsRole.contractor, BsRole.bot],
    name: 'צ׳אטבוט BuildSmart',
    avatar: '🤖',
    isBot: true,
    messages: [
      _seed('th-bot', BsRole.bot, 'איך אפשר לעזור לך היום?', minute: -10),
    ],
  ),
];
