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

  Form101 copyWith({DateTime? sentTs}) => Form101(
        username: username,
        year: year,
        fullName: fullName,
        idNumber: idNumber,
        phone: phone,
        specialty: specialty,
        maritalStatus: maritalStatus,
        savedTs: savedTs,
        sentTs: sentTs ?? this.sentTs,
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
  });

  final String id;
  final String username;
  final DateTime ts;

  /// The photo reference returned by the camera seam (`pickTaskPhoto`).
  final String photo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'ts': ts.toIso8601String(),
        'photo': photo,
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
    return SickNote(id: id, username: username, ts: ts, photo: photo);
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
  WorkerFormsNotifier() : super(const WorkerFormsState()) {
    _load();
  }

  /// One-shot guard (the board_auth idiom): once a save has written state, a
  /// late `_load()` becomes non-destructive.
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kWorkerFormsKey);
    if (raw == null || _userTouched) return;
    try {
      final decoded =
          WorkerFormsState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (_userTouched) return;
      state = decoded;
    } on Object catch (_) {
      // Corrupt payload — keep the empty store.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kWorkerFormsKey, jsonEncode(state.toJson()));
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

  /// Add a sick-note photo upload. Returns the created note.
  SickNote addSickNote({required String username, required String photo}) {
    _userTouched = true;
    final note = SickNote(
      id: 'sick-${DateTime.now().microsecondsSinceEpoch}',
      username: username,
      ts: DateTime.now(),
      photo: photo,
    );
    state = state.copyWith(sickNotes: [...state.sickNotes, note]);
    _persist();
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
