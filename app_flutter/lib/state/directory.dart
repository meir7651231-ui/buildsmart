// ─────────────────────────────────────────────────────────────────────────────
// directory — the CLIENT reader for the small, readable "who exists here" list
// (#8 · phase 3b). The server (functions/src/directory.ts, fired by
// onUserDocWritten) maintains `directory/{uid} = {role, displayName, status,
// updatedAt}`; the Security Rules let ANY signed-in, non-anonymous user READ it
// (writes are server-only). This file is the missing client seam over that
// collection — the people-picker source that lets someone START a conversation
// with a person (home_shell `_NewChatSheet`), the counterpart of the role→uid
// resolution `UsersLookup.uidsByRole` already reads out of the same collection.
//
// WHY A SECOND directory reader (next to UsersLookup): they answer different
// questions from the same data. `UsersLookup.uidsByRole` resolves a ROLE to its
// members' uids (chat participantUids stamping); this exposes the LIST of people
// as display rows (uid + name + role) to render a picker. Keeping the picker
// reader here — a plain `StreamProvider<List<DirectoryEntry>>`, the
// `pendingRoleRequestsProvider` idiom (state/role_requests.dart) — keeps the
// widget layer free of the raw `RemoteDoc`/collection plumbing.
//
// HARD RULES (identical to every data seam — break one, break the
// zero-regression contract):
//   1. NO Firebase touch without the live backend. [directorySourceProvider]
//      gates on the SAME `useFirebaseBackend` switch every repo uses ⇒ the whole
//      Firebase-free test suite + the demo build get null, and [directoryProvider]
//      resolves to an EMPTY list (byte-identical OFF behaviour — the picker keeps
//      today's hardcoded fallback).
//   2. ADDITIVE ONLY. Nothing here changes an existing flow; it only EXPOSES the
//      directory as display rows for the picker (phase 3b) and, later, the
//      manager-customers→chat link (phase 3c).
//   3. A backend hiccup must NEVER throw into the UI — the stream degrades to an
//      empty list (an honest "nobody here yet"), never an exception.
//
// Comment density/voice mirrors users_lookup.dart / role_requests.dart — the two
// files this one sits between.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/edge/edge_collection_source.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart'
    show currentUidProvider, filteredFirestoreProvider;
import 'package:buildsmart/state/sys_chat.dart' show BsRole;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `directory/{uid}` field names this reader keys on. Kept verbatim with the
/// server writer (functions/src/directory.ts) so the read side can never
/// silently drift from the write side (the same discipline
/// `kUsersPhoneField`/`kUsersRoleField` keep for `users`).
const String kDirectoryDisplayNameField = 'displayName';
const String kDirectoryRoleField = 'role';
const String kDirectoryStatusField = 'status';

/// The two account-lifecycle status values the approval flow keys on — kept
/// verbatim with the server, which writes these exact strings into `users.status`
/// / `directory.status` (functions/src/reviewRoleRequest.ts + approveUsers.ts).
/// A user is born [kDirectoryStatusPending] (checkout-blocked) and the owner's
/// approval panel flips them to [kDirectoryStatusActive] via the `approveUsers`
/// callable. Same drift-guard discipline as the field-name constants above.
const String kDirectoryStatusPending = 'pending';
const String kDirectoryStatusActive = 'active';

/// Parse a stored `role` string into a [BsRole], or null when it is
/// absent/unknown. [BsRole.bot] is deliberately NOT matchable — the bot is the
/// system, never a `directory` row — so a stray `'bot'` value resolves to null
/// (a display-neutral "no role") rather than surfacing the chatbot as a person.
/// Pure ⇒ unit-tested directly.
BsRole? parseBsRole(Object? raw) {
  if (raw is! String) return null;
  for (final r in BsRole.values) {
    if (r != BsRole.bot && r.name == raw) return r;
  }
  return null;
}

/// One row of the readable people directory — the MINIMUM needed to address a
/// person (uid to key a DM on, a name + role to show), and nothing the readable
/// list must not carry (no phone / e-mail — those stay `users`, admin-only).
@immutable
class DirectoryEntry {
  const DirectoryEntry({
    required this.uid,
    required this.displayName,
    this.role,
    this.status = '',
  });

  /// Decode one `directory` [RemoteDoc] (id = uid). TOLERANT by design (HARD
  /// RULE #3): a missing/non-String `displayName`/`status` reads back '', an
  /// absent/unknown `role` reads back null — a single odd doc degrades to a
  /// harmless row, it never throws. Pure ⇒ unit-tested directly.
  factory DirectoryEntry.fromDoc(RemoteDoc doc) => DirectoryEntry(
        uid: doc.id,
        displayName: doc.data[kDirectoryDisplayNameField] is String
            ? doc.data[kDirectoryDisplayNameField] as String
            : '',
        role: parseBsRole(doc.data[kDirectoryRoleField]),
        status: doc.data[kDirectoryStatusField] is String
            ? doc.data[kDirectoryStatusField] as String
            : '',
      );

  /// The person's `auth.uid` — the `directory` doc-id, the key a per-user DM
  /// thread is built on (`dmThreadId`, sys_chat.dart).
  final String uid;

