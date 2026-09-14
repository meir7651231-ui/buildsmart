// ⚛️ אטום-Dart (דרגת-חוזה) · chatCounterpartRole
// מוצא: buildsmart/app_flutter/lib/screens/chats_screen.dart:1506 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): BsRole.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__chats_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): אימוג׳י · אין · שיחות · בארכיון · אעדכן · אותך · בהקדם · אפשרויות · ארכיון · בטל · השתקה · ביטול

/// The personas that can take part in a chat. `bot` is the special auto-reply
/// counterpart kept from the legacy `chats_screen` (SPEC §6 — "bot נשאר").
enum BsRole { contractor, store, courier, worker, manager, bot }

/// #chat-dm-reroute — the SINGLE "other side" role of a seed thread for the
/// reading [persona], or null when there is no single real counterpart: the bot
/// thread, a per-user dm thread (empty role [ChatThread.participants]), or an
/// ambiguous multi-party thread (>1 non-self role). Pure ⇒ ratchet-tested.
///
/// It exists because a shared SEED role-thread (`th-contractor-manager`, …) can
/// hold at most ONE plain contractor: `ensureParticipantUids` stamps
/// participantUids ONCE, and a plain contractor (no role claim) can't re-stamp an
/// already-stamped thread (chatThreads rule). So a real conversation between two
/// plain users over a seed thread silently loses the second party — this maps the
/// seed thread to its counterpart role so the tap can reroute onto a real
/// dm-<uids> thread that lists BOTH uids from creation (create rule passes both).
BsRole? chatCounterpartRole(List<BsRole> participants, BsRole persona) {
  final others =
      participants.where((r) => r != persona && r != BsRole.bot).toList();
  return others.length == 1 ? others.first : null;
}
