// C5.2 — lightweight server-usage monitor (DORMANT until the server path is wired).
//
// Counts DB reads / writes / errors + latency per session, so during the gradual
// rollout we can watch COST (read-count/session) and HEALTH (error-rate, latency) and
// dial back if anything spikes. A plain in-memory counter here; a real sink
// (analytics / Crashlytics / a log) is attached at activation. Nothing writes to it
// until then, so it is inert.

class DbUsageMonitor {
  int reads = 0;
  int writes = 0;
  int errors = 0;
  int _latencySumMs = 0;
  int _latencyCount = 0;

  void onRead([int count = 1]) => reads += count;
  void onWrite([int count = 1]) => writes += count;
  void onError() => errors++;
  void onLatency(int ms) {
    _latencySumMs += ms;
    _latencyCount++;
  }

  /// Average request latency (ms) this session; 0 when nothing was timed.
  double get avgLatencyMs =>
      _latencyCount == 0 ? 0 : _latencySumMs / _latencyCount;

  /// Errors as a fraction of all DB ops this session; 0 when idle.
  double get errorRate =>
      (reads + writes) == 0 ? 0 : errors / (reads + writes);

  /// The read-count/session cost signal — the primary Firestore-egress metric.
  int get readsThisSession => reads;

  Map<String, dynamic> snapshot() => <String, dynamic>{
        'reads': reads,
        'writes': writes,
        'errors': errors,
        'avgLatencyMs': avgLatencyMs,
        'errorRate': errorRate,
      };

  void reset() {
    reads = 0;
    writes = 0;
    errors = 0;
    _latencySumMs = 0;
    _latencyCount = 0;
  }
}

/// The shared session monitor — dormant (nothing increments it until the server path
/// is wired at activation).
final DbUsageMonitor dbUsageMonitor = DbUsageMonitor();
