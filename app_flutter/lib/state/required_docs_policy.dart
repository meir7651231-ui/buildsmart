import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// cluster #101 · מדיניות מסמכים-נדרשים — the CONTRACTOR's employer-scoped
/// policy declaring which certificate/document TYPES are MANDATORY for their
/// workers. Each employer (keyed by `session.employerId`) owns a list of
/// required cert display-names (e.g. "היתר עבודה בגובה"); the worker's
/// documents-readiness gate (#101, `docs_readiness.dart`) enforces this policy
/// as an ADD-ON layer on top of the existing 101 + no-expired-cert rule.
///
/// HONEST / no fabrication: matching is by NORMALIZED-EXACT equality (see
/// [normalizeDocName]) — NEVER substring/contains — so a required type is only
/// "satisfied" by a present VALID cert whose name normalizes to the SAME value
/// (the E2 lesson: no fabricated satisfaction). The stored value keeps the
/// contractor's typed/trimmed DISPLAY form; normalization is for MATCHING only.
///
/// Persisted under [kRequiredDocsKey] with the `board_auth.dart` idiom (lazy
/// `_load()` + one-shot `_userTouched` guard + `bool _persist()` with in-memory
/// rollback on a failed write — the F-8 idiom).
///
/// SERVER-SWAP: this becomes the employer's server-side required-documents
/// config. It fulfills the existing gate placeholder — the #101 rule notes
/// "⚠️ DEMO / SERVER-SWAP … המעסיק יגדיר את סט-המסמכים הנדרש בצד-השרת"; this is
/// the on-device employer-scoped stand-in for exactly that config.

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kRequiredDocsKey = 'bs.required-docs.v1';

/// Normalize a document/cert name for MATCHING (the gate compares a required
/// name against a present cert's name through this): trim, collapse internal
/// runs of whitespace to a single space, and lower-case. This is the E2 lesson
/// — match by NORMALIZED-EXACT equality, NEVER substring/contains — so e.g.
/// 'בטיחות' and 'בטיחות בגובה' stay DISTINCT (one is not "contained" in the
/// other). The stored policy value keeps the contractor's display form; only
/// the comparison runs through here.
String normalizeDocName(String s) =>
    s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

class RequiredDocsPolicyNotifier
    extends StateNotifier<Map<String, List<String>>> {
  RequiredDocsPolicyNotifier() : super(const {}) {
    _load();
  }

  /// One-shot guard (the board_auth idiom): once an add/remove/set has written
  /// state, a late async `_load()` becomes non-destructive.
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted || _userTouched) return;
    final raw = prefs.getString(kRequiredDocsKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map;
      if (!mounted || _userTouched) return;
      state = {
        for (final entry in decoded.entries)
          if (entry.key is String)
            entry.key as String: <String>[
              if (entry.value is List)
                for (final n in entry.value as List)
                  if (n is String) n,
            ],
      };
    } on Object catch (_) {
      // Corrupt payload — keep the empty policy.
    }
  }

  /// True when the write actually landed; false on a storage failure (web
  /// localStorage quota / platform failure). Honest: callers must NOT pretend
  /// the policy was saved — the in-memory state is rolled back by the mutators.
  bool _persist() {
    final before = state;
    try {
      // Fire-and-forget like the other `bs.*` notifiers; jsonEncode handles a
      // Map<String, List<String>> natively.
      SharedPreferences.getInstance().then(
        (prefs) => prefs.setString(kRequiredDocsKey, jsonEncode(state)),
      );
      return true;
    } on Object catch (_) {
      if (mounted) state = before; // rollback — nothing persisted
      return false;
    }
  }

  /// CONTRACTOR write — add a required cert TYPE for [employerId]. The name is
  /// trimmed and stored in its DISPLAY form; a no-op when empty or when an
  /// existing member already normalizes to the same value (dedupe). Immutable
  /// update (a NEW map) so watchers re-evaluate.
  void addRequirement(String employerId, String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    final current = state[employerId] ?? const <String>[];
    final key = normalizeDocName(n);
    if (current.any((m) => normalizeDocName(m) == key)) return; // dedupe
    _userTouched = true;
    state = {
      ...state,
      employerId: [...current, n],
    };
    _persist();
  }

  /// CONTRACTOR write — remove every member of [employerId]'s list whose name
  /// normalizes to [name]'s normalized form. Immutable update.
  void removeRequirement(String employerId, String name) {
    final current = state[employerId];
    if (current == null) return;
    final key = normalizeDocName(name);
    _userTouched = true;
    state = {
      ...state,
      employerId: [
        for (final m in current)
          if (normalizeDocName(m) != key) m,
      ],
    };
    _persist();
  }

  /// CONTRACTOR write — replace [employerId]'s whole list. Normalize-deduped
  /// (the FIRST display form of each normalized key wins) and empties dropped.
  void setRequirements(String employerId, List<String> names) {
    final seen = <String>{};
    final cleaned = <String>[];
    for (final raw in names) {
      final n = raw.trim();
      if (n.isEmpty) continue;
      if (seen.add(normalizeDocName(n))) cleaned.add(n);
    }
    _userTouched = true;
    state = {...state, employerId: cleaned};
    _persist();
  }
}

/// The contractor's required-docs policy — employerId → required cert display
/// names. Screens scope by the session's employerId (the worker→contractor
/// link); the gate reads it through [requiredDocsForEmployer].
final requiredDocsPolicyProvider = StateNotifierProvider<
    RequiredDocsPolicyNotifier, Map<String, List<String>>>(
  (ref) => RequiredDocsPolicyNotifier(),
);

/// The required cert TYPES for one employer — `const []` when the employer has
/// no policy (back-compat: an empty/absent policy adds NO requirement, so the
/// gate behaves exactly as before).
final requiredDocsForEmployer = Provider.family<List<String>, String>(
  (ref, employerId) =>
      ref.watch(requiredDocsPolicyProvider)[employerId] ?? const <String>[],
);
