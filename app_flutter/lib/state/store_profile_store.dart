// #87.1 · STORE PROFILE STORE (F-18 / חוזה 8) — per-username editable business
// profile for the supplier board's אזור-אישי: שם עסק, טלפון, כתובת, ח.פ.
// ולוגו (a data-URL captured via `services/task_photo.dart`). שעות-פעילות is
// deliberately NOT here — it stays on the legacy supplierSettingsProvider
// seam (store_dashboard_screen.dart) as its single remaining owner, outside
// the cross-file StoreProfile contract.
//
// The store holds ONLY the supplier's explicit OVERRIDES (אין המצאות): an
// empty `businessName` falls back to the live [BoardSession.displayName] in
// the UI (and the dashboard header falls further to the kStores demo seed —
// F-20); empty phone/address/businessId simply don't render; a null logo
// shows the default 🏪 avatar.
//
// Persisted as a `username → profile` map under [kStoreProfileKey] in the
// exact worker_profile_store.dart pattern: lazy `_load()` + the one-shot
// `_userTouched` guard (ticket #24), and an AWAITED `save()` → `Future<bool>`
// with rollback so a web-quota failure (oversized logo) never fakes success.
//
// MIGRATION (F-18.3, one-time + honest): the legacy bs.supplier-settings.v1
// record was a single GLOBAL profile — every store session (lipskey / demo)
// read and overwrote the same record. On load, any known store username that
// has no entry of its own yet is seeded IN-MEMORY from that legacy record
// (each of them really did see this data before), and the first save()
// materializes it under the new keyed map. The legacy key is NEVER deleted.
//
// This file also hosts the supplier's certificate wallet provider (#87.3):
// the shared WorkerCertsNotifier re-instantiated with the store-scoped key —
// no model duplication, and no leakage through the shared `demo` username.
//
// SERVER-SWAP: becomes the server-side business profile (+ verified business
// certificates) once the backend lands; the provider surface (read map /
// `save`) stays identical.

import 'dart:convert';

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/repositories/store_profile_repository.dart';
import 'package:buildsmart/data/repositories/worker_certs_repository.dart';
import 'package:buildsmart/state/board_auth.dart' show BoardRole;
import 'package:buildsmart/state/worker_certs.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// One import serves the store screens: the providers below + the shared cert
// model/status they expose (no duplicated model code anywhere).
export 'package:buildsmart/state/worker_certs.dart'
    show CertExpiryStatus, WorkerCert;

/// SharedPreferences key (versioned like every other `bs.*.v1` key).
const String kStoreProfileKey = 'bs.store-profile.v1';

/// The LEGACY global supplier-settings key (bs.supplier-settings.v1,
/// store_dashboard_screen.dart) — read here ONCE for the honest migration;
/// never written and never deleted by this store.
const String kLegacySupplierSettingsKey = 'bs.supplier-settings.v1';

// ─── store certificate wallet (#87.3) ────────────────────────────────────────

/// Supplier business-certificate wallet — same payload shape as
/// bs.worker-certs.v1, store-scoped key (mandatory: the shared `demo`
/// username would otherwise leak certificates across boards).
const String kStoreCertsKey = 'bs.store-certs.v1';

/// Quick-add presets for the business-certificate wallet (#87.3). The preset
/// chips pre-fill the NAME field ONLY — issuer and expiry stay user input
/// (אין המצאות: no invented issuer, no invented dates).
const List<String> kStoreCertPresets = ['רישיון עסק', 'ביטוח עסק'];

/// The supplier business-certificate wallet — persisted under
/// [kStoreCertsKey]; expiry traffic-light via [WorkerCert.statusAt] as-is.
final storeCertsProvider =
    StateNotifierProvider<WorkerCertsNotifier, List<WorkerCert>>(
  (ref) => WorkerCertsNotifier(
    storageKey: kStoreCertsKey,
    repo: ref.watch(storeCertsRepositoryProvider),
  ),
);

// ─── business profile model ──────────────────────────────────────────────────

