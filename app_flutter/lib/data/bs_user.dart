// ─────────────────────────────────────────────────────────────────────────────
// bs_user — U0.1 (user-system foundation): the UNIFIED user model.
//
// WHY THIS EXISTS (SPEC-user-system, step U0):
//   Today identity is split — [UserProfile] (state/user_profile.dart) is the
//   on-device demo profile (name/contact/profession/…), while `users/{uid}` is a
//   loose Firestore MIRROR written ad-hoc by the welcome flow + the profile
//   editor ({displayName, phone, email, …}). [BsUser] is the ONE typed shape both
//   sides speak: the doc-id IS the `auth.uid`, and the fields carry the identity
//   the whole app can key on (role, store-ownership, approval status).
//
// LOCKED DECISIONS this model encodes (SPEC-user-system §"הקשר-החלטות"):
//   • Registration is ALL-BY-APPROVAL → a fresh user is born [UserStatus.pending]
//     (never self-`active`; the flip is a server/admin action — see firestore.rules
//     users block + U0.4). The guarded default is `pending`, so an absent/garbage
//     `status` reads as "not yet approved", never as "approved".
//   • Store-ownership is SINGLE-OWNER → ONE [storeUid] (not a list).
//   • `role` mirrors the Firebase custom-claim (the real source of truth); this
//     field is a READ MIRROR the client may never self-write (rules block it).
//
// PURE / FIREBASE-FREE (the same rule as every data-layer model): this file
// imports NO firebase package, so it unit-tests with zero backend. Firestore
// stores timestamps as `Timestamp`, but the model speaks plain maps — [_parseTime]
// tolerates an epoch-millis int (what [toDoc] writes), an ISO-8601 string, OR a
// duck-typed `Timestamp` (`.toDate()`/`.millisecondsSinceEpoch`), so a doc written
// by a future Admin-SDK `serverTimestamp()` still decodes. Every decode is
// GUARDED (a bad field falls back to a safe default, never throws) — the mirror of
// `UserProfile.fromJson`'s `as String? ?? ''` idiom.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/foundation.dart';

/// The approval / lifecycle state of a [BsUser]. The wire value is the enum
/// [name] verbatim (`'active'`/`'suspended'`/`'pending'`). The guarded
/// [fromWire] defaults to [pending] for anything unknown/missing — the
/// all-by-approval safe default (an un-decodable status is NOT treated as active).
enum UserStatus {
  active,
  suspended,
  pending;

  /// The stable string written to the `status` field.
  String get wire => name;

  /// Decode a `status` field value. Anything that is not exactly `'active'` or
  /// `'suspended'` (including null / wrong type / a typo) → [pending].
  static UserStatus fromWire(Object? value) {
    switch (value) {
      case 'active':
        return UserStatus.active;
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.pending;
    }
  }
}

/// The unified user record — `users/{uid}`, doc-id == `auth.uid`.
///
/// Field ⇄ doc-key mapping (kept verbatim with the EXISTING mirror + `users_lookup`
/// so the read/write sides can never silently drift): [name]⇄`displayName`,
/// [phone]⇄`phone`, [email]⇄`email`, [role]⇄`role`, [storeUid]⇄`storeUid`,
/// [orgId]⇄`orgId`, [status]⇄`status`, [createdAt]⇄`createdAt`,
/// [lastSeen]⇄`lastSeen`.
@immutable
class BsUser {
  const BsUser({
    required this.uid,
    this.name = '',
    this.phone,
    this.email,
    this.role = '',
    this.storeUid,
    this.orgId,
    this.status = UserStatus.pending,
    this.createdAt,
    this.lastSeen,
  });

  /// Guarded decode of one `users/{uid}` document. [uid] comes from the doc-id
  /// (the source of truth); [data] is the field map. Every field falls back to a
  /// safe default — a corrupt doc yields a valid-shaped [BsUser], never a throw.
  factory BsUser.fromJson(String uid, Map<String, dynamic> data) => BsUser(
        uid: uid,
        name: (data['displayName'] as String?) ?? '',
        phone: _nonEmptyString(data['phone']),
        email: _nonEmptyString(data['email']),
        role: (data['role'] as String?) ?? '',
        storeUid: _nonEmptyString(data['storeUid']),
        orgId: _nonEmptyString(data['orgId']),
        status: UserStatus.fromWire(data['status']),
        createdAt: _parseTime(data['createdAt']),
        lastSeen: _parseTime(data['lastSeen']),
      );

