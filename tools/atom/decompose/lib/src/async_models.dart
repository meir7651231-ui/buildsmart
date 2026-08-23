// The async model produced by the async decomposer (DECOMP-DEPTH phase async).
// It opens the STATE MACHINE of loading: for each provider, is there a
// loading / error / empty state — or is there none because it CANNOT fail?
//
// BuildSmart's HARD RULE #3: an error is folded to EMPTY, never a crash — a
// `.when(error: ...)` returns the same empty view the empty-data branch does.
// And the app is SPLIT (step 85): the catalog / cart are SYNCHRONOUS const data
// (no `AsyncValue`, no loading, empty is ad-hoc) while only Firestore / Cloud
// Functions flow through `AsyncValue` + `.when`. So there is NO uniform async
// contract — the decomposer documents the split, it does not impose one.
//
//   provider  — a Riverpod provider: async (Stream/Future) or sync (State/plain),
//               backed by firestore / functions / local.
//   consumer  — a `.when(loading/error/data)` site: which states it models, and
//               whether error folds to empty (#3) and empty is caught in data.
//   exception — a repo's TYPED failure (OrderFunctionsException, …) — the error
//               a data-layer call throws, before the UI folds it to empty.
//
// Read-only: a missing error-path is DOCUMENTED as a gap ("local — cannot
// fail"), never "fixed" by adding one.

/// A Riverpod provider.
class AsyncProvider {
  const AsyncProvider({
    required this.name,
    required this.kind,
    required this.async,
    required this.backing,
    required this.line,
  });

  final String name;

  /// StreamProvider · FutureProvider · AsyncNotifierProvider ·
  /// StateNotifierProvider · StateProvider · Provider.
  final String kind;

  /// True for Stream/Future/AsyncNotifier — the ones that can be loading/error.
  final bool async;

  /// firestore · functions · local — where the data comes from.
  final String backing;

  final int line;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'kind': kind,
        'async': async,
        'backing': backing,
        'line': line,
      };
}

/// A `.when(loading/error/data)` consumption site.
class AsyncConsumer {
  const AsyncConsumer({
    required this.source,
    required this.line,
    required this.loading,
    required this.error,
    required this.data,
    required this.errorFoldsToEmpty,
    required this.emptyInData,
  });

  /// The receiver of `.when` (the provider value being unwrapped).
  final String source;
  final int line;

  final bool loading;
  final bool error;
  final bool data;

  /// The `error:` branch returns the empty view (HARD RULE #3 — never crash).
  final bool errorFoldsToEmpty;

  /// The `data:` branch catches `isEmpty` and shows the empty view.
  final bool emptyInData;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'source': source,
        'line': line,
        'states': <String>[
          if (loading) 'loading',
          if (error) 'error',
          if (data) 'data',
        ],
        'errorFoldsToEmpty': errorFoldsToEmpty,
        'emptyInData': emptyInData,
      };
}

/// A typed repo exception — the failure a data call throws.
class AsyncException {
  const AsyncException({
    required this.name,
    required this.line,
    required this.throwSites,
  });

  final String name;
  final int line;
  final int throwSites;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'line': line,
        'throwSites': throwSites,
      };
}

/// The async decomposition of one module.
class AsyncModuleDecomposition {
  AsyncModuleDecomposition({
    required this.module,
    required this.sourcePath,
    required this.providers,
    required this.consumers,
    required this.exceptions,
  });

  final String module;
  final String sourcePath;
  final List<AsyncProvider> providers;
  final List<AsyncConsumer> consumers;
  final List<AsyncException> exceptions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'module': module,
        'source': sourcePath,
        'providerCount': providers.length,
        'consumerCount': consumers.length,
        'providers': providers.map((p) => p.toJson()).toList(),
        'consumers': consumers.map((c) => c.toJson()).toList(),
        'exceptions': exceptions.map((e) => e.toJson()).toList(),
      };
}

/// The merged async overview across many modules — the split, quantified.
class AsyncOverview {
  AsyncOverview({
    required this.providers,
    required this.consumers,
    required this.exceptions,
  });

  final List<AsyncProvider> providers;
  final List<AsyncConsumer> consumers;
  final List<AsyncException> exceptions;

  int get asyncProviders => providers.where((p) => p.async).length;
  int get syncProviders => providers.where((p) => !p.async).length;
  int get errorFoldedConsumers =>
      consumers.where((c) => c.errorFoldsToEmpty).length;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'providerCount': providers.length,
        'asyncProviders': asyncProviders,
        'syncProviders': syncProviders,
        'consumerCount': consumers.length,
        'errorFoldedConsumers': errorFoldedConsumers,
        'exceptionCount': exceptions.length,
        'providers': providers.map((p) => p.toJson()).toList(),
        'consumers': consumers.map((c) => c.toJson()).toList(),
        'exceptions': exceptions.map((e) => e.toJson()).toList(),
      };
}