/// One supplier's editable business profile. Every field is an OPTIONAL
/// override: `businessName == ''` → the UI falls back honestly (session
/// displayName → kStores demo seed); `logo == null` → the default 🏪 avatar.
class StoreProfile {
  const StoreProfile({
    this.businessName = '',
    this.phone = '',
    this.address = '',
    this.businessId = '',
    this.logo,
  });

  /// Business display-name override; `''` means "use the honest fallback".
  final String businessName;

  /// Business phone (validated as an Israeli mobile in the edit UI); `''` = unset.
  final String phone;

  /// Business address free-text; `''` = unset.
  final String address;

  /// ח.פ. / ע.מ. — 9 digits (format-validated in the edit UI); `''` = unset.
  final String businessId;

  /// Business logo as a data-URL (`data:image/...;base64,…`), or null.
  final String? logo;

  StoreProfile copyWith({
    String? businessName,
    String? phone,
    String? address,
    String? businessId,
    Object? logo = _sentinel,
  }) =>
      StoreProfile(
        businessName: businessName ?? this.businessName,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        businessId: businessId ?? this.businessId,
        logo: logo == _sentinel ? this.logo : logo as String?,
      );

  static const _sentinel = Object();

  /// JSON keys intentionally MATCH the legacy bs.supplier-settings.v1 payload
  /// ('name'/'bid'/'phone'/'address'/'logo') so the one-time migration
  /// decodes the legacy record with this same factory (the legacy 'hours'
  /// key is simply ignored — it keeps living on the legacy seam).
  Map<String, dynamic> toJson() => {
        'name': businessName,
        'phone': phone,
        'address': address,
        'bid': businessId,
        if (logo != null) 'logo': logo,
      };

  /// Defensive decode — a wrong-typed field falls back to its honest empty
  /// default, never a crash (חוק tryFromJson הגנתי).
  factory StoreProfile.fromJson(Map<String, dynamic> j) => StoreProfile(
        businessName: j['name'] is String ? j['name'] as String : '',
        phone: j['phone'] is String ? j['phone'] as String : '',
        address: j['address'] is String ? j['address'] as String : '',
        businessId: j['bid'] is String ? j['bid'] as String : '',
        logo: j['logo'] is String ? j['logo'] as String : null,
      );
}

// ─── store ───────────────────────────────────────────────────────────────────

class StoreProfileStore extends StateNotifier<Map<String, StoreProfile>> {
  StoreProfileStore({this.persist = true, this.repo}) : super(const {}) {
    if (persist) _load();
  }

  /// When false (tests), SharedPreferences is skipped entirely so the
  /// in-memory behavior can be asserted in isolation (the engines' pattern).
  final bool persist;

  /// The server store for THIS store's own business profile (`storeProfiles/{uid}`)
  /// when USER_DATA_SERVER is on for a real signed-in store; null (the default) ⇒
  /// the SharedPreferences path, byte-identical. Injected by [storeProfileProvider].
  /// Single-doc + self-only: the loaded profile is re-keyed by the uid (since
  /// `session.username == uid` for a real store). The legacy-global (F-18.3) seed
  /// is SKIPPED on the server path — a real store starts from its own server doc.
  final StoreProfileRepository? repo;

  /// One-shot guard (the board_auth idiom, ticket #24): once [save] has
  /// written state, a late async `_load()` becomes non-destructive.
  bool _userTouched = false;

  /// Test hook (the F-9 pattern): inject a failing persist to assert the
  /// rollback path without mocking the platform channel.
  @visibleForTesting
  Future<bool> Function()? debugPersistOverride;

  /// The store usernames that could have seen the legacy GLOBAL record: the
  /// seeded store accounts + the shared `demo` session (board_auth enterDemo).
  static List<String> get _storeUsernames => [
        for (final a in kBoardAccounts)
          if (a.role == BoardRole.store) a.username,
        'demo',
      ];

