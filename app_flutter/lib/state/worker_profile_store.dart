// #85ד · WORKER PROFILE STORE — per-username editable profile for the worker
// board's אזור-אישי: display-name, phone, specialty chip (התמחות) and a
// profile photo (a data-URL captured via `services/task_photo.dart`).
//
// The store holds ONLY the worker's explicit OVERRIDES (אין המצאות): an empty
// `name` falls back to the live [BoardSession.displayName] in the UI, an
// empty phone/specialty simply doesn't render, a null photo shows the default
// 🦺 avatar. Nothing here invents business data — it records what the worker
// typed/captured.
//
// Persisted as a `username → profile` map under [kWorkerProfileKey], with the
// `board_auth.dart` idiom: lazy `_load()` from SharedPreferences + a one-shot
// `_userTouched` guard so a late load can never clobber a fresh user write
// (the ticket-#24 race).
//
// SERVER-SWAP: becomes the server-side user profile once Firebase Auth lands;
// the provider surface (read map / `save`) stays identical.

import 'dart:convert';

import 'package:buildsmart/data/repositories/worker_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key (versioned like every other `bs.*.v1` key).
const String kWorkerProfileKey = 'bs.worker-profile.v1';

/// The selectable התמחות chips — the three field trades the worker board
/// serves today. A profile may also keep `''` (no specialty chosen).
const List<String> kWorkerSpecialties = ['אינסטלטור', 'חשמלאי', 'כללי'];

/// One worker's editable profile. Every field is an OPTIONAL override:
/// `name == ''` → the UI falls back to the session displayName; `photo ==
/// null` → the default 🦺 avatar disc.
///
/// #104 — the personal details beyond name/phone (ת.ז · כתובת · איש-קשר
/// לחירום) are ALL optional too, and decode `null`/missing on the older
/// `bs.worker-profile.v1` records (back-compat: a v1 profile saved before
/// #104 simply reads these as `''`). התמחות is NOT re-edited here: טופס 101
/// is the single source of truth (#104ב) and the UI derives the displayed
/// specialty from the saved Form101, keeping `specialty` only as the honest
/// back-compat fallback for a profile saved before the 101 sync.
class WorkerProfile {
  const WorkerProfile({
    this.name = '',
    this.phone = '',
    this.specialty = '',
    this.photo,
    this.idNumber = '',
    this.address = '',
    this.emergencyName = '',
    this.emergencyPhone = '',
  });

  /// Display-name override; `''` means "use [BoardSession.displayName]".
  final String name;

  /// Worker phone (validated as an Israeli mobile in the edit UI); `''` = unset.
  final String phone;

  /// One of [kWorkerSpecialties], or `''` when none was chosen. #104ב —
  /// retained ONLY as the back-compat fallback; טופס 101 is the live source
  /// of truth for the displayed התמחות (the edit sheet no longer writes it).
  final String specialty;

  /// Profile photo as a data-URL (`data:image/...;base64,…`), or null.
  final String? photo;

  /// #104 — תעודת-זהות (9 digits, format-validated in the edit UI); `''` = unset.
  final String idNumber;

  /// #104 — free-text address (כתובת); `''` = unset.
  final String address;

  /// #104 — emergency contact name (איש-קשר לחירום · שם); `''` = unset.
  final String emergencyName;

  /// #104 — emergency contact phone (validated as an Israeli mobile when
  /// non-empty); `''` = unset.
  final String emergencyPhone;

  WorkerProfile copyWith({
    String? name,
    String? phone,
    String? specialty,
    Object? photo = _sentinel,
    String? idNumber,
    String? address,
    String? emergencyName,
    String? emergencyPhone,
  }) =>
      WorkerProfile(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        specialty: specialty ?? this.specialty,
        photo: photo == _sentinel ? this.photo : photo as String?,
        idNumber: idNumber ?? this.idNumber,
        address: address ?? this.address,
        emergencyName: emergencyName ?? this.emergencyName,
        emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      );

  static const _sentinel = Object();

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'specialty': specialty,
        'photo': photo,
        'idNumber': idNumber,
        'address': address,
        'emergencyName': emergencyName,
        'emergencyPhone': emergencyPhone,
      };

  factory WorkerProfile.fromJson(Map<String, dynamic> j) => WorkerProfile(
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        specialty: j['specialty'] as String? ?? '',
        photo: j['photo'] as String?,
        // #104 back-compat: a v1 record saved before these fields existed
        // decodes them as '' (null/missing → honest empty override).
        idNumber: j['idNumber'] as String? ?? '',
        address: j['address'] as String? ?? '',
        emergencyName: j['emergencyName'] as String? ?? '',
        emergencyPhone: j['emergencyPhone'] as String? ?? '',
      );
}

