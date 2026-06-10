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
class WorkerProfile {
  const WorkerProfile({
    this.name = '',
    this.phone = '',
    this.specialty = '',
    this.photo,
  });

  /// Display-name override; `''` means "use [BoardSession.displayName]".
  final String name;

  /// Worker phone (validated as an Israeli mobile in the edit UI); `''` = unset.
  final String phone;

  /// One of [kWorkerSpecialties], or `''` when none was chosen.
  final String specialty;

  /// Profile photo as a data-URL (`data:image/...;base64,…`), or null.
  final String? photo;

  WorkerProfile copyWith({
    String? name,
    String? phone,
    String? specialty,
    Object? photo = _sentinel,
  }) =>
      WorkerProfile(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        specialty: specialty ?? this.specialty,
        photo: photo == _sentinel ? this.photo : photo as String?,
      );

  static const _sentinel = Object();

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'specialty': specialty,
        'photo': photo,
      };

  factory WorkerProfile.fromJson(Map<String, dynamic> j) => WorkerProfile(
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        specialty: j['specialty'] as String? ?? '',
        photo: j['photo'] as String?,
      );
}

class WorkerProfileStore extends StateNotifier<Map<String, WorkerProfile>> {
  WorkerProfileStore({this.persist = true}) : super(const {}) {
    if (persist) _load();
  }

  /// When false (tests), SharedPreferences is skipped entirely so the
  /// in-memory behavior can be asserted in isolation (the engines' pattern).
  final bool persist;

  /// One-shot guard (the board_auth idiom, ticket #24): once [save] has
  /// written state, a late async `_load()` becomes non-destructive.
  bool _userTouched = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kWorkerProfileKey);
      if (raw == null || raw.isEmpty) return;
      if (_userTouched) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
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
  (ref) => WorkerProfileStore(),
);