  /// Bridge from the on-device [UserProfile] to a [BsUser] — WITHOUT touching
  /// [UserProfile] or any of its consumers (U0.1 "הרחבת UserProfile→BsUser").
  /// The profile's single `contact` field is split to `phone` XOR `email` by the
  /// same validators the welcome mirror uses, so an email never lands in `phone`.
  /// `role` stays `''` (the default persona — a role is a server/claim concern,
  /// never derived from the local profile); `status` defaults to [UserStatus.pending].
  factory BsUser.fromProfile(
    UserProfile profile, {
    required String uid,
    UserStatus status = UserStatus.pending,
    String role = '',
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    final contact = profile.contact.trim();
    return BsUser(
      uid: uid,
      name: profile.name.trim(),
      phone: validIsraeliMobile(contact) ? contact : null,
      email: validEmail(contact) ? contact : null,
      role: role,
      status: status,
      createdAt: createdAt,
      lastSeen: lastSeen,
    );
  }

  /// The Firebase `auth.uid` — the doc-id, the identity every Security Rule keys
  /// on. A [BsUser] with an empty [uid] is invalid (see [isValid]).
  final String uid;

  /// Display name (⇄ `displayName`). Empty when unknown.
  final String name;

  /// E.164 / local Israeli phone (⇄ `phone`) — null when the account has none.
  final String? phone;

  /// Email (⇄ `email`) — null for phone-only accounts.
  final String? email;

  /// The operational role, in the persona dialect (`''` = contractor / default).
  /// A READ MIRROR of the custom-claim — the client may NEVER self-write it
  /// (firestore.rules blocks `role`/`roles` on a self write).
  final String role;

  /// The store this user OWNS (single-owner) — null when they own no store.
  /// Server/callable-assigned only (rules block a self write).
  final String? storeUid;

  /// The organisation this user belongs to — null when none. Server-assigned.
  final String? orgId;

  /// Approval / lifecycle status. Born [UserStatus.pending] (all-by-approval).
  final UserStatus status;

  /// When the record was first created — null until stamped.
  final DateTime? createdAt;

  /// Last time the user was seen (refreshed on entry — U0.3).
  final DateTime? lastSeen;

  /// A record is valid when it has a [uid] and any present contact field has a
  /// well-formed shape (empty/absent is allowed — contact is optional). Pure,
  /// mirroring `registrationValid` / `input_validators`.
  bool get isValid {
    if (uid.trim().isEmpty) return false;
    final p = phone;
    if (p != null && p.isNotEmpty && !validIsraeliMobile(p)) return false;
    final e = email;
    if (e != null && e.isNotEmpty && !validEmail(e)) return false;
    return true;
  }

  BsUser copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? storeUid,
    String? orgId,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) =>
      BsUser(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        role: role ?? this.role,
        storeUid: storeUid ?? this.storeUid,
        orgId: orgId ?? this.orgId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        lastSeen: lastSeen ?? this.lastSeen,
      );

  /// FULL serialisation — every present field (empties/nulls omitted). Used for
  /// the local cache round-trip and for a privileged (manager/admin) author
  /// write. NOTE: a CLIENT self-write must NOT carry `role`/`storeUid`/`orgId`
  /// and may only set `status` to `pending` on CREATE — the repository builds
  /// those rules-safe partial maps explicitly (users_repository.dart); this full
  /// map is not the client self-write path.
  Map<String, dynamic> toDoc() => <String, dynamic>{
        if (name.isNotEmpty) 'displayName': name,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (role.isNotEmpty) 'role': role,
        if (storeUid != null && storeUid!.isNotEmpty) 'storeUid': storeUid,
        if (orgId != null && orgId!.isNotEmpty) 'orgId': orgId,
        'status': status.wire,
        if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
        if (lastSeen != null) 'lastSeen': lastSeen!.millisecondsSinceEpoch,
      };

  /// A trimmed non-empty string, or null (so an empty stored field decodes to
  /// null rather than `''` — keeps the optional-field contract clean).
  static String? _nonEmptyString(Object? value) {
    if (value is! String) return null;
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  /// Guarded timestamp decode. Accepts an epoch-millis int (what [toDoc] writes)
  /// or an ISO-8601 string; anything else (a corrupt value / a shape we do not
  /// speak) → null, never a throw. The client writes millis ints; a future
  /// server-side `serverTimestamp` gets decoded where that path is added.
  static DateTime? _parseTime(Object? value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is BsUser &&
      other.uid == uid &&
      other.name == name &&
      other.phone == phone &&
      other.email == email &&
      other.role == role &&
      other.storeUid == storeUid &&
      other.orgId == orgId &&
      other.status == status &&
      other.createdAt == createdAt &&
      other.lastSeen == lastSeen;

  @override
  int get hashCode => Object.hash(
        uid,
        name,
        phone,
        email,
        role,
        storeUid,
        orgId,
        status,
        createdAt,
        lastSeen,
      );

  @override
  String toString() => 'BsUser($uid, $name, role=$role, status=${status.wire})';
}
