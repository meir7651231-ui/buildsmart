// ⚛️ אטום-Dart (דרגת-חוזה) · chatMessageIsMine
// מוצא: buildsmart/app_flutter/lib/state/sys_chat.dart:187 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): ChatMessage, BsRole.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__chats_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): אימוג׳י · אין · שיחות · בארכיון · אעדכן · אותך · בהקדם · אפשרויות · ארכיון · בטל · השתקה · ביטול

/// A single message in a thread. `fromRole` drives "mine vs theirs" in the UI
/// (the reading persona's own messages render right, others left — SPEC §1
/// "כיווניות").
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.fromRole,
    required this.text,
    required this.ts,
    this.fromUid = '',
    this.status = MsgStatus.sent,
  });

  final String id;
  final String threadId;
  final BsRole fromRole;
  final String text;
  final DateTime ts;

  /// A8 (launch uid-migration) — the sender's `auth.uid` when the message was
  /// sent while signed-in, else ''. Additive and display-neutral: [fromRole]
  /// still drives the mine/theirs rendering; a later phase (post-S1) scopes
  /// `chatMessages`/thread `participants` on this uid (the server activates that
  /// via the firestore rules — see chat_firebase.dart's deferred-join note).
  /// Written only when non-empty so the seed + every legacy/pre-A8 doc
  /// round-trips byte-identical (zero regression).
  final String fromUid;

  /// HONEST delivery status (#chat-delivery-status). Defaults to [MsgStatus.sent]
  /// so every seed / legacy / demo message reads as a single ✓ with no migration;
  /// [MsgStatus.delivered] is set ONLY by the server decode (`fromDoc`) — that is
  /// the structural ✓✓-only-from-the-server invariant. SENDER-LOCAL — `toDoc`
  /// strips it, so it never travels to or from the server doc fields.
  final MsgStatus status;

  /// The class had NO `copyWith` before #chat-delivery-status — the delivery
  /// flow patches status (pending → sent/failed on the write outcome; delivered
  /// on a `fromDoc` decode) immutably, so it is added covering ALL fields.
  ChatMessage copyWith({
    String? id,
    String? threadId,
    BsRole? fromRole,
    String? text,
    DateTime? ts,
    String? fromUid,
    MsgStatus? status,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        threadId: threadId ?? this.threadId,
        fromRole: fromRole ?? this.fromRole,
        text: text ?? this.text,
        ts: ts ?? this.ts,
        fromUid: fromUid ?? this.fromUid,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'fromRole': fromRole.name,
        'text': text,
        'ts': ts.toIso8601String(),
        if (fromUid.isNotEmpty) 'fromUid': fromUid,
        // #chat-delivery-status — written ONLY when it differs from the default
        // `sent`, so the seed + every legacy doc stays byte-identical (the same
        // zero-regression rule fromUid follows). The server doc never carries it
        // (the repo's `toDoc` strips it); this is the LOCAL prefs/JSON shape.
        if (status != MsgStatus.sent) 'status': status.name,
      };

  static ChatMessage? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final threadId = raw['threadId'];
    final text = raw['text'];
    final ts = DateTime.tryParse('${raw['ts']}');
    final role = BsRole.values
        .where((r) => r.name == raw['fromRole'])
        .cast<BsRole?>()
        .firstWhere((_) => true, orElse: () => null);
    if (id is! String || threadId is! String || text is! String ||
        ts == null || role == null) {
      return null;
    }
    return ChatMessage(
      id: id,
      threadId: threadId,
      fromRole: role,
      text: text,
      ts: ts,
      // A8 — tolerant read: present on a post-A8 doc, '' on every legacy/seed
      // doc (the zero-regression default). A non-String value coerces to ''.
      fromUid: raw['fromUid'] is String ? raw['fromUid'] as String : '',
      // #chat-delivery-status — tolerant read mirroring the `LineStatus` idiom
      // (persona_fulfillment.dart): an OLD doc with no `status` reads back `sent`
      // (zero regression). Server docs carry no status either (toDoc strips it),
      // so a message decoded by the repo's `fromDoc` arrives here as `sent` and
      // is THEN upgraded to `delivered` by that decode — the honest invariant.
      status: MsgStatus.values.firstWhere(
        (s) => s.name == raw['status'],
        orElse: () => MsgStatus.sent,
      ),
    );
  }
}

/// The personas that can take part in a chat. `bot` is the special auto-reply
/// counterpart kept from the legacy `chats_screen` (SPEC §6 — "bot נשאר").
enum BsRole { contractor, store, courier, worker, manager, bot }

/// HONEST per-message delivery status (#chat-delivery-status). The check-mark a
/// message renders is now driven STRUCTURALLY by where the message came from —
/// it is no longer the cosmetic `readReceipts` toggle:
///   • [pending] 🕐 — the optimistic write is in flight (Firebase path, initial);
///   • [sent] ✓ — in the local outbox / demo-local, NO server confirmation (the
///     back-compat default: every seed/legacy/demo message reads as sent ✓);
///   • [delivered] ✓✓ — the message was rebuilt from a SERVER snapshot (it really
///     reached the server). The HONEST INVARIANT: this is set ONLY by the
///     Firestore decode (`FirebaseChatRepository` message `fromDoc`) — a message
///     that never reached the server can NEVER show ✓✓ (enforced structurally);
///   • [failed] ❌ — the background write threw (the user gets a "נסה שוב" retry).
/// Status is SENDER-LOCAL: it is never written to the server doc (`toDoc` strips
/// it), so a doc's delivered-ness is implied purely by coming back via `fromDoc`.
enum MsgStatus { pending, sent, delivered, failed }

/// #chat-identity (uid-based mine/theirs) — is message [m] "MINE" for the person
/// reading the thread? The reader is the auth [readerUid]; the display [persona]
/// is only the LEGACY fallback.
///
/// THE BUG THIS FIXES: attribution keyed on `fromRole == persona` treats ONE
/// person as TWO whenever they act from two boards. A manager who answers a
/// client from the CONTRACTOR board sends `fromRole: contractor`; from the
/// MANAGER board he sends `fromRole: manager`. Reading the same thread his two
/// lines then land on OPPOSITE sides — and worse, his contractor-board line is
/// indistinguishable from the REAL contractor client's (both `contractor`), so
/// the client sees the manager's reply rendered as the client's OWN message.
///
/// THE FIX: when the message carries a real sender uid AND the reader's uid is
/// known, "mine" is `fromUid == readerUid` — ONE PERSON, every board. Only when a
/// uid is missing (the seed + every legacy/local/demo message, the signed-out /
/// Firebase-free path, the whole test suite) do we fall back to the role compare,
/// so that path stays BYTE-IDENTICAL (zero regression).
bool chatMessageIsMine(ChatMessage m, BsRole persona, String? readerUid) {
  if (m.fromUid.isNotEmpty && readerUid != null && readerUid.isNotEmpty) {
    return m.fromUid == readerUid;
  }
  return m.fromRole == persona;
}
