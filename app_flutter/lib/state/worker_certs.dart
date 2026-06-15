import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// cluster #85ח · ארנק תעודות מקצועיות — the worker's certificate wallet
/// (תיק בטיחות): name / issuer / expiry + an optional photo ref from the
/// camera seam. Expiry drives the red (expired) / amber (≤ a month) badge in
/// `worker_safety_screen.dart`.
///
/// Persisted under [kWorkerCertsKey] with the `board_auth.dart` idiom (lazy
/// `_load()` + one-shot `_userTouched` guard).
/// SERVER-SWAP: becomes the server's verified-certificates store when the
/// backend lands.

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kWorkerCertsKey = 'bs.worker-certs.v1';

/// Expiry traffic-light for a certificate, derived from [WorkerCert.expiry].
enum CertExpiryStatus { expired, expiringSoon, valid }

class WorkerCert {
  const WorkerCert({
    required this.id,
    required this.username,
    required this.name,
    required this.issuer,
    required this.expiry,
    required this.addedTs,
    this.photo,
    this.employerId = '',
  });

  final String id;

  /// Board login username (`ran` / `omer` / `demo`).
  final String username;

  /// Id of the contractor who EMPLOYS the worker (the worker→contractor LINK,
  /// `session.employerId`) — lets the contractor's view scope to THEIR workers
  /// (see [certsForEmployer]). Default `''` (field-economy: only serialised when
  /// non-empty). Back-compat: old persisted records carry no 'employerId' and
  /// decode as `''` (and are excluded from any non-empty employer query).
  final String employerId;

  /// e.g. "היתר עבודה בגובה".
  final String name;

  /// המנפיק — e.g. "משרד העבודה".
  final String issuer;

  /// Expiry date (date-only semantics — compared by calendar day).
  final DateTime expiry;

  final DateTime addedTs;

  /// Optional photo reference from the camera seam (`pickTaskPhoto`).
  final String? photo;

  /// Red = expired · amber = expires within 31 days · otherwise valid.
  CertExpiryStatus statusAt(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiry.year, expiry.month, expiry.day);
    if (exp.isBefore(today)) return CertExpiryStatus.expired;
    if (exp.difference(today).inDays <= 31) {
      return CertExpiryStatus.expiringSoon;
    }
    return CertExpiryStatus.valid;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'issuer': issuer,
        'expiry': expiry.toIso8601String(),
        'addedTs': addedTs.toIso8601String(),
        'photo': photo,
        if (employerId.isNotEmpty) 'employerId': employerId,
      };

  /// Defensive decode — a malformed entry is dropped, never crashes the load.
  static WorkerCert? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final username = raw['username'];
    final name = raw['name'];
    final expiry = DateTime.tryParse('${raw['expiry']}');
    final added = DateTime.tryParse('${raw['addedTs']}');
    if (id is! String ||
        username is! String ||
        name is! String ||
        expiry == null ||
        added == null) {
      return null;
    }
    return WorkerCert(
      id: id,
      username: username,
      name: name,
      issuer: raw['issuer'] is String ? raw['issuer'] as String : '',
      expiry: expiry,
      addedTs: added,
      photo: raw['photo'] is String ? raw['photo'] as String : null,
      employerId: raw['employerId'] is String ? raw['employerId'] as String : '',
    );
  }
}

class WorkerCertsNotifier extends StateNotifier<List<WorkerCert>> {
  WorkerCertsNotifier({this.storageKey = kWorkerCertsKey}) : super(const []) {
    _load();
  }

  /// The SharedPreferences key this notifier reads/writes. Defaults to the
  /// worker wallet; the courier board passes `'bs.courier-certs.v1'` so the
  /// two roles never share a wallet (the shared `demo` username would
  /// otherwise leak certificates across boards).
  final String storageKey;

  /// One-shot guard (the board_auth idiom): once an add/remove has written
  /// state, a late `_load()` becomes non-destructive.
  bool _userTouched = false;

  /// Monotonic id suffix — web DateTime is ~1ms-precise, so two adds in the same
  /// millisecond would collide on a timestamp-only id, and `remove(id)` (delete
  /// every row with that id) would then wipe BOTH. Mirrors vacation_requests /
  /// worker_trainings / material_requests.
  int _seq = 0;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final raw = prefs.getString(storageKey);
    if (raw == null || _userTouched) return;
    try {
      final list = jsonDecode(raw) as List;
      if (!mounted || _userTouched) return;
      state = [
        for (final e in list)
          if (WorkerCert.tryFromJson(e) case final c?) c,
      ];
    } on Object catch (_) {
      // Corrupt payload — keep the empty wallet.
    }
  }

  /// True when the write actually landed; false on a storage failure — most
  /// commonly the web localStorage quota rejecting a too-large certificate
  /// photo data-URL. Honest: callers must NOT pretend the cert was saved.
  Future<bool> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        storageKey,
        jsonEncode([for (final c in state) c.toJson()]),
      );
    } on Object catch (_) {
      return false; // quota exceeded / platform failure — nothing persisted
    }
  }

  /// Add a certificate to [username]'s wallet. Returns the created cert, or
  /// null when the persist FAILED (e.g. the localStorage quota rejected an
  /// oversized photo data-URL) — the in-memory state is rolled back so the
  /// UI never shows a cert that would not survive a reload.
  Future<WorkerCert?> add({
    required String username,
    required String name,
    required String issuer,
    required DateTime expiry,
    String? photo,
    String employerId = '',
  }) async {
    _userTouched = true;
    final cert = WorkerCert(
      id: 'cert-${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
      username: username,
      name: name.trim(),
      issuer: issuer.trim(),
      expiry: expiry,
      addedTs: DateTime.now(),
      photo: photo,
      employerId: employerId,
    );
    final before = state;
    state = [...state, cert];
    final ok = await _persist();
    if (!ok) {
      if (mounted) state = before;
      return null;
    }
    return cert;
  }

  /// Remove a certificate (confirmed destructive in the UI).
  void remove(String id) {
    _userTouched = true;
    state = [
      for (final c in state)
        if (c.id != id) c,
    ];
    _persist();
  }
}

/// The certificate wallet — screens filter by the logged username (#66).
final workerCertsProvider =
    StateNotifierProvider<WorkerCertsNotifier, List<WorkerCert>>(
  (ref) => WorkerCertsNotifier(),
);

/// The CONTRACTOR's view of their workers' certifications — every cert that
/// names this `employerId` (the worker→contractor link), newest-first.
/// Deterministic via `all.reversed` (insertion order; avoids createdTs-tie
/// instability). Read-only — the contractor does not edit worker certs.
/// Reuses [WorkerCert.statusAt] for the expiry traffic-light.
final certsForEmployer = Provider.family<List<WorkerCert>, String>((ref, employerId) {
  final all = ref.watch(workerCertsProvider);
  return [for (final c in all.reversed) if (c.employerId == employerId) c];
});
