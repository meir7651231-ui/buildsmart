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
//   • store board (#83)   — the supplier's own chat-tab list (audience:'store'):
//                           קבלנים·שליח·מנהל·קבוצת-ספקים, each visible to BOTH
//                           sides via the participants filter
//   • bot                 — the chatbot thread (auto-reply kept), shared with
//                           the worker/courier/supplier boards (one bot for
//                           everyone)
//
// Board-audience seeds (contract §3): the courier-board threads (#75, marked
// `audience: 'courier'`) and the supplier-board threads (#83, marked
// `audience: 'store'` — קבלנים·שליח·מנהל·קבוצת-ספקים) live here too; the
// worker-board list is in `sys_chat.dart` (`kWorkerChatThreads`).
//
// Timestamps are fixed (not `DateTime.now()`) so the seed is deterministic for
// tests and stable across rebuilds — only user-sent messages use the wall clock.

import 'package:buildsmart/config/app_brand.dart';
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

  // 👷 ↔ 🎧 — contractor & APP SUPPORT (legacy t4 tone). 🏪/🛵 must NOT see it.
  // #110 — the BsRole.manager thread is platform support/help ("עזרה
  // באפליקציה"), NOT a boss; retagged to "תמיכה" / 🎧. Only the display name +
  // avatar change — id/participants/visibility stay (the isolation tests key
  // off the id 'th-contractor-manager', not the name).
  ChatThread(
    id: 'th-contractor-manager',
    participants: const [BsRole.contractor, BsRole.manager],
    name: 'תמיכה',
    avatar: '🎧',
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

  // ── שיחות לוח-השליח (#75 · audience:'courier') — demo seeds שמפנים אך ורק
  // להזמנות האמיתיות מה-seed (BS-1040 · משה אברהם · וילה — סביון · 6 פריטים,
  // משאית | BS-1039 · דוד לוי · משרדים — תל אביב · בדרך). SERVER-SWAP: עם
  // חיבור השרת השיחות האלה יגיעו מצד השרת. ─────────────────────────────────

  // 🛵 ↔ 🏪 — השליח מול חנות ליפסקי (איסוף BS-1040).
  ChatThread(
    id: 'th-courier-lipskey',
    participants: const [BsRole.store, BsRole.courier],
    audience: 'courier',
    name: 'חנות ליפסקי',
    avatar: '🏪',
    messages: [
      _seed('th-courier-lipskey', BsRole.store,
          'BS-1040 (משה אברהם, וילה — סביון) מוכן לאיסוף — 6 פריטים, דורש משאית.',
          minute: -50),
      _seed('th-courier-lipskey', BsRole.courier,
          'קיבלתי, יוצא לאיסוף עם המשאית 🚛', minute: -45),
    ],
  ),

  // 🛵 ↔ 👤 — השליח מול הלקוח של המשלוח האמיתי BS-1040.
  ChatThread(
    id: 'th-courier-customer',
    participants: const [BsRole.contractor, BsRole.courier],
    audience: 'courier',
    name: 'לקוח — משה אברהם',
    avatar: '👤',
    messages: [
      _seed('th-courier-customer', BsRole.courier,
          'שלום, משלוח BS-1040 בדרך אליך היום לוילה בסביון.', minute: -40),
      _seed('th-courier-customer', BsRole.contractor,
          'מעולה, אני באתר אחרי 12:00. תודה!', minute: -35),
    ],
  ),

  // 🛵 ↔ 🛵 — קבוצת השליחים (עדכוני משמרת; המנהל משתתף כמוקד).
  ChatThread(
    id: 'th-couriers-group',
    participants: const [BsRole.courier, BsRole.manager],
    audience: 'courier',
    name: 'שליחים',
    avatar: '🛵',
    messages: [
      _seed('th-couriers-group', BsRole.manager,
          'עדכון בוקר: BS-1039 (דוד לוי) כבר בדרך למשרדים בתל אביב.',
          minute: -30),
      _seed('th-couriers-group', BsRole.courier,
          'BS-1040 ייאסף בהמשך הבוקר מהחנות 🛵', minute: -25),
    ],
  ),

  // ── שיחות לוח-הספק (#83 · audience:'store') — demo seeds שמפנים אך ורק
  // להזמנות האמיתיות מה-seed (kSysOrdersSeed, supplier_data.dart: BS-1042 ·
  // יוסי כהן · מגדל הרצליה · התקבלה | BS-1041 · אבי מזרחי · דירה — רמת גן ·
  // בהכנה | BS-1040 · משה אברהם · וילה — סביון · מוכן לאיסוף | BS-1039 ·
  // דוד לוי · משרדים — תל אביב · בדרך לאתר). SERVER-SWAP: עם חיבור השרת
  // השיחות האלה יגיעו מצד השרת. ────────────────────────────────────────────

  // 🏪 ↔ 👷 — הספק מול הקבלנים (ההזמנות האמיתיות BS-1042 / BS-1041).
  ChatThread(
    id: 'th-store-contractors',
    participants: const [BsRole.store, BsRole.contractor],
    audience: 'store',
    name: 'קבלנים',
    avatar: '👷',
    messages: [
      _seed('th-store-contractors', BsRole.store,
          'BS-1042 (יוסי כהן, מגדל הרצליה) התקבלה — 7 פריטים, מתחילים בהכנה.',
          minute: -80),
      _seed('th-store-contractors', BsRole.contractor,
          'מעולה. מה הסטטוס של BS-1041 (דירה — רמת גן)?', minute: -75),
      _seed('th-store-contractors', BsRole.store,
          'BS-1041 בהכנה — אסלה תלויה ומיכל הדחה סמוי; נעדכן כשמוכן לאיסוף.',
          minute: -70),
    ],
  ),

  // 🏪 ↔ 🛵 — הספק מול השליח (איסוף BS-1040 · מסירת BS-1039).
  ChatThread(
    id: 'th-store-courier-pickups',
    participants: const [BsRole.store, BsRole.courier],
    audience: 'store',
    name: 'שליח',
    avatar: '🛵',
    messages: [
      _seed('th-store-courier-pickups', BsRole.store,
          'BS-1040 (משה אברהם, וילה — סביון) מוכן לאיסוף — 6 פריטים, דורש משאית.',
          minute: -58),
      _seed('th-store-courier-pickups', BsRole.courier,
          'קיבלתי, מגיע עם המשאית 🚛 BS-1039 (דוד לוי) כבר בדרך למשרדים בתל אביב.',
          minute: -52),
    ],
  ),

  // 🏪 ↔ 🎧 — הספק מול תמיכת-האפליקציה (אישור הזמנות נכנסות).
  // #110 — thread עם BsRole.manager = תמיכה/עזרה-באפליקציה, לא בוס; שם-תצוגה
  // + אווטאר עברו ל"תמיכה" / 🎧. רק התווית והאייקון השתנו — id/participants/
  // audience/visibility נשמרים (בדיקת-הבידוד נעולה על id 'th-store-manager').
  ChatThread(
    id: 'th-store-manager',
    participants: const [BsRole.store, BsRole.manager],
    audience: 'store',
    name: 'תמיכה',
    avatar: '🎧',
    messages: [
      _seed('th-store-manager', BsRole.manager,
          'בוקר טוב, BS-1042 (יוסי כהן) התקבלה — נא לאשר ולהתחיל הכנה היום.',
          minute: -110),
      _seed('th-store-manager', BsRole.store,
          'מטופל: BS-1040 כבר מוכן לאיסוף ו-BS-1041 בהכנה.', minute: -100),
    ],
  ),

  // 🏪 ↔ 🏪 — קבוצת הספקים (עדכוני מלאי/זמינות; המנהל משתתף כמוקד — המבנה
  // של th-couriers-group). שמות החנויות = kStores (supplier_data.dart).
  ChatThread(
    id: 'th-suppliers-group',
    participants: const [BsRole.store, BsRole.manager],
    audience: 'store',
    name: 'קבוצת ספקים',
    avatar: '🏪',
    messages: [
      _seed('th-suppliers-group', BsRole.manager,
          'עדכון בוקר לקבוצת הספקים (מחסני אינסטלציה תל-אביב · ספקי סניטריה השרון · חומרי בניין הרצליה): נא לעדכן זמינות מלאי להיום.',
          minute: -95),
      _seed('th-suppliers-group', BsRole.store,
          'מחסני אינסטלציה תל-אביב: BS-1040 מוכן לאיסוף, BS-1042 נכנסת להכנה — אין חוסרים.',
          minute: -88),
    ],
  ),

  // 🤖 — chatbot thread (auto-reply kept). Shared across boards: the worker +
  // courier + supplier boards list it too (the "+בוט" rule of the audience
  // filter), so those roles participate as well — one bot thread for everyone.
  ChatThread(
    id: 'th-bot',
    participants: const [
      BsRole.contractor,
      BsRole.worker,
      BsRole.courier,
      BsRole.store,
      BsRole.bot,
    ],
    name: 'צ׳אטבוט ${AppBrand.name}',
    avatar: '🤖',
    isBot: true,
    messages: [
      _seed('th-bot', BsRole.bot, 'איך אפשר לעזור לך היום?', minute: -10),
    ],
  ),
];