  /// The name to show in the picker. The server's `pickName` guarantees a
  /// non-empty value for a real account; [directoryProvider] drops empties
  /// defensively so a nameless row can never render.
  final String displayName;

  /// The person's role, or null when absent/unknown ([parseBsRole]). Drives the
  /// row's role label/emoji only — display-neutral, never a permission decision.
  final BsRole? role;

  /// The `directory` status stamp (e.g. presence/last-seen), '' when absent.
  /// Carried through for later phases ("who is online"); unused by the picker.
  final String status;
}

/// The `directory` collection seam — null when Firebase is not initialised (the
/// entire Firebase-free test suite + the demo build), the SAME `useFirebaseBackend`
/// gate every repo/`usersProfileWriterProvider` uses, so nothing here can ever
/// touch `FirebaseFirestore.instance` off the live path. Tests override this with
/// a fake [RemoteCollectionSource] to drive [directoryProvider]. The read is
/// whole-collection: the rules allow every signed-in non-anonymous user to read
/// `directory`, so no scope is needed (unlike the participant-scoped chat listen).
final directorySourceProvider = Provider<RemoteCollectionSource?>((ref) {
  // 🌉 מצב-מסונן: המילון דרך REST (הגשר) — ה-SDK בקו-מסונן חסר-טוקן ⇒ ה-listen
  // נדחה בשקט והרשימה ריקה ("אין עדיין משתמשים"). זה בדיוק המקור ש-usersLookup
  // כבר משתמש בו (הוכח עובד באבחון: manager→1, contractor→23). כבוי ⇒ SDK.
  final rest = ref.watch(filteredFirestoreProvider);
  if (rest != null) return EdgeRestCollectionSource('directory', rest);
  if (!useFirebaseBackend) return null;
  // BOUNDED (stage-2 scale rule 4 — boundedness conformance): cap the people
  // listen at 500 rows (a picker, not a feed; a search/pagination is the follow-up
  // for a larger base). No orderBy → no composite index needed.
  return FirestoreCollectionSource('directory', bound: (q) => q.limit(500));
});

/// The live people directory — every OTHER signed-in person as a display row.
///
/// GATED (HARD RULE #1): when [directorySourceProvider] is null (Firebase-free /
/// demo / the whole test suite) this resolves to a single EMPTY emission, so an
/// OFF build never watches Firestore and the picker keeps today's behaviour —
/// byte-identical when the backend is off.
///
/// FILTERED: excludes the current user's own row ([currentUidProvider]) — you do
/// not start a chat with yourself — and any row with an empty [DirectoryEntry
/// .displayName] (a half-written doc must never render as a blank, un-pickable
/// row). A stream error degrades to the last value, never a throw
/// ([FirestoreCollectionSource.snapshots] surfaces errors the widget's
/// `AsyncValue.error` handles as an honest empty).
final directoryProvider = StreamProvider<List<DirectoryEntry>>((ref) {
  final src = ref.watch(directorySourceProvider);
  if (src == null) return Stream<List<DirectoryEntry>>.value(const []);
  final me = ref.watch(currentUidProvider);
  return src.snapshots().map((docs) {
    final out = <DirectoryEntry>[];
    for (final d in docs) {
      if (d.id == me) continue; // exclude self — no chat-with-yourself row
      final entry = DirectoryEntry.fromDoc(d);
      if (entry.displayName.isEmpty) continue; // never a blank, un-pickable row
      out.add(entry);
    }
    return out;
  });
});

// ── registration approval (owner-driven) — the PURE checklist logic ───────────
// The Manager Customers approval panel (manager_dashboard_screen.dart) drives its
// checklist + the three approve affordances through these two pure functions, so
// the select/all/all-except logic is unit-tested widget-free (the callable itself
// is `userApproverProvider` in role_requests.dart; the server authorizes).

/// PURE — the PENDING directory rows ([DirectoryEntry.status] ==
/// [kDirectoryStatusPending]) in input order: the approval panel's checklist
/// source (every registered user still waiting to be approved to buy). Selftested
/// widget-free.
List<DirectoryEntry> pendingDirectoryEntries(List<DirectoryEntry> entries) => [
      for (final e in entries)
        if (e.status == kDirectoryStatusPending) e,
    ];

/// PURE — resolve which pending uids an approve action targets. [all] (the
/// "אשר הכל" button) approves EVERY pending uid regardless of the tick-state;
/// otherwise ("אשר מסומנים") only the [checked] ones. Order follows [pendingUids]
/// (deterministic), and a [checked] uid no longer in [pendingUids] is ignored
/// (stale-exclusion safety across a live stream re-emit). This ONE mapping is
/// behind all three panel affordances:
///   • "approve all"          → all: true
///   • "approve selected"     → all: false, checked = the ticked rows
///   • "approve all-except-X" → untick X, then all: false (X ∉ checked)
/// Selftested widget-free.
List<String> resolveApproveTargets({
  required bool all,
  required List<String> pendingUids,
  required Set<String> checked,
}) =>
    all
        ? List<String>.of(pendingUids)
        : [
            for (final u in pendingUids)
              if (checked.contains(u)) u,
          ];
