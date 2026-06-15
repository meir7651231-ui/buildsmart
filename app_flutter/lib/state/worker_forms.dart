import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// cluster #85ח · טפסים עובד — the worker's structured digital forms:
///   • [Form101] — one per username per tax year (saved, optionally sent to
///     the contractor through the chat engine). HONEST: this is a structured
///     DIGITAL form, NOT the official רשות-המסים PDF. SERVER-SWAP: official
///     filing (signed 101 PDF) lands with the server connection.
///   • [SickNote] — uploaded sick-leave photo confirmations (the photo ref
///     comes from the camera seam, `services/task_photo.dart`).
///
/// Persisted together under [kWorkerFormsKey] with the `board_auth.dart`
/// idiom (lazy `_load()` + one-shot `_userTouched` guard).

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kWorkerFormsKey = 'bs.worker-forms.v1';

/// Standard declaration text shown above the signature on every worker form
/// (101 / חופשה / מחלה) — the worker confirms the details are true before
/// signing/sending. SERVER-SWAP: the official wording lands with the backend.
const String kDeclarationText =
    'אני מצהיר/ה בזאת שכל הפרטים שמסרתי נכונים, מלאים ומדויקים בהתאם לחוק.';

/// One saved טופס-101 — keyed by (username, year).
class Form101 {
  const Form101({
    required this.username,
    required this.year,
    required this.fullName,
    required this.idNumber,
    required this.phone,
    required this.specialty,
    required this.maritalStatus,
    required this.savedTs,
    this.sentTs,
    this.signature = '',
    this.declared = false,
    this.employerName = '',
    this.employerBusinessId = '',
    this.employerAddress = '',
  });

  final String username;
  final int year;
  final String fullName;

  /// ת.ז — 9 digits (format-validated in the screen).
  final String idNumber;

  final String phone;

  /// מקצוע/התמחות — free text the worker fills (no seed profile field exists
  /// to pre-fill it from; אין המצאות).
  final String specialty;

  /// רווק/ה · נשוי/אה · גרוש/ה · אלמן/ה.
  final String maritalStatus;

  final DateTime savedTs;

  /// When the worker sent the form to the contractor — null until sent.
  final DateTime? sentTs;

  /// PNG data-URL of the worker's handwritten signature (`signature_pad.dart`)
  /// — empty until signed. Back-compat: old persisted forms have no signature.
  final String signature;

  /// Whether the worker ticked the [kDeclarationText] declaration checkbox.
  /// Back-compat: old persisted forms decode as `false`.
  final bool declared;

  /// EMPLOYER (מעסיק) autofill — pulled from the contractor's profile in the
  /// screen (NO fabrication; empty when the profile has no data). Persisted on
  /// the form so a sent/printed copy keeps the snapshot. Back-compat: ''.
  final String employerName;
  final String employerBusinessId;
  final String employerAddress;

  Form101 copyWith({
    String? username,
    int? year,
    String? fullName,
    String? idNumber,
    String? phone,
    String? specialty,
    String? maritalStatus,
    DateTime? savedTs,
    DateTime? sentTs,
    String? signature,
    bool? declared,
    String? employerName,
    String? employerBusinessId,
    String? employerAddress,
  }) =>
      Form101(
        username: username ?? this.username,
        year: year ?? this.year,
        fullName: fullName ?? this.fullName,
        idNumber: idNumber ?? this.idNumber,
        phone: phone ?? this.phone,
        specialty: specialty ?? this.specialty,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        savedTs: savedTs ?? this.savedTs,
        sentTs: sentTs ?? this.sentTs,
        signature: signature ?? this.signature,
        declared: declared ?? this.declared,
        employerName: employerName ?? this.employerName,
        employerBusinessId: employerBusinessId ?? this.employerBusinessId,
        employerAddress: employerAddress ?? this.employerAddress,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'year': year,
        'fullName': fullName,
        'idNumber': idNumber,
        'phone': phone,
        'specialty': specialty,
        'maritalStatus': maritalStatus,
        'savedTs': savedTs.toIso8601String(),
        'sentTs': sentTs?.toIso8601String(),
        'signature': signature,
        'declared': declared,
        'employerName': employerName,
        'employerBusinessId': employerBusinessId,
        'employerAddress': employerAddress,
      };

