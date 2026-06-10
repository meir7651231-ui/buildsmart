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
  });

  final String id;

  /// Board login username (`ran` / `omer` / `demo`).
  final String username;

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
    );
  }
}

class WorkerCertsNotifier extends StateNotifier<List<WorkerCert>> {
  WorkerCertsNotifier() : super(const []) {
    _load();
  }

  /// One-shot guard (the board_auth idiom): once an add/remove has written
  /// state, a late `_load()` becomes non-destructive.
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kWorkerCertsKey);
    if (raw == null || _userTouched) return;
    try {
      final list = jsonDecode(raw) as List;
      if (_userTouched) return;
      state = [
        for (final e in list)
          if (WorkerCert.tryFromJson(e) case final c?) c,
      ];
    } on Object catch (_) {
      // Corrupt payload — keep the empty wallet.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kWorkerCertsKey,
      jsonEncode([for (final c in state) c.toJson()]),
    );
  }

  /// Add a certificate to [username]'s wallet. Returns the created cert.
  WorkerCert add({
    required String username,
    required String name,
    required String issuer,
    required DateTime expiry,
    String? photo,
  }) {
    _userTouched = true;
    final cert = WorkerCert(
      id: 'cert-${DateTime.now().microsecondsSinceEpoch}',
      username: username,
      name: name.trim(),
      issuer: issuer.trim(),
      expiry: expiry,
      addedTs: DateTime.now(),
      photo: photo,
    );
    state = [...state, cert];
    _persist();
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
