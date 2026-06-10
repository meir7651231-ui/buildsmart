import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// cluster #85ח · בקשות חופשה — the worker files a request (טפסים → בקשת
/// חופשה), the MANAGER decides it in מרכז השליטה → ניהול → בקשות חופשה. Both
/// boards read THIS shared provider, so a decision flips the worker's own
/// list live (the cross-persona pattern of `worker_tasks_engine.dart`).
///
/// Persisted to SharedPreferences under [kVacationRequestsKey] with the
/// `board_auth.dart` idiom (lazy `_load()` + `_userTouched` guard).
/// SERVER-SWAP: becomes a server-side HR queue when the backend lands.

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kVacationRequestsKey = 'bs.vacation-requests.v1';

/// Request lifecycle — `pending` until the manager decides.
const String kVacationPending = 'pending';
const String kVacationApproved = 'approved';
const String kVacationRejected = 'rejected';

class VacationRequest {
  const VacationRequest({
    required this.id,
    required this.username,
    required this.workerName,
    required this.from,
    required this.to,
    required this.reason,
    required this.createdTs,
    this.status = kVacationPending,
    this.decidedTs,
  });

  final String id;

  /// Board login username (`ran` / `omer` / `demo`).
  final String username;

  /// Hebrew display name shown to the manager (straight off the BoardSession).
  final String workerName;

  /// Inclusive vacation range.
  final DateTime from;
  final DateTime to;

  /// Free-text reason — may be empty.
  final String reason;

  final DateTime createdTs;

  /// [kVacationPending] · [kVacationApproved] · [kVacationRejected].
  final String status;

  /// When the manager decided — null while [kVacationPending].
  final DateTime? decidedTs;

  /// `12.6.2026–14.6.2026` — the human range both boards render.
  String get range => from.isAtSameMomentAs(to) || _sameDay(from, to)
      ? _d(from)
      : '${_d(from)}–${_d(to)}';

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _d(DateTime d) => '${d.day}.${d.month}.${d.year}';

  VacationRequest copyWith({String? status, DateTime? decidedTs}) =>
      VacationRequest(
        id: id,
        username: username,
        workerName: workerName,
        from: from,
        to: to,
        reason: reason,
        createdTs: createdTs,
        status: status ?? this.status,
        decidedTs: decidedTs ?? this.decidedTs,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'workerName': workerName,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'reason': reason,
        'createdTs': createdTs.toIso8601String(),
        'status': status,
        'decidedTs': decidedTs?.toIso8601String(),
      };

  /// Defensive decode — a malformed entry is dropped, never crashes the load.
  static VacationRequest? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final username = raw['username'];
    final workerName = raw['workerName'];
    final from = DateTime.tryParse('${raw['from']}');
    final to = DateTime.tryParse('${raw['to']}');
    final created = DateTime.tryParse('${raw['createdTs']}');
    if (id is! String ||
        username is! String ||
        workerName is! String ||
        from == null ||
        to == null ||
        created == null) {
      return null;
    }
    return VacationRequest(
      id: id,
      username: username,
      workerName: workerName,
      from: from,
      to: to,
      reason: raw['reason'] is String ? raw['reason'] as String : '',
      createdTs: created,
      status: raw['status'] is String ? raw['status'] as String : kVacationPending,
      decidedTs: DateTime.tryParse('${raw['decidedTs']}'),
    );
  }
}

class VacationRequestsNotifier extends StateNotifier<List<VacationRequest>> {
  VacationRequestsNotifier() : super(const []) {
    _load();
  }

  /// One-shot guard (the board_auth idiom): once a submit/decision has written
  /// state, a late `_load()` becomes non-destructive.
  bool _userTouched = false;

  /// Monotonic id suffix — on web DateTime precision is ~1ms, so two rapid
  /// submits could collide on a timestamp-only id (a decision would then hit
  /// BOTH requests; caught by the 'decision touches ONLY the given id' test).
  int _seq = 0;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kVacationRequestsKey);
    if (raw == null || _userTouched) return;
    try {
      final list = jsonDecode(raw) as List;
      if (_userTouched) return;
      state = [
        for (final e in list)
          if (VacationRequest.tryFromJson(e) case final r?) r,
      ];
    } on Object catch (_) {
      // Corrupt payload — keep the empty queue.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kVacationRequestsKey,
      jsonEncode([for (final r in state) r.toJson()]),
    );
  }

  /// WORKER write — file a new pending request. Returns the created request.
  VacationRequest submit({
    required String username,
    required String workerName,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) {
    _userTouched = true;
    _seq++;
    final r = VacationRequest(
      id: 'vac-${DateTime.now().microsecondsSinceEpoch}-$_seq',
      username: username,
      workerName: workerName,
      from: from,
      to: to,
      reason: reason.trim(),
      createdTs: DateTime.now(),
    );
    state = [...state, r];
    _persist();
    return r;
  }

  /// MANAGER write — approve a pending request (no-op on a decided one).
  void approve(String id) => _decide(id, kVacationApproved);

  /// MANAGER write — reject a pending request (no-op on a decided one).
  void reject(String id) => _decide(id, kVacationRejected);

  void _decide(String id, String status) {
    _userTouched = true;
    state = [
      for (final r in state)
        if (r.id == id && r.status == kVacationPending)
          r.copyWith(status: status, decidedTs: DateTime.now())
        else
          r,
    ];
    _persist();
  }
}

/// The shared vacation-request queue — the worker board writes (submit), the
/// manager board decides (approve/reject), both watch the same list.
final vacationRequestsProvider =
    StateNotifierProvider<VacationRequestsNotifier, List<VacationRequest>>(
  (ref) => VacationRequestsNotifier(),
);
