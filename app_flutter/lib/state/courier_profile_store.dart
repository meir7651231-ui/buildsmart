// #86.1 · COURIER PROFILE STORE (F-9) — per-username editable profile for the
// courier board's אזור-אישי: display-name, phone, preferred haul type (סוג
// רכב מועדף, an id out of `kHaulTypes`) and a profile photo (a data-URL
// captured via `services/task_photo.dart`).
//
// Cloned one-to-one from the canonical `worker_profile_store.dart` template —
// the ONLY full implementation of all three required pieces: the one-shot
// `_userTouched` guard before the first write, the double re-check inside
// `_load()` (after the await AND after jsonDecode), and an awaited `save()`
// returning bool with a mounted-guarded rollback (ticket #24 + honest
// quota-fail reporting).
//
// The store holds ONLY the courier's explicit OVERRIDES (אין המצאות): an
// empty `displayName` falls back to the live [BoardSession.displayName] in
// the UI, an empty phone simply doesn't render, a null photo shows the
// default 🛵 avatar, and an empty `preferredHaul` means "no vehicle chosen" —
// it is NEVER guessed via `haulInfo()` (whose silent `kHaulTypes.first`
// fallback would invent a preference the courier did not pick).
//
// `preferredHaul` is a DISPLAY preference only: it may seed the profile's
// vehicle-eligible "בדרך" semantics — it must NOT influence the shared order
// engine or any store/manager sums.
//
// Persisted as a `username → profile` map under [kCourierProfileKey].
//
// SERVER-SWAP: becomes the server-side courier profile once the backend
// lands; the provider surface (read map / `save`) stays identical.

import 'dart:convert';

import 'package:buildsmart/data/supplier_data.dart' show kVehicleRank;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key (versioned like every other `bs.*.v1` key).
const String kCourierProfileKey = 'bs.courier-profile.v1';

/// One courier's editable profile. Every field is an OPTIONAL override:
/// `displayName == ''` → the UI falls back to [BoardSession.displayName];
/// `photo == null` → the default 🛵 avatar disc; `preferredHaul == ''` → no
/// preferred vehicle was chosen (honest empty — never invented).
class CourierProfile {
  const CourierProfile({
    this.displayName = '',
    this.phone = '',
    this.preferredHaul = '',
    this.photo,
  });

  /// Display-name override; `''` means "use [BoardSession.displayName]".
  final String displayName;

  /// Courier phone (validated as an Israeli mobile in the edit UI); `''` = unset.
  final String phone;

  /// Preferred haul-type id — one of the `kHaulTypes` ids
  /// (`'small' | 'van' | 'truck'`), or `''` when none was chosen.
  /// Persisted as the id, NEVER the Hebrew name. Consumers must not run an
  /// unvalidated value through `haulInfo()` (its `kHaulTypes.first` fallback
  /// invents a vehicle) — [normalizeHaul] already guarantees validity here.
  final String preferredHaul;

  /// Profile photo as a data-URL (`data:image/...;base64,…`), or null.
  final String? photo;

  /// [id] when it is a real haul-type id (validated against [kVehicleRank]),
  /// otherwise `''` (not-chosen) — the honest alternative to the inventing
  /// `haulInfo()` fallback.
  static String normalizeHaul(Object? id) =>
      id is String && kVehicleRank.containsKey(id) ? id : '';

  CourierProfile copyWith({
    String? displayName,
    String? phone,
    String? preferredHaul,
    Object? photo = _sentinel,
  }) =>
      CourierProfile(
        displayName: displayName ?? this.displayName,
        phone: phone ?? this.phone,
        preferredHaul: preferredHaul ?? this.preferredHaul,
        photo: photo == _sentinel ? this.photo : photo as String?,
      );

  static const _sentinel = Object();

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'phone': phone,
        'preferredHaul': preferredHaul,
        'photo': photo,
      };

  factory CourierProfile.fromJson(Map<String, dynamic> j) => CourierProfile(
        displayName: j['displayName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        // A persisted value that is not a known haul id decays honestly to ''
        // (not-chosen) — never to an invented kHaulTypes.first.
        preferredHaul: normalizeHaul(j['preferredHaul']),
        photo: j['photo'] is String ? j['photo'] as String : null,
      );
}

class CourierProfileStore extends StateNotifier<Map<String, CourierProfile>> {
  CourierProfileStore({this.persist = true}) : super(const {}) {
    if (persist) _load();
  }

  /// When false (tests), SharedPreferences is skipped entirely so the
  /// in-memory behavior can be asserted in isolation (the engines' pattern).
  final bool persist;

  /// Test seam (F-9): when set, [_persist] delegates here instead of touching
  /// SharedPreferences — return `false` to exercise the REAL rollback path
  /// (state restored to `before`, other usernames untouched).
  @visibleForTesting
  Future<bool> Function()? debugPersistOverride;

  /// One-shot guard (the board_auth idiom, ticket #24): once [save] has
  /// written state, a late async `_load()` becomes non-destructive.
  bool _userTouched = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kCourierProfileKey);
      if (raw == null || raw.isEmpty) return;
      if (_userTouched) return; // re-check after the await (ticket #24)
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (_userTouched) return; // re-check after jsonDecode (ticket #24)
      state = {
        for (final e in m.entries)
          if (e.value is Map)
            e.key: CourierProfile.fromJson(
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
    final override = debugPersistOverride;
    if (override != null) return override();
    if (!persist) return true; // tests: in-memory only, nothing can fail
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        kCourierProfileKey,
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
  Future<bool> save(String username, CourierProfile profile) async {
    _userTouched = true;
    final before = state;
    state = {
      ...state,
      // Defensive normalization at the write seam too — a save can never
      // smuggle an unknown haul id into the persisted map.
      username: profile.copyWith(
        preferredHaul: CourierProfile.normalizeHaul(profile.preferredHaul),
      ),
    };
    final ok = await _persist();
    if (!ok && mounted) state = before;
    return ok;
  }
}

/// `username → profile` overrides for every courier who edited their profile.
/// Read narrowly:
/// `ref.watch(courierProfileProvider.select((m) => m[session.username] ?? const CourierProfile()))`.
final courierProfileProvider =
    StateNotifierProvider<CourierProfileStore, Map<String, CourierProfile>>(
  (ref) => CourierProfileStore(),
);