class WorkerProfileStore extends StateNotifier<Map<String, WorkerProfile>> {
  WorkerProfileStore({this.persist = true, this.repo}) : super(const {}) {
    if (persist) _load();
  }

  /// When false (tests), SharedPreferences is skipped entirely so the
  /// in-memory behavior can be asserted in isolation (the engines' pattern).
  final bool persist;

  /// The server store for THIS worker's own profile (`workerProfiles/{uid}`)
  /// when USER_DATA_SERVER is on for a real signed-in worker; null (the default)
  /// ⇒ the SharedPreferences path, byte-identical. Injected by
  /// [workerProfileProvider]. Single-doc + self-only: the loaded profile is
  /// re-keyed by the uid, and since `session.username == uid` for a real worker
  /// the UI read `map[session.username]` still resolves.
  final WorkerProfileRepository? repo;

  /// One-shot guard (the board_auth idiom, ticket #24): once [save] has
  /// written state, a late async `_load()` becomes non-destructive.
  bool _userTouched = false;

  Future<void> _load() async {
    final r = repo;
    if (r != null) {
      // Server path (USER_DATA_SERVER): this worker's profile lives at
      // `workerProfiles/{uid}`, re-keyed by the uid so `map[session.username]`
      // (== map[uid] for a real worker) resolves. Absent ⇒ keep the empty map
      // (every field falls back honestly, exactly like the local raw == null).
      try {
        final p = await r.load();
        if (!mounted || _userTouched || p == null) return;
        state = {r.uid: p};
      } on Object catch (_) {
        // Absent/unreadable — keep the empty map.
      }
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(kWorkerProfileKey);
      if (raw == null || raw.isEmpty) return;
      if (_userTouched) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted || _userTouched) return;
      state = {
        for (final e in m.entries)
          if (e.value is Map)
            e.key: WorkerProfile.fromJson(
              (e.value as Map).cast<String, dynamic>(),
            ),
      };
    } on Object catch (_) {
      // Corrupt value — keep the empty map (every field falls back honestly).
    }
  }

  /// True when the write actually landed; false on a storage failure —
  /// most commonly the web localStorage quota rejecting a too-large photo
  /// data-URL. Honest: the caller must NOT pretend the profile was saved.
  Future<bool> _persist() async {
    final r = repo;
    if (r != null) {
      // Server path: mirror THIS worker's profile to `workerProfiles/{uid}`.
      // Firestore has no localStorage photo-quota, so the write is optimistic —
      // return true (a rare server failure is swallowed, never rolls back the
      // UI; the forms/certs migrations take the same optimistic stance).
      try {
        await r.save(state[r.uid] ?? const WorkerProfile());
      } on Object catch (_) {}
      return true;
    }
    if (!persist) return true; // tests: in-memory only, nothing can fail
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        kWorkerProfileKey,
        jsonEncode({for (final e in state.entries) e.key: e.value.toJson()}),
      );
    } on Object catch (_) {
      return false; // quota exceeded / platform failure — nothing persisted
    }
  }

  /// Save [profile] as [username]'s overrides (the whole record at once —
  /// the edit sheet collects all fields, then commits in one write).
  ///
  /// Returns false when the persist FAILED (e.g. the localStorage quota
  /// rejected an oversized photo) — the in-memory state is rolled back so
  /// the UI never shows a profile that did not actually survive a reload.
  Future<bool> save(String username, WorkerProfile profile) async {
    _userTouched = true;
    final before = state;
    state = {...state, username: profile};
    final ok = await _persist();
    if (!ok && mounted) state = before;
    return ok;
  }
}

/// `username → profile` overrides for every worker who edited their profile.
/// Read with `ref.watch(workerProfileProvider)[session.username]` and fall
/// back to `const WorkerProfile()` when absent.
final workerProfileProvider =
    StateNotifierProvider<WorkerProfileStore, Map<String, WorkerProfile>>(
  (ref) => WorkerProfileStore(repo: ref.watch(workerProfileRepositoryProvider)),
);
