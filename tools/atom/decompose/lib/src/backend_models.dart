// The backend model produced by the backend decomposer (DECOMP-DEPTH phase B,
// steps 97-98). The server side — Cloud Functions (TypeScript) — opened with the
// same spirit as the logic layer, at the FUNCTION tier:
//
//   object       — name · trigger (onCall / onDocument* / onSchedule) · region.
//   connections  — reads / writes (which Firestore collections) · external calls
//                  (FCM · R2 · Claude · http) · auth-gated?
//   contract     — the typed failure surface: the HttpsError codes it throws.
//
// This closes the loop with the client's async layer: a client
// `OrderFunctionsException` is the mirror of the server `advanceOrderStage`
// throwing `HttpsError("failed-precondition", …)`.
//
// TS, not Dart — so this is a source-scan (comment-blanked), not an analyzer AST.
// Read-only: it documents the server contract; it never edits a function.

/// One Cloud Function.
class BackendFunction {
  BackendFunction({
    required this.name,
    required this.trigger,
    required this.region,
    required this.line,
    required this.authGated,
    List<String>? reads,
    List<String>? writes,
    List<String>? calls,
    List<String>? errorCodes,
  })  : reads = reads ?? <String>[],
        writes = writes ?? <String>[],
        calls = calls ?? <String>[],
        errorCodes = errorCodes ?? <String>[];

  final String name;

  /// onCall · onRequest · onDocumentCreated · onDocumentUpdated ·
  /// onDocumentWritten · onDocumentDeleted · onSchedule.
  final String trigger;

  final String region;
  final int line;

  /// Checks `request.auth` — a callable that requires sign-in.
  final bool authGated;

  /// Firestore collections read (`.get` / `collection().doc().get`).
  final List<String> reads;

  /// Firestore write ops seen (`set` · `update` · `create` · `delete` · `add`).
  final List<String> writes;

  /// External calls: `fcm` · `r2` · `claude` · `http`.
  final List<String> calls;

  /// The typed failure surface — the `HttpsError` codes it throws.
  final List<String> errorCodes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'trigger': trigger,
        'region': region,
        'line': line,
        'authGated': authGated,
        'reads': reads,
        'writes': writes,
        'calls': calls,
        'errorCodes': errorCodes,
      };
}

/// The backend decomposition of one module (a functions/src/*.ts file).
class BackendModuleDecomposition {
  BackendModuleDecomposition({
    required this.module,
    required this.sourcePath,
    required this.functions,
  });

  final String module;
  final String sourcePath;
  final List<BackendFunction> functions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'module': module,
        'source': sourcePath,
        'functionCount': functions.length,
        'functions': functions.map((f) => f.toJson()).toList(),
      };
}

/// The merged backend overview across all modules.
class BackendOverview {
  BackendOverview({required this.functions});

  final List<BackendFunction> functions;

  int get callables => functions.where((f) => f.trigger == 'onCall').length;
  int get triggers =>
      functions.where((f) => f.trigger.startsWith('onDocument')).length;
  int get scheduled => functions.where((f) => f.trigger == 'onSchedule').length;

  Set<String> get allErrorCodes =>
      functions.expand((f) => f.errorCodes).toSet();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'functionCount': functions.length,
        'callables': callables,
        'documentTriggers': triggers,
        'scheduled': scheduled,
        'errorCodes': allErrorCodes.toList()..sort(),
        'functions': functions.map((f) => f.toJson()).toList(),
      };
}