  static Form101? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final username = raw['username'];
    final year = raw['year'];
    final saved = DateTime.tryParse('${raw['savedTs']}');
    if (username is! String || year is! int || saved == null) return null;
    String s(Object? v) => v is String ? v : '';
    return Form101(
      username: username,
      year: year,
      fullName: s(raw['fullName']),
      idNumber: s(raw['idNumber']),
      phone: s(raw['phone']),
      specialty: s(raw['specialty']),
      maritalStatus: s(raw['maritalStatus']),
      savedTs: saved,
      sentTs: DateTime.tryParse('${raw['sentTs']}'),
      signature: s(raw['signature']),
      declared: raw['declared'] == true,
      employerName: s(raw['employerName']),
      employerBusinessId: s(raw['employerBusinessId']),
      employerAddress: s(raw['employerAddress']),
    );
  }
}

/// One uploaded sick-leave confirmation photo.
class SickNote {
  const SickNote({
    required this.id,
    required this.username,
    required this.ts,
    required this.photo,
    this.signature = '',
    this.declared = false,
  });

  final String id;
  final String username;
  final DateTime ts;

  /// The photo reference returned by the camera seam (`pickTaskPhoto`).
  final String photo;

  /// PNG data-URL of the worker's handwritten signature — empty until signed.
  /// Back-compat: old persisted notes have no signature.
  final String signature;

  /// Whether the worker ticked the [kDeclarationText] declaration checkbox.
  /// Back-compat: old persisted notes decode as `false`.
  final bool declared;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'ts': ts.toIso8601String(),
        'photo': photo,
        'signature': signature,
        'declared': declared,
      };

  static SickNote? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final username = raw['username'];
    final photo = raw['photo'];
    final ts = DateTime.tryParse('${raw['ts']}');
    if (id is! String || username is! String || photo is! String || ts == null) {
      return null;
    }
    return SickNote(
      id: id,
      username: username,
      ts: ts,
      photo: photo,
      signature: raw['signature'] is String ? raw['signature'] as String : '',
      declared: raw['declared'] == true,
    );
  }
}

/// The combined forms store — 101 forms + sick-note uploads.
class WorkerFormsState {
  const WorkerFormsState({
    this.forms = const [],
    this.sickNotes = const [],
  });

  factory WorkerFormsState.fromJson(Map<String, dynamic> j) => WorkerFormsState(
        forms: [
          if (j['forms'] is List)
            for (final e in j['forms'] as List)
              if (Form101.tryFromJson(e) case final f?) f,
        ],
        sickNotes: [
          if (j['sick'] is List)
            for (final e in j['sick'] as List)
              if (SickNote.tryFromJson(e) case final s?) s,
        ],
      );

  final List<Form101> forms;
  final List<SickNote> sickNotes;

  /// The saved 101 of (username, year), or null.
  Form101? form101For(String username, int year) {
    for (final f in forms) {
      if (f.username == username && f.year == year) return f;
    }
    return null;
  }

  /// [username]'s sick-note uploads, newest first.
  List<SickNote> sickNotesFor(String username) =>
      sickNotes.where((s) => s.username == username).toList()
        ..sort((a, b) => b.ts.compareTo(a.ts));

  WorkerFormsState copyWith({
    List<Form101>? forms,
    List<SickNote>? sickNotes,
  }) =>
      WorkerFormsState(
        forms: forms ?? this.forms,
        sickNotes: sickNotes ?? this.sickNotes,
      );