  Future<void> _load() async {
    final r = repo;
    if (r != null) {
      // Server path (USER_DATA_SERVER): this store's profile lives at
      // `storeProfiles/{uid}`, re-keyed by the uid so `map[session.username]`
      // (== map[uid] for a real store) resolves. NO legacy-global seed — a real
      // store starts from its own server doc (the F-18.3 device migration is a
      // local-only affordance). Absent ⇒ keep the empty map (honest fallback).
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
      if (_userTouched) return;

      var loaded = <String, StoreProfile>{};
      final raw = prefs.getString(kStoreProfileKey);
      if (raw != null && raw.isNotEmpty) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        loaded = {
          for (final e in m.entries)
            if (e.value is Map)
              e.key: StoreProfile.fromJson(
                (e.value as Map).cast<String, dynamic>(),
              ),
        };
      }

      // One-time honest migration (F-18.3): the legacy record was global —
      // seed it (in-memory) for every known store username that has no entry
      // of its own yet. The legacy key is left in place, NOT deleted; the
      // first save() writes the seeded entry into the new keyed map.
      final legacy = _readLegacy(prefs);
      if (legacy != null) {
        for (final u in _storeUsernames) {
          if (!loaded.containsKey(u)) {
            loaded = {...loaded, u: legacy};
          }
        }
      }

      if (!mounted || _userTouched) return;
      if (loaded.isNotEmpty) state = loaded;
    } on Object catch (_) {
      // Corrupt value — keep the empty map (every field falls back honestly).
    }
  }

  /// Decode the legacy GLOBAL bs.supplier-settings.v1 payload, or null when
  /// absent/corrupt (no migration then — nothing is invented).
  StoreProfile? _readLegacy(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(kLegacySupplierSettingsKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return StoreProfile.fromJson(decoded.cast<String, dynamic>());
    } on Object catch (_) {
      return null; // corrupt legacy payload — skip the migration honestly
    }
  }

  /// True when the write actually landed; false on a storage failure —
  /// most commonly the web localStorage quota rejecting a too-large logo
  /// data-URL. Honest: the caller must NOT pretend the profile was saved.
  Future<bool> _persist() async {
    if (debugPersistOverride != null) return debugPersistOverride!();
    final r = repo;
    if (r != null) {
      // Server path: mirror THIS store's business profile to `storeProfiles/{uid}`.
      // Firestore has no localStorage logo-quota, so the write is optimistic —
      // return true (a rare server failure is swallowed, never rolls back the UI;
      // the worker/courier_profile migrations take the same optimistic stance).
      try {
        await r.save(state[r.uid] ?? const StoreProfile());
      } on Object catch (_) {}
      return true;
    }
    if (!persist) return true; // tests: in-memory only, nothing can fail
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        kStoreProfileKey,
        jsonEncode({for (final e in state.entries) e.key: e.value.toJson()}),
      );
    } on Object catch (_) {
      return false; // quota exceeded / platform failure — nothing persisted
    }
  }

  /// Save [profile] as [username]'s business profile (the whole record at
  /// once — the edit sheet collects all fields, then commits in one write;
  /// NOT persist-per-keystroke).
  ///
  /// Returns false when the persist FAILED (e.g. the localStorage quota
  /// rejected an oversized logo) — the in-memory state is rolled back so the
  /// UI never shows a profile that did not actually survive a reload.
  Future<bool> save(String username, StoreProfile profile) async {
    _userTouched = true;
    final before = state;
    state = {...state, username: profile};
    final ok = await _persist();
    if (!ok && mounted) state = before;
    return ok;
  }
}

/// `username → business profile` for every supplier account that edited its
/// profile (plus the in-memory legacy seeds — see the migration note above).
/// Read with `ref.watch(storeProfileProvider)[session.username]` and fall
/// back to `const StoreProfile()` when absent. logout() never touches other
/// usernames' records.
final storeProfileProvider =
    StateNotifierProvider<StoreProfileStore, Map<String, StoreProfile>>(
  (ref) => StoreProfileStore(repo: ref.watch(storeProfileRepositoryProvider)),
);