  Map<String, dynamic> toJson() => {
        'forms': [for (final f in forms) f.toJson()],
        'sick': [for (final s in sickNotes) s.toJson()],
      };
}

class WorkerFormsNotifier extends StateNotifier<WorkerFormsState> {
  WorkerFormsNotifier({this.storageKey = kWorkerFormsKey})
      : super(const WorkerFormsState()) {
    _load();
  }

  /// The SharedPreferences key this notifier reads/writes. Defaults to the
  /// worker store; the courier board passes `'bs.courier-forms.v1'` so the
  /// two roles never share forms (the shared `demo` username would otherwise
  /// leak forms across boards).
  final String storageKey;

  /// One-shot guard (the board_auth idiom): once a save has written state, a
  /// late `_load()` becomes non-destructive.
  bool _userTouched = false;

  /// Monotonic id suffix — web DateTime is ~1ms-precise, so two sick-note adds
  /// in the same millisecond would collide on a timestamp-only id, and
  /// `removeSickNote(id)` would then delete BOTH. Mirrors vacation_requests /
  /// worker_trainings.
  int _seq = 0;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final raw = prefs.getString(storageKey);
    if (raw == null || _userTouched) return;
    try {
      final decoded =
          WorkerFormsState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (!mounted || _userTouched) return;
      state = decoded;
    } on Object catch (_) {
      // Corrupt payload — keep the empty store.
    }
  }

  /// True when the write actually landed; false on a storage failure — most
  /// commonly the web localStorage quota rejecting a too-large sick-note
  /// photo data-URL. Honest: callers must NOT pretend the data was saved.
  Future<bool> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(storageKey, jsonEncode(state.toJson()));
    } on Object catch (_) {
      return false; // quota exceeded / platform failure — nothing persisted
    }
  }

  /// Save/replace the (username, year) 101 form. A re-save keeps an existing
  /// [Form101.sentTs] only if the caller passes it (a content edit after
  /// sending honestly clears the "sent" mark unless re-sent).
  void saveForm101(Form101 form) {
    _userTouched = true;
    state = state.copyWith(forms: [
      for (final f in state.forms)
        if (!(f.username == form.username && f.year == form.year)) f,
      form,
    ]);
    _persist();
  }

  /// Mark the (username, year) form as sent to the contractor (now).
  void markForm101Sent(String username, int year) {
    _userTouched = true;
    state = state.copyWith(forms: [
      for (final f in state.forms)
        if (f.username == username && f.year == year)
          f.copyWith(sentTs: DateTime.now())
        else
          f,
    ]);
    _persist();
  }

  /// Add a sick-note photo upload. Returns the created note, or null when
  /// the persist FAILED (e.g. the localStorage quota rejected an oversized
  /// photo data-URL) — the in-memory state is rolled back so the UI never
  /// shows an upload that would not survive a reload.
  Future<SickNote?> addSickNote({
    required String username,
    required String photo,
    String signature = '',
    bool declared = false,
  }) async {
    _userTouched = true;
    final note = SickNote(
      id: 'sick-${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
      username: username,
      ts: DateTime.now(),
      photo: photo,
      signature: signature,
      declared: declared,
    );
    final before = state;
    state = state.copyWith(sickNotes: [...state.sickNotes, note]);
    final ok = await _persist();
    if (!ok) {
      if (mounted) state = before;
      return null;
    }
    return note;
  }

  /// Remove an uploaded sick note (confirmed destructive in the UI).
  void removeSickNote(String id) {
    _userTouched = true;
    state = state.copyWith(
      sickNotes: [
        for (final s in state.sickNotes)
          if (s.id != id) s,
      ],
    );
    _persist();
  }
}

/// The worker forms store — 101 forms per year + sick-note uploads.
final workerFormsProvider =
    StateNotifierProvider<WorkerFormsNotifier, WorkerFormsState>(
  (ref) => WorkerFormsNotifier(),
);
